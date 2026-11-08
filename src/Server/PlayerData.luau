--!strict
-- Player profiles. M1: in memory only. M2 adds DataStore persistence here and nowhere else.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local Types = require(ReplicatedStorage.Shared.Types)

local SCHEMA_VERSION = 1

local profiles: { [Player]: Types.PlayerData } = {}
local loadedCallbacks: { (Player, Types.PlayerData) -> () } = {}
local removingCallbacks: { (Player) -> () } = {}

local function defaults(): Types.PlayerData
	return {
		version = SCHEMA_VERSION,
		cash = EconomyConfig.startCash,
		bin = 0,
		lastSeen = os.time(),
		padCount = EconomyConfig.startPads,
		robots = {},
		upgrades = { shoes = 0, gloves = 0, bin = 0 },
		facilities = {},
		vaults = {},
		dex = {},
		stats = { steals = 0, caught = 0, vaults = 0, purchases = 0 },
		receipts = {},
	}
end

local PlayerData = {}

function PlayerData.get(player: Player): Types.PlayerData?
	return profiles[player]
end

-- Called for each profile as it loads, including profiles already loaded when registering.
function PlayerData.onLoaded(callback: (Player, Types.PlayerData) -> ())
	table.insert(loadedCallbacks, callback)
	for player, data in profiles do
		task.spawn(callback, player, data)
	end
end

function PlayerData.onRemoving(callback: (Player) -> ())
	table.insert(removingCallbacks, callback)
end

local function load(player: Player)
	if profiles[player] ~= nil then
		return
	end
	local data = defaults()
	profiles[player] = data
	for _, callback in loadedCallbacks do
		task.spawn(callback, player, data)
	end
end

function PlayerData.start()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		for _, callback in removingCallbacks do
			task.spawn(callback, player)
		end
		profiles[player] = nil
	end)
end

return PlayerData
