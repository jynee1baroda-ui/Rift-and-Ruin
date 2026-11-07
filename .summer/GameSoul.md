# Rift & Ruin — Game Soul

## The Pitch
An isometric, click-to-move action RPG in a volcanic wasteland split by lava rifts. You play the Blood Sorceress: every spell is paid for with her own life. Clear monster packs, collect relics, and step into the next, harder rift layer. There is no final victory — only the next layer.

## Look
- Palette: near-black basalt and dark violet shadow, broken by amber, crimson and electric gold.
- Ground: fractured basalt plates with thin molten seams. Lava rivers cut the arena into islands joined by narrow stone bridges. Lava is a living hazard, not decoration.
- Lighting: warm key light, violet fill from above, volcanic fog and volumetric haze, strong bloom on magical seams and lava.
- Ability VFX read as hard-edged blood-red rings, discs and ember bursts.
- UI: dark stone plates with amber borders, crimson vitae, gold legendary text. Vitae bar sits above the ability row; each ability card shows its life cost.

## Feel
- Every spell costs health. The player lives on the edge of their own death spiral.
- Lava plates burn; eruptions telegraph and explode. Standing still is punished.
- The camera sits high enough to read the next bridge and the lava river ahead, with the hero lit clearly at the centre.
- Packs aggro at 13 m, so fights are deliberate and readable instead of a screen-wide swarm.

## Core Loop (implemented)
1. Random connected cave layout of stone plates over lava; rivers and pools are carved through it, a river always cuts the ground north of the spawn, and the disconnected islands are rejoined with narrow stone bridges.
2. Packs of cultists, wolves, crawlers and slingers spawn away from the player. From layer 2 a Hushed Prophet boss joins.
3. Killing drops colour-coded relics and life orbs. Walking over a relic shows a stat comparison card; click the card (or Enter) to bind it to the single relic slot.
4. Clearing every pack opens a rift gate. Stepping into it starts the next layer: more enemies, more HP and damage, better rarity odds.
5. Death ends the run and shows the layer reached; R revives at layer 1 keeping the relic.

## Classes and Abilities
Only the Blood Sorceress is playable.
- 1 Blood Nova — AoE detonation around the player, 9 life.
- 2 Crimson Lance — piercing blood spear toward the cursor, 5 life.
- 3 Sanguine Siphon — 2 s drain on nearby foes that heals a share of damage.
- Space Riftstep — dash toward the cursor, invulnerable during the dash, can cross lava.

## Legendary Relics (one slot, they change how a skill works)
- Bloodmoon Crown: Blood Nova costs no life and is 55% wider.
- Riftfang Diadem: Crimson Lance pierces and fires three lances.
- Sanguine Chalice: Sanguine Siphon drains and heals twice as much.
- Emberwake Sigil: Riftstep ends in a burning detonation.

## Decisions on the open questions
- Prestige: stats only (not in the first playable).
- Rifts are not timed; pressure comes from scaling and lava hazards.
- Solo, self-found; no trading.
- Three active ability slots plus a movement dash.

## Tech Map
- `res://main.tscn` — WorldEnvironment, sun/rim/fill lights, camera, game root.
- `scripts/game.gd` — floor generation, mesh building, spawning, combat resolution, loot, portal, HUD wiring.
- `scripts/player.gd` — Blood Sorceress movement, life-cost abilities, stats and relic effects.
- `scripts/enemy.gd` — pack AI (aggro, pathing, windup attacks, HP bars, death).
- `scripts/hud.gd` — vitae bar, ability cooldowns, relic panel, comparison card, toasts, death screen, title.
- `scripts/item_db.gd` — rarities, mods, legendaries, formatting.
- `scripts/fx.gd`, `scripts/projectile.gd`, `scripts/loot.gd`, `scripts/hazard.gd` — effects, blood bolts, drops, lava eruptions.
- `shaders/basalt.gdshader`, `shaders/lava.gdshader`, `shaders/portal.gdshader` — world look.
- Assets: Summer Library `dungeon-dark-fantasy` (monsters, pillars, braziers, pots), generated Blood Sorceress character, generated basalt rocks and rift gate, generated music/ambience/SFX.

## Attribution
- Dungeon kit props and monsters: Summer curated `dungeon-dark-fantasy` collection (CC0 kit by SigilsVault; monsters Summer licence).
- Blood Sorceress, rift gate, basalt rocks: Summer generated assets.
- Audio: Summer generated (ElevenLabs).
