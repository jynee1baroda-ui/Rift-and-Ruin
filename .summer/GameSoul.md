# Rift & Ruin — Game Soul

## The Pitch
An isometric, click-to-move action RPG in a volcanic wasteland split by lava rifts. You play the Blood Sorceress: every spell is paid for with her own life. Clear monster packs, collect relics, and step into the next, harder rift layer. There is no final victory — only the next layer.

## Look
- Palette: near-black basalt and dark violet shadow, broken by amber, crimson and electric gold.
- Ground: fractured basalt plates using the generated cracked-lava texture at three scales over the procedural plate shader. The texture reads as rock grain and pits, dark plate seams read as bevels, and amber veins glow only inside low-frequency hot zones, so most of the floor stays dark basalt. Trench side walls are darkened so they never read as glowing slabs. Lava rivers cut the arena into islands joined by narrow stone bridges.
- Lighting: warm key light, violet fill from above, volcanic fog and volumetric haze, strong bloom on magical seams and lava.
- Scenery: lava gardens of generated ember plants and obsidian shards tinted with each theme's seam colour, plus cinder-bloom mushroom clusters, glowing braziers, scattered boulders, ruined pillars and pots. Rock and plant density rises with each theme's decor and plants values, so no two layers are dressed the same.
- Ability VFX are built from textured billboards, never visible geometry: soft radial falloff sprites, ground shockwave rings drawn with a ring gradient texture, rising smoke mist, scattered embers and a short light flash. Nova opens with a low-alpha heat bloom, a thin soft shockwave, embers and an aftershock; Lance throws a muzzle gout and spark spray; Siphon opens with a violet bloom and pulls beads of light from every foe. Mobs flash red through their windup telegraph, spark on every hit, and burst into blood and embers on death; bosses add a scorching shockwave on their swings and a full nova when they fall. Rings fade with distance from the blast so a big nova stays readable instead of washing the screen.
- UI: dark stone plates with amber borders, grainy gradient backdrop, crimson vitae, gold legendary text, Cinzel display face. The vitae bar has a smoothed fill, an orange damage trail and a live REGEN readout. Each ability card shows its life cost and can be clicked to cast.
- Rift map (top left): tile-accurate minimap of the floor, lava and bridges, with the player in gold, packs in red, elites in amber and the gate in violet.
- Lava reads as dark cooled crust with molten amber seams, so the pit stays legible without turning the screen orange.

## Feel
- Every spell costs health, but the price is sustainable: Nova 6, Lance 3, Siphon free.
- Vitae is 220 base and regenerates 2.4/s out of combat (ramping in over a second) and 0.5/s while fighting. Kills build Bloodrush.
- Movement is WASD only and camera relative. Left mouse is the primary attack (Crimson Lance), right mouse is the secondary (Crimson Nova); 1 2 3 cast the same abilities, Space is Riftstep, mouse wheel zooms. Loot and the Broker still take a left click.
- Cast locks are per ability (lance 0.12 s, nova 0.24 s, siphon 0.30 s) so the primary attack recovers immediately. The sorceress turns toward the cursor when standing still.
- Taking a hit grants only a 0.12 s grace window; ordinary foes stagger for 0.17 s on a solid hit and lose their windup, elites 0.1 s, bosses never.
- Lava plates burn; eruptions telegraph and explode. Standing still is punished.
- The camera leans lower and closer than before, drifts toward your aim, and eases between positions.
- Packs aggro at 13 m, so fights are deliberate and readable instead of a screen-wide swarm.

## Home Hub and the Mirror Ring
- The story spine lives in `STORY` in game.gd: the Warden speaks a line in the boon panel when a floor is cleared, the Ashen Broker speaks a line at the top of his shop, and both are written per layer so each depth advances the reason the rift exists and why the Broker keeps selling.
- The lava has an explanation now, and it is the spine of the whole setting: nine hundred years ago the sea went down into a seam in the crust all at once, and what came back up was fire. The lava is the world's blood and the rift is the cut that lets it out; it moves like a tide and every eruption raises the level a little. The first sorceresses cut the rift deliberately to bleed the pressure, then sealed it with their own blood. Eight went down, one came back, and the seal has been kept by a single family ever since. Vesna is the last of that line: she feels the seal in her teeth when she sleeps, the Bastion's wells are turning to steam, and the First Warden — who descended forty years ago with a lantern and a promise — is still down there counting. She is not there to save the world; she is there to reach the bottom and decide whether to close the wound or open it wider. This is `INTRO_BODY`, shown once when a character is created, with `%HERO%` replaced by the name the player typed.
- `LORE_BOOK` in hud.gd is the ten-page Ledger of the Drowning (The Drowning, The Wound, The First Seal, The Ashen Bastion, The Blooded Line, The First Warden, The Ashen Broker, The Hushed Prophet, The Brood Mother, The Last Furnace). The title's HALL button turns its pages inline; the pause menu's LORE button opens it as a full page with PREV/NEXT, arrow keys and Esc. Both read the same data, so they cannot drift apart.
- Each layer also has a `rift` voice in `STORY` that plays as the second line of the arrival whisper, under the place's own `LAYER_LORE` line, so the dungeon speaks on every descent and the merchant floors speak too.
- Online play is built on Summer's dedicated-server model: the player runs `client/main.tscn`, the match runs headless from `authority/main.tscn`, and both load one network contract (`network/composition.tres`). The project declares `summer.build.json`, `world.json`, `runtime-manifest.json` and `source-domains.json`; the queue is `rift` for 1-4 players.
- The authority picks the world seed and publishes it on the `rift.world` State stream; every client seeds its floor generator with `seed + layer * 9176` before building, so two players always stand in the same randomised rift.
- Each player owns one pose group (`rift.motion`, key `p<seat>`) carrying entity, position and yaw. The authority checks every pose with an arena bound and a distance allowance refilled at 22 m/s, and refuses teleports; a refused pose snaps the owner back. Other players are observer projections that glide 100 ms behind, so remote movement stays smooth.
- Joining a World drops the player straight into the rift (`ONLINE - n IN RIFT - SEAT n` chip under the minimap). With no World available the client prints `RIFT_NET_SOLO` and boots the untouched solo game, so single player never depends on the network.
- Local co-op test: `summer/local_play/players = 2` and PlayGame starts one headless authority plus two clients on port 7787.
- One multiplayer surface serves the home screen and the pause menu: `show_net_panel(mode)` with `net_action(action, mode)`. FIND MATCH really retries the Summer queue join and prints the real error (`unavailable` outside Local Play or hosting); DUEL THE MIRROR starts the local mirror duel. There is no second, disconnected co-op/PvP UI.
- The pause menu offers RESUME, CHARACTER (relic loadout), WORLD MAP, CO-OP ONLINE, PVP ARENA, OPTIONS, LORE (the Ledger of the Drowning) and LEAVE TO HUB (two-press confirmation, then back to the title). Leaving the hub also closes the pause and codex overlays, so no panel is ever stranded on the title.
- The rift ladder is interactive: mouse or arrow keys move the selection, the footer prints tier, recommended level, WARDEN/BROKER tags and the lock rule, and ENTER RIFT (or Enter) regenerates that local layer up to deepest + 1.
- Camera: wheel zooms toward `zoom_target` (0.78-1.4), middle-drag and optional edge panning move `camera_pan`, F recenters, and the follow strength, pan speed, edge pan and zoom step live in settings.

- The game opens on the Ashen Bastion title card over the live floor: RIFT & RUIN, deepest rift reached, CONTINUE (layer, level, coin of the saved run) or ENTER THE RIFT / NEW RIFT, then CO-OP, PVP, WORLD MAP, HALL and OPTIONS.
- NEW RIFT opens CREATE YOUR CHARACTER: a full class list with concept portraits (Blood Sorceress, Iron Paladin, Shadow Huntress, and the unnamed fourth seat), a live 3D turntable of the Blood Sorceress playing her Idle clip in a lit SubViewport, a name field (VESNA by default, 16 characters) and ENTER THE RIFT. Sealed seats can be clicked to read their lore and see their art; their card says SEALED and the create button refuses, so a class can never be silently swapped for another.
- Hovering a menu entry writes a lore line into the card's panel. HALL OF WARDENS is a four-page lore book (Bastion, Hushed Prophet, Brood Mother, Ashen Broker), one page per click.
- DUEL THE MIRROR is the PvP mode: a clean obsidian ring with no packs, no hazards, no portal and no relics. The rival is the sorceress model with the player's own kit: a five-bolt soul volley on a windup, a seven-bolt blood fan that heals her, and a phase break at half life. Winning or losing opens a result card with DUEL AGAIN and RETURN TO BASTION. Duel results never touch the run save.
- Entering any layer prints a quiet one-line whisper under the status text (LAYER_LORE), so each rift has a voice without stopping play.

## Core Loop (implemented)
1. Thirty rift layers, each a different place and a different floor plan (ten originals plus twenty added in the depth pass; see THEMES in game.gd for the full ladder). Each theme carries its own rock, seam, lava crust/hot/core colours, fog, sun tint, prop density and plant density. Lava spits are filled in, the gate scar leaves a land gap, and bridges are widened so every floor is walkable end to end.
2. Packs of cultists, wolves, bats, crawlers, slingers and alphas spawn away from the player. Every 6th layer is a warden floor: the Hushed Prophet (6), the Brood Mother (12), the Iron Choir (18), the Bone Tide (24) and The Drowning (30), each with its own model, special attack, boss bar, boss music and triple loot. Layer 18/24/30 use new generated models fitted to a target height.
2b. Every 5th layer (5, 11, 17, 23, 29) is the Ashen Broker's floor: no hostiles, the broker on his dais, ambient metal and a gate onward.
3. Killing drops colour-coded relics, life orbs and coin. Walking over a relic shows a stat comparison card; click the card (or Enter) to bind it to a relic slot.
4. Clearing every pack opens a rift gate. Stepping into it starts the next layer: more enemies, +24% enemy life and +11% damage per layer, better rarity odds. Every 5th layer is the Ashen Broker's bazaar instead.
5. Death ends the run and shows the layer reached; R starts a fresh run at layer 1 with a level-1 sorceress.

## Levels and scaling
- The player gains XP from kills (12 + 2 per layer, x3 elites, x10 bosses) and levels up with a burst, a heal and a toast.
- Each level adds 14 max vitae, 4.5% ability power, 0.09 vitae regen and 0.7% move speed, plus one passive point for THE BLOODIED PATH.
- Descending a layer also lifts the sorceress to that layer's level, so character level tracks rift depth instead of falling behind it. Layer 10 is a level 10 sorceress even before her kills are counted.
- Enemy life is 1 + 0.16 x (layer - 1) of base and enemy damage is 1 + 0.075 x (layer - 1); bosses use 1 + 0.20 x (layer - 1) life. A layer-30 warden has about 11x a layer-6 warden's life.
- Regeneration now scales with the health pool: out of combat it is max(regen, 3.5% of max vitae) per second, in combat max(0.5, 0.35% of max vitae), so deep layers stay survivable without trivialising the early game.

## THE BLOODIED PATH (passive tree, K)
- Three branches of six nodes: MIGHT (damage, crit), VITAE (life, regen, heal on kill), GRACE (speed, cooldowns, cost). One point per level, prerequisites are enforced, and the tree is saved with the run.

## Characters and saves
- `scripts/roster.gd` keeps a character list in `user://roster.cfg` with one save per hero (`user://saves/<id>.cfg`), holding name, class, level, layer, deepest, coin and time.
- The title's CHARACTERS button opens the list (portrait, class, level, layer, deepest, coin) with LOAD and a two-press DELETE; CREATE NEW opens the class creator.
- Continue loads the last played hero; the creator prefills each class's own name (VESNA / ARDEN / SERA).

## Rift Boons (per-layer progression)
- Clearing every pack opens the gate and deals three boons; click one or press 1-3 before you descend.
- Blood Fury +15% ability damage, Deep Vitae +40 max vitae and a heal, Quickened Blood -15% cooldowns, Sanguine Flow +0.9 regen/s, Gilded Hour +30% relic drop chance, Crimson Stride +8% move speed.
- Boons stack for the whole run and reset on death/restart.

## Coin and the Ashen Broker
- Every kill drops a coin stack that flies to the player (coins are saved as they are picked up). Elites pay x3, bosses x9; payout scales with the layer.
- Every 5th layer is a merchant floor: no enemies, no hazards. The Ashen Broker stands on a lit dais with his stall, braziers and a label; walk up and press E (or click him) to open the shop, and step into the gate to descend.
- Layer 30 (and every 60th after it) is a boss floor that also carries the broker near the entrance, so a warden and a trader share the milestone.
- The shop sells 3 relics (priced by rarity and layer), 2 random boons and a full vitae flask. Bought relics open the normal slot-bind window; boons apply at once.
- The merchant floor plays the ambient metal bazaar track and shows NO HOSTILES - THE BROKER WAITS.

## Music
- Seven combat tracks cover the seven combat layers of 1-10 (layers 1, 2, 3, 4, 7, 8, 9), the boss layer plays the boss track, and merchant layers 5 and 10 play the ambient metal bazaar theme. Each layer therefore has its own song for a full ten-layer run.
- Music tracks live in audio/music, audio/generated/metal_combat ... metal_combat6, metal_boss and metal_merchant; each folder is picked up automatically.

## Saving and settings per save
- The run is saved at every floor start, coin pickup, relic bind, boon claim, shop purchase and settings change to user://run_save.cfg.
- The title offers PRESS C - CONTINUE LAYER N when a run save exists; clicking starts a new run and clears it. Death clears the save.
- The save stores layer, coins, boons, relic loadout, health and a snapshot of the settings; continuing reapplies that snapshot, so each save carries its own audio/video/gameplay/interface setup.
- Settings > Interface has Save Settings Automatically and the window has SAVE SETTINGS; RESET DEFAULTS restores everything.

## Classes and Abilities
Three classes are playable: the Blood Sorceress (VESNA, vitae), the Iron Paladin (ARDEN, RESOLVE) and the Shadow Huntress (SERA, FOCUS). Each has its own generated 3D character, its own three abilities, dash and skill icons, driven from `scripts/hero_classes.gd`. The fourth seat is visible, readable and sealed. Class art lives in `res://art/portraits/` and is used both as the card thumbnail and as the preview for a sealed seat.
- Iron Paladin: Hammer of Noon (frontal slam), Aegis Rush (charge, shield + heal), Hallow (4 s burning ground); dash Shieldrush.
- Shadow Huntress: Piercing Shot, Fan of Arrows, Shade Step (blink + crit window); dash Shadestep.
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
- Esc or P pauses (Resume button too). The pause panel lists every control, states the merchant and boss cadence, and carries a live layer/level/coin/souls summary. OPTIONS opens settings on top of the pause without losing it, and Resume drops back into the fight.
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
- `scripts/hand_grip.gd` - finger joints and weapon sockets: every humanoid gets a BoneAttachment3D per hand carrying four three-joint fingers and a thumb, plus a grip node holding the class weapon (hammer, staff, bow built from primitives).
- `scripts/hero_pose.gd` - signature bind-pose stances per class, aimed by bone direction so no character is ever left in a T or A pose; used by the creator turntable.
- `scripts/hero_classes.gd`, `scripts/passives.gd`, `scripts/roster.gd` - class data, passive tree, character list.
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
- Blood Sorceress, rift gate, basalt rocks: Summer generated assets. Class concept portraits for the Blood Sorceress, Iron Paladin and Shadow Huntress are imported into `res://art/portraits/` from the project board.
- Audio: Summer generated (ElevenLabs).
