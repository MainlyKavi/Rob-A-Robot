# Rob a Robot: economy

Status: v1 numbers, simulated 2026-11-02. These become `src/Shared/Config/` when the matching milestone is built. Change numbers here and in config together, then re-run the sim.

Simulation tool: [`tools/economy-sim.luau`](../../tools/economy-sim.luau) (run it in Studio Edit mode; pure math, it changes nothing in the place).

## Principles

1. **One currency, Cash.** No gems, tickets or premium currency.
2. **Cash buys the ability to steal, never robots.** Sinks are pads, gear, vault doors and facility gates.
3. **Robbing beats waiting.** Every escape pays a Getaway Bonus scaled to your income, and offline income is capped.
4. **Each new place is a clear step up.** A facility's Common earns about what the previous facility's Epic earns.
5. **No dead tiers.** Old robots keep value through permanent Robodex bonuses and, later, variants.
6. **Solo-complete.** Nothing in this file depends on other players.

## Sources and sinks

| Source | Rule | Config key |
|---|---|---|
| Robot income | base income/s of every robot on a pad, ticked into the Cash Bin once per second | `Robots[id].income` |
| Getaway Bonus | on each successful escape: 10 s (floor), 25 s (guarded), 60 s (vault) of current base income | `Economy.getawaySeconds` |
| Offline Cash Bin | while away, the bin fills at full income up to its cap: 10 min, upgradeable to 20 and 30 min | `Economy.binMinutes` |
| Scrap | a robot you can't fit sells for 60 s of its own income | `Economy.scrapSeconds` |
| Robodex bonus | +10% base income per completed facility page, permanent | `Economy.dexBonus` |

| Sink | Levels and costs |
|---|---|
| Pads (start 4, max 16) | pad 5-16: 250 · 1k · 5k · 25k · 120k · 600k · 3M · 15M · 75M · 250M · 600M · 1.5B |
| Speed Shoes (-8% heist time per level) | 150 · 5k · 400k · 25M · 1B |
| Grip Gloves (+4% escape chance on guarded and vault per level, and a wider grip window) | 800 · 30k · 2M · 100M · 3B |
| Cash Bin (offline cap 10 → 20 → 30 min) | 300k · 30M |
| Vault doors (one-time) | Junkyard 2,500 · Toy Factory 2M · Space Lab 300M |
| Facility gates (one-time) | Toy Factory 150k · Space Lab 30M |

## Robots

Scrap value = 60 s of income. Payback isn't relevant (robots are stolen, not bought); what matters is how big a step each robot is over your current weakest pad.

| Facility | Robot | Tier | Income/s | Scrap |
|---|---|---|---|---|
| Junkyard | Toasty | Common | 2 | 120 |
| Junkyard | Mopsy | Common | 3 | 180 |
| Junkyard | Trashy | Common | 4 | 240 |
| Junkyard | Bolt Pup | Rare | 8 | 480 |
| Junkyard | Clank Crab | Rare | 10 | 600 |
| Junkyard | Sir Rustalot | Epic | 20 | 1,200 |
| Junkyard | Crusher | Legendary | 50 | 3,000 |
| Toy Factory | Windy | Common | 20 | 1,200 |
| Toy Factory | Jack | Common | 30 | 1,800 |
| Toy Factory | Plushbot | Rare | 80 | 4,800 |
| Toy Factory | Yo-Yo Bot | Rare | 100 | 6,000 |
| Toy Factory | Robo-Rex | Epic | 200 | 12,000 |
| Toy Factory | Disco Dan | Epic | 250 | 15,000 |
| Toy Factory | Gigabear | Legendary | 600 | 36,000 |
| Space Lab | Moon Rover | Common | 200 | 12,000 |
| Space Lab | Astro Pup | Common | 300 | 18,000 |
| Space Lab | Satellite Sally | Rare | 800 | 48,000 |
| Space Lab | Comet Kid | Rare | 1,000 | 60,000 |
| Space Lab | Rocket Rick | Epic | 2,000 | 120,000 |
| Space Lab | Star Smith | Epic | 2,500 | 150,000 |
| Space Lab | Nova | Legendary | 6,000 | 360,000 |
| Events | Error 404 | Secret | set when events ship (about 2x the newest facility's Legendary) | |

Variants (post-MVP, not in the sim): Gold 1/20 at 2x, Rainbow 1/150 at 5x. Expected income effect is about +8%, small enough not to break pacing.

## Facility slots

`time` is the average round trip from base in seconds; `escape` is an average player's chance of getting home.

| Facility | Zone | Time | Escape | Spawn weights | Vault restock |
|---|---|---|---|---|---|
| Junkyard | Floor | 15 | 97% | Common 85, Rare 15 | |
| Junkyard | Guarded | 28 | 75% | Rare 85, Epic 15 | |
| Junkyard | Vault | 45 | 60% | Epic 92, Legendary 8 | 90 s |
| Toy Factory | Floor | 21 | 93% | Common 85, Rare 15 | |
| Toy Factory | Guarded | 34 | 70% | Rare 85, Epic 15 | |
| Toy Factory | Vault | 52 | 55% | Epic 95, Legendary 5 | 180 s |
| Space Lab | Floor | 27 | 90% | Common 85, Rare 15 | |
| Space Lab | Guarded | 40 | 65% | Rare 85, Epic 15 | |
| Space Lab | Vault | 60 | 50% | Epic 95, Legendary 5 | 240 s |

Spawn weights are per-slot rolls that cost nothing to the player. They are *not* paid random items. Odds are shown in the Robodex anyway, because players like knowing what they're chasing.

## Simulation

### Method

The sim plays 200 runs per player profile for 30 in-game days:
- Each step the player picks the heist with the best expected value per second, counting the Getaway Bonus, scrap, the gain over their weakest pad (valued over 10 minutes), and how much an unseen robot helps complete a Robodex page.
- Failure costs 60% of the trip and the robot goes home.
- Purchases: gates and vaults first when affordable (players save for new places), otherwise the cheapest affordable upgrade (how most kids actually shop).
- Between sessions the Cash Bin fills to its cap.
- The first steal is a guaranteed Toasty after 40 s of tutorial.

Profiles:

| Profile | First session | Then daily | Escape chance | Trip time |
|---|---|---|---|---|
| casual | 15 min | 10 min | x0.85 | x1.25 |
| average | 20 min | 15 min | x1.00 | x1.00 |
| engaged | 30 min | 40 min | x1.08 | x0.90 |

### Results (final tuning, median play time and day; a % means only that share of runs got there within 30 days)

| Milestone | casual | average | engaged |
|---|---|---|---|
| first robot | 0:40 (d1) | 0:40 (d1) | 0:40 (d1) |
| first Rare | 1:36 (d1) | 1:08 (d1) | 1:05 (d1) |
| first purchase | 1:50 (d1) | 1:36 (d1) | 1:30 (d1) |
| first Epic | 3:45 (d1) | 2:42 (d1) | 2:22 (d1) |
| Junkyard vault | 3:44 (d1) | 3:07 (d1) | 2:44 (d1) |
| Toy Factory | 15:30 (d2) | 20:07 (d2) | 19:50 (d1) |
| first Toy Factory Epic | 23:19 (d2) | 22:43 (d2) | 22:09 (d1) |
| Junkyard Legendary | 37:03 (d4) | 30:47 (d2) | 30:17 (d1) |
| Toy Factory vault | 35:45 (d4) | 35:28 (d3) | 31:09 (d2) |
| Gigabear (TF Legendary) | 1h31 (d9) [98%] | 1h33 (d6) [99%] | 1h21 (d3) |
| Space Lab | 2h18 (d14) | 2h22 (d10) | 2h35 (d5) |
| Space Lab vault | 4h39 (d27) [97%] | 5h05 (d20) | 6h02 (d10) |
| Nova (SL Legendary) | 4h53 (d29) [35%] | 5h31 (d22) [49%] | 6h43 (d11) [73%] |
| every robot | 4h51 (d28) [34%] | 5h31 (d22) [48%] | 6h44 (d11) [73%] |
| max pads (16) | not in 30 days | not in 30 days | 11h56 (d19) |

Where income came from (whole 30 days):

| Profile | Passive | Getaway Bonus | Scrap | Offline | Base income d1 / d3 / d7 / d14 / d30 |
|---|---|---|---|---|---|
| casual | 20% | 20% | 0% | 59% | $150 / $1.4k / $3.1k / $15k / $34k per s |
| average | 23% | 31% | 0% | 46% | $180 / $2.4k / $3.9k / $19k / $43k per s |
| engaged | 29% | 49% | 0% | 22% | $1.3k / $4.0k / $19k / $48k / $52k per s |

### What the sim changed

| Run | Problem found | Change |
|---|---|---|
| 1 | Offline earnings were 85-95% of all cash (uncapped hours of offline income). The whole game was done in about 1 hour. Nobody went back for the Junkyard legendary, so no run completed the collection. | Cash Bin capped at 10-30 min. Added the Getaway Bonus. Added the Robodex +10% bonus. Flattened income tiers. |
| 2 | Active play now 35-51% of income, but content still ran out at about 3.5 h. The Junkyard vault opened at 2:27, a little early for the "big goal" beat. | Raised gates and late pads, lowered legendary weights, longer vault restocks, vault door to $2,500. |
| 3 | First five minutes on target. A 3-hour stretch with nothing new between the Toy Factory vault and Space Lab; Nova so rare that 75% of engaged players never got it. | Space Lab gate 60M → 30M, Nova weight 3% → 5%, restock 300 s → 240 s, cheaper last pads. |
| 4 (final) | See results above. | |

### Known issues and next tuning pass

1. **Wall: Space Lab unlock (2h22) → Space Lab vault (5h05) for average players.** 2h40 with only pad and gear purchases. Proposed: vault 300M → 120M, then re-run. Unverified; do it before Update 1 ships, since Space Lab is not in the MVP.
2. **Scrap is 0% of income.** That's fine: scrap exists as feedback ("+$480") so a wasted steal never feels like nothing. Don't raise it into a money source.
3. **Offline is 46-59% for players who play 10-15 min a day.** Accepted: it is the welcome-back hook and keeps casual players progressing. Engaged players rely on heists (offline 22%). Don't raise the cap above 30 min without re-running.
4. **Escape chances and trip times are guesses.** Replace them with real playtest numbers after M3/M4 (caught rate and average trip time per zone), then re-run.
5. **The agent plays well.** It always picks the best heist. Real kids waste time, so real pacing will be somewhat slower. Expect that and compare with playtest timings before adding friction.

## Rebirth

Not at launch. A rebirth resets progress for a permanent bonus. It suits idle games, but here it would wipe the collection players are proudest of. Revisit when real engaged players reach max pads (sim: about 12 hours of play). If added, the candidate design is a "Reboot" that resets cash, pads and gear but keeps the Robodex, cosmetics and one favourite robot, for +25% permanent income per Reboot.

## Config layout (for Codex)

| File | Holds |
|---|---|
| `src/Shared/Config/Robots.luau` | id, display name, facility, tier, income, quirks, model name |
| `src/Shared/Config/Facilities.luau` | gate cost, vault cost, zones (weights, restock, spawn counts), guard settings |
| `src/Shared/Config/Upgrades.luau` | pads, Speed Shoes, Grip Gloves, Cash Bin: cost and effect per level |
| `src/Shared/Config/Economy.luau` | start cash, start pads, getaway seconds, scrap seconds, bin minutes, dex bonus, carry speed, grip window |

Once `Config` exists, change `tools/economy-sim.luau` to `require` it instead of keeping its own copy of the numbers.
