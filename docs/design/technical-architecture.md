# Rob a Robot: technical architecture

Status: v1 plan (2026-11-02). Follows the conventions in [AGENTS.md](../../AGENTS.md#architecture); nothing here changes them. If a milestone needs to change a convention, update AGENTS.md in the same commit.

## Principles

- **The server owns money, robots, ownership, rewards and stealing.** The client sends intents ("steal slot X", "buy item Y", "grip now") and draws things. It never sends prices, amounts, robot ids it claims to own, or positions to trust.
- **One function adds robots** (`Robots.give`). One module touches DataStores (`PlayerData`). One module creates remotes (`Remotes`).
- **Event-driven where possible.** One 1 Hz income loop for everyone; one 10 Hz loop for guard detection. Nothing per frame on the server.
- **Plain ModuleScripts with functions.** No frameworks, no packages (AGENTS.md rules 8 and 11).

## Roblox services used

| Service | Used for | From |
|---|---|---|
| Players, ReplicatedStorage, ServerScriptService, ServerStorage | basics | M1 |
| ProximityPromptService (via `ProximityPrompt`) | hold-to-steal, touch-friendly out of the box | M1 |
| CollectionService | none at first; plots and slots are found by name and attribute | later if needed |
| DataStoreService | `PlayerData` module only | M2 |
| TweenService, SoundService | client feedback | M1 (sounds), M4 (VFX) |
| AnalyticsService | funnels and economy events | M4/M6 |
| MarketplaceService | **only after the user approves monetization** | never before |

## Folder and module map

`src/` syncs to Studio through Script Sync (see AGENTS.md). Milestone = when the module first appears.

```
src/Server/                         -> ServerScriptService.Server
  Main.server.luau        M1  requires systems, calls init() then start() in order
  Remotes.luau            M1  creates ReplicatedStorage.Remotes and every RemoteEvent
  RateLimit.luau          M1  allow(player, key, perSecond): boolean
  PlayerData.luau         M1  live profile table per player; M2 adds DataStore persistence
  Robots.luau             M1  give / place / scrap: the only code that adds or removes robots
  Economy.luau            M1  income loop, Cash Bin, collect, addCash/trySpend; M4 purchases
  Bases.luau              M1  plot assignment, pad visuals, Home Zone
  Heists.luau             M1  personal slots, steal, carry, deposit; M3 quirks, caught, vault, Getaway Bonus
  Security.luau           M3  Sweeper Bots, vault alarm
  Analytics.luau          M4  thin wrapper over AnalyticsService
src/Client/                         -> StarterPlayer.StarterPlayerScripts.Client
  Main.client.luau        M1
  SlotRenderer.luau       M1  draws this player's facility robots and their steal prompts
  Feedback.luau           M1  sounds; M4 popups and VFX
  GripController.luau     M3  GRIP! button and input
  UI/Hud.luau             M4  cash, Cash Bin, carry state
  UI/Shop.luau            M4
  UI/Tutorial.luau        M4  arrows and Grabby bubbles driven by player state
  UI/Robodex.luau         M5
src/Shared/                         -> ReplicatedStorage.Shared
  Config/Robots.luau      M1
  Config/Facilities.luau  M1
  Config/Economy.luau     M1
  Config/Upgrades.luau    M4
  Types.luau              M1  shared Luau types (PlayerData, RobotEntry, ...)
  Format.luau             M4  1.2K / 3.4M / 1.5B formatting
```

Server modules expose `init()` (create state, connect nothing that depends on others) and `start()` (connect events, start loops) only when needed. Modules require each other directly; `Main` controls order: Remotes → PlayerData → Robots → Economy → Bases → Heists → Security.

### Place-side instances (built in Studio, not synced)

Script Sync only syncs scripts and folders, so these live in the place file and are backed up by publishing (see README):

```
Workspace.Map
  Plots
    Plot1..Plot8 (Model)
      Spawn        SpawnLocation (player.RespawnLocation is set to it)
      HomeZone     Part, transparent, CanCollide false, covers the base entrance
      Pads         Folder: Pad1..Pad16 (Part); only the first padCount are shown
      Sign         Part with a SurfaceGui TextLabel (server writes the display name)
  Facilities
    Junkyard (Model)
      Slots        Folder of Parts; attribute Zone = "Floor" | "Guarded" | "Vault"
      Exit         Part marking the door (caught players are moved here; alarm shutters)
      VaultDoor    Part (M3)
      GuardPath    Folder of waypoint Parts named 1..n (M3)
ReplicatedStorage.RobotModels   Model per robot id (PrimaryPart set, anchored false, no scripts)
ServerStorage.Guards            Sweeper Bot template (M3)
StarterGui.Hud                  ScreenGui (M4)
```

A slot's id is `"<Facility>/<PartName>"`, for example `"Junkyard/Floor1"`.

## State: who owns what

| State | Lives in | Owner | Client sees it via |
|---|---|---|---|
| Cash, Cash Bin, pad count, upgrade levels | `PlayerData` profile | server | Player attributes `Cash`, `Bin`, `PadCount`, `Shoes`, `Gloves`, `BinLevel` |
| Robots on pads | profile `robots` list | server | server-built pad models in the plot (everyone sees them) |
| Unlocked facilities, vaults, Robodex | profile | server | `ProfileSync` RemoteEvent snapshot on load and on change |
| Personal slot contents | `Heists` memory, per player | server | `SlotChanged` RemoteEvent to that player only |
| Carrying | `Heists` memory | server | attribute `Carrying` (robot id or ""), carried model welded to the character |
| Guard positions | server NPCs | server | normal physics replication |
| Plot assignment | `Bases` memory | server | attribute `Plot` |

## Data (M2)

### Schema v1

```lua
export type RobotEntry = { id: string, variant: string? } -- variant stays nil until variants ship
export type PlayerData = {
	version: number, -- 1
	cash: number,
	bin: number, -- uncollected Cash Bin
	lastSeen: number, -- os.time() of the last save, for offline earnings
	padCount: number,
	robots: { RobotEntry }, -- dense list, pad order; #robots <= padCount
	upgrades: { shoes: number, gloves: number, bin: number },
	facilities: { [string]: boolean }, -- unlocked gates
	vaults: { [string]: boolean },
	dex: { [string]: boolean },
	stats: { steals: number, caught: number, vaults: number, purchases: number },
	receipts: { [string]: boolean }, -- only used once monetization is approved
}
```

### PlayerData rules (AGENTS.md rule 6)

- DataStore `PlayerData`, key `"u_" .. userId`. Stored value: `{ data = PlayerData, lock = { jobId: string, at: number }? }`.
- **Load:** `UpdateAsync`. If another server's lock is younger than 5 minutes, don't take it; retry every 5 s for up to 30 s (that server is probably saving on leave), then kick with a friendly "still saving, rejoin in a minute" message. Otherwise write our lock and take the data. Missing data → defaults.
- **Validate on load:** cash and bin finite and ≥ 0; robot ids exist in config (drop unknown ones and log); `#robots ≤ padCount`; levels inside config ranges; run migrations while `version` < current.
- **Offline earnings on load:** `bin += clamp(now - lastSeen, 0, binCapSeconds) × income`, then cap the bin.
- **Save:** `UpdateAsync` that aborts (returns nil) if the stored lock isn't ours; refreshes `lock.at`. Autosave every 60 s, on `PlayerRemoving` (then release the lock), and in `BindToClose` (all players in parallel, wait up to about 25 s).
- **Lost lock:** if a save finds someone else's lock, stop saving that player and kick them, so a stale server can never overwrite newer data.
- **Retries:** 3 attempts with 1/2/4 s backoff; check `GetRequestBudgetForRequestType` before non-urgent writes.
- **Studio:** needs the place published and Game Settings → Security → Enable Studio Access to API Services. Use a separate DataStore name in Studio (`PlayerData_Studio`) so tests never touch live saves.

## Remotes

All in `ReplicatedStorage.Remotes`, created by `Remotes.luau`. Every client → server handler checks argument types first, then rate limits, then game rules. Rejections are silent to the client except a generic `Notify("error")`.

| Remote | Dir | Args | Server checks | Rate | From |
|---|---|---|---|---|---|
| `RequestSteal` | C→S | `slotId: string` | string, ≤ 64 chars; slot exists; this player's slot holds a robot; not already carrying; alive; HumanoidRootPart within 12 studs of the slot part; facility unlocked; vault slots also need the vault unlocked and restocked | 4/s | M1 |
| `RequestGrip` | C→S | none | carrying a Wriggly robot with an open grip window (server-timed, +0.25 s latency slack) | 10/s | M3 |
| `RequestPurchase` | C→S | `itemId: string` | string, ≤ 32 chars; item in `Config.Upgrades`/`Facilities`; next level exists; prerequisites met; affordable. Check and deduct in one step with no yield in between | 5/s | M4 |
| `SlotChanged` | S→C | `slotId: string, robotId: string?` | | | M1 |
| `ProfileSync` | S→C | client-visible subset `{ facilities, vaults, dex }` | | | M2 |
| `Notify` | S→C | `kind: string, data: { [string]: any }?` | feedback: stolen, deposited, scrapped, caught, wriggle, purchase, error | | M1 |

Deposit and collect use **no remote**: the server listens to the player's own `HomeZone.Touched` and confirms the character position is inside the zone.

## Key flows

**Steal (M1)**
1. Server gives each player their own slot table on join and sends `SlotChanged` for every slot.
2. Client `SlotRenderer` clones `RobotModels[robotId]` onto the slot part and adds a `ProximityPrompt` (HoldDuration 1 s, MaxActivationDistance 8).
3. Prompt triggers → `RequestSteal:FireServer(slotId)`.
4. Server validates (table above), clears the slot, sends `SlotChanged(slotId, nil)`, sets `Carrying`, welds a server clone of the robot to the character (massless, no collision), lowers WalkSpeed (carry multiplier × shoes multiplier), records carry start time and slot position, and schedules the slot restock.
5. Client plays the grab sound and the robot's panic face.

**Deposit and collect (M1)**
1. Player touches their own HomeZone.
2. Server: if carrying, run the **travel check**: time carried must be at least `distance(slot, HomeZone) / (carry WalkSpeed × 1.4)`. Fail → robot returns to the slot, log it, no reward.
3. Pass → `Robots.give(player, robotId)`: free pad → place; pads full → replace the weakest if the new one earns more and scrap the old one, else scrap the new one. Add a Robodex entry if new.
4. Always: move the Cash Bin into Cash. `Notify("deposited", ...)`, restore WalkSpeed.

**Income (M1)**
One loop, `task.wait(1)`: for each loaded player, `bin = min(bin + income, income × binCapSeconds)`; set the `Bin` attribute.

**Wriggle (M3)**
Server timer per carried Wriggly robot: every 4-6 s open a grip window (about 1.2 s, wider with gloves) and `Notify("wriggle")`. A valid `RequestGrip` inside the window closes it. Window expires → the robot drops a few studs away and walks back toward its slot; while it's loose, the slot is still "taken" and the player can re-grab it.

**Caught (M3)**
`Security` detection loop (10 Hz): guard sees a carrying player inside its cone → chase. Guard within 4 studs → drop the robot back on its slot, move the player to the facility `Exit`, `Notify("caught")`. Vault alarm countdown runs out while the carrier is inside the facility → same result.

**Purchase (M4)**
`RequestPurchase(itemId)` → look up cost and prerequisites in config → `Economy.trySpend(player, cost)` → apply the effect → update attributes or `ProfileSync`.

## Security invariants (review every milestone with the `roblox-security` skill)

1. No client-sent number is ever used as a price, amount, reward or position.
2. Every robot add goes through `Robots.give`. Grep for other writes to `robots` in review.
3. Distance checks use server-side character positions. Steal requires being near the slot; deposit requires being in your own HomeZone and passing the travel-time check.
4. Check-then-spend happens without a yield in between.
5. Leaving mid-carry: an NPC robot simply goes back to its slot pool; nothing is granted.
6. PvP (M7) never changes ownership. "Borrowed" is an in-memory marker with an expiry, never saved.
7. Rate limits on every client → server remote.

## Performance budgets

| Item | Budget |
|---|---|
| Server loops | income 1 Hz (all players); guard detection 10 Hz (all guards); no Heartbeat work |
| Guards | ≤ 2 per facility, moved with `Humanoid:MoveTo` between waypoints |
| Facility robots | client-only models, ≤ 9 per facility per player |
| Robot model size | ≤ 30 parts (grey-box ≤ 10) |
| Whole map | < 3,000 parts at launch |
| Replication | `Bin` attribute at most once per second per player |
| Players per server | 8 |

## Solo check

Every system is per player. Guards and alarms are shared but behave identically with one player. Raid Mode (M7) is the only multiplayer system, it's opt-in, and the game is complete without it.

## Testing

Per AGENTS.md "Testing" and the `roblox-playtest` skill: a solo playtest through MCP for every milestone (console clean, effect verified with `execute_luau`/`inspect_instance`/`screen_capture`). Remote abuse tests: from the **Client** datamodel during play, fire remotes with bad arguments and confirm the server state didn't change. Multiplayer (M7) needs the user to run a Studio "Clients and Servers" test. UI milestones need a phone-sized device check.
