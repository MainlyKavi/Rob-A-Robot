# Rob a Robot

A Roblox game. Luau source lives in `src/` and syncs into Roblox Studio with Studio's built-in Script Sync. The rules for AI assistants are in `AGENTS.md`.

## Layout

```
src/Server/    -> ServerScriptService.Server            (server systems)
src/Client/    -> StarterPlayer.StarterPlayerScripts.Client
src/Client/UI/ -> UI scripts (ScreenGuis themselves stay in the place)
src/Shared/    -> ReplicatedStorage.Shared              (config, types, helpers)
docs/design/   game design, economy, monetization, research, technical architecture
docs/tasks/    roadmap, backlog and milestone plans
tools/         helper scripts (place backups, economy simulation)
backups/       local .rbxl backups (git-ignored)
.claude/skills/ project skills for Claude Code
```

## One-time Script Sync setup (in Studio)

1. Open the Rob a Robot place in Studio.
2. In Explorer, create three Folders: `Server` in ServerScriptService, `Client` in StarterPlayer > StarterPlayerScripts, `Shared` in ReplicatedStorage.
3. Right-click each of `Server`, `Client` and `Shared` > **Sync to…** > pick the `src` folder itself (`D:\Kavi Vids\Coding prj\Rob a Robot\src`) > Save. Studio creates the `Server`/`Client`/`Shared` subfolder inside it; picking `src\Server` would nest it as `src\Server\Server`.
4. If a conflict dialog appears, read the lists carefully. On first setup the disk folders are empty, so choose **Keep Studio**: nothing is lost and Studio's scripts get written to disk.
5. Install the **Luau Language Server Companion** plugin from the Creator Store (the publisher is JohnnyMorganz), then click it in the Plugins tab while VS Code is open. This gives VS Code the game's Explorer tree for autocomplete.

Sync resumes on its own when you reopen the place.

## Daily commands

```powershell
stylua src      # format
selene src      # lint
git status
```

## Backups

Script Sync and Git only cover scripts. Parts, models, UI instances, lighting and terrain live only in the place file, so back the place up separately:

- **Publish to Roblox** (File > Publish to Roblox). Published places keep version history (Game Settings / Creator Hub > place > Version History), so you can restore an older version.
- **Local copy**: File > Save to File As… `RobARobot.rbxl`, then run
  `.\tools\backup-place.ps1 "C:\path\to\RobARobot.rbxl"` to keep a timestamped copy in `backups\` (git-ignored). Copy `backups\` to a cloud drive or USB now and then.
- Save or publish **before** asking an AI assistant for large changes, since MCP edits the open place directly.
