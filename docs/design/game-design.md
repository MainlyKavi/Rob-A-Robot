# Rob a Robot: game design

Status: blueprint v1 (2026-11-02), waiting for the user's approval before implementation starts.
Numbers live in [economy.md](economy.md) and, once built, in `src/Shared/Config/`. This doc says *what* and *why*.

Related docs: [economy](economy.md) · [monetization](monetization.md) · [research and evidence](research.md) · [technical architecture](technical-architecture.md) · [roadmap](../tasks/roadmap.md) · [first milestone](../tasks/m1-steal-loop.md)

## 0. The core decision

**Robbing NPC robots is the core mechanic.** Every robot a player owns was stolen. Cash never buys a robot. It buys the *ability to steal better robots*: gear, vault doors, new facilities and more display pads. Passive income pays for that, so idle time feeds the next heist instead of replacing it.

This answers the old open questions from the first draft of this doc:

| Old question | Decision |
|---|---|
| How does a robot get robbed? | Hold a prompt for 1 s, carry it home through the facility's security, drop it in your Home Zone. Each robot fights back in its own way (section 4). |
| Offline earnings? | Yes, capped. Robots fill a Cash Bin while you're away, up to 10 minutes of income (upgradeable to 30). |
| Rarity and how robots are obtained? | Four tiers plus Secrets. Robots spawn on slots in NPC facilities. Rarer slots are harder to rob. No eggs, crates or paid randomness. |

### Where the original concept was weak, and what fixes it

| Weakness | Why it matters | Fix |
|---|---|---|
| "Steal a ___" is the most cloned format on Roblox. | A third-party count found about 3,300 "Steal a" clones by June 2026. Roblox says games whose metadata and place files closely resemble existing games are no longer prioritized for recommendations. | No conveyor shop. NPC heists, robots that fight back, original art. A 5-second clip must not look like Steal a Brainrot. |
| "Walk, hold E, walk back" is dull by minute ten. | Random rewards alone don't carry a session. | Every robot has a Getaway Quirk. Three slot types with rising risk. One hazard per facility. Server events. |
| Waiting beats playing. | In the first economy sim, offline earnings were 85-95% of all cash. | Getaway Bonus on every escape and a capped Cash Bin. Sim now: active heists bring 31-49% of income. |
| Losing robots to other players drives kids away. | Clips of upset kids whose characters were stolen were Steal a Brainrot's worst press. | **Robots always come home.** PvP borrows a robot for 10 minutes and never takes it. |
| Old areas become worthless. | In the sim, players skipped the Junkyard legendary once the Toy Factory opened. | Completing a facility's Robodex page gives +10% income forever. |
| Shared NPC spawns turn a full server into a race. | The youngest player never wins the vault. | Personal spawns: every player sees and robs their own copy of each facility's robots. |

## 1. Game vision

**One sentence:** Sneak into robot factories, grab robots that fight back, and carry them home to build a cash-printing robot collection.

**One paragraph:** Rob a Robot is a light heist-and-collect game. Across the street from your base sit robot facilities full of bots that panic, wriggle and beep when you grab them. Each heist takes 15 to 60 seconds: pick a target, dodge a security sweeper, grip the robot when it tries to escape, and get home before the alarm shutters drop. Robots on your pads earn cash every second. You spend that cash on faster shoes, stronger gloves, vault doors and new facilities with rarer, sillier robots. It plays fully solo, every session ends with something new on your pads, and other players are an optional extra, never a threat to your collection.

Tagline in-game: **STEAL ROBOTS. GET RICH. UPGRADE.** (Keep "get rich" out of store metadata, see section 12.)

## 2. Core gameplay loop

```
        ┌──────────────────────────────────────────────────────┐
        │ 1. SPOT    a robot (rarity beam shows value)         │
        │ 2. STEAL   hold 1 s; it panics, you carry it         │
        │ 3. ESCAPE  grip it when it wriggles, dodge security  │
        │ 4. HOME    drop it on a pad: Getaway Bonus + collect │
        │ 5. EARN    pads earn $/s, Cash Bin fills             │
        │ 6. UPGRADE shoes, gloves, pads, vault, new facility  │
        └────────────────────────── back to 1 ─────────────────┘
```

- **Short loop (15-60 s):** one heist. Every successful one pays a Getaway Bonus and usually a better robot.
- **Medium loop (5-20 min):** fill pads, buy the next upgrade, open a vault.
- **Long loop (days):** unlock facilities, complete Robodex pages, chase legendaries, secrets and variants.

Rules that keep it tight:
- One currency: **Cash**.
- Carry one robot at a time.
- Pads full? A new robot replaces your weakest if it's better; otherwise it's scrapped for a little cash. No inventory screen.
- Collecting is automatic when you step into your Home Zone, with a cash burst and a "cha-ching".

## 3. The first five minutes

The sim times below are for an "average" player (see [economy.md](economy.md#simulation)).

| Time | What happens | Sim |
|---|---|---|
| 0:00-0:30 **Discover** | You spawn on your own base: 4 empty pads with holographic "?" outlines. Across a short street stands the Robot Tower; through its open door, on the Junkyard floor, a Toasty sits under a grey beam. Grabby, the mascot, says in a speech bubble: "Those robots? Let's borrow one." A glowing path leads there (about 40 studs). The objective banner reads STEAL ROBOTS. GET RICH. UPGRADE. | |
| 0:30-1:00 **First robot** | Walk up and hold STEAL. Toasty's screen face flips to panic, it squeals and pops toast. Carry it home along the path, step into the Home Zone: it hops onto a pad, cash ticks up (+$2/s), coins burst, "cha-ching". | first robot 0:40 |
| 1:00-2:00 **First upgrade** | Two or three more quick floor heists. A blue beam in the Junkyard means a Rare. Speed Shoes ($150) and a 5th pad ($250) light up in the shop. Buying shoes makes the next trip visibly faster. | first rare 1:08, first purchase 1:36 |
| 2:00-3:30 **First exciting moment** | The Guarded Wing: a Sweeper Bot patrols with a flashlight cone. Bolt Pup (Rare) is Wriggly: halfway home the GRIP! button flashes; tap it or the pup hops free and scampers back. If the sweeper spots you, a siren goes off and it chases. If it touches you: ZAP, the robot runs home and you're bounced to the exit. No damage, no death. Escaping pays a bigger Getaway Bonus. | first epic 2:42 |
| 3:30-5:00 **First big goal** | The Vault: a door reading UNLOCK VAULT $2,500, and through the glass a gold beam: Crusher, the Junkyard Legendary. Lifting a vault robot sets off an alarm: 15 seconds to get out before the shutters drop. Across the street the Toy Factory gate reads $150,000, with Robo-Rex and Gigabear dancing behind glass. The Robodex pops up: "Junkyard 4/7. Complete it for +10% cash forever." | vault unlocked 3:07 |

What happens next (average player): Toy Factory at about 20 minutes, right as session 1 ends or at the start of session 2 when the Cash Bin pays out. That is the reason to come back tomorrow.

## 4. Signature mechanic: Robots Fight Back

Every robot reacts to being stolen through a **Getaway Quirk** and a **panic face** on its screen. This is what a thumbnail and a five-second clip show: a player sprinting with a panicking robot under one arm while it wriggles, beeps or drags them down.

Why this one: it makes the core action (stealing) better instead of adding a new system beside it. It scales difficulty with rarity for free. It creates funny, shareable moments. It is cheap to build: quirks are a handful of reusable behaviours, configured per robot.

### Launch quirks (four behaviours)

| Quirk | What the player feels | Counter | Build cost |
|---|---|---|---|
| **Chill** | Nothing. Commons, tutorial. | none | none |
| **Heavy** | Carry speed -25%, longer hold to grab. | Speed Shoes | one multiplier |
| **Wriggly** | Every 4-6 s it tries to jump free. A big GRIP! button flashes for about 1.2 s. Miss it and the robot hops out and runs back toward its slot; you can grab it again if you catch it. | Grip Gloves (wider window, fewer wriggles) | server timer + one remote + one button |
| **Noisy** | Beeps every few seconds. Each beep pulls nearby Sweeper Bots toward you. | Take the long way, move fast | reuse guard "investigate" state |

Rares get one quirk, Epics one strong quirk, Legendaries two. Post-launch quirks (only if data says heists feel samey): Floaty (low-gravity hops, a fun buff), Runner (blasts off when it escapes), Glitch (teleports a few studs in your arms, Secret only).

Panic faces: each robot model has a face plate with 3 expressions (calm, panic, happy-on-pad), swapped by texture. Players read personality instantly at no animation cost.

## 5. Robot system

### Rarity

| Tier | Colour | Where it spawns | Feel |
|---|---|---|---|
| Common | grey | facility floor | quick, safe, tutorial |
| Rare | blue | floor (15%), guarded wing | first real challenge |
| Epic | purple | guarded wing (15%), vault | "I need that" |
| Legendary | gold | vault only (5-8%) | chase item, two quirks |
| Secret | glitch magenta | events only | bragging rights |

Four visible tiers plus one hidden. No "Uncommon", no "Mythic+Ultra". Each tier is about 2.5-4x the income of the one below inside a facility, and each facility's Common earns about as much as the previous facility's Epic. So a new facility always feels like a step up, and old robots stay useful as Robodex entries.

**Variants (post-MVP):** any robot can spawn **Gold** (1 in 20, 2x income) or **Rainbow** (1 in 150, 5x income). One material swap plus particles per variant. These are the "show my friends" moments and the long tail after the Robodex is full.

### Robot concepts (25)

Income numbers are the simulated values in [economy.md](economy.md). L = launch, M = MVP, U = post-launch update, F = future idea.

| # | Robot | Facility | Tier | Quirk | Identity (look, behaviour, sound) | Ship |
|---|---|---|---|---|---|---|
| 1 | Toasty | Junkyard | Common | Chill | Chrome toaster on legs. Pops toast when grabbed. Tutorial robot. | M |
| 2 | Mopsy | Junkyard | Common | Chill | Mop-head cleaner bot that leaves soap bubbles. Hums a cleaning song. | M |
| 3 | Trashy | Junkyard | Common | Heavy | Trash-can bot, lid flaps like a mouth when it complains. | M |
| 4 | Bolt Pup | Junkyard | Rare | Wriggly | Robot puppy, wagging antenna tail, yips. | M |
| 5 | Clank Crab | Junkyard | Rare | Wriggly | Scrap crab, scuttles sideways when it escapes. | M |
| 6 | Sir Rustalot | Junkyard | Epic | Heavy (Noisy once it ships) | Rusty knight; armour clanks loudly with every step. | M |
| 7 | Crusher | Junkyard | Legendary | Heavy + Wriggly | Compactor mech carried over your head. Yells "CRUSH!" | M |
| 8 | Windy | Toy Factory | Common | Chill | Wind-up toy, legs keep walking in your arms. | L |
| 9 | Jack | Toy Factory | Common | Noisy | Jack-in-the-box bot, springs out and honks. | L |
| 10 | Plushbot | Toy Factory | Rare | Noisy | Fluffy robot that squeaks when squeezed. | L |
| 11 | Yo-Yo Bot | Toy Factory | Rare | Wriggly | Yo-yos itself out of your hands. | L |
| 12 | Robo-Rex | Toy Factory | Epic | Wriggly | Toy T-rex robot, tiny arms, big roar. | L |
| 13 | Disco Dan | Toy Factory | Epic | Noisy | Disco-ball head; music and lights pull guards in. | L |
| 14 | Gigabear | Toy Factory | Legendary | Heavy + Wriggly | Giant teddy mech. Hugs you. Hard to carry. | L |
| 15 | Moon Rover | Space Lab | Common | Chill | Six-wheeled rover, dish antenna spins. | U |
| 16 | Astro Pup | Space Lab | Common | Chill | Bolt Pup's space cousin in a fishbowl helmet. | U |
| 17 | Satellite Sally | Space Lab | Rare | Noisy | Solar-panel wings, beeps in morse. | U |
| 18 | Comet Kid | Space Lab | Rare | Wriggly | Fiery tail, zips around when free. | U |
| 19 | Rocket Rick | Space Lab | Epic | Wriggly | Rocket bot, launches straight up if it escapes. | U |
| 20 | Star Smith | Space Lab | Epic | Heavy | Forge bot hammering a tiny star. | U |
| 21 | Nova | Space Lab | Legendary | Wriggly + Noisy | Glowing star-core robot, lights the whole vault. | U |
| 22 | Error 404 | any (events) | Secret | Glitch | A robot that renders wrong: flickers, teleports, speaks in error beeps. | L |
| 23 | Golden Grabby | reward | Secret | (not stealable) | Gold mascot statue for completing every launch Robodex page. | L |
| 24 | Vendy | future | Rare | Runner | Vending-machine bot that drops coins as you run. | F |
| 25 | Professor Sprocket | future Secret Lab | Legendary | Glitch | Mad-scientist bot with a jar-brain head. | F |

**Recommended rosters**
- **MVP: 7 robots** (Junkyard 1-7). That is the smallest set that tests every slot type, every launch quirk and a legendary chase.
- **Launch: 16** (Junkyard + Toy Factory + Error 404 + Golden Grabby).
- **Update 1, about 1-2 weeks after launch: Space Lab** (7 robots), built before launch and held back. The economy already simulates all three facilities.

### Ownership and income
- A robot exists as `{ id, variant }` in the owner's save. It has exactly one owner, always (see [technical-architecture.md](technical-architecture.md)).
- Income = robot base income × variant multiplier × (1 + 0.10 per completed Robodex page) × pass multiplier (if ever approved).
- The server ticks income into the Cash Bin once per second for all players in one loop.

### Keeping old collections valuable as new robots arrive
1. Robodex bonuses are permanent and stack. An old facility's page keeps paying forever.
2. New facilities add power at the top. They never nerf old robots.
3. Gold and Rainbow variants of old robots are new chases.
4. Events re-feature old facilities ("Junkyard Rush: Gold chance x3 this weekend").
5. Cosmetics are never power, so nothing cosmetic goes stale.

## 6. NPC heist system (solo core)

### Facility layout (each facility uses the same template)

| Zone | Slots | Spawns | Risk | Restock |
|---|---|---|---|---|
| Floor | 8 (two by each door) | 85% Common, 15% Rare | none | 5 s |
| Guarded Wing | 2 | 85% Rare, 15% Epic | Sweeper Bot patrol | 15 s |
| Vault | 1 | Epic, or a Legendary 5-8% of the time | paid door + alarm escape | 90-240 s |

Plus one **facility hazard** for flavour: Junkyard has a swinging scrap claw, Toy Factory moving conveyor belts, Space Lab low-gravity pads and laser sweeps.

### Personal spawns
Each player's facility slots are their own. The server keeps per-player slot state and tells only that client what sits on each slot. The client draws the robot locally. So 1 player and 8 players get the same experience, nobody snipes your vault, and robot models in facilities cost the server nothing. Sweeper Bots are shared server NPCs. Carried robots are server models, visible to everyone.

### Sweeper Bots (guards)
- Patrol a loop of waypoints with a flashlight cone (about 30 studs, 60°).
- They only care about players **carrying** a robot. Empty-handed players can walk anywhere: scouting is free and kid-friendly.
- Spotted: siren, chase at carry speed + 2 studs/s for up to 8 s or until line of sight breaks. Touch = **ZAP**.
- **Caught:** the robot pops out and runs back to its slot. The player is bounced to the facility exit with a cartoon spin. No health, no damage, no death. That keeps the content maturity rating at Minimal (see [research.md](research.md)).
- Budget: at most 2 sweepers per facility, server-driven, simple state machine (patrol → investigate → chase → return), updated at 5-10 Hz.

### Vault
- One-time paid door per facility (Junkyard $2,500).
- Lifting the vault robot starts the alarm: red lights, klaxon, a 15 s countdown, and shutters at the facility exit. Not out in time = caught.
- After a successful vault steal, the vault restocks on a cooldown (90 s at the Junkyard), shown on the door. Floor and guarded heists fill the wait.

### Difficulty curve
Average-player escape chances in the sim: floor 97%, guarded 75%, vault 60% at the Junkyard, dropping to 90/65/50% in the Space Lab. Grip Gloves add +4% per level on guarded and vault. Target caught rates for playtests: floor under 5%, guarded 20-30%, vault 35-50%. If real players miss these, tune guard speed, cone size and grip window in config.

### Getaway Bonus
Every successful escape pays a bonus worth 10 s (floor), 25 s (guarded) or 60 s (vault) of your base income. It is the main reason robbing beats waiting: in the sim, a player who keeps heisting earns about 2.3-2.7x per minute what a player idling at base does.

## 7. Multiplayer (optional layer, after the solo MVP is fun)

**Principle: robots always come home.** Nobody ever permanently loses a robot to another player.

- **Raid Mode** is opt-in, toggled at your base. You can only raid players who also have it on. Turning it off needs you to be at your base and 2 minutes since your last raid action, so nobody can dodge mid-chase.
- Unlocks after you own the Toy Factory. Brand-new players can't raid or be raided.
- **Borrowing:** steal a robot from another Raid Mode player's pad and carry it home. It works on *your* pad for 10 minutes, then escapes and walks back to its owner. Ownership never changes; only a temporary "borrowed by" marker does, kept in memory. If the server shuts down, the robot is simply home.
- The thief gets a Raid Getaway Bonus (larger than an NPC one). The victim loses that robot's income for up to 10 minutes and can grab it back early from the thief's base.
- **Protections:** your 3 best robots can never be borrowed. After being raided, a 5-minute shield. The same thief can raid the same victim at most once every 15 minutes. Spawn and Home Zones are safe zones. Each base has a Lock button (45 s laser door, 3-minute cooldown).
- No trading. Trading invites scams, duplication bugs and paid-item trading rules, and adds nothing to the heist loop.

Why this design: it keeps the thrill of raiding a real player and of defending your base, takes away the reason to bully, and kills the classic dupe-and-loss bugs because ownership never moves.

## 8. Economy

Full numbers, assumptions and simulation output: [economy.md](economy.md). Summary:
- Start: $0, 4 pads, first robot guaranteed by the tutorial.
- Sources: robot income (passive), Getaway Bonus (active), offline Cash Bin (10-30 min cap), scrap.
- Sinks: pads (4 → 16), Speed Shoes, Grip Gloves, Cash Bin, vault doors, facility gates.
- Simulated pace (average player, 20 min then 15 min/day): Toy Factory about 20 min, Space Lab about 2h20, Space Lab vault about 5h, full Robodex about 5.5h (49% of average players within 30 days).
- No rebirth at launch. Revisit when engaged players hit max pads (sim: about 12 h of play).

## 9. Monetization

Full product list: [monetization.md](monetization.md). **Nothing is enabled until the user explicitly approves each product** (AGENTS.md rule 12). Direction: a 2x Cash pass, a mostly cosmetic VIP pass, convenience passes, a server-wide Heist Hour boost (fixed, non-random), cosmetics, and income-scaled cash packs. No paid random items, no PvP power, no fake scarcity.

## 10. Retention and replayability

The game must be fun with no timers at all; these sit on top.

| Feature | Why players return | When | Cost |
|---|---|---|---|
| Robodex pages with permanent +10% bonus | Completion goal with a real reward | MVP (Junkyard page) | low |
| Capped Cash Bin | "Welcome back, $X waiting" | MVP (M2) | low |
| Visible next goal | Locked gate with robots dancing behind glass | MVP | low |
| Rare Robot Alert | Every 15 min in-server: vault restock and boosted legendary chance for 2 minutes, Error 404 possible | post-MVP | low |
| Gold and Rainbow variants | Long tail, shareable | post-MVP | low |
| Heist Contracts | 3 daily goals ("escape 2 alarms") for cash. No streak punishment. | post-launch | medium |
| Content cadence | A new facility or robot batch every 1-2 weeks | live ops | ongoing |
| Weekend events | Facility-themed boosts | live ops | low |

Skipped: login-streak penalties, battle passes at launch, trading, guilds.

## 11. World design

**The Robot Tower.** One chunky tower stands in the middle of the map; each floor is a facility. Eight bases ring it, two facing each of its four doors.

```
              [B1]  [B2]
                 \  /
        [B8]  +---door---+  [B3]
           \  |          |  /
           door  TOWER   door
           /  |          |  \
        [B7]  +---door---+  [B4]
                 /  \
              [B6]  [B5]

  Top-down. Tower about 72 x 72 studs; bases about 45 studs from its walls.
  Floors: 1 Junkyard (open) · 2 Toy Factory ($150k gate) · 3 Space Lab ($30M gate)
```

- **Why a tower:** every base is about the same distance (roughly 60 studs) from a door, so no plot is worse than another and a floor heist round trip stays around 10-15 s. Progression is literally "climb the tower", and the tower is the landmark in every thumbnail and clip. Higher floors mean longer escapes, which matches the sim's longer trip times per facility.
- **Inside each floor:** Floor slots along the outer walls (two by each door, so close to every base), the Guarded Wing as an inner ring, the Vault in the core. Same order on every floor, so players learn the layout once.
- **Going up and down:** wide ramps or lift pads at the core corners, usable while carrying. The gate to a floor is a cash door at the top of its ramp.
- **8 players per server.** Fewer plots, less replication, and still lively.
- **Base:** pad grid that grows from 2x2 to 4x4 (16 pads), Home Zone strip at the front facing the tower, Lock button, name sign showing the player's display name. No player-written text on bases: free-form writing restricts a game to 16+ players.
- **Performance:** grey-box first; target under 3,000 parts in the whole map at launch, simple materials, no unions in moving parts.

## 12. Art direction, brand and discoverability

**Visual style:** bright, chunky, toy-like low-poly robots with big LED-screen faces. The face is where the personality is: calm on a slot, panic when grabbed, happy on your pad. Readable at thumbnail size and on a phone.

**Palette:** Heist Orange `#FF8A1F` (brand, CTA buttons), Bot Teal `#19C3B1` (secondary, cash), Night Navy `#1B2340` (UI panels). Rarity: Common `#B8C0CC`, Rare `#3D8BFF`, Epic `#A64DFF`, Legendary `#FFC21A`, Secret glitch magenta `#FF2BD6`.

**Mascot: Grabby.** A small round orange robot with a black bandit mask painted across its LED eyes and one oversized claw. It's your heist buddy: tutorial bubbles, signs, loading screen, the icon, and the gold statue reward.

**UI:** few, large elements. Top: cash. Bottom right: GRIP! (only when needed), Shop. Bottom left: Robodex. Icons over words. Minimum 44 px tap targets, scale-based sizing with `UIScale`.

**Sound:** each robot gets a short pitch-shifted beep voice; panic squeal on grab; cartoon klaxon; "cha-ching" on Home Zone. All audio made in-project or from Roblox's own first-party library, never unverified uploads.

**VFX:** rarity beams over slots (seen from the street), coin burst on collect, speed lines while carrying, shutter slam on vault alarm.

**Thumbnail concept:** one player sprinting at the camera with a panicking Toasty under their arm, a Sweeper Bot with a red siren behind, cash flying. Logo "ROB A ROBOT" in chunky orange with Grabby's mask. Three elements, readable at 150 px. It must show real gameplay (Roblox requires thumbnails to reflect the game, and personalization tests are only allowed with accurate thumbnails).

**Store description (draft):**
> Sneak into robot factories and grab robots that fight back! Every robot panics, wriggles or beeps when you steal it. Dodge security bots, escape vault alarms and carry your loot home. Your robots earn cash while you plan the next heist. Unlock new factories, complete your Robodex, and find the legendary bots. Play solo or switch on Raid Mode with friends. Robots always come home!

Avoid phrases that suggest real money or Robux rewards in the title, description or thumbnails: Roblox does not prioritize metadata that implies monetary rewards.

**Shareable moments (YouTube/Shorts):** a robot wriggling free at the last second; a vault alarm escape with shutters closing behind you; a Rainbow robot reveal; Crusher carried over a tiny avatar's head; "my robot came home" PvP clips. Creator-friendly touches: a camera mode toggle later, distinct robot sounds, big readable reactions.

## 13. MVP scope

The MVP proves one thing: **is stealing robots fun enough to repeat for 15 minutes alone?**

In: one base plot (8 plots in the map), the Junkyard (Floor, Guarded Wing, Vault), 7 robots, 3 quirks (Chill, Heavy, Wriggly), one Sweeper Bot, vault alarm, Getaway Bonus, 4-8 pads with replace/scrap, Speed Shoes and Grip Gloves, Cash Bin with offline cap, saving and loading, a minimal HUD, guided first heist, sounds and basic VFX, Junkyard Robodex page, Toy Factory gate (visible, locked).

Out: Toy Factory contents, Space Lab, Noisy quirk, facility hazards, variants, events, contracts, Raid Mode, monetization, trading, rebirth, multiple currencies, combat.

Milestones, acceptance criteria and who does what: [roadmap.md](../tasks/roadmap.md).

## 14. Technical architecture

See [technical-architecture.md](technical-architecture.md). In short: one server module per system (data, economy, robots, bases, heists, security), one `Remotes` module, config in `src/Shared/Config/`, a single session-locked DataStore module, per-player spawns drawn on the client, all ownership and money on the server.

## 15. Development roadmap

See [roadmap.md](../tasks/roadmap.md): M0 setup fixes, M1 steal loop, M2 saving, M3 heist challenge, M4 upgrades, HUD and tutorial (= MVP playtest), then content, events, multiplayer, launch prep.

## 16. Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Looks like another "Steal a" clone, gets no recommendations | high | NPC heist identity, panic faces, original art, no conveyor shop. Thumbnail shows a heist, not a base. Review the first 5-second clip against this before launch. |
| Heists get repetitive after 20 minutes | medium | Quirk mix per facility, hazards, Rare Robot Alerts, variants. Measure heists per session and session length in playtests. |
| Walking feels like dead time, worst on mobile | medium | Robot Tower layout keeps every base about 60 studs from a door; Speed Shoes as first purchase; round trips 10-60 s. |
| Waiting beats playing | medium | Getaway Bonus, Cash Bin cap. Sim-checked; re-check with real analytics. |
| Mid-game wall | medium | Sim found a 2h40 gap between Space Lab unlock and its vault. Fix proposed in economy.md before Update 1. |
| Exploits: teleport steals, remote spam, duplication | high on any hit game | Server validates distance, carry time, rate, ownership. One function adds robots. PvP never moves ownership. Security review each milestone. |
| Data loss | low-medium | Single session-locked DataStore module with retries, `UpdateAsync`, `BindToClose`, schema version. |
| Kids audience can't reach the game | medium | Under-16 accounts need an ID-verified creator, 2FA, the maturity questionnaire, a Kids fee or Premium, and an evaluation (250 highly engaged plays in 60 days). Plan it into launch prep. |
| Scope creep for a solo developer | high | MVP gate: no new systems until the MVP playtest passes. |
| Monetization feels pay-to-win | medium | Rules in monetization.md. User approves each product. |

## 17. Success metrics

Full table with benchmarks and sources: [research.md](research.md#benchmarks). Targets:

| Metric | Private test target | Launch target | Benchmark (GameAnalytics 2026, games with 1M+ MAU) |
|---|---|---|---|
| First steal within 60 s | 90% of new players | 85% | our own target |
| Tutorial (first deposit + first purchase) done | 80% | 75% | our own target |
| Average session length | 15 min | 12 min | median 9.8, p75 12.0, p90 14.7 |
| D1 retention | qualitative | 13% (aspirational 16%) | median 10.3%, p75-p90 12.9-15.9%, p99 22.2% |
| D7 retention | n/a | 3% (aspirational 5%) | median 1.6%, p99 9.1% |
| Payer rate | n/a | 2-4% over 30 days (only after monetization approval) | 3.8% of tracked players paid over 12 months |

Instrument from M4 onward with `AnalyticsService`: onboarding funnel (join → first steal → first deposit → first purchase → guarded steal → vault unlock → Toy Factory), economy events (every source and sink), and custom events (caught by zone, wriggle escapes, heist duration, session end reason). What to act on is listed in [research.md](research.md#what-to-measure-and-what-to-do-about-it).
