--!strict
-- Server entry: requires the systems and starts them in dependency order.
local Bases = require(script.Parent.Bases)
local Economy = require(script.Parent.Economy)
local Heists = require(script.Parent.Heists)
local PlayerData = require(script.Parent.PlayerData)
local RateLimit = require(script.Parent.RateLimit)
local Remotes = require(script.Parent.Remotes)

Remotes.init()
RateLimit.start()
PlayerData.start()
Economy.start()
Bases.start()
Heists.start()
