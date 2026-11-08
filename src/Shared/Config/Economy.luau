--!strict
-- Economy tunables. Balancing changes go here, not in logic.

local Economy = {
	startCash = 0,
	startPads = 4,
	maxPads = 16,
	scrapSeconds = 60, -- scrap value = income * scrapSeconds
	binMinutes = { 10, 20, 30 }, -- Cash Bin cap by level; index = level + 1
	walkSpeed = 16,
	carrySpeedMultiplier = 0.8,
	stealDistance = 12, -- server check; the prompt itself uses 8
	travelSpeedSlack = 1.4, -- deposit needs carryTime >= distance / (walkSpeed * carrySpeedMultiplier * slack)
}

return table.freeze(Economy)
