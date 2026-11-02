--!nonstrict
-- Tool script with dynamic tables, not game code. Game scripts in src/ use --!strict.
--[[
	Rob a Robot economy simulation. Design and results: docs/design/economy.md.

	Run in Studio Edit mode: paste into the command bar, or send this file's text through MCP execute_luau.
	Pure math, changes nothing in the place. It plays simplified players through 30 days and prints
	the median play time (and day) at which each milestone happens, plus where income came from.

	shortcut: numbers are copied from docs/design/economy.md; once src/Shared/Config exists, require it instead.
]]

local SELL_SECONDS = 60 -- a robot sells for this many seconds of its own income
local GETAWAY_SECONDS = { floor = 10, guarded = 25, vault = 60 } -- escape bonus, in seconds of base income
local DEX_BONUS = 0.1 -- +10% base income per facility whose Robodex page is complete
local KEEP_HORIZON = 600 -- seconds of future income a player weighs when picking a heist target
local START_PADS = 4
local RUNS = 200
local DAYS = 30

local TIERS = { "Common", "Rare", "Epic", "Legendary" }

local ROBOTS = {
	{ id = "Toasty", facility = 1, tier = "Common", income = 2 },
	{ id = "Mopsy", facility = 1, tier = "Common", income = 3 },
	{ id = "Trashy", facility = 1, tier = "Common", income = 4 },
	{ id = "BoltPup", facility = 1, tier = "Rare", income = 8 },
	{ id = "ClankCrab", facility = 1, tier = "Rare", income = 10 },
	{ id = "SirRustalot", facility = 1, tier = "Epic", income = 20 },
	{ id = "Crusher", facility = 1, tier = "Legendary", income = 50 },
	{ id = "Windy", facility = 2, tier = "Common", income = 20 },
	{ id = "JackBox", facility = 2, tier = "Common", income = 30 },
	{ id = "Plushbot", facility = 2, tier = "Rare", income = 80 },
	{ id = "YoYoBot", facility = 2, tier = "Rare", income = 100 },
	{ id = "RoboRex", facility = 2, tier = "Epic", income = 200 },
	{ id = "DiscoDan", facility = 2, tier = "Epic", income = 250 },
	{ id = "Gigabear", facility = 2, tier = "Legendary", income = 600 },
	{ id = "MoonRover", facility = 3, tier = "Common", income = 200 },
	{ id = "AstroPup", facility = 3, tier = "Common", income = 300 },
	{ id = "SatelliteSally", facility = 3, tier = "Rare", income = 800 },
	{ id = "CometKid", facility = 3, tier = "Rare", income = 1000 },
	{ id = "RocketRick", facility = 3, tier = "Epic", income = 2000 },
	{ id = "StarSmith", facility = 3, tier = "Epic", income = 2500 },
	{ id = "Nova", facility = 3, tier = "Legendary", income = 6000 },
}

-- time = average round trip in seconds from base, success = chance an average player escapes,
-- cooldown = seconds before the vault restocks after a successful steal
local FACILITIES = {
	{
		name = "Junkyard",
		gate = 0,
		vaultCost = 2500,
		floor = { time = 15, success = 0.97, weights = { Common = 85, Rare = 15 } },
		guarded = { time = 28, success = 0.75, weights = { Rare = 85, Epic = 15 } },
		vault = { time = 45, success = 0.6, cooldown = 90, weights = { Epic = 92, Legendary = 8 } },
	},
	{
		name = "Toy Factory",
		gate = 150000,
		vaultCost = 2e6,
		floor = { time = 21, success = 0.93, weights = { Common = 85, Rare = 15 } },
		guarded = { time = 34, success = 0.7, weights = { Rare = 85, Epic = 15 } },
		vault = { time = 52, success = 0.55, cooldown = 180, weights = { Epic = 95, Legendary = 5 } },
	},
	{
		name = "Space Lab",
		gate = 30e6,
		vaultCost = 300e6,
		floor = { time = 27, success = 0.9, weights = { Common = 85, Rare = 15 } },
		guarded = { time = 40, success = 0.65, weights = { Rare = 85, Epic = 15 } },
		vault = { time = 60, success = 0.5, cooldown = 240, weights = { Epic = 95, Legendary = 5 } },
	},
}

local PAD_COSTS = { 250, 1000, 5000, 25000, 120000, 600000, 3e6, 15e6, 75e6, 250e6, 600e6, 1.5e9 } -- pads 5..16
local SNEAKER_COSTS = { 150, 5000, 400000, 25e6, 1e9 } -- each level: heist time -8%
local GLOVE_COSTS = { 800, 30000, 2e6, 100e6, 3e9 } -- each level: +4% escape chance on guarded and vault
local BIN_COSTS = { 300000, 30e6 } -- offline Cash Bin cap 10 -> 20 -> 30 minutes of base income
local BIN_MINUTES = { 10, 20, 30 }
local SNEAKER_STEP, GLOVE_STEP = 0.08, 0.04

local PROFILES = {
	{ name = "casual", successMul = 0.85, timeMul = 1.25, firstMinutes = 15, dailyMinutes = 10 },
	{ name = "average", successMul = 1, timeMul = 1, firstMinutes = 20, dailyMinutes = 15 },
	{ name = "engaged", successMul = 1.08, timeMul = 0.9, firstMinutes = 30, dailyMinutes = 40 },
}

local MILESTONES = {
	"first robot",
	"first purchase",
	"F1 Rare",
	"vault Junkyard",
	"F1 Epic",
	"F1 Legendary",
	"unlock Toy Factory",
	"F2 Epic",
	"vault Toy Factory",
	"F2 Legendary",
	"unlock Space Lab",
	"F3 Epic",
	"vault Space Lab",
	"F3 Legendary",
	"all robots",
	"max pads",
}

local pool = {} -- pool[facility][tier] = robots
local facilitySize = {}
for _, robot in ROBOTS do
	pool[robot.facility] = pool[robot.facility] or {}
	pool[robot.facility][robot.tier] = pool[robot.facility][robot.tier] or {}
	table.insert(pool[robot.facility][robot.tier], robot)
	facilitySize[robot.facility] = (facilitySize[robot.facility] or 0) + 1
end

local function simulate(profile, rng)
	local s = {
		cash = 0,
		pads = {}, -- incomes of robots on pads
		padCount = START_PADS,
		sneakers = 0,
		gloves = 0,
		bin = 0,
		facilities = 1,
		vaults = {},
		vaultReadyAt = {},
		dex = {},
		dexByFacility = {},
		dexDone = 0,
		dexCount = 0,
		play = 0,
		day = 1,
		earned = { passive = 0, getaway = 0, sell = 0, offline = 0 },
	}
	local hit = {}
	local function mark(name)
		if not hit[name] then
			hit[name] = { play = s.play, day = s.day }
		end
	end

	local function income() -- base income per second, including Robodex bonuses
		local sum = 0
		for _, value in s.pads do
			sum += value
		end
		return sum * (1 + DEX_BONUS * s.dexDone)
	end
	local function worst()
		local index, low = nil, math.huge
		for i, value in s.pads do
			if value < low then
				index, low = i, value
			end
		end
		return index, low
	end
	local function robotValue(robot) -- what stealing this robot is worth to the player right now
		local value = robot.income * SELL_SECONDS
		if #s.pads < s.padCount then
			value += robot.income * KEEP_HORIZON
		else
			local _, low = worst()
			value += math.max(0, robot.income - low) * KEEP_HORIZON
		end
		if not s.dex[robot.id] then
			local missing = facilitySize[robot.facility] - (s.dexByFacility[robot.facility] or 0)
			value += DEX_BONUS * income() * KEEP_HORIZON / missing
		end
		return value
	end
	local function earn(kind, amount)
		s.cash += amount
		s.earned[kind] += amount
	end
	local function receive(robot)
		if not s.dex[robot.id] then
			s.dex[robot.id] = true
			s.dexCount += 1
			s.dexByFacility[robot.facility] = (s.dexByFacility[robot.facility] or 0) + 1
			if s.dexByFacility[robot.facility] == facilitySize[robot.facility] then
				s.dexDone += 1
			end
			if s.dexCount == #ROBOTS then
				mark("all robots")
			end
		end
		mark(("F%d %s"):format(robot.facility, robot.tier))
		if #s.pads < s.padCount then
			table.insert(s.pads, robot.income)
			return
		end
		local index, low = worst()
		if robot.income > low then
			s.pads[index] = robot.income
			earn("sell", low * SELL_SECONDS)
		else
			earn("sell", robot.income * SELL_SECONDS)
		end
	end
	local function spend(seconds) -- online: robots earn, the player collects on every trip home
		earn("passive", income() * seconds)
		s.play += seconds
	end

	local function pay(cost)
		s.cash -= cost
		mark("first purchase")
	end
	local function buy()
		while true do
			-- new places first: players save for these
			local nextFacility = FACILITIES[s.facilities + 1]
			if nextFacility and s.cash >= nextFacility.gate then
				pay(nextFacility.gate)
				s.facilities += 1
				mark("unlock " .. nextFacility.name)
				continue
			end
			local boughtVault = false
			for i = 1, s.facilities do
				if not s.vaults[i] and s.cash >= FACILITIES[i].vaultCost then
					pay(FACILITIES[i].vaultCost)
					s.vaults[i] = true
					mark("vault " .. FACILITIES[i].name)
					boughtVault = true
					break
				end
			end
			if boughtVault then
				continue
			end
			-- otherwise the cheapest affordable upgrade
			local options = {
				pads = PAD_COSTS[s.padCount - START_PADS + 1],
				sneakers = SNEAKER_COSTS[s.sneakers + 1],
				gloves = GLOVE_COSTS[s.gloves + 1],
				bin = BIN_COSTS[s.bin + 1],
			}
			local best, bestCost = nil, math.huge
			for name, cost in options do
				if cost <= s.cash and cost < bestCost then
					best, bestCost = name, cost
				end
			end
			if not best then
				return
			end
			pay(bestCost)
			if best == "pads" then
				s.padCount += 1
				if s.padCount == START_PADS + #PAD_COSTS then
					mark("max pads")
				end
			elseif best == "sneakers" then
				s.sneakers += 1
			elseif best == "gloves" then
				s.gloves += 1
			else
				s.bin += 1
			end
		end
	end

	local function chooseHeist()
		local best, bestRate = nil, -1
		for f = 1, s.facilities do
			for _, kind in { "floor", "guarded", "vault" } do
				local slot = FACILITIES[f][kind]
				if kind == "vault" and (not s.vaults[f] or s.play < (s.vaultReadyAt[f] or 0)) then
					continue
				end
				local p = slot.success * profile.successMul + (if kind == "floor" then 0 else s.gloves * GLOVE_STEP)
				p = math.min(p, 0.98)
				local t = slot.time * profile.timeMul * (1 - s.sneakers * SNEAKER_STEP)
				local value = GETAWAY_SECONDS[kind] * income()
				for tier, weight in slot.weights do
					local robots = pool[f][tier]
					local sum = 0
					for _, robot in robots do
						sum += robotValue(robot)
					end
					value += weight / 100 * sum / #robots
				end
				local rate = p * value / t
				if rate > bestRate then
					best, bestRate = { f = f, kind = kind, p = p, t = t }, rate
				end
			end
		end
		return best
	end
	local function heist(h)
		if rng:NextNumber() >= h.p then
			spend(h.t * 0.6) -- caught partway: the robot runs home, the trip is lost
			return
		end
		spend(h.t)
		earn("getaway", GETAWAY_SECONDS[h.kind] * income())
		local slot = FACILITIES[h.f][h.kind]
		local roll, acc, tier = rng:NextNumber() * 100, 0, nil
		for _, name in TIERS do
			local weight = slot.weights[name]
			if weight then
				tier = name
				acc += weight
				if roll < acc then
					break
				end
			end
		end
		local robots = pool[h.f][tier]
		receive(robots[rng:NextInteger(1, #robots)])
		if h.kind == "vault" then
			s.vaultReadyAt[h.f] = s.play + slot.cooldown
		end
	end

	-- tutorial: the first steal is a guaranteed Toasty after about 40 s of learning
	spend(40)
	receive(ROBOTS[1])
	mark("first robot")
	local incomeByDay = {}
	for day = 1, DAYS do
		s.day = day
		local minutes = if day == 1 then profile.firstMinutes else profile.dailyMinutes
		local sessionEnd = s.play + minutes * 60 - (if day == 1 then 40 else 0)
		while s.play < sessionEnd do
			buy()
			heist(chooseHeist())
		end
		buy()
		incomeByDay[day] = income()
		earn("offline", income() * BIN_MINUTES[s.bin + 1] * 60) -- the Cash Bin fills while away, up to its cap
	end
	return hit, s.earned, incomeByDay
end

local function clock(seconds)
	if seconds < 3600 then
		return ("%d:%02d"):format(seconds // 60, seconds % 60)
	end
	return ("%dh%02d"):format(seconds // 3600, (seconds % 3600) // 60)
end
local function median(list)
	table.sort(list)
	return list[math.max(1, math.ceil(#list / 2))]
end
local function money(n)
	if n >= 1e6 then
		return ("%.1fM"):format(n / 1e6)
	elseif n >= 1e3 then
		return ("%.1fk"):format(n / 1e3)
	end
	return ("%d"):format(n)
end

local lines =
	{ ("Economy sim: %d runs x %d days. Median play time (day) [share of runs that got there]"):format(RUNS, DAYS) }
local results = {}
for _, profile in PROFILES do
	local plays, days, incomes = {}, {}, {}
	local shares = { passive = 0, getaway = 0, sell = 0, offline = 0 }
	for run = 1, RUNS do
		local hit, earned, incomeByDay = simulate(profile, Random.new(run))
		for name, at in hit do
			plays[name] = plays[name] or {}
			days[name] = days[name] or {}
			table.insert(plays[name], at.play)
			table.insert(days[name], at.day)
		end
		local total = earned.passive + earned.getaway + earned.sell + earned.offline
		for key, value in earned do
			shares[key] += value / total / RUNS
		end
		for day, value in incomeByDay do
			incomes[day] = incomes[day] or {}
			table.insert(incomes[day], value)
		end
		if run % 20 == 0 then
			task.wait()
		end
	end
	results[profile.name] = { plays = plays, days = days, shares = shares, incomes = incomes }
end

local header = {}
for _, profile in PROFILES do
	table.insert(header, ("%s (%d min, then %d/day)"):format(profile.name, profile.firstMinutes, profile.dailyMinutes))
end
table.insert(lines, ("%-20s | %s"):format("milestone", table.concat(header, " | ")))
for _, name in MILESTONES do
	local cells = {}
	for _, profile in PROFILES do
		local r = results[profile.name]
		local list = r.plays[name]
		if list then
			local cell = ("%s (d%d)"):format(clock(median(list)), median(r.days[name]))
			if #list < RUNS then
				cell ..= (" [%d%%]"):format(#list * 100 // RUNS)
			end
			table.insert(cells, cell)
		else
			table.insert(cells, "not in 30 days")
		end
	end
	table.insert(lines, ("%-20s | %s"):format(name, table.concat(cells, " | ")))
end
for _, profile in PROFILES do
	local r = results[profile.name]
	local perDay = {}
	for _, day in { 1, 2, 3, 7, 14, 30 } do
		table.insert(perDay, ("d%d $%s/s"):format(day, money(median(r.incomes[day]))))
	end
	table.insert(
		lines,
		("%s: income from passive %d%%, getaway %d%%, selling %d%%, offline %d%% | base income %s"):format(
			profile.name,
			r.shares.passive * 100 + 0.5,
			r.shares.getaway * 100 + 0.5,
			r.shares.sell * 100 + 0.5,
			r.shares.offline * 100 + 0.5,
			table.concat(perDay, ", ")
		)
	)
end
print(table.concat(lines, "\n"))
