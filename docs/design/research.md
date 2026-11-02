# Rob a Robot: research and evidence

Researched 2026-11-02. This file separates what sources show from what we are guessing, so playtests can confirm or kill each guess. Re-check policy items before launch; Roblox changes them often.

Confidence: **official** = Roblox docs or company statements; **reported** = mainstream press or Wikipedia; **third-party** = analytics blogs and fan sites (directional only).

## What the hits actually do

| Game | Observed mechanics | Evidence | Lesson for us |
|---|---|---|---|
| Steal a Brainrot (May 2025) | Buy characters from a conveyor belt or steal them from other players' bases; characters earn passive income; a base button gives a temporary shield; rebirth for multipliers; "admin abuse" events with exclusive characters. Peak 20M CCU in Aug 2025, 25.4M in Oct 2025. | reported ([Wikipedia](https://en.wikipedia.org/wiki/Steal_a_Brainrot)) | A simple, legible verb (steal) plus visible passive income spreads well on TikTok/YouTube. |
| Steal a Brainrot, criticism | "Best items only available for cash" (Polygon); automation cheats for collecting and stealing (GameRant); viral clips of upset children whose characters were stolen. | reported ([Wikipedia](https://en.wikipedia.org/wiki/Steal_a_Brainrot)) | Permanent PvP loss and pay-to-win are its weak points. Our answers: robots always come home, no paid power, server-side validation. |
| Steal a Brainrot, anti-griefing changes | Later updates changed when stolen characters drop or get deleted after owners leave. Mixed reception. | third-party fan guides (low confidence) | Even the leader had to patch PvP loss rules after launch. Design them first. |
| Grow a Garden | Plants grow while offline; seed stock rotates; weekly exclusive items; drove much of Roblox's Q2 2025 growth; peak about 21.9M CCU in July 2025. | reported ([Wikipedia](https://en.wikipedia.org/wiki/Grow_a_Garden), [Reuters via AOL](https://www.aol.com/news/roblox-raises-annual-bookings-forecast-120501339.html)); third-party for CCU and cadence ([RoLearn](https://rolearn.dev/insights/grow-a-garden-ccu-record-analysis)) | Offline progress and a fast update cadence (reported every 5-7 days) bring players back. Simple, cosy presentation is fine. |
| "Steal a ___" clones | About 3,300 clones by June 2026; in one sample of 105 live clones, one game held 92% of players. The Steal a Brainrot developers filed at least four lawsuits against imitators. | third-party ([RoWatcher](https://rowatcher.com/news/105-games-cloned-steal-a-one-holds-92-of-the-players)); reported (Bloomberg, 2026-03-24, paywalled, via search summary) | The format is saturated and winner-take-most. Copying it is a losing bet; a distinct twist is required. |
| Build, Fight, Steal (Sept 2025) | Robot-themed conveyor tycoon: buy robot parts from a conveyor, robots battle automatically on platforms, rebirth. | third-party ([Sportskeeda](https://www.sportskeeda.com/roblox-news/build-fight-steal-a-beginner-s-guide)) | Closest robot competitor. It is a Steal-a-Brainrot-style tycoon; we differentiate with NPC heists and robots that fight back. No game named "Rob a Robot" or "Steal a Robot" was found. |

## Platform rules that shape the design

| Rule | Source | Design consequence |
|---|---|---|
| Recommendations rank on many signals with play-through rate first; first-play bounce is a negative signal; only users who arrive from Recommended count at the ranking stage. | official ([Discovery](https://create.roblox.com/docs/discovery)) | The first 60 seconds matter most: a robot in your hands in under a minute. |
| Games whose metadata and place files closely resemble existing games are no longer prioritized and may rank lower in search. | official ([Discovery](https://create.roblox.com/docs/discovery)) | Original art, layout and mechanics. Don't reuse clone kits or "Steal a" naming in metadata. |
| Metadata implying any monetary reward is not prioritized. A custom thumbnail is required for homepage impressions; personalized thumbnails must accurately reflect the game. | official ([Discovery](https://create.roblox.com/docs/discovery)) | Keep "get rich" in-game only. Thumbnails show real gameplay. |
| Paid random items need real numerical odds; paid odds boosters must be explained and their odds updated live; indirect purchases count; ineligible users must be blocked or given a free path. | official ([Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)) | We sell no randomness at all (see monetization.md). |
| Brazil: under-18s cannot access paid random item mechanics. | official ([Roblox Help](https://en.help.roblox.com/hc/cs/articles/48706630819476-Brazil-Digital-ECA-Updates)) | Another reason to avoid them entirely. |
| PEGI generally rates new games with paid random items 16+. | third-party ([Out of Games](https://outof.games/news/9897-pegi-16-draws-a-new-line-around-paid-random-rewards/)) | Same. |
| Content maturity: Minimal allows occasional mild violence; Mild allows repeated mild, unrealistic violence; fear content (jump scares, creepy NPCs) is Mild. No descriptor exists for theft. Free-form user creation (drawing or writing on surfaces) limits a game to 16+. Playable gambling is not allowed. | official ([Content maturity](https://create.roblox.com/docs/production/promotion/content-maturity)) | No health or death: getting caught bounces you out. Cartoon security, no scares. No player-written text on bases. Aim for Minimal. |
| Roblox Kids (ages 5-8) and Roblox Select (9-15) accounts, rolled out from June 2026. Unverified users get a Kids account. Kids sees Minimal and Mild; Select also Moderate. | official ([Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select)); reported ([Gigazine](https://www.gigazine.net/gsc_news/en/20260414-roblox-age-based-content-access)) | Most of this genre's audience is under 16, so eligibility is a launch requirement, not a nice-to-have. |
| To reach Kids and Select: account in good standing, age-checked and ID-verified creator, 2FA, completed maturity questionnaire, (Kids) a refundable per-game fee or 2+ months of Premium/Plus, and an evaluation of 250 unique plays by highly engaged players in 60 days (games start visible only to age-checked 16+ users). Optional refundable 50,000 Robux expedited review. | official ([Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select)) | Put these on the launch checklist. Plan a soft launch to 16+ players to pass the 250-play evaluation. The doc's fee wording for Select is ambiguous; re-check at launch. |
| Chat requires an age check (from January 2026). | reported ([BusinessWire](https://secure.businesswire.com/news/home/20260107986568/en/Roblox-Requires-Users-Worldwide-to-Age-Check-to-Access-Chat)) | The game must be fun without chat: all social cues are visual (banners, emotes, robots). |
| Monetization options: passes (creator keeps 70% when selling its own passes), developer products, subscriptions, paid access, private servers, rewarded video and immersive ads, creator rewards, managed pricing. | official ([Monetize your games](https://create.roblox.com/docs/monetize-experiences)) | See monetization.md. |

## Benchmarks

GameAnalytics 2026 Roblox Benchmark Report: 500+ games with 1M+ MAU, August 2025 to July 2026 ([report](https://www.gameanalytics.com/reports/2026-roblox-report)). These games are already successful, so the median here is above the median Roblox game.

| Metric | p25 | Median | p75-p90 | p99 |
|---|---|---|---|---|
| D1 retention | 8.4% | 10.3% | 12.9-15.9% | 22.2% |
| D7 retention | 1.0% | 1.6% | n/a | 9.1% |
| D30 retention | 0.3% | 0.5% | n/a | 4.7% |
| Avg session length (min) | 7.3 | 9.8 | 12.0-14.7 | 21.1 |
| Sessions per player per day | 1.34 | 1.56 | 2.07-3.22 | 8.30 |
| ARPPU (USD) | $0.32 | $0.70 | $1.25-2.33 | $55.31 |
| Payer rate (pooled across all tracked players, 12 months) | | 3.8% | | |

Device mix of players (17,000+ games): mobile + PC 44.0%, PC only 40.8%, mobile only 11.6%, any console 3.7%. So more than half of players use a phone at least sometimes, and PC is just as important: design for touch first, test on both.

The report warns that widely quoted "good" (20%) and "excellent" (40%) D1 numbers come from small samples of promoted games. Genre tables from promotion services (for example, "Simulator 32% D1") are the same kind of number: treat them as a ceiling, not a target.

## Our hypotheses and how to test them

| # | Hypothesis | Test | Kill or change it if |
|---|---|---|---|
| H1 | Robots that fight back make heists fun to repeat. | M3 playtest: heists per session, "what was fun?" survey, watch for unprompted laughs. | Players skip Wriggly robots, or GRIP feels like a chore (low tap success, complaints). |
| H2 | A robot in hand within 60 s keeps new players. | Funnel: join → first steal time. | Under 85% steal in 60 s: shorten the path, stronger arrow. |
| H3 | Getaway Bonus makes players heist instead of idling. | Analytics: share of cash from getaway vs passive vs offline (sim says 31-49% getaway). | Getaway share under 20% for engaged players. |
| H4 | Personal spawns make full servers as fun as solo. | Compare session length and vault attempts in 1-player vs 6+ player servers. | Full servers feel empty or players want to compete for spawns (then add shared Rare Robot Alerts). |
| H5 | "Robots always come home" keeps PvP fun without rage-quits. | Raid Mode opt-in rate; churn in the session after being raided. | Opt-in under 10% (too tame) or churn spikes after raids. |
| H6 | Robodex bonuses pull players back to old facilities. | Visits to the Junkyard after the Toy Factory unlock. | Players never return: raise the bonus or add old-facility contracts. |
| H7 | 8-player servers feel lively enough. | Watch average players per server and session length. | Servers feel dead: raise to 10-12 (needs more plots). |

## What to measure and what to do about it

| Signal | Where | Action if bad |
|---|---|---|
| Funnel drop between join and first steal | AnalyticsService funnel | Shorten path, clearer arrow, fewer UI elements at spawn. |
| Drop between first deposit and first purchase | funnel | Make Speed Shoes cheaper or the shop button pulse once. |
| Caught rate by zone (targets: floor under 5%, guarded 20-30%, vault 35-50%) | custom event | Tune guard speed, cone size, alarm timer, grip window in config. |
| Average heist duration by zone | custom event | Too long: move doors closer or make Speed Shoes stronger. |
| Session length and end reason (left mid-heist vs at base) | custom event | Leaving mid-heist often means frustration; check caught rate first. |
| Cash share by source | economy events | Re-run the sim with real numbers; adjust bin cap or getaway seconds. |
| Time to Toy Factory, Space Lab | funnel | Compare with sim (20 min, 2h20); a big gap means pacing is off. |
| D1, D7, sessions per day | Creator Hub retention | Below median D1: onboarding first. Fine D1 but weak D7: midgame goals and update cadence. |
| First-play bounce on Recommended traffic | Creator Hub Home Recommendations dashboard | Fix the first 30 seconds before spending anything on ads. |

## Challenges to the original brief

1. **"Steal" puts us in the most crowded genre on Roblox.** The name stays (it is clear and distinct from "Steal a"), but gameplay and visuals must not read as a clone.
2. **Passive income and "no waiting" pull in opposite directions.** Resolved with the Getaway Bonus and a capped Cash Bin, and checked in the sim.
3. **12 players per server is more than this game needs.** Personal spawns mean more players add little to the core loop; 8 keeps plots compact and walks short.
4. **PvP is the genre's selling point and its biggest source of harm.** We keep the raid thrill and remove permanent loss.
5. **Benchmarks are not forecasts.** The numbers above describe games that already have 1M+ MAU. Most games never get there. Targets in this repo are goals to steer by, not predictions of revenue or virality.
