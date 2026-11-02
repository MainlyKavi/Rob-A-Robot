# Rob a Robot: monetization plan

Status: **proposal only. Nothing here may be built or enabled without the user's explicit approval, product by product** (AGENTS.md rule 12). No `MarketplaceService` code exists or should exist until then.

Goal: earn because players enjoy the game. Sell time-savers, convenience, cosmetics and social moments. Never sell power over other players, never sell randomness, never pressure.

## Hard rules

1. **No paid random items.** No crates, eggs, spins or "mystery" anything for Robux, and no Robux product that changes the odds of a random outcome. Roblox's policy covers indirect purchases (Robux → currency → spin) and odds boosters, requires showing real odds, and makes these mechanics unavailable to some players (for example under-18s in Brazil). PEGI now generally rates new games with paid random items 16+. Not worth it.
2. **No PvP power for money.** No paid shields, raid immunity, steal speed or protection from borrowing. Raid Mode rules apply equally to everyone.
3. **Never sell robots or income variants directly.** Robots are stolen. Selling them would make heists pointless. Cosmetic paints are fine; Gold and Rainbow (which change income) are earned only.
4. **No pressure.** No countdown timers on Robux offers, no fake "only 3 left", no pop-ups during a heist, no purchase prompt in a player's first session unless they open the shop themselves.
5. **Correct and safe purchase code.** `ProcessReceipt` is idempotent and grants only after the save succeeds. Pass ownership is checked on the server. Prices are never sent from the client.

## Recommended products

Prices are starting points. Once live, use Roblox's managed pricing (price optimization and regional pricing) instead of guessing. Passes sold in your own game pay the creator 70% of the Robux spent (Roblox docs).

| # | Product | Type | What it does | Why players want it | Price (R$) | When they discover it | Economy effect | Build cost |
|---|---|---|---|---|---|---|---|---|
| 1 | **2x Cash** | Pass | Doubles robot income and the Getaway Bonus. | The genre's best seller: everything comes twice as fast. | 449 | Shop, always visible. One contextual line after unlocking the Toy Factory. | Halves time to every goal and burns content faster. Not simulated yet: run the sim at 2x income before enabling, and keep update cadence ahead of it. No effect on PvP. | low |
| 2 | **VIP** | Pass | VIP chat tag, gold base trim, Royal paint for Grabby and Toasty, +1 pad. | Status and looks, plus a small comfort perk. | 249 | Shop, and on other players' bases (seeing it is the ad). | +1 pad is about +6% income at max pads. Mostly cosmetic. | low |
| 3 | **Big Cash Bin** | Pass | Doubles the offline Cash Bin cap (10 → 20 min, up to 30 → 60). | For players who can only drop in once a day. | 149 | Welcome-back screen ("Your bin was full! Big Cash Bin holds twice as much"). | Raises offline share for casual players; capped, so it can't replace play. | low |
| 4 | **Robot Radar** | Pass | Shows the rarest robot in each zone through walls, your vault restock timer from anywhere, and pings Rare Robot Alerts. | Saves scouting time. Feels clever, not powerful. | 199 | Shop, and when a Rare Robot Alert starts. | Small efficiency gain; no new robots. | medium |
| 5 | **Heist Hour** (server boost) | Developer product | Everyone in the server gets 2x Getaway Bonus for 5 minutes. Banner: "Kavi started Heist Hour!" One per server every 10 minutes. | Social, generous, visible. Kids love being the hero of the server. | 79 | Shop; the banner itself advertises it. | Fixed, non-random boost. Short; benefits free players too. | low |
| 6 | **Cash Stash** (S / M / L) | Developer product | Instant cash worth 15 min / 1 h / 3 h of your current base income, with a floor of $500 / $2k / $6k. | Skip a wait for the next pad or gate. | 49 / 149 / 399 | Shop only. Never auto-prompted. | Pure time skip that scales with progress, so it never becomes useless or overpowered. Watch purchase frequency. | low |
| 7 | **Base themes** | Developer product (owned once, saved) | Neon, Candy, Space and other skins for your base. | Show-off, personal space. | 99-199 each | Shop, other players' bases. | None. | medium (art) |
| 8 | **Carry trails and robot paints** | Developer product (owned once, saved) | Trails behind you while carrying; paint jobs for robots you own. | Make your heists look cool in clips. | 49-149 | Shop, and on other players. | None. Paint never changes income. | medium (art) |
| 9 | **Private servers** | Private server | Play with chosen friends. | Friends, YouTubers, safe play. | Free at launch | Game page. | None. Revisit pricing after launch. | none |

### Later, only after launch data

- **Robo Club subscription:** a monthly cosmetic robot paint, a daily cash stash, VIP perks. Only once retention shows players stay a month.
- **Rewarded video ads:** for example "watch an ad, double this Cash Bin". Roblox handles which users can see ads; check eligibility rules when it is time.
- **Seasonal cosmetic bundles.** Fine as long as the items come back later, so scarcity is never fake.

### Rejected

| Idea | Why not |
|---|---|
| Crates, eggs, spins, "mystery robots" for Robux | Paid random items: policy, age and region limits, PEGI 16, and bad for trust. |
| Paid vault restock or paid odds boosters | A Robux purchase that triggers or improves a random roll counts as a paid random item. |
| Base shields, raid immunity, faster stealing for Robux | Pay-to-win against other players. |
| Buying robots or Gold/Rainbow variants | Makes heists pointless and collections cheap. |
| "Admin abuse" style paid server powers that hurt others | Bullying for money. |
| Starter packs with countdown timers | Pressure tactics on a young audience. |

## Rollout order (each step needs approval)

1. At launch: 2x Cash, VIP, Big Cash Bin, Cash Stash, free private servers.
2. With the Rare Robot Alert update: Heist Hour, Robot Radar.
3. With the first art pass: base themes, trails, paints.
4. After 30 days of data: decide on Robo Club and ads.

## Technical notes for when it is approved

- One server module, `src/Server/Monetization.luau`, owns `MarketplaceService`. Product and pass ids live in `src/Shared/Config/Products.luau`.
- `ProcessReceipt`: look up the purchase id in the player's saved `receipts` set; if already granted, return `PurchaseGranted`. Otherwise grant, save, and only then return `PurchaseGranted`. Return `NotProcessedYet` if the player left or the save failed.
- Pass checks: `UserOwnsGamePassAsync` on join (cached, with retry) plus `PromptGamePassPurchaseFinished` for live purchases.
- Analytics: log every purchase as an economy event (`AnalyticsService:LogEconomyEvent`) and the shop funnel (open → view item → prompt → buy).
