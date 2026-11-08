--!strict
-- Robot ownership. Robots.give is the ONLY function that adds robots to a profile.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local PlayerData = require(script.Parent.PlayerData)
local RobotConfigs = require(ReplicatedStorage.Shared.Config.Robots)
local Types = require(ReplicatedStorage.Shared.Types)

export type Decision = "place" | "replace" | "scrap"

local Robots = {}

function Robots.income(data: Types.PlayerData): number
	local total = 0
	for _, entry in data.robots do
		total += RobotConfigs[entry.id].income
	end
	return total
end

-- Pure. "place" if a pad is free; "replace" and the index of the lowest pad if newIncome is
-- strictly higher; otherwise "scrap".
function Robots.decide(padIncomes: { number }, padCount: number, newIncome: number): (Decision, number?)
	if #padIncomes < padCount then
		return "place", nil
	end
	local lowestIndex: number? = nil
	local lowest = math.huge
	for index, income in padIncomes do
		if income < lowest then
			lowest = income
			lowestIndex = index
		end
	end
	if lowestIndex ~= nil and newIncome > lowest then
		return "replace", lowestIndex
	end
	return "scrap", nil
end

-- Returns the decision and the scrap value the caller must pay (0 if none).
function Robots.give(player: Player, robotId: string): (Decision, number)
	local config = RobotConfigs[robotId]
	if config == nil then
		error(`Robots.give: unknown robot id {robotId}`)
	end
	local data = PlayerData.get(player)
	if data == nil then
		error("Robots.give: profile not loaded")
	end
	data.dex[robotId] = true
	data.stats.steals += 1

	local padIncomes = {}
	for index, entry in data.robots do
		padIncomes[index] = RobotConfigs[entry.id].income
	end
	local decision, index = Robots.decide(padIncomes, data.padCount, config.income)
	if decision == "place" then
		table.insert(data.robots, { id = robotId })
		return decision, 0
	elseif decision == "replace" and index ~= nil then
		local old = data.robots[index]
		data.robots[index] = { id = robotId }
		return decision, RobotConfigs[old.id].income * EconomyConfig.scrapSeconds
	end
	return "scrap", config.income * EconomyConfig.scrapSeconds
end

return Robots
