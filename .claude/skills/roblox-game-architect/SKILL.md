---
name: roblox-game-architect
description: Plan and structure Rob a Robot systems in Luau. Use when designing a new feature or system, deciding where code goes (Server/Client/Shared), splitting modules, defining remotes, or writing an implementation plan for Codex in docs/tasks/.
---

# Roblox game architect (Rob a Robot)

The architecture is defined in `AGENTS.md` ("Architecture"). Read it first. This skill is about applying it, not reinventing it.

## Before designing

1. Read `docs/design/game-design.md` and the relevant `docs/tasks/` entry.
2. Look at what exists: `src/` on disk, plus the live place through MCP (`list_roblox_studios`, then `search_game_tree` / `inspect_instance`, all read-only). Reuse existing modules before adding new ones.
3. For engine API questions, call the Studio MCP `skill` tool for Roblox's built-in guidance instead of relying on memory.

## Placement rules

- Owns or changes currency, robots, ownership, rewards, saved data -> `src/Server/`.
- Input, camera, effects, UI behavior -> `src/Client/` (`UI/` for interface scripts).
- Read by both sides and holds no secrets -> `src/Shared/` (config tables, types, pure functions).
- Numbers a designer will tune -> `src/Shared/Config/`, never inline.

## Designing a system

For each feature produce, in this order:
1. **State**: what data exists, where it lives (server memory, DataStore profile, replicated attribute/value), and who owns it.
2. **Flow**: a numbered sequence (client action -> remote -> server validation -> state change -> replication -> UI update).
3. **Remotes**: name, direction, argument types, server-side checks (type, rate limit, ownership, affordability, distance if spatial).
4. **Modules**: file path, public functions with Luau type signatures, and nothing else.
5. **Solo check**: confirm it works with one player. Multiplayer-only parts must be optional and isolated.
6. **Test plan**: the concrete MCP steps and console checks that prove it works (hand off to `roblox-playtest`).

Write the result to `docs/tasks/<feature>.md` so Codex can implement it.

## Keep it small

- Prefer a plain ModuleScript with functions over classes, frameworks or service locators.
- No new dependency or framework without the user's approval.
- One remote per player intent; don't build a generic "do anything" remote.
- If a plan needs more than ~5 new modules for one feature, cut scope and say what you cut.
- Changing the architecture itself means updating `AGENTS.md` in the same change, so Codex stays aligned.
