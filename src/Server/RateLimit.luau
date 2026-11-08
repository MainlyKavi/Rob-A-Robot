--!strict
-- Per-player, per-key minimum interval limiter.
local Players = game:GetService("Players")

local lastCall: { [Player]: { [string]: number } } = {}

local RateLimit = {}

function RateLimit.allow(player: Player, key: string, perSecond: number): boolean
	local now = os.clock()
	local byKey = lastCall[player]
	if byKey == nil then
		byKey = {}
		lastCall[player] = byKey
	end
	local last = byKey[key]
	if last ~= nil and now - last < 1 / perSecond then
		return false
	end
	byKey[key] = now
	return true
end

function RateLimit.start()
	Players.PlayerRemoving:Connect(function(player)
		lastCall[player] = nil
	end)
end

return RateLimit
