--!strict
-- Facilities and their slot zones. M1 uses the Junkyard Floor zone only.

export type Zone = { weights: { [string]: number }, restockSeconds: number }
export type Facility = { order: number, gateCost: number, vaultCost: number, zones: { [string]: Zone } }

local Facilities: { [string]: Facility } = {
	Junkyard = {
		order = 1,
		gateCost = 0,
		vaultCost = 2500,
		zones = {
			Floor = { weights = { Common = 85, Rare = 15 }, restockSeconds = 5 },
			Guarded = { weights = { Rare = 85, Epic = 15 }, restockSeconds = 15 },
			Vault = { weights = { Epic = 92, Legendary = 8 }, restockSeconds = 90 },
		},
	},
}

return table.freeze(Facilities)
