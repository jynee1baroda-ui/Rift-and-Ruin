# Rift & Ruin — Game Soul

## The Pitch
An isometric, click-to-move action RPG in a volcanic wasteland split by lava rifts. You play the Blood Sorceress: every spell is paid for with her own life. Clear monster packs, collect relics, and step into the next, harder rift layer. There is no final victory — only the next layer.

## Look
- Palette: near-black basalt and dark violet shadow, broken by amber, crimson and electric gold.
- Ground: fractured basalt plates using the generated cracked-lava texture at three scales over the procedural plate shader. The texture reads as rock grain and pits, dark plate seams read as bevels, and amber veins glow only inside low-frequency hot zones, so most of the floor stays dark basalt. Trench side walls are darkened so they never read as glowing slabs. Lava rivers cut the arena into islands joined by narrow stone bridges.
- Lighting: warm key light, violet fill from above, volcanic fog and volumetric haze, strong bloom on magical seams and lava.
- Ability VFX read as hard-edged blood-red rings, discs and ember bursts.
- UI: dark stone plates with amber borders, grainy gradient backdrop, crimson vitae, gold legendary text, Cinzel display face. The vitae bar has a smoothed fill, an orange damage trail and a live REGEN readout. Each ability card shows its life cost and can be clicked to cast.
- Rift map (top left): tile-accurate minimap of the floor, lava and bridges, with the player in gold, packs in red, elites in amber and the gate in violet.
- Lava reads as dark cooled crust with molten amber seams, so the pit stays legible without turning the screen orange.

## Feel
- Every spell costs health, but the price is sustainable: Nova 6, Lance 3, Siphon free.
- Vitae is 220 base and regenerates 2.4/s out of combat (ramping in over a second) and 0.5/s while fighting. Kills build Bloodrush.
- Movement is WASD first (camera relative); clicking the ground still walks there, clicking a foe lances it, mouse wheel zooms.
- Lava plates burn; eruptions telegraph and explode. Standing still is punished.
- The camera leans lower and closer than before, drifts toward your aim, and eases between positions.
- Packs aggro at 13 m, so fights are deliberate and readable instead of a screen-wide swarm.

## Core Loop (implemented)
1. Random connected cave layout of stone plates over lava, chosen from four floor themes that cycle: ASHEN CAUSEWAY, MOLTEN WARRENS, SUNKEN CATHEDRAL, CINDER CHASM. Each changes land density, river and pool count, props, fog and ambient colour. Lava spits are filled in, the gate scar leaves a land gap, and bridges are widened.
2. Packs of cultists, wolves, bats, crawlers, slingers and alphas spawn away from the player. Every 5th layer is a boss floor: the Hushed Prophet or the Brood Mother with two brutes, a boss bar, boss music and triple loot.
3. Killing drops colour-coded relics, life orbs and coin. Walking over a relic shows a stat comparison card; click the card (or Enter) to bind it to a relic slot.
4. Clearing every pack opens a rift gate. Stepping into it starts the next layer: more enemies, more HP and damage, better rarity odds. Every 6th layer is the Ashen Broker's bazaar instead.
5. Death ends the run and shows the layer reached; R revives at layer 1 keeping the relics.

## Rift Boons (per-layer progression)
- Clearing every pack opens the gate and deals three boons; click one or press 1-3 before you descend.
- Blood Fury +15% ability damage, Deep Vitae +40 max vitae and a heal, Quickened Blood -15% cooldowns, Sanguine Flow +0.9 regen/s, Gilded Hour +30% relic drop chance, Crimson Stride +8% move speed.
- Boons stack for the whole run and reset on death/restart.

## Coin and the Ashen Broker
- Every kill drops a coin stack that flies to the player (coins are saved as they are picked up). Elites pay x3, bosses x9; payout scales with the layer.
- Every 6th layer is a merchant floor: no enemies, no hazards. The Ashen Broker stands on a lit dais with his stall, braziers and a label; walk up and press E (or click him) to open the shop, and step into the gate to descend.
- The shop sells 3 relics (priced by rarity and layer), 2 random boons and a full vitae flask. Bought relics open the normal slot-bind window; boons apply at once.
- The merchant floor plays the ambient metal bazaar track and shows NO HOSTILES - THE BROKER WAITS.

## Music
- Combat floors 1-4 each play a different metal track, layer 5 uses the boss track, and every 6th layer plays the ambient metal merchant theme. Layers cycle after that.
- Music tracks live in audio/music, audio/generated/metal_combat, metal_combat2, metal_combat3, metal_boss and metal_merchant; each folder is picked up automatically.

## Saving and settings per save
- The run is saved at every floor start, coin pickup, relic bind, boon claim, shop purchase and settings change to user://run_save.cfg.
- The title offers PRESS C - CONTINUE LAYER N when a run save exists; clicking starts a new run and clears it. Death clears the save.
- The save stores layer, coins, boons, relic loadout, health and a snapshot of the settings; continuing reapplies that snapshot, so each save carries its own audio/video/gameplay/interface setup.
- Settings > Interface has Save Settings Automatically and the window has SAVE SETTINGS; RESET DEFAULTS restores everything.

## Classes and Abilities
Only the Blood Sorceress is playable.
- 1 Blood Nova — AoE detonation around the player, 6 life.
- 2 Crimson Lance — piercing blood spear toward the cursor, 3 life.
- 3 Sanguine Siphon — 2 s drain on nearby foes that heals a share of damage.
- Space Riftstep — dash toward the cursor, invulnerable during the dash, can cross lava.

## Bloodrush (kill momentum)
- Every kill adds one Bloodrush stack (max 10) and refreshes a 4.5 s timer.
- Each stack adds +3.5% spell damage and +0.07 vitae/s regen, shown as a gold meter under the vitae bar.
- Stacks reset on death, so the damage spike is tied to keeping the clear going.

## Quality of Life
- WASD / arrows move; hold left mouse to keep walking; release to stop.
- Loot within 6.5 m is pulled into the player.
- Esc or P pauses (Resume button too), and the pause panel lists every control.
- Skill cards can be clicked to cast; the Riftstep card included.
- A thin rift-clear bar under the layer title tracks packs cleared.
- The death screen has a DESCEND AGAIN button, not just the R hotkey.
- Clearing a floor restores 20% vitae before the rift opens.
- The deepest rift layer reached is saved and shown on the title and death screens.
- Relic drops are click-to-claim and never auto-equip; the loadout window opens on the claim.

## Settings (SET button top right, Esc closes)
- Audio: master, music, ambience and effects volumes; changes save instantly to user://settings.cfg.
- Video: fullscreen, vsync, brightness, camera distance, frame rate cap.
- Gameplay: screen shake, damage numbers, enemy health bars, hold-mouse-to-move, rift modifier chips.
- Interface: HUD scale, rift minimap, announcement toasts.
- RESET DEFAULTS restores the defaults; the window resizes to fit each tab.

## Relics (three slots, families and synergetic rites)
- Three relic slots. Any family stacks at most twice, so builds are 2 + 1 or 1 + 1 + 1.
- Families: Blood (damage, life), Ember (crit), Rift (speed, regen, Riftstep).
- Two of one family unlocks its rite: Blood +18% damage and +8 life; Ember +8% crit and +30% crit damage; Rift +10% speed, +1.2 regen, Riftstep -0.5 s. One of each unlocks the Bloodmoon Triad (+6% damage, +5% life, -10% spell cost).
- TAB opens the loadout window with RELICS and SYNERGY tabs. Click a glowing drop on the floor to claim it, then bind it to a slot.
- Legendary relics change a skill: Bloodmoon Crown (free, wider Nova), Riftfang Diadem (triple piercing Lance), Sanguine Chalice (double Siphon), Emberwake Sigil (burning Riftstep).

## Legendary Relics (they change how a skill works)
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
- `scripts/settings.gd` - GameSettings: defaults, load/save to user://settings.cfg, reset.
- `res://main.tscn` — WorldEnvironment, sun/rim/fill lights, camera, game root.
- `scripts/game.gd` — floor generation, mesh building, spawning, combat resolution, loot, portal, HUD wiring.
- `scripts/player.gd` — Blood Sorceress movement, life-cost abilities, stats and relic effects.
- `scripts/enemy.gd` — pack AI (aggro, pathing, windup attacks, HP bars, death).
- `scripts/hud.gd` — custom-drawn vitae bar with damage trail, Bloodrush bar, rift minimap, rift-clear bar, clickable ability cards with cooldowns and life costs, relic panel, comparison card, toasts, pause, death screen, title (Cinzel display font, `fonts/cinzel.ttf`, OFL).
- `scripts/item_db.gd` — rarities, mods, legendaries, formatting.
- `scripts/fx.gd`, `scripts/projectile.gd`, `scripts/loot.gd`, `scripts/hazard.gd` — effects, blood bolts, drops, lava eruptions.
- `shaders/basalt.gdshader`, `shaders/lava.gdshader`, `shaders/portal.gdshader` — world look.
- Assets: Summer Library `dungeon-dark-fantasy` (monsters, pillars, braziers, pots), generated Blood Sorceress character, generated basalt rocks and rift gate, generated music/ambience/SFX.

## Attribution
- Dungeon kit props and monsters: Summer curated `dungeon-dark-fantasy` collection (CC0 kit by SigilsVault; monsters Summer licence).
- Blood Sorceress, rift gate, basalt rocks: Summer generated assets.
- Audio: Summer generated (ElevenLabs).
