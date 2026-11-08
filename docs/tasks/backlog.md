# Backlog

Each task: goal, files touched, acceptance criteria, test plan. Claude Code writes plans; Codex implements. Milestone order and acceptance summaries: [roadmap.md](roadmap.md).

- [x] Write the core loop in `docs/design/game-design.md` (robots, income, prices, rarity). Blueprint v1 plus economy, monetization, research and architecture docs, 2026-11-02. Approved 2026-11-08.
- [x] M0a: Script Sync fixed and verified 2026-11-02 (disk → Studio and Studio → disk round trips in Server, Client and Shared; deletes sync too).
- [ ] M0b: publish the place (PlaceId was still 0 on 2026-11-02), then enable Studio API access. Needed before M2, not M1.
- [ ] M1: first robot + income loop, solo playable: [m1-steal-loop.md](m1-steal-loop.md).
- [ ] M2: data layer, `src/Server/PlayerData.luau` with session-locked DataStore saves (rules in `docs/design/technical-architecture.md`).
- [ ] M3: heist challenge (quirks, Sweeper Bot, vault alarm, Getaway Bonus).
- [ ] M4: upgrades, HUD, tutorial, analytics. Then the MVP playtest gate.
- [ ] Economy: fix the Space Lab vault wall (300M → about 120M) and re-run `tools/economy-sim.luau` before Update 1.
