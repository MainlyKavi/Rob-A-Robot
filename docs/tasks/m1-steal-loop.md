# M1: Steal loop (grey-box, no saving)

Status: **ready for implementation once the user approves.** Owner: Codex. Reviewer: Claude Code.
Design: [game-design.md](../design/game-design.md) sections 2, 6, 11 · Architecture: [technical-architecture.md](../design/technical-architecture.md) · Numbers: [economy.md](../design/economy.md)

## Goal

Alone in a server, a player can walk into the Junkyard, steal a robot, carry it home, watch it earn, and collect the cash. Nothing else. This proves the loop and lays the server-authoritative base every later milestone builds on.

## Preconditions

- M0 done: Script Sync works (no "Can't sync … Root file or folder is missing" in the output), so files in `src/` appear in Studio.
- The user has saved or published the place before any MCP edit to Workspace or ReplicatedStorage.

## Out of scope (later milestones)

Saving (M2). Guarded Wing, Vault, quirks, guards, GRIP, Getaway Bonus (M3). Shop, HUD, tutorial, Robodex, analytics, extra pads (M4). Any purchase with Robux (never without approval). Raid Mode (M7).

## 1. Studio grey-box (place-side, not synced)

Build in Edit mode through MCP after the user confirms the place is saved. Plain anchored Parts, `SmoothPlastic`, no scripts inside. Studs, Y up, tower centre at the origin.

**Junkyard floor of the Robot Tower:** `Workspace.Map.Facilities.Junkyard` (Model)
- `Shell` (Folder): floor 72 × 1 × 72 at (0, 0.5, 0); four walls 2 thick and 16 high around it, each with a 12-stud door gap centred on that side.
- `Slots` (Folder): 8 Parts `Floor1`..`Floor8`, size 5 × 0.4 × 5, CanCollide false, attribute `Zone = "Floor"`, at y = 1.2:
  - north door: `Floor1` (-14, -26), `Floor2` (14, -26)
  - east door: `Floor3` (26, -14), `Floor4` (26, 14)
  - south door: `Floor5` (14, 26), `Floor6` (-14, 26)
  - west door: `Floor7` (-26, 14), `Floor8` (-26, -14)

  (x, z pairs.)

**Plots:** `Workspace.Map.Plots`, 8 Models `Plot1`..`Plot8`, two per side, each 40 × 40, centre 101 studs from the origin and 25 studs either side of the door axis, front edge facing the tower (pivot with `CFrame.lookAt(centre, Vector3.new(0, centre.Y, 0))`). Plot1 and Plot2 are north at (-25, -101) and (25, -101); continue clockwise. Each plot contains:
- `Floor`: 40 × 1 × 40 base part.
- `Spawn`: SpawnLocation 6 × 1 × 6 at the back centre, `Neutral = true`, `Duration = 0`.
- `HomeZone`: 40 × 8 × 4 Part along the front edge, `Transparency = 0.8`, CanCollide false, colour Bot Teal `#19C3B1`.
- `Pads` (Folder): 16 Parts `Pad1`..`Pad16`, 6 × 0.6 × 6 in a 4 × 4 grid (9-stud spacing), front row first, left to right. Pads above `padCount` are hidden by `Bases` (Transparency 1, CanCollide false).
- `Sign`: Part with a SurfaceGui and TextLabel at the front corner.

Build on top of the existing Baseplate. Ask the user before deleting the default `SpawnLocation` (plots have their own).

**Robot models:** `ReplicatedStorage.RobotModels`, one Model per robot id from `Config.Robots` (`Toasty`, `Mopsy`, `Trashy`, `BoltPup`, `ClankCrab`, `SirRustalot`, `Crusher`), 3-10 parts each, `PrimaryPart` set, unanchored, CanCollide false. Body colour by tier (Common `#B8C0CC`, Rare `#3D8BFF`, Epic `#A64DFF`, Legendary `#FFC21A`). Size about 3 studs for Commons up to 6 for Crusher. Front `Face` part with a SurfaceGui TextLabel showing `🙂` (the client swaps it to `😱` when carried; nice to have in M1).

## 2. Files

All new files start with `--!strict`. Keep modules free of side effects at require time: connect events in `start()`.

```
src/Shared/Config/Robots.luau      all 7 Junkyard robots (fields below)
src/Shared/Config/Facilities.luau  Junkyard with Floor, Guarded, Vault zones (M1 uses Floor only)
src/Shared/Config/Economy.luau     tunables below
src/Shared/Types.luau              PlayerData, RobotEntry, RobotConfig types
src/Server/Main.server.luau        require + init/start in order
src/Server/Remotes.luau            creates ReplicatedStorage.Remotes: RequestSteal, SlotChanged, Notify
src/Server/RateLimit.luau
src/Server/PlayerData.luau         in-memory profiles for now (M2 adds DataStore)
src/Server/Robots.luau
src/Server/Economy.luau
src/Server/Bases.luau
src/Server/Heists.luau
src/Client/Main.client.luau
src/Client/SlotRenderer.luau
src/Client/Feedback.luau
```

Remove the `.gitkeep` files in folders that now contain real files.

### Config values

`Robots.luau` (values from economy.md):

```lua
export type RobotConfig = { name: string, facility: string, tier: string, income: number, quirks: { string } }
-- Toasty Common 2 · Mopsy Common 3 · Trashy Common 4 {"Heavy"} · BoltPup Rare 8 {"Wriggly"}
-- ClankCrab Rare 10 {"Wriggly"} · SirRustalot Epic 20 {"Heavy"} · Crusher Legendary 50 {"Heavy","Wriggly"}
-- Display names: "Toasty", "Mopsy", "Trashy", "Bolt Pup", "Clank Crab", "Sir Rustalot", "Crusher"
```

`Facilities.luau`:

```lua
Junkyard = {
	order = 1,
	gateCost = 0,
	vaultCost = 2500,
	zones = {
		Floor = { weights = { Common = 85, Rare = 15 }, restockSeconds = 5 },
		Guarded = { weights = { Rare = 85, Epic = 15 }, restockSeconds = 15 },
		Vault = { weights = { Epic = 92, Legendary = 8 }, restockSeconds = 90 },
	},
}
```

`Economy.luau`:

```lua
startCash = 0, startPads = 4, maxPads = 16,
scrapSeconds = 60,          -- scrap value = income * scrapSeconds
binMinutes = { 10, 20, 30 }, -- Cash Bin cap by level; M1 uses level 0 -> 10 minutes
walkSpeed = 16,
carrySpeedMultiplier = 0.8,
stealDistance = 12,         -- server check; the prompt itself uses 8
travelSpeedSlack = 1.4,     -- deposit needs carryTime >= distance / (walkSpeed * carrySpeedMultiplier * slack)
```

### Module APIs (public functions only)

```lua
-- PlayerData
PlayerData.get(player: Player): Types.PlayerData?
PlayerData.onLoaded(callback: (Player, Types.PlayerData) -> ())   -- called for each profile as it loads
PlayerData.onRemoving(callback: (Player) -> ())
-- Profile shape: Types.PlayerData from technical-architecture.md (version, cash, bin, lastSeen, padCount,
-- robots, upgrades, facilities, vaults, dex, stats, receipts). Fill defaults now so M2 changes nothing else.

-- Robots
Robots.income(data: Types.PlayerData): number
Robots.decide(padIncomes: { number }, padCount: number, newIncome: number): ("place" | "replace" | "scrap", number?)
	-- pure: "place" if a pad is free; "replace", index of the lowest pad if newIncome is strictly higher;
	-- otherwise "scrap"
Robots.give(player: Player, robotId: string): (string, number)
	-- the ONLY function that adds robots; returns the decision and the scrap value to pay (0 if none);
	-- also marks dex[robotId] = true and stats.steals += 1

-- Economy
Economy.addCash(player: Player, amount: number)   -- asserts amount is finite and > 0; updates attribute + leaderstats
Economy.collect(player: Player): number           -- moves bin into cash, returns the amount
Economy.start()                                   -- one 1 Hz loop for all players: bin = min(bin + income, cap)

-- Bases
Bases.getPlot(player: Player): Model?
Bases.refreshPads(player: Player)                 -- shows padCount pads, puts robot models on filled pads
Bases.start()                                     -- assigns plots on join, frees them on leave

-- Heists
Heists.start()                                    -- slots per player, RequestSteal, carry, HomeZone deposit
```

Dependency direction (no cycles): `Heists` → `Robots`, `Economy`, `Bases`, `PlayerData`, `Remotes`, `RateLimit`. `Economy` → `Robots`, `PlayerData`. `Bases` → `PlayerData`. `Robots` → `PlayerData`, config.

## 3. Behaviour

**Join:** `PlayerData` creates a default profile. `Bases` assigns the first free plot, sets `player.RespawnLocation` to its `Spawn`, writes the display name on the `Sign`, sets attribute `Plot`. Make sure the first character spawns at the plot (for example `Players.CharacterAutoLoads = false` plus `LoadCharacter()` after assignment, and respawn on death). No free plot → kick with "Server full, please rejoin."

**Attributes on the Player:** `Cash`, `Bin`, `PadCount`, `Carrying` (robot id or ""). Also a `leaderstats` folder with a `Cash` value so testers can see it before the M4 HUD.

**Slots:** on profile load, `Heists` rolls a robot for each of the player's 8 Floor slots (tier by zone weights, then a uniform robot of that tier from the facility) and fires `SlotChanged(slotId, robotId)` to that player. Slot id = `"Junkyard/Floor1"` etc.

**Client `SlotRenderer`:** on `SlotChanged`, remove any model on that slot; if `robotId` is set, clone `RobotModels[robotId]` into a client-only folder in Workspace, pivot it onto the slot part, add a `ProximityPrompt` (ActionText "Steal", ObjectText = display name, HoldDuration 1, MaxActivationDistance 8, RequiresLineOfSight false). `Triggered` → `RequestSteal:FireServer(slotId)`. Remote events fired before the client connects are queued by Roblox, so the initial burst isn't lost.

**Steal (`RequestSteal`):**
1. `typeof(slotId) == "string"` and `#slotId <= 64`, else ignore.
2. `RateLimit.allow(player, "steal", 4)`.
3. Profile loaded, character alive, not carrying.
4. Slot exists and this player's slot holds a robot.
5. `HumanoidRootPart` within `stealDistance` of the slot part (server position).
6. Then: clear the slot and fire `SlotChanged(slotId, nil)`; clone the model on the server, make its parts Massless, CanCollide/CanTouch/CanQuery false, weld it in front of the HumanoidRootPart, parent it to the character; set `Carrying`; WalkSpeed = 16 × 0.8; remember `{ robotId, slotId, startedAt = os.clock(), from = slot position }`; schedule the slot restock in 5 s; `Notify("stolen", { robotId })` to the player.

**Deposit and collect (`HomeZone.Touched`, own plot only):**
1. Confirm the touching part belongs to this player's character and the HumanoidRootPart is inside the zone's bounds.
2. If carrying: travel check `os.clock() - startedAt >= distance(from, zone) / (walkSpeed * carrySpeedMultiplier * travelSpeedSlack)`. Fail → destroy the carried model, clear carrying, `warn` with the player name, no reward (the slot restocks as normal). Pass → `Robots.give`, `Economy.addCash` the scrap value if any, `Bases.refreshPads`, destroy the carried model, restore WalkSpeed, `Notify("deposited", { robotId, result, scrap })`.
3. Always `Economy.collect(player)`; if it returned more than 0, `Notify("collected", { amount })`.
4. Debounce per player (for example 0.5 s) so the many Touched events from limbs don't run it repeatedly.

**Death or leaving while carrying:** clear carrying and destroy the model (dies with the character anyway); nothing is granted. The slot's restock is already scheduled. On leave, `Bases` hides that plot's pad robots and frees the plot; `Heists` drops the player's slot table.

**Client `Feedback`:** on `Notify`, play a short sound for stolen, deposited, scrapped and collected. Use only built-in `rbxasset://sounds/...` files or sounds made in-project (AGENTS.md rule 10); check each one actually plays. Swap the carried robot's face to `😱` if the model has a `Face` label.

## 4. Acceptance criteria

1. All files above exist, start with `--!strict`, and `stylua src` and `selene src` report nothing.
2. On joining a solo playtest, the player spawns on `Plot1`, its sign shows their display name, attributes `Plot`, `Cash` (0), `Bin` (0), `PadCount` (4), `Carrying` ("") are set.
3. Within 3 seconds, 8 robots stand on the Junkyard floor slots in the **Client** datamodel and none exist in the **Server** datamodel's Workspace.
4. Holding Steal for 1 s near a slot: the slot empties, `Carrying` = that robot id, a robot model is welded to the character (visible in the Server datamodel), WalkSpeed is 12.8.
5. About 5 s later that slot shows a new robot.
6. Entering the player's own HomeZone: the robot appears on the next pad (server model), `Carrying` = "", WalkSpeed 16, a deposit sound plays.
7. `Bin` rises each second by the total income of robots on pads and stops at 10 minutes' worth; entering the HomeZone moves it into `Cash` (and leaderstats).
8. With 4 pads full, a better robot replaces the weakest (scrap of the weakest paid); an equal or worse robot is scrapped (income × 60 paid).
9. `Robots.decide` passes the Edit-mode asserts in the test plan.
10. Every abuse test in the test plan leaves `Carrying`, `Cash`, pads and slots unchanged (except the legitimate rate-limited steals).
11. Dying while carrying clears `Carrying`, the slot restocks, no errors. Stopping play while carrying logs no errors.
12. A 5-minute solo session produces no errors or warnings from our scripts (the travel-check `warn` only appears in the teleport test).
13. `grep -rn "DataStoreService\|MarketplaceService" src` finds nothing.

## 5. Test plan (MCP, solo)

Start: `list_roblox_studios` → confirm the Rob a Robot place → `get_studio_state` is Edit.

1. **Pure logic (Edit mode)** with `execute_luau`:
   ```lua
   local Robots = require(game.ServerScriptService.Server.Robots)
   assert(Robots.decide({}, 4, 2) == "place")
   local action, index = Robots.decide({ 2, 3, 4, 8 }, 4, 10)
   assert(action == "replace" and index == 1)
   assert(Robots.decide({ 8, 8, 8, 8 }, 4, 3) == "scrap")
   assert(Robots.decide({ 8, 8, 8, 8 }, 4, 8) == "scrap") -- equal is not better
   print("Robots.decide ok")
   ```
2. `start_stop_play` (start). `get_console_output`: no errors.
3. **Join state (Server):** read the player's attributes and plot; check 0 robot models under `Workspace.Map` on the server and 8 client robot models in the Client datamodel (`search_game_tree` with `datamodel_type = "Client"`).
4. **Legit heist:** walk with `character_navigation` to `Junkyard/Floor1`, hold the prompt (`user_keyboard_input` E for 1+ s; if the tool can't hold a key, call `prompt:InputHoldBegin()`, wait 1.1 s, `prompt:InputHoldEnd()` from the Client datamodel), confirm `Carrying` on the server, walk back into the HomeZone, confirm pad, `Carrying` = "", WalkSpeed 16. Wait 5 s; confirm `Bin` ≈ 5 × income. Re-enter the zone; confirm `Cash` rose by the bin.
5. **Abuse tests (Client datamodel `execute_luau`)**, then check server state each time:
   ```lua
   local r = game.ReplicatedStorage.Remotes.RequestSteal
   r:FireServer(123)                       -- wrong type
   r:FireServer(string.rep("x", 1000))     -- too long
   r:FireServer("Junkyard/Nope")           -- unknown slot
   r:FireServer("Junkyard/Floor1")         -- from the plot: too far
   ```
   Then stand next to a slot (server: `character:PivotTo(...)` beside it) and fire `RequestSteal` for it 50 times in one frame: exactly one steal happens (already carrying blocks the rest). Fire for a slot just emptied: rejected.
6. **Teleport deposit:** steal legitimately, then on the server `PivotTo` the character straight into the HomeZone. Expect no pad change, `Carrying` cleared, one `warn` line.
7. **Pads full:** on the server, call `Robots.give` for four robots, then one better and one worse robot; check pads and cash against the rules.
8. **Death while carrying:** steal, then set Humanoid.Health = 0 on the server; check `Carrying`, slot restock, console.
9. `get_console_output`, `start_stop_play` (stop), confirm Edit mode.
10. Report: passed (tool + observed result), failed (error, steps, file:line), not tested (two-player plot assignment: needs a user-run "Clients and Servers" test; phone feel).

## 6. Review checklist (Claude Code, before merge)

- `roblox-security`: every check in the `RequestSteal` handler, travel check, rate limit, no client numbers used.
- Only `Robots.give` writes `data.robots`.
- No per-frame server work; one income loop.
- Module boundaries and names match technical-architecture.md; no new dependencies.
- The place changes are additive and listed in the Codex report.
