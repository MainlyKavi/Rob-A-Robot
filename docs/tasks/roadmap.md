# Rob a Robot: roadmap

Status: v1 (2026-11-02). Implementation starts only after the user approves the design and M1.

Each milestone is small, testable in Studio, and leaves the game playable. Claude Code writes the task file (`docs/tasks/mN-*.md`) before Codex starts; Codex implements against it; Claude Code reviews (security, economy, architecture); Studio verification closes it. No milestone is "done" without the test report described in AGENTS.md "Testing".

Rule for the whole roadmap: **no new system starts until the MVP playtest gate (after M4) passes.**

## M0: Setup fixes (before any code)

Goal: make sure scripts written on disk actually reach Studio, and that saving can be tested later.

| Who | Work |
|---|---|
| User (Studio) | Fix Script Sync: Studio's log on 2026-11-02 shows `Can't sync ServerScriptService.Server to disk: Root file or folder is missing` (same for `Client` and `Shared`). Re-link each folder via right-click → **Sync to…** → `D:\Kavi Vids\Coding prj\Rob a Robot\src` (README step 3). Publish the place to Roblox, then turn on Game Settings → Security → **Enable Studio Access to API Services** (needed in M2). |
| Claude Code | Verify through MCP: no sync errors in the console; a test file under `src/Shared/` appears in Studio and is deleted again. Commit the design docs once the user approves them. |
| Codex | none |

Acceptance: console shows no "Can't sync" errors after reopening the place; a round-trip test file appears in `ReplicatedStorage.Shared`.

## M1: Steal loop (grey-box, no saving)

Task: [m1-steal-loop.md](m1-steal-loop.md). Goal: a player can steal a Junkyard robot, carry it home, see it earn, and collect cash, alone in a server.

Acceptance (summary): plot assigned on join; personal floor robots; 1 s hold steals; carry at reduced speed; Home Zone deposits, places on pads and collects the Cash Bin; replace or scrap when pads are full; every remote abuse test rejected; console clean; stylua and selene clean.

| Claude Code | Codex | Studio verification |
|---|---|---|
| Task file (done), review the diff with `roblox-security` and `roblox-game-architect` | Config, Remotes, RateLimit, PlayerData (memory only), Robots, Economy (income + bin), Bases, Heists (floor), client SlotRenderer and Feedback; build the grey-box map and robot models through MCP after the user saves the place | Solo playtest through MCP: steal → deposit → income → collect; abuse tests from the Client datamodel |

## M2: Saving and offline earnings

Goal: progress survives leaving, rejoining and server shutdown, with no duplication.

Acceptance:
- `PlayerData` follows the [data rules](../design/technical-architecture.md#data-m2): `UpdateAsync`, session lock, retries, autosave every 60 s, save on leave, `BindToClose`, schema `version = 1`, validation on load, Studio uses `PlayerData_Studio`.
- Stop and restart play: cash, robots, pad count and Robodex are identical.
- Offline Cash Bin: leave for 2+ minutes, rejoin, bin = elapsed × income (capped at 10 min).
- Corrupt-data test: a profile with an unknown robot id and negative cash loads cleaned, with a warning.
- Lock test: a profile locked by another `jobId` less than 5 minutes ago is not loaded (simulate by writing the lock with `execute_luau` in Studio).

| Claude Code | Codex | Studio verification |
|---|---|---|
| Task file; data-safety review (`roblox-security` "Saved data") | `PlayerData` persistence and migration hook | Save/load round trip across play sessions; the user confirms API access is on |

## M3: Heist challenge

Goal: stealing has risk and skill. This is where the game becomes the game.

Scope: Guarded Wing and Vault slots; quirks Chill, Heavy, Wriggly; GRIP! button (touch and keyboard/gamepad); one Sweeper Bot with patrol → chase → ZAP; caught flow (robot returns, player to Exit, no damage); vault door bought with cash (temporary debug purchase until M4's shop); vault alarm with 15 s shutters; vault restock cooldown; Getaway Bonus.

Acceptance:
- Average round trips within ±30% of the sim (floor 15 s, guarded 28 s, vault 45 s); report the measured times.
- A Wriggly robot drops if GRIP isn't pressed within the window, and can be re-grabbed.
- Guard only reacts to carrying players; catching never damages or kills.
- Vault: alarm starts on steal; failing to exit in 15 s counts as caught; restock timer shows on the door.
- Getaway Bonus pays 10/25/60 s of income.
- Fake `RequestGrip` spam outside a window does nothing.
- Guard detection loop shows no measurable cost in the MicroProfiler with 2 guards.

| Claude Code | Codex | Studio verification |
|---|---|---|
| Task file; tune grip window and guard numbers in config after the first playtest | Quirks in `Heists`, `Security` (guard, alarm), `GripController` | MCP playtest with `character_navigation`; the user plays 10 heists and reports how it felt |

## M4: Upgrades, HUD, tutorial (= MVP)

Goal: a new player understands the game without help and has a reason to keep going.

Scope: shop (pads 5-8, Speed Shoes, Grip Gloves, Junkyard vault door); HUD (cash, Cash Bin, carrying); guided first heist (arrow path, Grabby bubbles, steps driven by player state); Robodex page for the Junkyard with the +10% bonus; Toy Factory gate visible and locked; sounds and basic VFX; `AnalyticsService` onboarding funnel and economy events; phone layout pass.

Acceptance:
- Purchases validated on the server (price from config, prerequisite order, no yield between check and spend).
- A brand-new player reaches a first steal in under 60 s and a first purchase in under 2 minutes (sim targets 0:40 and 1:36).
- Every tap target ≥ 44 px; nothing clipped on a phone-sized device in the Device Simulator.
- Funnel events fire in order in a test session.

| Claude Code | Codex | Studio verification |
|---|---|---|
| Task file; UX review on phone screenshots; economy check against the sim | Shop, HUD, Tutorial, Robodex UI modules, Analytics wrapper; the user builds or approves the ScreenGui instances | Solo playtest, Device Simulator check, the user plays from a fresh profile |

### MVP playtest gate

5-10 testers (include younger players and phone players), solo servers, no coaching. Pass if:
- ≥ 80% steal a robot within 60 s unaided.
- Median session ≥ 12 minutes.
- ≥ 70% attempt the vault.
- Caught rates within 10 points of the targets (floor < 5%, guarded 20-30%, vault 35-50%).
- Most testers can say what the game is in one sentence.
- No data loss in 20 rejoin cycles; no console errors.

Fail → fix M3/M4 feel before adding content.

## M5: Toy Factory and Robodex

Goal: the second facility and the first long-term goal.

Scope: Toy Factory (7 robots, Noisy quirk, conveyor hazard); facility gate; full Robodex UI; robot face art pass (calm, panic, happy).
Acceptance: sim milestones within ±30% for a fresh profile (Toy Factory about 20 min); Noisy beeps pull the guard; Robodex bonus applies once per completed page and survives rejoin.

## M6: Live features

Scope: Rare Robot Alerts (free timed server event); Gold and Rainbow variants; Error 404 Secret; Space Lab (7 robots, built and held back for Update 1); re-run the sim with real playtest numbers and fix the Space Lab vault wall.
Acceptance: events never block solo progress; variant odds shown in the Robodex; economy table updated in `economy.md`.

## M7: Raid Mode (optional multiplayer)

Scope: the rules in [game-design.md section 7](../design/game-design.md#7-multiplayer-optional-layer-after-the-solo-mvp-is-fun): opt-in toggle, borrowing for 10 minutes, top-3 protection, shields, base Lock.
Acceptance: ownership never changes (grep and test); a borrowed robot returns on timer, thief leave, victim leave and server shutdown; solo play unaffected. **Needs a user-run "Clients and Servers" test with 2-3 players.**

## M8: Launch prep

- Art pass on map and robots; thumbnail and icon (section 12 concept); store description; trailer clips.
- Maturity & Compliance Questionnaire (target Minimal); creator ID verification and 2FA; Kids fee or Premium; plan a 16+ soft launch to pass the 250-play evaluation.
- Monetization: only the products the user approves, in the order in [monetization.md](../design/monetization.md#rollout-order-each-step-needs-approval).
- Analytics dashboards checked; error reporting reviewed; final security review.
- Soft launch, watch D1 and first-play bounce for a week, then Update 1 (Space Lab) in week 1-2.
