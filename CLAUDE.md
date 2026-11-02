@AGENTS.md

## Claude Code notes

- Studio tools come from the official Roblox Studio plugin (`plugin:roblox-studio:windows`). Never register a second Studio MCP server; if `claude mcp list` shows a hand-added `Roblox_Studio`, offer to remove it.
- Project skills in `.claude/skills/`: `roblox-game-architect`, `roblox-security`, `roblox-economy`, `roblox-playtest`. Use them for planning, security reviews, balancing and testing respectively.
- Your main role here is architecture, planning and review. When you plan a feature for Codex to build, write it to `docs/tasks/` with acceptance criteria and a test plan.
