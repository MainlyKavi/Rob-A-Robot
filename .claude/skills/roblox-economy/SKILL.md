---
name: roblox-economy
description: Balance Rob a Robot's economy. Use when setting or changing robot prices, income rates, rarity weights, upgrade costs, rebirth/prestige, offline earnings, steal rewards, or when evaluating any monetization idea.
---

# Roblox economy balancing (Rob a Robot)

All tunable numbers live in `src/Shared/Config/`. Balance by changing config, not logic.

## Model it before changing it

Build a small table, in the reply or as a Luau/PowerShell calculation, with one row per robot or tier:
`price`, `income/sec`, `payback time = price / income`, `time to afford from previous tier's income`.

Targets for a simple idle/collect game (adjust with the user):
- First purchase within ~30 s. First new tier within ~3-5 min.
- Payback time grows slowly per tier (for example x1.2-1.5), never shrinks. A tier with a shorter payback than the one before makes everything below it pointless.
- Time-to-next-tier stays roughly flat or grows gently. A sudden jump is a wall where players quit.

## Curves

- Prices: geometric, `base * growth^n`, growth usually 1.5-3 per tier. Upgrade costs per level: `base * 1.15^level`-style.
- Income should grow slower than price, which keeps progression meaningful and stops runaway inflation.
- Upgrades: show the marginal value (`income gained / cost`) per level. It must stay worth buying but decline.
- Rarity: weights sum to 100. Expected value of a crate/egg = sum(weight x robot value) / 100. Compare it to the price of buying directly; random should not be strictly better or strictly worse.

## Sinks and inflation

Every source of cash needs a sink (new tiers, upgrades, base expansion, rebirth). Check for:
- Loops that print money (buy -> sell for more, steal -> resell, duplication: hand those to `roblox-security`).
- Offline earnings without a cap (cap at a few hours of income).
- Stealing that pays more than earning. The steal value should be a fraction of the robot's worth, with a cooldown, so solo players aren't punished for not stealing.

## Solo fairness

The whole progression must be completable solo at a reasonable pace. Multiplayer bonuses can speed it up but never gate it.

## Monetization

Never add Robux items without the user's approval (rule 12). When asked to evaluate an idea:
- OK: cosmetics, convenience (auto-collect), modest time-savers.
- Flag: pay-to-win steal protection or stealing power, paid currency that outscales play, loot boxes for power.
Report what it would do to the progression table above.

Always end with the table, the specific config changes proposed, and the expected effect on time-to-next-tier.
