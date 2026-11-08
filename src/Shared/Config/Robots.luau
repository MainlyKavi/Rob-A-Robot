--!strict
-- Every robot, keyed by id. Values from docs/design/economy.md.
local Types = require(script.Parent.Parent.Types)

local Robots: { [string]: Types.RobotConfig } = {
	Toasty = { name = "Toasty", facility = "Junkyard", tier = "Common", income = 2, quirks = {} },
	Mopsy = { name = "Mopsy", facility = "Junkyard", tier = "Common", income = 3, quirks = {} },
	Trashy = { name = "Trashy", facility = "Junkyard", tier = "Common", income = 4, quirks = { "Heavy" } },
	BoltPup = { name = "Bolt Pup", facility = "Junkyard", tier = "Rare", income = 8, quirks = { "Wriggly" } },
	ClankCrab = { name = "Clank Crab", facility = "Junkyard", tier = "Rare", income = 10, quirks = { "Wriggly" } },
	SirRustalot = { name = "Sir Rustalot", facility = "Junkyard", tier = "Epic", income = 20, quirks = { "Heavy" } },
	Crusher = {
		name = "Crusher",
		facility = "Junkyard",
		tier = "Legendary",
		income = 50,
		quirks = { "Heavy", "Wriggly" },
	},
}

return table.freeze(Robots)
