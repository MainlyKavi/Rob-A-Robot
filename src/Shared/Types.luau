--!strict
-- Shared Luau types. Schema: docs/design/technical-architecture.md "Data".

export type RobotEntry = { id: string, variant: string? } -- variant stays nil until variants ship

export type PlayerData = {
	version: number,
	cash: number,
	bin: number, -- uncollected Cash Bin
	lastSeen: number, -- os.time() of the last save, for offline earnings (M2)
	padCount: number,
	robots: { RobotEntry }, -- dense list in pad order; #robots <= padCount
	upgrades: { shoes: number, gloves: number, bin: number },
	facilities: { [string]: boolean },
	vaults: { [string]: boolean },
	dex: { [string]: boolean },
	stats: { steals: number, caught: number, vaults: number, purchases: number },
	receipts: { [string]: boolean },
}

export type RobotConfig = { name: string, facility: string, tier: string, income: number, quirks: { string } }

local Types = {}
return Types
