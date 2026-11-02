@AGENTS.md

## Claude Code notes

- Studio tools come from the `Roblox_Studio` MCP server (local scope for this project, added by Studio's Quick Connect; runs `%LOCALAPPDATA%\Roblox\mcp.bat`). The Roblox Studio Claude plugin is deliberately not installed. Never install it or register a second Studio server: that duplicates every tool. If `claude mcp list` shows another Studio entry, offer to remove the extra one.
- Project skills in `.claude/skills/`: `roblox-game-architect`, `roblox-security`, `roblox-economy`, `roblox-playtest`. Use them for planning, security reviews, balancing and testing respectively.
- Your main role here is architecture, planning and review. When you plan a feature for Codex to build, write it to `docs/tasks/` with acceptance criteria and a test plan.
