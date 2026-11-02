# Rob a Robot: project rules for AI assistants

This file is the single source of truth for Claude Code and Codex. `CLAUDE.md` imports it. Change rules here, not in two places.

## The game

Rob a Robot is a Roblox game written in Luau. Players steal robots from NPC facilities (robbing is the core mechanic), carry them home, and the robots earn cash over time. Cash buys heist gear, pads, vault doors and new facilities, never robots. Optional Raid Mode lets players borrow each other's robots for a while; robots always return to their owner. Design doc: `docs/design/game-design.md` (with `economy.md`, `monetization.md`, `research.md`, `technical-architecture.md` next to it). Milestones: `docs/tasks/roadmap.md`. Current tasks: `docs/tasks/backlog.md`.

## Non-negotiable rules

1. Use Luau and Roblox-supported engine APIs only. Use `--!strict` in new scripts.
2. The game must be fully playable by one player alone. Every core loop works with an empty server.
3. Multiplayer mechanics (stealing, trading, leaderboards) are optional extras layered on top. They never block solo progress.
4. Keep gameplay simple and addictive. Prefer a tighter loop over more features.
5. The server is authoritative over currency, purchases, robot ownership, rewards and stealing. Clients send *requests*; the server validates and decides. Never trust a value the client sends (price, amount, robot id ownership, position-based claims) without checking it on the server.
6. DataStore access goes through one server module with retries, `UpdateAsync` for writes, session locking, saving on leave and `BindToClose`, and a schema version field. No other script touches DataStoreService.
7. Optimize for mobile and desktop: touch-friendly UI (min ~44px tap targets, `UIScale`/scale-based sizing), limited part counts, no per-frame work that can be event-driven.
8. Prefer small reusable ModuleScripts over large scripts. No frameworks unless the user approves one.
9. Test every new feature in Studio before calling it done (see "Testing"). Report what you tested and what you could not.
10. Do not insert unverified Toolbox models, free models or external scripts. Assets must be made in-project or be verified first-party.
11. Add no dependencies (Wally packages, frameworks, plugins) without the user's approval.
12. **Never add Robux purchases** (Developer Products, Game Passes, `MarketplaceService` prompts) without the user's explicit approval.
13. Only modify this project. Do not touch other folders or projects on this machine.
14. Both assistants follow the same architecture below. If you need to change it, propose the change and update this file in the same commit.

## Architecture

Scripts live in `src/` and sync into Studio with Studio's built-in Script Sync. Each top-level `src` folder maps to one Studio Folder:

| Disk | Studio location | Contents |
|------|-----------------|----------|
| `src/Server/` | `ServerScriptService.Server` | Server systems: data, economy, robots, stealing. Server-only modules. |
| `src/Client/` | `StarterPlayer.StarterPlayerScripts.Client` | Client controllers, input, effects. |
| `src/Client/UI/` | (same, subfolder) | UI scripts. UI *instances* (ScreenGuis) live in `StarterGui` in the place, not on disk. |
| `src/Shared/` | `ReplicatedStorage.Shared` | Config tables (prices, rarities), types, pure helper modules used by both sides. |

File suffixes decide script type: `Name.server.luau` = server Script, `Name.client.luau` = client Script, `Name.luau` = ModuleScript, `folder/init.luau` = module with children.

Conventions:
- One entry script per side (`Main.server.luau`, `Main.client.luau`) that requires and starts the systems. Systems are modules with `init()`/`start()` where needed.
- Remotes are created by the server in one place (`ReplicatedStorage.Remotes`) and named by action, such as `RequestBuyRobot`. Every remote handler validates argument types, rate-limits, and checks ownership and affordability on the server.
- Tunable numbers (prices, income rates, rarity weights) live in `src/Shared/Config/` so balancing never needs logic changes.
- Script Sync only syncs Script, LocalScript, ModuleScript and Folder. Don't put other instances, attributes or tags inside synced folders.

## Tooling

- Format: `stylua src` (config `stylua.toml`). Lint: `selene src` (config `selene.toml`). Run both before committing. Fix what they report.
- Roblox Studio is reached through Roblox's official Studio MCP server (`list_roblox_studios`, `search_game_tree`, `inspect_instance`, `script_read`, `multi_edit`, `execute_luau`, `start_stop_play`, `get_console_output`, `screen_capture`, and others). Always call `list_roblox_studios` first and confirm which Studio/place you are targeting. Codex may keep these tools deferred: if they seem missing, use tool search for `Roblox_Studio` before concluding they are unavailable.
- For Roblox API guidance, use Studio's built-in skills via the MCP `skill` tool before guessing at an API.
- Studio and disk are linked by Script Sync. If you edit scripts through MCP, the change lands on disk too. Don't edit the same script on disk and in Studio at the same time.
- Ask before large or destructive changes to the place (deleting instances, mass edits). Remind the user to save/publish the place first.

## Testing

For every feature: run a solo playtest through MCP (`start_stop_play`), read `get_console_output` for errors and warnings, and check the feature's actual effect (with `execute_luau` or `inspect_instance` in play mode, or `screen_capture`). Multiplayer features also need a Studio "Clients and Servers" test with 2+ players. That is a manual step for the user, so say so. UI changes also need a phone-sized device emulation check.

## Git

- Small commits with clear messages. Commit Luau source, docs and config, never `.rbxl` files or secrets.
- Never force-push, reset, rewrite history, or delete branches without the user's approval. Never push without asking.
- Claude Code (architecture, planning, reviews) and Codex (implementation, debugging) share this repo. Pull/check `git status` before starting, and don't work on the same files at the same time.

## Division of labor

- Claude Code: architecture, planning, design docs, code review, security and economy review, troubleshooting.
- Codex: feature implementation and debugging against the plans in `docs/tasks/`.
- Roblox Studio: building, level design, UI instances, and playtesting.
