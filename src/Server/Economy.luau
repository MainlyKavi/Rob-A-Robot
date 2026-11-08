--!strict
-- Cash, the Cash Bin and the one income loop.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local PlayerData = require(script.Parent.PlayerData)
local Robots = require(script.Parent.Robots)
local Types = require(ReplicatedStorage.Shared.Types)

local Economy = {}

local function syncCash(player: Player, data: Types.PlayerData)
	player:SetAttribute("Cash", data.cash)
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	if cash ~= nil and cash:IsA("NumberValue") then
		cash.Value = data.cash
	end
end

function Economy.addCash(player: Player, amount: number)
	assert(amount > 0 and amount < math.huge, "Economy.addCash: amount must be finite and > 0")
	local data = PlayerData.get(player)
	if data == nil then
		return
	end
	data.cash += amount
	syncCash(player, data)
end

-- Moves the Cash Bin into Cash and returns the amount moved.
function Economy.collect(player: Player): number
	local data = PlayerData.get(player)
	if data == nil or data.bin <= 0 then
		return 0
	end
	local amount = data.bin
	data.bin = 0
	data.cash += amount
	player:SetAttribute("Bin", 0)
	syncCash(player, data)
	return amount
end

local function tick()
	for _, player in Players:GetPlayers() do
		local data = PlayerData.get(player)
		if data == nil then
			continue
		end
		local income = Robots.income(data)
		local cap = income * EconomyConfig.binMinutes[data.upgrades.bin + 1] * 60
		local bin = math.min(data.bin + income, cap)
		if bin ~= data.bin then
			data.bin = bin
			player:SetAttribute("Bin", bin)
		end
	end
end

function Economy.start()
	PlayerData.onLoaded(function(player, data)
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		local cash = Instance.new("NumberValue")
		cash.Name = "Cash"
		cash.Parent = leaderstats
		leaderstats.Parent = player
		player:SetAttribute("Bin", data.bin)
		player:SetAttribute("PadCount", data.padCount)
		syncCash(player, data)
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			tick()
		end
	end)
end

return Economy
