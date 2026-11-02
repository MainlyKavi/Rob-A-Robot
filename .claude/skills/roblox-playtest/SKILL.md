---
name: roblox-playtest
description: Playtest Rob a Robot in Roblox Studio through the Studio MCP and report real results. Use after implementing or changing a feature, when the user reports a bug, or to check errors, multiplayer behavior, mobile layout or performance.
---

# Roblox playtest (Rob a Robot)

Uses the official Roblox Studio MCP tools. Never report a feature as working without evidence from these steps.

## 0. Connect

1. `list_roblox_studios`: pick the Studio instance with the Rob a Robot place. If none, tell the user to open Studio and enable **Assistant > ... > Settings > MCP Servers > Enable Studio as MCP server**. Stop.
2. `get_studio_state`: must be in Edit mode before starting a test.
3. Ask the user to save/publish first if the test plan changes anything.

## 1. Solo playtest (always)

1. `start_stop_play` to start play mode.
2. Wait a few seconds, then `get_console_output`. Any error or red stack trace fails the test. List warnings too.
3. Exercise the feature:
   - Movement/interaction: `character_navigation`, `user_keyboard_input`, `user_mouse_input`.
   - Check state directly with read-only `execute_luau` (for example print the player's cash or robot count from the server data module) or `inspect_instance`.
   - `screen_capture` to confirm UI shows the right values.
4. `get_console_output` again, then `start_stop_play` to stop. Confirm you are back in Edit mode.
5. If data saving is involved: note that Studio needs **Game Settings > Security > Enable Studio Access to API Services** on, and test a stop/restart round-trip.

## 2. Multiplayer (when the feature involves other players)

The MCP drives a solo session. Ask the user to run **Test tab > Clients and Servers > 2 players > Start** and tell them exactly what to try on each client (for example "Player1 steals Player2's robot, then Player2 checks inventory"). Then read `get_console_output` and check both inventories. Always test:
- The feature still works solo (stealing optional, nothing blocks progress).
- A player leaving mid-action (steal/trade) loses nothing and duplicates nothing.

## 3. Mobile

Ask the user to pick a phone in **Test tab > Device** (or use the emulator toolbar), then `screen_capture`. Check: buttons reachable with thumbs, no text clipped or overlapping, nothing hidden under the jump button/top bar, UI scales rather than using fixed pixel offsets.

## 4. Performance (when something feels slow, or for big features)

- `execute_luau` (read-only) to count instances in Workspace and connections per robot; grep `src/` for `RunService.Heartbeat`/`while true` loops doing work that could be event-driven or batched.
- Income ticks should be one loop for all players, not one per robot.
- Ask the user to open **View > Script Performance** / the MicroProfiler (Ctrl+F6) during play if a hotspot is suspected.

## Report format

- **Passed**: what you verified and how (tool + observed result).
- **Failed**: error text, steps to reproduce, likely file:line.
- **Not tested**: anything you could not run (multiplayer, real device) and why.

Do not modify the place to make a test pass. Report and propose the fix instead.
