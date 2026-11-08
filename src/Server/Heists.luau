--!strict
-- Personal facility slots, stealing, carrying and depositing at the HomeZone.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bases = require(script.Parent.Bases)
local Economy = require(script.Parent.Economy)
local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local FacilityConfigs = require(ReplicatedStorage.Shared.Config.Facilities)
local PlayerData = require(script.Parent.PlayerData)
local RateLimit = require(script.Parent.RateLimit)
local RobotConfigs = require(ReplicatedStorage.Shared.Config.Robots)
local Robots = require(script.Parent.Robots)
local Remotes = require(script.Parent.Remotes)

type Slot = { part: BasePart, facility: string, zone: string }
type Carry = { robotId: string, slotId: string, startedAt: number, from: Vector3, model: Model }

local MAX_SLOT_ID_LENGTH = 64
local HOME_DEBOUNCE = 0.5
local ZONE_SLACK = 2 -- studs; the root part is at the zone edge when Touched first fires

local slots: { [string]: Slot } = {} -- slotId -> slot, built from the map
local slotContents: { [Player]: { [string]: string } } = {} -- player -> slotId -> robotId
local carrying: { [Player]: Carry } = {}
local lastHome: { [Player]: number } = {}
local tierPools: { [string]: { [string]: { string } } } = {} -- facility -> tier -> robot ids
local random = Random.new()

local Heists = {}

local function roll(facility: string, zone: string): string
	local weights = FacilityConfigs[facility].zones[zone].weights
	local total = 0
	for _, weight in weights do
		total += weight
	end
	local pick = random:NextNumber(0, total)
	local chosenTier = ""
	for tier, weight in weights do
		chosenTier = tier
		pick -= weight
		if pick <= 0 then
			break
		end
	end
	local pool = tierPools[facility][chosenTier]
	if pool == nil or #pool == 0 then
		error(`Heists: no {chosenTier} robots in {facility}`)
	end
	return pool[random:NextInteger(1, #pool)]
end

local function setSlot(player: Player, slotId: string, robotId: string?)
	local contents = slotContents[player]
	if contents == nil then
		return
	end
	contents[slotId] = robotId
	Remotes.SlotChanged:FireClient(player, slotId, robotId)
end

local function restockLater(player: Player, slotId: string)
	local slot = slots[slotId]
	task.delay(FacilityConfigs[slot.facility].zones[slot.zone].restockSeconds, function()
		local contents = slotContents[player]
		if contents ~= nil and contents[slotId] == nil then
			setSlot(player, slotId, roll(slot.facility, slot.zone))
		end
	end)
end

local function humanoidAndRoot(player: Player): (Humanoid?, BasePart?)
	local character = player.Character
	if character == nil then
		return nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid == nil or humanoid.Health <= 0 or root == nil or not root:IsA("BasePart") then
		return nil, nil
	end
	return humanoid, root
end

local function attachRobot(character: Model, root: BasePart, robotId: string): Model
	local models = ReplicatedStorage:FindFirstChild("RobotModels")
	local model = if models ~= nil then models:FindFirstChild(robotId) else nil
	assert(model ~= nil and model:IsA("Model"), "Heists: missing robot model")
	local carried = model:Clone()
	carried.Name = "CarriedRobot"
	for _, part in carried:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.Massless = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
		end
	end
	local size = carried:GetExtentsSize()
	-- Robot models pivot at their feet: hold the robot in front of the chest.
	carried:PivotTo(root.CFrame * CFrame.new(0, -1, -(root.Size.Z / 2 + size.Z / 2 + 0.5)))
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = carried.PrimaryPart
	weld.Parent = carried
	carried.Parent = character
	return carried
end

-- Clears the carry without granting anything (death, leave, failed travel check).
local function drop(player: Player): Carry?
	local carry = carrying[player]
	if carry == nil then
		return nil
	end
	carrying[player] = nil
	carry.model:Destroy()
	player:SetAttribute("Carrying", "")
	local humanoid = humanoidAndRoot(player)
	if humanoid ~= nil then
		humanoid.WalkSpeed = EconomyConfig.walkSpeed
	end
	return carry
end

local function onRequestSteal(player: Player, slotId: unknown)
	if typeof(slotId) ~= "string" or #slotId > MAX_SLOT_ID_LENGTH then
		return
	end
	if not RateLimit.allow(player, "steal", 4) then
		return
	end
	local data = PlayerData.get(player)
	if data == nil or carrying[player] ~= nil then
		return
	end
	local humanoid, root = humanoidAndRoot(player)
	if humanoid == nil or root == nil then
		return
	end
	local slot = slots[slotId]
	local contents = slotContents[player]
	local robotId = if slot ~= nil and contents ~= nil then contents[slotId] else nil
	if slot == nil or robotId == nil then
		return
	end
	if FacilityConfigs[slot.facility].gateCost > 0 and not data.facilities[slot.facility] then
		return
	end
	if (root.Position - slot.part.Position).Magnitude > EconomyConfig.stealDistance then
		return
	end

	setSlot(player, slotId, nil)
	carrying[player] = {
		robotId = robotId,
		slotId = slotId,
		startedAt = os.clock(),
		from = slot.part.Position,
		model = attachRobot(humanoid.Parent :: Model, root, robotId),
	}
	player:SetAttribute("Carrying", robotId)
	humanoid.WalkSpeed = EconomyConfig.walkSpeed * EconomyConfig.carrySpeedMultiplier
	restockLater(player, slotId)
	Remotes.Notify:FireClient(player, "stolen", { robotId = robotId })
end

local function insideZone(zone: BasePart, position: Vector3): boolean
	local offset = zone.CFrame:PointToObjectSpace(position)
	local half = zone.Size / 2 + Vector3.one * ZONE_SLACK
	return math.abs(offset.X) <= half.X and math.abs(offset.Y) <= half.Y and math.abs(offset.Z) <= half.Z
end

local function onHome(player: Player, zone: BasePart)
	local _, root = humanoidAndRoot(player)
	if root == nil or not insideZone(zone, root.Position) then
		return
	end
	local now = os.clock()
	local last = lastHome[player]
	if last ~= nil and now - last < HOME_DEBOUNCE then
		return
	end
	lastHome[player] = now

	local carry = drop(player)
	if carry ~= nil then
		local carrySpeed = EconomyConfig.walkSpeed * EconomyConfig.carrySpeedMultiplier
		local minTime = (carry.from - zone.Position).Magnitude / (carrySpeed * EconomyConfig.travelSpeedSlack)
		if now - carry.startedAt < minTime then
			warn(`Heists: {player.Name} deposited {carry.robotId} too fast; no reward`)
		else
			local result, scrap = Robots.give(player, carry.robotId)
			if scrap > 0 then
				Economy.addCash(player, scrap)
			end
			Bases.refreshPads(player)
			Remotes.Notify:FireClient(player, "deposited", { robotId = carry.robotId, result = result, scrap = scrap })
		end
	end

	local amount = Economy.collect(player)
	if amount > 0 then
		Remotes.Notify:FireClient(player, "collected", { amount = amount })
	end
end

local function onLoaded(player: Player)
	player:SetAttribute("Carrying", "")
	slotContents[player] = {}
	for slotId, slot in slots do
		setSlot(player, slotId, roll(slot.facility, slot.zone))
	end
	local function watch(character: Model)
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.Died:Connect(function()
			drop(player)
		end)
	end
	player.CharacterAdded:Connect(watch)
	if player.Character ~= nil then
		task.spawn(watch, player.Character)
	end
end

function Heists.start()
	for robotId, config in RobotConfigs do
		local byTier = tierPools[config.facility] or {}
		tierPools[config.facility] = byTier
		local pool = byTier[config.tier] or {}
		byTier[config.tier] = pool
		table.insert(pool, robotId)
	end

	local map = workspace:WaitForChild("Map")
	for _, facility in map:WaitForChild("Facilities"):GetChildren() do
		local slotFolder = facility:FindFirstChild("Slots")
		if FacilityConfigs[facility.Name] == nil or slotFolder == nil then
			continue
		end
		for _, part in slotFolder:GetChildren() do
			local zone = part:GetAttribute("Zone")
			-- M1 only stocks Floor slots; Guarded and Vault arrive in M3.
			if part:IsA("BasePart") and zone == "Floor" then
				slots[`{facility.Name}/{part.Name}`] = { part = part, facility = facility.Name, zone = "Floor" }
			end
		end
	end

	for _, plot in map:WaitForChild("Plots"):GetChildren() do
		local zone = plot:FindFirstChild("HomeZone")
		if zone == nil or not zone:IsA("BasePart") then
			continue
		end
		zone.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player ~= nil and Bases.getPlot(player) == plot then
				onHome(player, zone)
			end
		end)
	end

	Remotes.RequestSteal.OnServerEvent:Connect(onRequestSteal)
	PlayerData.onLoaded(onLoaded)
	PlayerData.onRemoving(function(player)
		drop(player)
		slotContents[player] = nil
		lastHome[player] = nil
	end)
end

return Heists
