extends Node3D

const CELL := 4.0
const GRID := 17
const CAMERA_OFFSET := Vector3(0.0, 24.5, 14.6)
const ENGAGE_RANGE := 11.0
const MAX_MELEE_ATTACKERS := 2
const RECORD_PATH := "user://rift_record.cfg"
const HERO_DIR := "res://art/generated/blood_sorceress"
const ROCK_PATH := "res://art/generated/basalt_rocks/3d_61c4c6fd5084468abe17b1bb_1794029018098.glb"
const GATE_PATH := "res://art/generated/rift_gate/3d_de536d2e46e04f69aab95a43_1794029026993.glb"
const BASALT_TEX := "res://art/generated/basalt_v2/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037284380-0_1794037284380_vzb0pgdi.png"
const DUNGEON_DIR := "res://assets/library/dungeon/"
const MERCHANT_DIR := "res://art/generated/merchant_broker"

const KINDS := {
	"wolf": {"key": "wolf", "name": "Gloam Wolf", "file": "gloam-wolf.glb", "health": 46.0, "damage": 8.0, "speed": 5.0, "range": 2.0, "interval": 1.5, "windup": 0.45, "scale": 1.0},
	"crawler": {"key": "crawler", "name": "Cave Crawler", "file": "cave-crawler.glb", "health": 30.0, "damage": 6.0, "speed": 5.6, "range": 1.5, "interval": 1.1, "windup": 0.3, "scale": 1.7},
	"bat": {"key": "bat", "name": "Hollow Bat", "file": "hollow-bat.glb", "health": 24.0, "damage": 5.0, "speed": 6.4, "range": 1.7, "interval": 1.1, "windup": 0.25, "scale": 1.3},
	"acolyte": {"key": "acolyte", "name": "Hushed Acolyte", "file": "res://art/generated/mob_acolyte/3d_1794101415355.glb", "texture": "res://art/generated/mob_acolyte/3d_1794101415355_texture_20250901.png", "height": 1.78, "health": 62.0, "damage": 10.0, "speed": 4.0, "range": 2.1, "interval": 1.8, "windup": 0.55},
	"slinger": {"key": "slinger", "name": "Hushed Slinger", "file": "res://art/generated/mob_acolyte/3d_1794101415355.glb", "texture": "res://art/generated/mob_acolyte/3d_1794101415355_texture_20250901.png", "height": 1.62, "tint": Color(0.8, 0.6, 1.0), "health": 50.0, "damage": 7.0, "speed": 3.8, "range": 9.0, "interval": 2.4, "windup": 0.65, "ranged": true},
	"alpha": {"key": "alpha", "name": "Gloam Alpha", "file": "gloam-alpha.glb", "health": 120.0, "damage": 15.0, "speed": 5.6, "range": 2.3, "interval": 1.7, "windup": 0.5, "scale": 1.15, "elite": true},
	"brute": {"key": "brute", "name": "Hushed Brute", "file": "res://art/generated/mob_brute/3d_f87c220079fb4f2b841accb2_1794101648136.glb", "texture": "res://art/generated/mob_brute/3d_f87c220079fb4f2b841accb2_1794101648136_texture_20250901.png", "height": 2.35, "health": 190.0, "damage": 22.0, "speed": 3.4, "range": 2.7, "interval": 2.4, "windup": 0.85, "elite": true, "tint": Color(1.0, 0.9, 0.82)},
	"prophet": {"key": "prophet", "name": "The Hushed Prophet", "file": "hushed-prophet.glb", "health": 460.0, "damage": 24.0, "speed": 3.1, "range": 3.2, "interval": 2.6, "windup": 0.9, "scale": 1.05, "boss": true},
	"brood": {"key": "brood", "name": "The Brood Mother", "file": "brood-mother-boss.glb", "health": 520.0, "damage": 26.0, "speed": 3.3, "range": 3.6, "interval": 2.1, "windup": 0.75, "scale": 1.0, "boss": true},
	"nail": {"key": "nail", "name": "The Iron Choir", "file": "res://art/generated/boss_iron_choir/3d_1794099354340.glb", "texture": "res://art/generated/boss_iron_choir/3d_1794099354340_texture_20250901.png", "health": 780.0, "damage": 34.0, "speed": 3.6, "range": 3.0, "interval": 2.2, "windup": 0.8, "height": 2.9, "boss": true, "tint": Color(0.86, 0.9, 1.0), "special": "slam"},
	"tide": {"key": "tide", "name": "The Bone Tide", "file": "res://art/generated/boss_bone_tide/3d_1794099110423.glb", "texture": "res://art/generated/boss_bone_tide/3d_1794099110423_texture_20250901.png", "health": 980.0, "damage": 36.0, "speed": 4.5, "range": 2.6, "interval": 1.7, "windup": 0.6, "height": 2.2, "boss": true, "tint": Color(0.92, 1.0, 0.72), "special": "charge"},
	"drowning": {"key": "drowning", "name": "The Drowning", "file": "res://art/generated/boss_drowning/3d_0f6dfebbc8f24bbeb98f1108_1794099728369.glb", "texture": "res://art/generated/boss_drowning/3d_0f6dfebbc8f24bbeb98f1108_1794099728369_texture_20250901.png", "health": 1480.0, "damage": 44.0, "speed": 3.4, "range": 4.0, "interval": 2.0, "windup": 0.8, "height": 3.2, "boss": true, "tint": Color(1.0, 0.3, 0.24), "special": "storm"},
	"mirror": {"key": "mirror", "name": "THE MIRROR", "file": "", "health": 380.0, "damage": 11.0, "speed": 4.3, "range": 7.2, "interval": 1.9, "windup": 0.55, "scale": 1.0, "boss": true, "ranged": true, "aggro": 40.0},
}

## One warden every sixth layer, in order. Layer 6 is the Prophet, 12 the Brood
## Mother, 18 the Iron Choir, 24 the Bone Tide, 30 the Drowning.
const BOSS_ORDER := ["prophet", "brood", "nail", "tide", "drowning"]

const THEMES := [
	{"name": "ASHEN CAUSEWAY", "density": 0.76, "rivers": 1, "pools": 1, "decor": 1.0, "layout": "causeway",
		"fog": Color(0.10, 0.035, 0.05), "ambient": Color(0.30, 0.18, 0.22),
		"rock": Color(0.17, 0.145, 0.145), "seam": Color(1.0, 0.42, 0.10), "glow": 1.35, "plate": 0.13,
		"lava_crust": Color(0.09, 0.03, 0.02), "lava_hot": Color(1.0, 0.38, 0.05), "lava_core": Color(1.0, 0.78, 0.30),
		"plants": 0.55, "sun": Color(1.0, 0.88, 0.78)},
	{"name": "MOLTEN WARRENS", "density": 0.72, "rivers": 2, "pools": 1, "decor": 0.85, "layout": "warrens",
		"fog": Color(0.18, 0.06, 0.03), "ambient": Color(0.36, 0.20, 0.16),
		"rock": Color(0.18, 0.11, 0.09), "seam": Color(1.0, 0.32, 0.05), "glow": 1.45, "plate": 0.15,
		"lava_crust": Color(0.11, 0.025, 0.015), "lava_hot": Color(1.0, 0.30, 0.03), "lava_core": Color(1.0, 0.72, 0.20),
		"plants": 0.42, "sun": Color(1.0, 0.80, 0.62)},
	{"name": "SUNKEN CATHEDRAL", "density": 0.74, "rivers": 1, "pools": 1, "decor": 1.55, "layout": "cathedral",
		"fog": Color(0.07, 0.06, 0.13), "ambient": Color(0.24, 0.22, 0.42),
		"rock": Color(0.14, 0.14, 0.19), "seam": Color(0.72, 0.55, 1.0), "glow": 1.10, "plate": 0.11,
		"lava_crust": Color(0.05, 0.03, 0.07), "lava_hot": Color(0.82, 0.36, 1.0), "lava_core": Color(0.92, 0.82, 1.0),
		"plants": 0.28, "sun": Color(0.85, 0.84, 1.0)},
	{"name": "CINDER CHASM", "density": 0.68, "rivers": 1, "pools": 2, "decor": 0.7, "layout": "chasm",
		"fog": Color(0.13, 0.03, 0.03), "ambient": Color(0.34, 0.16, 0.14),
		"rock": Color(0.15, 0.11, 0.11), "seam": Color(1.0, 0.25, 0.08), "glow": 1.30, "plate": 0.12,
		"lava_crust": Color(0.07, 0.02, 0.02), "lava_hot": Color(1.0, 0.22, 0.05), "lava_core": Color(1.0, 0.62, 0.22),
		"plants": 0.35, "sun": Color(1.0, 0.74, 0.66)},
	{"name": "THE ASHEN BAZAAR", "density": 0.74, "rivers": 1, "pools": 1, "decor": 1.6, "layout": "plaza",
		"fog": Color(0.12, 0.06, 0.03), "ambient": Color(0.40, 0.28, 0.18),
		"rock": Color(0.19, 0.15, 0.11), "seam": Color(1.0, 0.66, 0.22), "glow": 1.25, "plate": 0.14,
		"lava_crust": Color(0.10, 0.04, 0.02), "lava_hot": Color(1.0, 0.45, 0.08), "lava_core": Color(1.0, 0.85, 0.40),
		"plants": 0.55, "sun": Color(1.0, 0.88, 0.70)},
	{"name": "EMBER SPIRES", "density": 0.60, "rivers": 1, "pools": 1, "decor": 0.9, "layout": "spires",
		"fog": Color(0.16, 0.07, 0.02), "ambient": Color(0.40, 0.24, 0.12),
		"rock": Color(0.20, 0.14, 0.09), "seam": Color(1.0, 0.55, 0.12), "glow": 1.50, "plate": 0.17,
		"lava_crust": Color(0.10, 0.04, 0.02), "lava_hot": Color(1.0, 0.40, 0.06), "lava_core": Color(1.0, 0.86, 0.35),
		"plants": 0.85, "sun": Color(1.0, 0.84, 0.64)},
	{"name": "GLASS FOUNDRY", "density": 0.70, "rivers": 1, "pools": 2, "decor": 1.2, "layout": "terrace",
		"fog": Color(0.05, 0.09, 0.12), "ambient": Color(0.20, 0.30, 0.40),
		"rock": Color(0.12, 0.15, 0.17), "seam": Color(0.55, 0.85, 1.0), "glow": 1.55, "plate": 0.10,
		"lava_crust": Color(0.03, 0.06, 0.08), "lava_hot": Color(0.35, 0.72, 1.0), "lava_core": Color(0.85, 0.98, 1.0),
		"plants": 0.22, "sun": Color(0.78, 0.90, 1.0)},
	{"name": "BONE ORCHARD", "density": 0.72, "rivers": 1, "pools": 1, "decor": 1.3, "layout": "cross",
		"fog": Color(0.10, 0.12, 0.07), "ambient": Color(0.32, 0.34, 0.22),
		"rock": Color(0.19, 0.18, 0.14), "seam": Color(0.85, 1.0, 0.40), "glow": 1.15, "plate": 0.13,
		"lava_crust": Color(0.05, 0.07, 0.03), "lava_hot": Color(0.75, 0.95, 0.35), "lava_core": Color(0.95, 1.0, 0.72),
		"plants": 0.95, "sun": Color(0.90, 1.0, 0.80)},
	{"name": "BLACK OBSIDIAN MAW", "density": 0.66, "rivers": 2, "pools": 1, "decor": 0.8, "layout": "ring",
		"fog": Color(0.04, 0.03, 0.10), "ambient": Color(0.18, 0.16, 0.34),
		"rock": Color(0.09, 0.09, 0.14), "seam": Color(1.0, 0.35, 0.90), "glow": 1.60, "plate": 0.12,
		"lava_crust": Color(0.04, 0.01, 0.06), "lava_hot": Color(1.0, 0.20, 0.70), "lava_core": Color(1.0, 0.75, 0.95),
		"plants": 0.30, "sun": Color(0.80, 0.72, 1.0)},
	{"name": "THE LAST FURNACE", "density": 0.64, "rivers": 1, "pools": 2, "decor": 1.0, "layout": "furnace",
		"fog": Color(0.22, 0.10, 0.02), "ambient": Color(0.46, 0.30, 0.14),
		"rock": Color(0.20, 0.16, 0.12), "seam": Color(1.0, 0.70, 0.20), "glow": 1.65, "plate": 0.14,
		"lava_crust": Color(0.12, 0.05, 0.01), "lava_hot": Color(1.0, 0.55, 0.08), "lava_core": Color(1.0, 0.95, 0.60),
		"plants": 0.70, "sun": Color(1.0, 0.90, 0.66)},
	{"name": "THE SALT SCAR", "density": 0.80, "rivers": 1, "pools": 1, "decor": 0.6, "layout": "causeway",
		"fog": Color(0.12, 0.12, 0.14), "ambient": Color(0.36, 0.35, 0.32),
		"rock": Color(0.30, 0.29, 0.27), "seam": Color(0.98, 0.88, 0.55), "glow": 1.10, "plate": 0.18,
		"lava_crust": Color(0.16, 0.13, 0.09), "lava_hot": Color(1.0, 0.72, 0.28), "lava_core": Color(1.0, 0.97, 0.78),
		"plants": 0.08, "sun": Color(1.0, 0.97, 0.90)},
	{"name": "THE NAIL CHOIR", "density": 0.74, "rivers": 1, "pools": 1, "decor": 1.7, "layout": "cathedral",
		"fog": Color(0.08, 0.07, 0.13), "ambient": Color(0.30, 0.27, 0.44),
		"rock": Color(0.24, 0.23, 0.26), "seam": Color(0.88, 0.78, 1.0), "glow": 1.20, "plate": 0.11,
		"lava_crust": Color(0.06, 0.04, 0.09), "lava_hot": Color(0.78, 0.55, 1.0), "lava_core": Color(0.96, 0.9, 1.0),
		"plants": 0.18, "sun": Color(0.90, 0.88, 1.0)},
	{"name": "THE DRIPPING VAULT", "density": 0.70, "rivers": 2, "pools": 2, "decor": 1.1, "layout": "warrens",
		"fog": Color(0.04, 0.10, 0.10), "ambient": Color(0.18, 0.34, 0.32),
		"rock": Color(0.13, 0.17, 0.17), "seam": Color(0.45, 1.0, 0.86), "glow": 1.35, "plate": 0.13,
		"lava_crust": Color(0.02, 0.06, 0.06), "lava_hot": Color(0.25, 0.92, 0.78), "lava_core": Color(0.80, 1.0, 0.95),
		"plants": 0.62, "sun": Color(0.78, 1.0, 0.94)},
	{"name": "THE CINDER GALLERY", "density": 0.72, "rivers": 1, "pools": 1, "decor": 1.35, "layout": "terrace",
		"fog": Color(0.14, 0.05, 0.05), "ambient": Color(0.34, 0.20, 0.18),
		"rock": Color(0.18, 0.12, 0.12), "seam": Color(1.0, 0.36, 0.18), "glow": 1.30, "plate": 0.15,
		"lava_crust": Color(0.09, 0.03, 0.02), "lava_hot": Color(1.0, 0.33, 0.10), "lava_core": Color(1.0, 0.78, 0.45),
		"plants": 0.30, "sun": Color(1.0, 0.80, 0.72)},
	{"name": "THE QUIET LEDGER", "density": 0.76, "rivers": 1, "pools": 1, "decor": 1.9, "layout": "plaza",
		"fog": Color(0.12, 0.09, 0.03), "ambient": Color(0.42, 0.34, 0.16),
		"rock": Color(0.20, 0.17, 0.10), "seam": Color(1.0, 0.82, 0.30), "glow": 1.30, "plate": 0.14,
		"lava_crust": Color(0.11, 0.06, 0.01), "lava_hot": Color(1.0, 0.62, 0.10), "lava_core": Color(1.0, 0.94, 0.55),
		"plants": 0.50, "sun": Color(1.0, 0.93, 0.76)},
	{"name": "THE HOLLOW CROWN", "density": 0.70, "rivers": 1, "pools": 1, "decor": 1.4, "layout": "ring",
		"fog": Color(0.09, 0.04, 0.13), "ambient": Color(0.28, 0.18, 0.42),
		"rock": Color(0.15, 0.11, 0.19), "seam": Color(0.85, 0.55, 1.0), "glow": 1.45, "plate": 0.12,
		"lava_crust": Color(0.06, 0.02, 0.09), "lava_hot": Color(0.95, 0.42, 1.0), "lava_core": Color(1.0, 0.86, 1.0),
		"plants": 0.35, "sun": Color(0.92, 0.80, 1.0)},
	{"name": "THE RUST GARDEN", "density": 0.70, "rivers": 1, "pools": 2, "decor": 1.25, "layout": "cross",
		"fog": Color(0.12, 0.07, 0.04), "ambient": Color(0.38, 0.26, 0.16),
		"rock": Color(0.21, 0.14, 0.09), "seam": Color(1.0, 0.55, 0.22), "glow": 1.25, "plate": 0.14,
		"lava_crust": Color(0.11, 0.05, 0.02), "lava_hot": Color(1.0, 0.44, 0.12), "lava_core": Color(1.0, 0.86, 0.52),
		"plants": 1.15, "sun": Color(1.0, 0.86, 0.70)},
	{"name": "THE SECOND SEAL", "density": 0.66, "rivers": 1, "pools": 1, "decor": 0.9, "layout": "chasm",
		"fog": Color(0.04, 0.08, 0.14), "ambient": Color(0.18, 0.28, 0.44),
		"rock": Color(0.12, 0.15, 0.20), "seam": Color(0.55, 0.80, 1.0), "glow": 1.60, "plate": 0.10,
		"lava_crust": Color(0.02, 0.05, 0.09), "lava_hot": Color(0.35, 0.66, 1.0), "lava_core": Color(0.86, 0.95, 1.0),
		"plants": 0.16, "sun": Color(0.82, 0.90, 1.0)},
	{"name": "THE SIGHING BRIDGE", "density": 0.74, "rivers": 2, "pools": 1, "decor": 0.8, "layout": "causeway",
		"fog": Color(0.05, 0.09, 0.10), "ambient": Color(0.22, 0.32, 0.34),
		"rock": Color(0.14, 0.17, 0.18), "seam": Color(0.45, 0.95, 0.90), "glow": 1.35, "plate": 0.13,
		"lava_crust": Color(0.03, 0.06, 0.07), "lava_hot": Color(0.30, 0.85, 0.80), "lava_core": Color(0.82, 1.0, 0.98),
		"plants": 0.40, "sun": Color(0.80, 0.98, 0.96)},
	{"name": "THE FURNACE STAIRS", "density": 0.68, "rivers": 1, "pools": 2, "decor": 1.0, "layout": "terrace",
		"fog": Color(0.18, 0.08, 0.02), "ambient": Color(0.44, 0.28, 0.12),
		"rock": Color(0.20, 0.15, 0.09), "seam": Color(1.0, 0.62, 0.16), "glow": 1.55, "plate": 0.16,
		"lava_crust": Color(0.12, 0.05, 0.01), "lava_hot": Color(1.0, 0.50, 0.06), "lava_core": Color(1.0, 0.90, 0.55),
		"plants": 0.34, "sun": Color(1.0, 0.86, 0.62)},
	{"name": "THE COINLESS MARCH", "density": 0.72, "rivers": 1, "pools": 1, "decor": 1.6, "layout": "plaza",
		"fog": Color(0.10, 0.08, 0.05), "ambient": Color(0.38, 0.32, 0.22),
		"rock": Color(0.19, 0.17, 0.14), "seam": Color(1.0, 0.74, 0.34), "glow": 1.20, "plate": 0.15,
		"lava_crust": Color(0.10, 0.07, 0.03), "lava_hot": Color(1.0, 0.55, 0.16), "lava_core": Color(1.0, 0.90, 0.62),
		"plants": 0.45, "sun": Color(1.0, 0.90, 0.78)},
	{"name": "THE GLASS THROAT", "density": 0.66, "rivers": 2, "pools": 2, "decor": 1.15, "layout": "warrens",
		"fog": Color(0.03, 0.09, 0.11), "ambient": Color(0.16, 0.34, 0.40),
		"rock": Color(0.10, 0.17, 0.19), "seam": Color(0.45, 0.92, 1.0), "glow": 1.65, "plate": 0.10,
		"lava_crust": Color(0.02, 0.06, 0.08), "lava_hot": Color(0.28, 0.80, 1.0), "lava_core": Color(0.86, 0.99, 1.0),
		"plants": 0.20, "sun": Color(0.78, 0.94, 1.0)},
	{"name": "THE WEEPING FOUNDRY", "density": 0.68, "rivers": 1, "pools": 2, "decor": 1.2, "layout": "furnace",
		"fog": Color(0.07, 0.08, 0.10), "ambient": Color(0.26, 0.30, 0.34),
		"rock": Color(0.16, 0.17, 0.19), "seam": Color(0.60, 0.85, 1.0), "glow": 1.40, "plate": 0.12,
		"lava_crust": Color(0.04, 0.05, 0.07), "lava_hot": Color(0.40, 0.62, 0.95), "lava_core": Color(0.88, 0.94, 1.0),
		"plants": 0.26, "sun": Color(0.84, 0.90, 1.0)},
	{"name": "THE BONE TIDE", "density": 0.70, "rivers": 1, "pools": 1, "decor": 1.35, "layout": "cross",
		"fog": Color(0.10, 0.12, 0.09), "ambient": Color(0.34, 0.38, 0.26),
		"rock": Color(0.22, 0.22, 0.18), "seam": Color(0.88, 1.0, 0.62), "glow": 1.25, "plate": 0.13,
		"lava_crust": Color(0.07, 0.08, 0.04), "lava_hot": Color(0.80, 0.95, 0.45), "lava_core": Color(0.97, 1.0, 0.82),
		"plants": 0.55, "sun": Color(0.94, 1.0, 0.86)},
	{"name": "THE BROKER'S LAST STALL", "density": 0.74, "rivers": 1, "pools": 1, "decor": 2.0, "layout": "plaza",
		"fog": Color(0.14, 0.06, 0.04), "ambient": Color(0.46, 0.30, 0.18),
		"rock": Color(0.22, 0.15, 0.11), "seam": Color(1.0, 0.60, 0.22), "glow": 1.50, "plate": 0.14,
		"lava_crust": Color(0.12, 0.05, 0.02), "lava_hot": Color(1.0, 0.48, 0.10), "lava_core": Color(1.0, 0.88, 0.55),
		"plants": 0.52, "sun": Color(1.0, 0.86, 0.68)},
	{"name": "THE OBSIDIAN CHOIR", "density": 0.64, "rivers": 2, "pools": 1, "decor": 1.6, "layout": "cathedral",
		"fog": Color(0.04, 0.02, 0.09), "ambient": Color(0.20, 0.14, 0.36),
		"rock": Color(0.10, 0.09, 0.14), "seam": Color(0.90, 0.45, 1.0), "glow": 1.70, "plate": 0.11,
		"lava_crust": Color(0.04, 0.01, 0.07), "lava_hot": Color(0.90, 0.30, 1.0), "lava_core": Color(1.0, 0.80, 1.0),
		"plants": 0.22, "sun": Color(0.86, 0.76, 1.0)},
	{"name": "THE SALT WIDOW", "density": 0.62, "rivers": 1, "pools": 1, "decor": 0.9, "layout": "spires",
		"fog": Color(0.14, 0.14, 0.16), "ambient": Color(0.38, 0.38, 0.40),
		"rock": Color(0.32, 0.31, 0.30), "seam": Color(0.85, 0.95, 1.0), "glow": 1.15, "plate": 0.19,
		"lava_crust": Color(0.18, 0.16, 0.14), "lava_hot": Color(0.78, 0.88, 1.0), "lava_core": Color(0.96, 1.0, 1.0),
		"plants": 0.12, "sun": Color(0.94, 0.98, 1.0)},
	{"name": "THE MAW BELOW", "density": 0.64, "rivers": 2, "pools": 2, "decor": 0.8, "layout": "ring",
		"fog": Color(0.03, 0.01, 0.07), "ambient": Color(0.16, 0.10, 0.30),
		"rock": Color(0.08, 0.07, 0.12), "seam": Color(1.0, 0.28, 0.85), "glow": 1.75, "plate": 0.10,
		"lava_crust": Color(0.03, 0.00, 0.05), "lava_hot": Color(1.0, 0.16, 0.62), "lava_core": Color(1.0, 0.72, 0.94),
		"plants": 0.20, "sun": Color(0.78, 0.66, 1.0)},
	{"name": "THE THIRD SEAL", "density": 0.72, "rivers": 1, "pools": 1, "decor": 1.4, "layout": "plaza",
		"fog": Color(0.15, 0.10, 0.02), "ambient": Color(0.48, 0.38, 0.16),
		"rock": Color(0.24, 0.19, 0.10), "seam": Color(1.0, 0.90, 0.40), "glow": 1.55, "plate": 0.15,
		"lava_crust": Color(0.13, 0.08, 0.02), "lava_hot": Color(1.0, 0.68, 0.14), "lava_core": Color(1.0, 0.98, 0.70),
		"plants": 0.48, "sun": Color(1.0, 0.94, 0.72)},
	{"name": "THE DROWNING FLOOR", "density": 0.66, "rivers": 2, "pools": 2, "decor": 0.9, "layout": "furnace",
		"fog": Color(0.055, 0.012, 0.022), "ambient": Color(0.22, 0.09, 0.11),
		"rock": Color(0.13, 0.07, 0.08), "seam": Color(0.92, 0.30, 0.20), "glow": 1.25, "plate": 0.12,
		"lava_crust": Color(0.08, 0.01, 0.02), "lava_hot": Color(1.0, 0.20, 0.08), "lava_core": Color(1.0, 0.72, 0.52),
		"plants": 0.30, "sun": Color(1.0, 0.70, 0.62)},
]

const MODIFIERS := [
	{"key": "frenzied", "name": "FRENZIED", "text": "Enemies move 20% faster", "color": Color(1.0, 0.5, 0.2)},
	{"key": "brutal", "name": "BRUTAL", "text": "Enemies deal 25% more damage", "color": Color(1.0, 0.3, 0.25)},
	{"key": "gilded", "name": "GILDED", "text": "Richer relic drops", "color": Color(1.0, 0.85, 0.35)},
	{"key": "unstable", "name": "UNSTABLE", "text": "Lava erupts more often", "color": Color(1.0, 0.45, 0.15)},
	{"key": "swarming", "name": "SWARMING", "text": "Bigger monster packs", "color": Color(0.85, 0.45, 1.0)},
]

const BOONS := [
	{"key": "fury", "name": "BLOOD FURY", "text": "+15% ability damage", "color": Color(1.0, 0.32, 0.26)},
	{"key": "vitality", "name": "DEEP VITAE", "text": "+40 max vitae and a full heal", "color": Color(1.0, 0.46, 0.56)},
	{"key": "haste", "name": "QUICKENED BLOOD", "text": "-15% ability cooldowns", "color": Color(1.0, 0.8, 0.3)},
	{"key": "regen", "name": "SANGUINE FLOW", "text": "+0.9 vitae regen per second", "color": Color(0.86, 0.38, 0.92)},
	{"key": "fortune", "name": "GILDED HOUR", "text": "+30% relic drop chance", "color": Color(1.0, 0.86, 0.42)},
	{"key": "swift", "name": "CRIMSON STRIDE", "text": "+8% move speed", "color": Color(0.52, 0.82, 1.0)},
]

const LAYER_LORE := {
	"ASHEN CAUSEWAY": "They paved this road to reach the rift. The rift let them.",
	"MOLTEN WARRENS": "Something breathes under the warrens, slow and patient, and it has been fed.",
	"SUNKEN CATHEDRAL": "The choir still sings down there. Nobody has told them the saints are gone.",
	"CINDER CHASM": "A chasm does not open. It is worn, the way a throat is worn by screaming.",
	"THE ASHEN BAZAAR": "Coin is the only prayer here, and the Broker answers every one.",
	"EMBER SPIRES": "Every spire is a pyre. Someone built them, and someone is still climbing.",
	"GLASS FOUNDRY": "The glass was sand once. The sand was someone's city.",
	"BONE ORCHARD": "The trees here grow fruit you should not eat, and people eat it anyway.",
	"BLACK OBSIDIAN MAW": "The Maw does not eat. It simply opens, and things fall in.",
	"THE LAST FURNACE": "This is where the rift was made. It is still running. It has never been turned off.",
}

## The spine that runs between layers: the Warden speaks when a floor is
## cleared, the Broker speaks when his shop opens. Keyed by layer.
## What the lava is, and why a blood sorceress goes down into it.
const INTRO_TITLE := "THE DROWNING"
const INTRO_BODY := """Nine hundred years ago the world did not end in war. It ended in a seam.

The sea went down into it — every ocean at once, with a sound the survivors described as a held breath finally let go. What climbed back up was fire. The rivers you are about to cross are not weather and they are not punishment: they are the world's blood, and the rift is the cut that lets it out. It breathes. Every eruption raises the tide a little.

Your order cut the first rift on purpose, to bleed the pressure before the whole crust split, and then sealed it with their own blood. Eight went down. One came back up and never spoke again. The seal has held for nine centuries on the strength of a single family, and you are the last of it.

You are %HERO% of the Ashen Bastion. You feel the seal in your teeth when you sleep. The wells are turning to steam, children are born with ember in their lungs, and the First Warden — who went down forty years ago with a lantern and a promise — is still down there, counting.

You are not here to save the world. You are here to reach the bottom of the wound and decide whether to close it, or open it wider."""


const STORY := {
	1: {"warden": "You came down with a heartbeat. Nobody has done that since the First Warden.",
		"broker": "Everything in this rift was somebody's once. You want it, you buy it.",
		"rift": "The heat down here has a rhythm. Count it. It is not your heartbeat."},
	2: {"warden": "The warrens breathe because something beneath them is still asleep. Do not wake it politely.",
		"broker": "The Prophet used to buy candles from me. He stopped when he ran out of face.",
		"rift": "Something under the warrens turns over when you step. It has not opened its eyes yet."},
	3: {"warden": "The choir is not mourning. Listen again: they are counting.",
		"broker": "Cathedral glass sells well. It sings when it breaks.",
		"rift": "The choir is not singing to the saints. It is singing to the pressure."},
	4: {"warden": "Cinder does not burn out. It remembers, and then it burns again.",
		"broker": "I do not set the prices. The rift does. I only hold the coin.",
		"rift": "The chasm is not a crack. It is a throat, and it is swallowing the ash you make."},
	5: {"warden": "You are standing in the only quiet place left. Do not mistake it for mercy.",
		"broker": "A blade, a boon, a bit of breath. Pick two. You cannot carry all three.",
		"rift": "Even the fire stops to trade. That should frighten you more than the fighting."},
	6: {"warden": "Each spire is a pyre. Someone is still climbing the last one.",
		"broker": "Ember glass. Sold to a woman who wanted to look like fire. She does now.",
		"rift": "Every pyre you pass has a name on it. Some of them are still warm."},
	7: {"warden": "The Foundry was built to make something beautiful. It has not stopped working.",
		"broker": "The glass remembers the city. Sometimes it sells that memory back.",
		"rift": "The Foundry is making something. You can hear the mould close."},
	8: {"warden": "The trees grow fruit so the dead have something to trade. Do not eat it.",
		"broker": "Orchard fruit. I do not ask who picked it.",
		"rift": "The orchard is fed from below. Everything here is fed from below."},
	9: {"warden": "The Maw does not want you. It simply does not stop opening.",
		"broker": "Ninth one to reach this depth with a purse. The other eight bought.",
		"rift": "The Maw is not hungry. It has simply stopped pretending to have a bottom."},
	10: {"warden": "This is where the rift was made. It was never given an off switch.",
		"broker": "This is the last layer I know. Below it, I would be a customer too.",
		"rift": "This is the throat. Everything above you is the wound's lips."},
}

@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $Sun
@onready var world_env: WorldEnvironment = $WorldEnvironment

var hud: GameHUD
var player: Player
var world_root: Node3D
var floor_root: Node3D
var entity_root: Node3D
var fx_root: Node3D

var grid := AStarGrid2D.new()
var walkable: Dictionary = {}
var bridge_cells: Dictionary = {}
var distance: Dictionary = {}
var start_cell := Vector2i(8, 14)
var enemies: Array[Enemy] = []
var portal: Node3D
var portal_area: Area3D
var portal_disc: MeshInstance3D
var portal_active := false

var layer := 1
var kills := 0
var total_enemies := 0
var run_active := false
var started := false
var hazard_timer := 7.0
var lava_timer := 0.0
var lava_warn_timer := 0.0
var camera_shake := 0.0
var rng := RandomNumberGenerator.new()
var model_cache: Dictionary = {}
var best_layer := 1
var sfx: Dictionary = {}
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_index := 0
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var ember_emitter: GPUParticles3D
var mouse_held := false
var hold_timer := 0.0
var last_move_target := Vector3(9999.0, 0.0, 9999.0)
var map_timer := 0.0
var theme: Dictionary = {}
var active_mods: Array = []
var boon_luck := 0.0
var run_boons: Array = []
var coins := 0
var merchant_npc: Node3D
var merchant_area: Area3D
var merchant_near := false
var shop_offers: Array = []
var shop_open := false
var boss_enemy: Enemy
var music_tracks: Array = []
var boss_tracks: Array = []
var music_boss := false
var music_mode := ""
var merchant_tracks: Array = []
var camera_zoom := 1.0
var camera_focus := Vector3.ZERO
var attack_target: Enemy
var attackers: Array = []
var move_marker: Node3D
var move_marker_point := Vector3(9999.0, 0.0, 9999.0)
var engage_timer := 0.0
var boss_phase_name := ""
var hazards_alive := 0
var duel_mode := false
var rival: Enemy
var duel_casts := 0
var online_mode := false
var world_seed := 0
var my_seat := 0
var online_peers := 1
var net: Node
var camera_pan := Vector3.ZERO
var zoom_target := 1.0
var boss_framing := 0.0
var pan_drag := false
var decor_props: Array = []
var prop_fade_timer := 0.0
var character_name := "VESNA"
var character_class := "BLOOD SORCERESS"
var character_class_id := "blood_sorceress"


func _ready() -> void:
	rng.randomize()
	GameSettings.load_all()
	Engine.max_fps = int(GameSettings.get_value("fps_cap"))
	world_root = Node3D.new()
	world_root.name = "World"
	add_child(world_root)
	floor_root = Node3D.new()
	floor_root.name = "Floor"
	world_root.add_child(floor_root)
	entity_root = Node3D.new()
	entity_root.name = "Entities"
	world_root.add_child(entity_root)
	fx_root = Node3D.new()
	fx_root.name = "FX"
	world_root.add_child(fx_root)
	hud = GameHUD.new()
	add_child(hud)
	hud.equip_requested.connect(_on_equip_requested)
	hud.unequip_requested.connect(_on_unequip_requested)
	hud.discard_requested.connect(_on_discard_requested)
	hud.ui_click.connect(_on_ui_click)
	hud.ability_pressed.connect(_on_hud_ability_pressed)
	hud.restart_pressed.connect(_restart_run)
	hud.start_pressed.connect(begin_run)
	hud.continue_pressed.connect(_continue_from_title)
	hud.settings_changed.connect(_apply_settings)
	hud.boon_chosen.connect(_on_boon_chosen)
	hud.shop_buy.connect(_on_shop_buy)
	hud.shop_close.connect(_on_shop_closed)
	hud.rift_map_requested.connect(_open_rift_map)
	hud.duel_pressed.connect(_start_duel)
	hud.duel_again_pressed.connect(_start_duel)
	hud.home_pressed.connect(_return_home)
	hud.net_action.connect(_on_net_action)
	hud.rift_enter_requested.connect(_on_rift_enter)
	hud.leave_run_pressed.connect(_return_home)
	hud.character_created.connect(_on_character_created)
	hud.passives_requested.connect(_open_passives)
	hud.passive_buy.connect(_on_passive_buy)
	hud.roster_requested.connect(_open_roster)
	hud.roster_load.connect(_on_roster_load)
	hud.roster_delete.connect(_on_roster_delete)
	hud.roster_create.connect(_on_roster_create)
	_setup_audio()
	_apply_settings()
	hud.show_loading()
	await get_tree().process_frame
	_create_player()
	_load_record()
	# The network decides between solo and a Summer World; both paths call
	# back into this script before the first floor is built.
	net = preload("res://client/net_client.gd").new()
	net.name = "RiftNet"
	add_child(net)
	net.start(self)


func boot_solo() -> void:
	online_mode = false
	_after_spawn(false)


func boot_online(seed_value: int, seat: int) -> void:
	online_mode = true
	world_seed = seed_value
	my_seat = seat
	_after_spawn(true)
	# A player who joined a World is already in that party's rift: no menu.
	started = true
	run_active = true
	hud.hide_title()
	hud.show_body()
	for enemy in enemies:
		enemy.frozen = false
	hud.toast("ONLINE RIFT  -  SEAT %d" % (seat + 1), Color(0.62, 0.95, 0.72), 2.6)


func set_online_peers(count: int) -> void:
	online_peers = maxi(1, count)
	if online_mode:
		hud.set_online(my_seat + 1, online_peers)


func _after_spawn(networked: bool) -> void:
	hud.set_hero(character_name, character_class)
	_generate_floor()
	camera.global_position = player.global_position + CAMERA_OFFSET
	camera.look_at(player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	hud.set_layer_info(layer, enemies.size(), total_enemies, kills)
	hud.set_relics(player.relics)
	if networked:
		hud.set_online(my_seat + 1, online_peers)
	else:
		hud.set_online(0, 1)
	hud.hide_loading()


func _create_player() -> void:
	player = Player.new()
	player.name = "Hero"
	world_root.add_child(player)
	player.add_to_group("local_player")
	var model := _class_model(character_class_id)
	player.setup(model[0], float(model[1]), model[2])
	player.set_class(character_class_id)
	player.died.connect(_on_player_died)
	player.damaged.connect(_on_player_damaged)
	player.healed.connect(_on_player_healed)
	player.health_changed.connect(_on_health_changed)
	player.focus_changed.connect(_on_focus_changed)
	player.ability_used.connect(_on_ability_used)
	player.life_spent.connect(_on_life_spent)
	player.leveled_up.connect(_on_player_leveled)


## [scene, scale, tint]. A class with its own generated character uses it; until
## that model exists the shared rig is tinted in the class colour so the
## silhouette still reads, and swapping in the model later needs no other change.
func _class_model(id: String) -> Array:
	var data := HeroClasses.definition(id)
	var path := String(data.get("model", ""))
	var scale := float(data.get("model_scale", 1.35))
	var scene: PackedScene = _get_model(path) if not path.is_empty() else null
	if scene != null:
		return [scene, scale, Color(0, 0, 0, 0)]
	return [_find_hero_scene(), 1.35, data.get("color", Color(0.6, 0.6, 0.6))]


func _apply_class_visuals() -> void:
	if player == null:
		return
	var model := _class_model(character_class_id)
	player.set_model(model[0], float(model[1]), model[2])
	player.set_class(character_class_id)
	if hud != null:
		hud.apply_class(HeroClasses.definition(character_class_id))
		hud.set_focus(player.focus, player.focus_max, player.focus_name, player.focus_color)


func _load_record() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(RECORD_PATH) == OK:
		best_layer = maxi(1, int(cfg.get_value("record", "best_layer", 1)))
	hud.set_record(best_layer)


func _save_record() -> void:
	if layer > best_layer:
		best_layer = layer
		var cfg := ConfigFile.new()
		cfg.set_value("record", "best_layer", best_layer)
		cfg.save(RECORD_PATH)
	hud.set_record(best_layer)


func _save_run() -> void:
	if online_mode:
		# Character persistence moves to the authority in the next phase;
		# two local clients must not fight over one save file.
		return
	if player == null or not run_active or not player.alive:
		return
	var relics: Array = []
	for item in player.relics:
		relics.append(item.duplicate(true) if not item.is_empty() else {})
	RunSave.write({
		"layer": layer,
		"name": character_name,
		"class": character_class,
		"class_id": character_class_id,
		"coins": coins,
		"boons": run_boons.duplicate(),
		"relics": relics,
		"level": player.level,
		"xp": player.xp,
		"health": clampf(player.health / maxf(1.0, player.max_health), 0.0, 1.0),
		"best": best_layer,
		"passives": player.passive_nodes.duplicate(),
		"passive_points": player.passive_points,
		"settings": GameSettings.snapshot(),
	})
	Roster.update(RunSave.slot, {
		"name": character_name,
		"class_id": character_class_id,
		"level": player.level,
		"layer": layer,
		"best": best_layer,
		"coins": coins,
	})
	if hud != null:
		hud.show_saved()


func continue_run() -> bool:
	var data := RunSave.read()
	if data.is_empty():
		return false
	duel_mode = false
	character_name = String(data.get("name", character_name))
	character_class = String(data.get("class", character_class))
	character_class_id = String(data.get("class_id", character_class_id))
	if not HeroClasses.CLASSES.has(character_class_id):
		character_class_id = "blood_sorceress"
	character_class = HeroClasses.display_name(character_class_id)
	_apply_class_visuals()
	hud.set_hero(character_name, character_class)
	var saved_settings = data.get("settings", {})
	if typeof(saved_settings) == TYPE_DICTIONARY and not saved_settings.is_empty():
		GameSettings.apply_snapshot(saved_settings)
		GameSettings.persist_now()
		_apply_settings()
	layer = maxi(1, int(data.get("layer", 1)))
	coins = maxi(0, int(data.get("coins", 0)))
	run_boons.clear()
	var saved_boons = data.get("boons", [])
	if typeof(saved_boons) == TYPE_ARRAY:
		for key in saved_boons:
			run_boons.append(String(key))
	started = true
	run_active = true
	hud.hide_title()
	hud.show_body()
	player.revive()
	player.set_progress(int(data.get("level", 1)), float(data.get("xp", 0.0)))
	var saved_passives: Array = data.get("passives", [])
	player.set_passives(saved_passives, int(data.get("passive_points", 0)))
	hud.close_relic_window()
	var saved_relics = data.get("relics", [])
	if typeof(saved_relics) == TYPE_ARRAY:
		for item in saved_relics:
			if typeof(item) == TYPE_DICTIONARY and not item.is_empty():
				player.equip(item)
	for key in run_boons:
		_apply_boon(String(key), false)
	_generate_floor()
	var ratio := clampf(float(data.get("health", 1.0)), 0.25, 1.0)
	player.health = maxf(1.0, player.max_health * ratio)
	player.health_changed.emit(player.health, player.max_health)
	hud.set_coins(coins)
	hud.set_relics(player.relics)
	hud.flash_transition()
	hud.toast("RIFT RESTORED  -  LAYER %d" % layer, Color(1.0, 0.78, 0.35), 2.8)
	_save_run()
	return true


func _find_hero_scene() -> PackedScene:
	var dir := DirAccess.open(HERO_DIR)
	if dir == null:
		return null
	var files := dir.get_files()
	for extension in ["tscn", "glb"]:
		for file in files:
			if String(file).get_extension().to_lower() == extension:
				var res := load(HERO_DIR.path_join(file))
				if res is PackedScene:
					return res
	return null


func _setup_audio() -> void:
	_load_sfx("cast", "res://audio/cast_blood.wav")
	_load_sfx("hit", "res://audio/hit_impact.wav")
	_load_sfx("portal", "res://audio/rift_portal.wav")
	_load_sfx("lava", "res://audio/lava_burst.wav")
	_load_sfx("death", "res://audio/enemy_death.wav")
	_load_sfx("pickup", "res://audio/loot_pickup.wav")
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_pool.append(p)
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -9.0
	add_child(music_player)
	music_player.finished.connect(_restart_music)
	music_tracks = _music_list("res://audio/music") + _music_list("res://audio/generated/metal_combat") + _music_list("res://audio/generated/metal_combat2") + _music_list("res://audio/generated/metal_combat3") + _music_list("res://audio/generated/metal_combat4") + _music_list("res://audio/generated/metal_combat5") + _music_list("res://audio/generated/metal_combat6")
	boss_tracks = _music_list("res://audio/generated/metal_boss")
	merchant_tracks = _music_list("res://audio/generated/metal_merchant")
	play_music(false)
	ambient_player = AudioStreamPlayer.new()
	ambient_player.volume_db = -16.0
	add_child(ambient_player)
	ambient_player.finished.connect(_restart_ambient)
	var ambient_path := _find_audio("res://audio/ambience")
	if ambient_path != "":
		ambient_player.stream = load(ambient_path)
		ambient_player.play()


func _find_audio(dir_path: String) -> String:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ""
	for file in dir.get_files():
		var ext := String(file).get_extension().to_lower()
		if ext == "mp3" or ext == "wav" or ext == "ogg":
			return dir_path.path_join(file)
	return ""


func _music_list(dir_path: String) -> Array:
	var list: Array = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return list
	for file in dir.get_files():
		var ext := String(file).get_extension().to_lower()
		if ext == "mp3" or ext == "wav" or ext == "ogg":
			list.append(dir_path.path_join(file))
	return list


func play_music(boss: bool) -> void:
	music_boss = boss
	var list := boss_tracks if boss and not boss_tracks.is_empty() else music_tracks
	if list.is_empty():
		return
	var index := 0
	if not boss:
		index = _combat_track_index(list.size())
	_play_track("boss" if boss else "combat", list, index)


func _combat_track_index(size: int) -> int:
	var ord := 0
	for l in range(1, layer):
		if _is_merchant_layer_at(l) or _is_boss_layer_at(l):
			continue
		ord += 1
	return ord % maxi(1, size)


func play_merchant_music() -> void:
	if merchant_tracks.is_empty():
		return
	_play_track("merchant", merchant_tracks, 0)


func _play_track(mode: String, list: Array, index: int) -> void:
	if music_player == null or list.is_empty():
		return
	var path := String(list[absi(index) % list.size()])
	var stream := load(path)
	if music_mode == mode and music_player.playing and music_player.stream == stream:
		return
	music_mode = mode
	music_player.stream = stream
	music_player.play()


func _restart_music() -> void:
	if music_player.stream != null:
		music_player.play()


func _restart_ambient() -> void:
	if ambient_player.stream != null:
		ambient_player.play()


func _load_sfx(key: String, path: String) -> void:
	if ResourceLoader.exists(path):
		sfx[key] = load(path)


func play_sfx(key: String, volume_db := 0.0, pitch_variation := 0.08) -> void:
	if not sfx.has(key):
		return
	var sfx_level := maxf(0.0001, float(GameSettings.get_value("sfx")))
	var p := sfx_pool[sfx_index % sfx_pool.size()]
	sfx_index += 1
	p.stream = sfx[key]
	p.volume_db = volume_db + linear_to_db(sfx_level)
	p.pitch_scale = 1.0 + rng.randf_range(-pitch_variation, pitch_variation)
	p.play()


func _apply_settings() -> void:
	zoom_target = clampf(float(GameSettings.get_value("camera_zoom")), 0.78, 1.4)
	camera_zoom = zoom_target
	var master := clampf(float(GameSettings.get_value("master")), 0.0, 1.0)
	AudioServer.set_bus_mute(0, master <= 0.001)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master, 0.0001)))
	if music_player != null:
		var music_level := maxf(0.0001, float(GameSettings.get_value("music")))
		music_player.volume_db = -9.0 + linear_to_db(music_level)
	if ambient_player != null:
		var amb_level := maxf(0.0001, float(GameSettings.get_value("ambience")))
		ambient_player.volume_db = -16.0 + linear_to_db(amb_level)
	Engine.max_fps = int(GameSettings.get_value("fps_cap"))
	var fullscreen := bool(GameSettings.get_value("fullscreen"))
	var mode := DisplayServer.window_get_mode()
	if fullscreen and mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not fullscreen and mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var vsync := bool(GameSettings.get_value("vsync"))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	_apply_brightness()
	_save_run()


func _apply_brightness() -> void:
	if world_env == null or world_env.environment == null:
		return
	var env := world_env.environment
	env.adjustment_enabled = true
	env.adjustment_brightness = float(GameSettings.get_value("brightness"))


func _generate_floor() -> void:
	if online_mode:
		# Every client builds the same floor for a given world and layer.
		rng.seed = world_seed + layer * 9176
	_clear_floor()
	hud.hide_boons()
	if duel_mode:
		_generate_duel_arena()
		return
	theme = THEMES[(layer - 1) % THEMES.size()]
	if _is_merchant_layer():
		# Every broker floor is a market, dressed in that depth's own palette.
		theme = theme.duplicate()
		theme["layout"] = "plaza"
		theme["decor"] = maxf(1.65, float(theme.get("decor", 1.0)))
	_roll_modifiers()
	portal = null
	portal_area = null
	portal_disc = null
	portal_active = false
	boss_enemy = null
	enemies.clear()
	kills = 0
	player.ensure_level(layer)
	hazard_timer = 11.0 * (0.7 if has_mod("unstable") else 1.0)
	_apply_theme()
	_make_layout()
	_build_ground()
	_build_decor()
	player.global_position = _cell_to_world(start_cell) + Vector3(0.0, 0.15, 0.0)
	player.velocity = Vector3.ZERO
	player.stop()
	camera_pan = Vector3.ZERO
	camera_focus = player.global_position
	camera.global_position = _camera_desired()
	camera.look_at(camera_focus + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	var merchant_floor := _is_merchant_layer()
	if merchant_floor:
		_spawn_merchant()
	else:
		_spawn_packs()
	_spawn_embers()
	hud.set_map_cells(walkable, bridge_cells, GRID)
	hud.set_modifiers(active_mods)
	hud.set_health(player.health, player.max_health)
	hud.set_relics(player.relics)
	hud.set_boss("", 0.0, false)
	hud.set_coins(coins)
	if merchant_floor:
		hud.set_layer_info(layer, 0, 0, kills)
		hud.set_theme_name("THE ASHEN BAZAAR")
		hud.set_status("NO HOSTILES  -  THE BROKER WAITS")
		hud.whisper(_layer_whisper())
		play_merchant_music()
		_open_portal(false)
	else:
		hud.set_layer_info(layer, enemies.size(), total_enemies, kills)
		hud.set_theme_name(String(theme.get("name", "RIFT")))
		hud.set_status("PACKS AWAKE")
		hud.whisper(_layer_whisper())
		play_music(_is_boss_layer())
	map_timer = 0.0
	_save_run()


func _generate_duel_arena() -> void:
	theme = THEMES[8]
	active_mods.clear()
	portal = null
	portal_area = null
	portal_disc = null
	portal_active = false
	boss_enemy = null
	enemies.clear()
	rival = null
	kills = 0
	hazard_timer = 9999.0
	level_label_refresh()
	_apply_theme()
	_make_layout()
	_build_ground()
	_build_decor()
	player.global_position = _cell_to_world(start_cell) + Vector3(0.0, 0.15, 0.0)
	player.velocity = Vector3.ZERO
	player.stop()
	camera_focus = player.global_position
	camera.global_position = _camera_desired()
	camera.look_at(camera_focus + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	_spawn_embers()
	_spawn_rival()
	hud.set_map_cells(walkable, bridge_cells, GRID)
	hud.set_modifiers([])
	hud.set_health(player.health, player.max_health)
	hud.set_relics(player.relics)
	hud.set_coins(coins)
	hud.set_theme_name("THE MIRROR RING")
	hud.set_layer_info(layer, 1, 1, kills)
	hud.set_status("DUEL  -  FIRST BLOOD")
	hud.set_boss("THE MIRROR", 1.0, true)
	hud.whisper("She has your face. Do not let her keep it.")
	play_music(true)
	map_timer = 0.0


func level_label_refresh() -> void:
	if player == null:
		return
	hud.set_level(player.level, player.xp, player.xp_to_next())


func _spawn_rival() -> void:
	var far: Array = []
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		if _cell_to_world(cell).distance_to(player.global_position) > 15.0:
			far.append(cell)
	if far.is_empty():
		for cell in walkable.keys():
			if walkable[cell] and cell != start_cell:
				far.append(cell)
	if far.is_empty():
		far.append(start_cell)
	var cell: Vector2i = far[rng.randi() % far.size()]
	rival = _spawn_enemy("mirror", cell)
	boss_enemy = rival
	total_enemies = 1
	FX.nova(fx_root, rival.global_position, Color(0.78, 0.32, 1.0, 1.0), 3.8)
	FX.ring(fx_root, rival.global_position, Color(0.95, 0.35, 0.45, 0.8), 3.2, 0.8, 0.07)


func _start_duel() -> void:
	if player == null:
		return
	if run_active and not duel_mode:
		return
	get_tree().paused = false
	duel_mode = true
	started = true
	run_active = true
	duel_casts = 0
	hud.hide_title()
	hud.hide_death()
	hud.hide_duel_result()
	hud.hide_boons()
	hud.hide_prompt()
	hud.close_relic_window()
	hud.close_shop()
	hud.show_body()
	player.revive()
	player.set_progress(maxi(1, player.level), player.xp)
	_generate_floor()
	hud.flash_transition()
	hud.toast("THE MIRROR RING", Color(0.85, 0.5, 1.0), 2.4)


func _duel_finished(won: bool) -> void:
	run_active = false
	hud.set_boss("", 0.0, false)
	hud.hide_boons()
	hud.close_relic_window()
	var casts := duel_casts
	var timer := get_tree().create_timer(0.8)
	timer.timeout.connect(func() -> void:
		if duel_mode:
			hud.show_duel_result(won, casts)
	)


func _return_home() -> void:
	hud.hide_codex()
	hud.hide_pause()
	duel_mode = false
	run_active = false
	started = false
	mouse_held = false
	attack_target = null
	_clear_move_marker()
	hud.hide_duel_result()
	hud.hide_death()
	hud.hide_boons()
	hud.hide_prompt()
	hud.close_relic_window()
	hud.close_shop()
	hud.hide_body()
	hud.show_title_again()


func _roll_modifiers() -> void:
	active_mods.clear()
	if _is_merchant_layer():
		return
	var pool := MODIFIERS.duplicate()
	var count := 1
	if layer >= 6:
		count = 2
	if layer >= 11:
		count = 3
	for i in count:
		if pool.is_empty():
			break
		var pick: Dictionary = pool[rng.randi() % pool.size()]
		pool.erase(pick)
		active_mods.append(pick)


## One line of the story spine for this layer, from the Warden or the Broker.
func _story_line(who: String, layer_num: int) -> String:
	var entry: Dictionary = STORY.get(layer_num, {})
	return String(entry.get(who, ""))


## What the layer says when you arrive: where you are, then the rift's voice.
func _layer_whisper() -> String:
	var lore := String(LAYER_LORE.get(String(theme.get("name", "")), ""))
	var voice := _story_line("rift", layer)
	if voice.is_empty():
		return lore
	return "%s\n%s" % [lore, voice]


func has_mod(key: String) -> bool:
	for mod in active_mods:
		if String(mod.get("key", "")) == key:
			return true
	return false


func _apply_theme() -> void:
	var fog: Color = theme.get("fog", Color(0.1, 0.04, 0.05))
	var ambient: Color = theme.get("ambient", Color(0.3, 0.2, 0.24))
	if world_env != null and world_env.environment != null:
		var env := world_env.environment
		env.fog_light_color = fog
		env.ambient_light_color = ambient
		env.fog_enabled = true
	if sun != null:
		var sun_color: Color = theme.get("sun", Color(1.0, 0.86, 0.78))
		sun.light_color = sun_color.lerp(fog.lightened(0.35), 0.35)


func _clear_floor() -> void:
	if shop_open:
		shop_open = false
		hud.close_shop()
	hud.hide_prompt()
	for root in [floor_root, entity_root, fx_root]:
		for child in root.get_children():
			child.queue_free()
	ember_emitter = null
	decor_props.clear()
	merchant_npc = null
	merchant_area = null
	merchant_near = false
	shop_offers.clear()
	attackers.clear()
	attack_target = null
	hazards_alive = 0
	move_marker = null
	move_marker_point = Vector3(9999.0, 0.0, 9999.0)


func _make_layout() -> void:
	walkable.clear()
	bridge_cells.clear()
	for x in GRID:
		for y in GRID:
			walkable[Vector2i(x, y)] = false
	start_cell = Vector2i(GRID / 2, GRID / 2)
	walkable[start_cell] = true
	var target_density := float(theme.get("density", 0.66))
	var target := int(float(GRID * GRID) * target_density)
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var pos := start_cell
	var carved := 1
	var guard := 0
	while carved < target and guard < 9000:
		guard += 1
		var dir: Vector2i = directions[rng.randi_range(0, 3)]
		if rng.randf() < 0.2:
			dir = directions[rng.randi_range(0, 3)]
		var next := pos + dir
		if next.x < 1 or next.y < 1 or next.x > GRID - 2 or next.y > GRID - 2:
			pos = start_cell
			continue
		pos = next
		if not walkable[pos]:
			walkable[pos] = true
			carved += 1
		if rng.randf() < 0.16:
			var side := pos + Vector2i(dir.y, dir.x)
			if side.x > 0 and side.y > 0 and side.x < GRID - 1 and side.y < GRID - 1:
				if not walkable[side]:
					walkable[side] = true
					carved += 1
	var chambers := 2 + mini(2, layer)
	for i in chambers:
		var centers: Array = []
		for cell in walkable.keys():
			if walkable[cell]:
				centers.append(cell)
		if centers.is_empty():
			break
		var center: Vector2i = centers[rng.randi() % centers.size()]
		for x in range(center.x - 1, center.x + 2):
			for y in range(center.y - 1, center.y + 2):
				if x > 0 and y > 0 and x < GRID - 1 and y < GRID - 1:
					if rng.randf() < 0.85:
						walkable[Vector2i(x, y)] = true
	walkable[start_cell] = true
	var style := String(theme.get("layout", "causeway"))
	_apply_layout_style(style)
	if style == "causeway" or style == "warrens":
		var rivers := int(theme.get("rivers", 1))
		for i in rivers:
			if i == 0:
				_carve_river(false, 1, clampi(start_cell.x + 3, 3, GRID - 4))
			else:
				_carve_river(i % 2 == 0, 1 if rng.randf() < 0.7 else 2)
		var pools := int(theme.get("pools", 1))
		for i in pools:
			_carve_pool()
	_fill_lava_spits()
	_clear_start_pad()
	_carve_gate_river()
	_ensure_connected()
	_widen_bridges()
	_rebuild_grid()
	_compute_distances()


func _inside_map(cell: Vector2i) -> bool:
	return cell.x > 0 and cell.y > 0 and cell.x < GRID - 1 and cell.y < GRID - 1


func _carve_rect(center: Vector2i, radius: int) -> void:
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			var cell := Vector2i(x, y)
			if _inside_map(cell):
				walkable[cell] = true


func _carve_line(a: Vector2i, b: Vector2i) -> void:
	var cell := a
	while cell != b:
		if _inside_map(cell):
			walkable[cell] = true
		if cell.x != b.x:
			cell += Vector2i(signi(b.x - cell.x), 0)
		else:
			cell += Vector2i(0, signi(b.y - cell.y))
	walkable[b] = true


func _apply_layout_style(style: String) -> void:
	match style:
		"warrens":
			for i in 4:
				var c := Vector2i(rng.randi_range(3, GRID - 4), rng.randi_range(3, GRID - 4))
				_carve_rect(c, rng.randi_range(1, 2))
				_carve_line(start_cell, c)
		"cathedral":
			for offset in [Vector2i(4, 4), Vector2i(4, -4), Vector2i(-4, 4), Vector2i(-4, -4)]:
				var c: Vector2i = start_cell + offset
				_carve_rect(c, 2)
				_carve_line(start_cell, c)
		"chasm":
			var offset := clampi(start_cell.y + rng.randi_range(-2, 2), 5, GRID - 7)
			for i in range(2, GRID - 2):
				var y := offset + int(round(sin(float(i) * 0.42 + 1.1) * 2.0))
				if i < 6 or i > GRID - 7:
					continue
				for w in 2:
					var cell := Vector2i(i, y + w)
					if _inside_map(cell):
						walkable[cell] = false
		"spires":
			for cell in walkable.keys():
				walkable[cell] = false
			for dx in [-6, 0, 6]:
				for dy in [-6, 0, 6]:
					_carve_rect(start_cell + Vector2i(dx, dy), 2)
			for dx in [-6, 0, 6]:
				for dy in [-6, 0, 6]:
					var c := start_cell + Vector2i(dx, dy)
					if dx < 6:
						_carve_line(c, start_cell + Vector2i(dx + 6, dy))
					if dy < 6:
						_carve_line(c, start_cell + Vector2i(dx, dy + 6))
		"terrace":
			for x in GRID:
				for y in GRID:
					var cell := Vector2i(x, y)
					var d := maxi(absi(x - start_cell.x), absi(y - start_cell.y))
					if d > 7:
						walkable[cell] = false
					elif d == 3 or d == 5:
						var gap := absi(x - start_cell.x) <= 1 or absi(y - start_cell.y) <= 1
						walkable[cell] = gap
		"cross":
			for i in range(2, GRID - 2):
				for w in 2:
					var row_cell := Vector2i(i, start_cell.y - 1 + w)
					var col_cell := Vector2i(start_cell.x - 1 + w, i)
					if _inside_map(row_cell):
						walkable[row_cell] = true
					if _inside_map(col_cell):
						walkable[col_cell] = true
			_carve_rect(start_cell, 2)
		"ring":
			for x in GRID:
				for y in GRID:
					var cell := Vector2i(x, y)
					var d := Vector2(cell - start_cell).length()
					walkable[cell] = d <= 3.2 or (d >= 4.2 and d <= 6.8)
			for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				for s in range(0, 9):
					var cell: Vector2i = start_cell + dir * s
					if _inside_map(cell):
						walkable[cell] = true
		"furnace":
			for x in GRID:
				for y in GRID:
					var cell := Vector2i(x, y)
					var d := Vector2(cell - start_cell).length()
					walkable[cell] = d <= 2.6 or (d >= 3.8 and d <= 5.8)
			for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				for s in range(0, 9):
					var cell: Vector2i = start_cell + dir * s
					if _inside_map(cell):
						walkable[cell] = true
		"plaza":
			_carve_rect(start_cell, 3)
			for i in range(2, GRID - 2):
				for w in 2:
					var row_cell := Vector2i(i, start_cell.y - 1 + w)
					var col_cell := Vector2i(start_cell.x - 1 + w, i)
					if _inside_map(row_cell):
						walkable[row_cell] = true
					if _inside_map(col_cell):
						walkable[col_cell] = true
	walkable[start_cell] = true


func _fill_lava_spits() -> void:
	var spits: Array = []
	for cell in walkable.keys():
		if walkable[cell]:
			continue
		if cell.x <= 1 or cell.y <= 1 or cell.x >= GRID - 2 or cell.y >= GRID - 2:
			continue
		var open := 0
		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if walkable.get(cell + dir, false):
				open += 1
		if open >= 3:
			spits.append(cell)
	for cell in spits:
		walkable[cell] = true


func _widen_bridges() -> void:
	var extra: Array = []
	for cell in bridge_cells.keys():
		for dir in [Vector2i(1, 0), Vector2i(0, 1)]:
			var side: Vector2i = cell + dir
			if side.x <= 1 or side.y <= 1 or side.x >= GRID - 2 or side.y >= GRID - 2:
				continue
			if walkable.get(side, false):
				continue
			if rng.randf() < 0.65:
				extra.append(side)
	for cell in extra:
		walkable[cell] = true
		bridge_cells[cell] = true



func _walkable_count() -> int:
	var count := 0
	for cell in walkable.keys():
		if walkable[cell]:
			count += 1
	return count


func _carve_river(horizontal: bool, width: int, start_offset := -1) -> void:
	var offset := start_offset if start_offset >= 0 else rng.randi_range(4, GRID - 5)
	for i in range(1, GRID - 1):
		offset = clampi(offset + rng.randi_range(-1, 1), 2, GRID - 3)
		for w in width:
			var cell := Vector2i(i, offset + w) if horizontal else Vector2i(offset + w, i)
			if cell.x > 0 and cell.y > 0 and cell.x < GRID - 1 and cell.y < GRID - 1:
				walkable[cell] = false


func _carve_pool() -> void:
	var origin := Vector2i(rng.randi_range(2, GRID - 4), rng.randi_range(2, GRID - 4))
	if origin.distance_to(start_cell) < 3.0:
		return
	var w := rng.randi_range(2, 3)
	var h := rng.randi_range(2, 2)
	for x in range(origin.x, origin.x + w):
		for y in range(origin.y, origin.y + h):
			if x < 1 or y < 1 or x > GRID - 2 or y > GRID - 2:
				continue
			if rng.randf() < 0.82:
				walkable[Vector2i(x, y)] = false


func _clear_start_pad() -> void:
	for x in range(start_cell.x - 1, start_cell.x + 2):
		for y in range(start_cell.y - 1, start_cell.y + 2):
			if x > 0 and y > 0 and x < GRID - 1 and y < GRID - 1:
				walkable[Vector2i(x, y)] = true
	walkable[start_cell] = true


func _carve_gate_river() -> void:
	var row := start_cell.y - 3
	var gap := rng.randi_range(3, GRID - 6)
	for x in range(2, GRID - 2):
		if absi(x - gap) <= 1:
			continue
		if rng.randf() < 0.82:
			walkable[Vector2i(x, row)] = false
		if rng.randf() < 0.12:
			walkable[Vector2i(x, row - 1)] = false


func _portal_cell() -> Vector2i:
	var best := start_cell
	var best_dist := -1
	for cell in distance.keys():
		if cell.x < 2 or cell.y < 2 or cell.x > GRID - 3 or cell.y > GRID - 3:
			continue
		var d := int(distance[cell])
		if d > best_dist:
			best_dist = d
			best = cell
	return best

func _ensure_connected() -> void:
	var guard := 0
	while guard < 24:
		guard += 1
		var reached := _flood(start_cell)
		var missing: Array = []
		for cell in walkable.keys():
			if walkable[cell] and not reached.has(cell):
				missing.append(cell)
		if missing.is_empty():
			return
		var target: Vector2i = missing[rng.randi() % missing.size()]
		var anchor := _nearest_cell(reached, target)
		_carve_bridge(anchor, target)
	var final_reached := _flood(start_cell)
	for cell in walkable.keys():
		if walkable[cell] and not final_reached.has(cell):
			walkable[cell] = false


func _flood(origin: Vector2i) -> Dictionary:
	var seen := {origin: true}
	var queue: Array[Vector2i] = [origin]
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while queue.size() > 0:
		var cell: Vector2i = queue.pop_back()
		for dir in directions:
			var next: Vector2i = cell + dir
			if next.x < 0 or next.y < 0 or next.x >= GRID or next.y >= GRID:
				continue
			if seen.has(next) or not walkable.get(next, false):
				continue
			seen[next] = true
			queue.append(next)
	return seen


func _nearest_cell(from_set: Dictionary, target: Vector2i) -> Vector2i:
	var best := target
	var best_dist := 1e9
	for cell in from_set.keys():
		var d := absi(cell.x - target.x) + absi(cell.y - target.y)
		if d < best_dist:
			best_dist = d
			best = cell
	return best


func _carve_bridge(from_cell: Vector2i, to_cell: Vector2i) -> void:
	var cell := from_cell
	var guard := 0
	var carved: Array[Vector2i] = []
	while cell != to_cell and guard < 80:
		guard += 1
		if not walkable.get(cell, false):
			carved.append(cell)
		walkable[cell] = true
		if cell.x != to_cell.x:
			cell += Vector2i(signi(to_cell.x - cell.x), 0)
		elif cell.y != to_cell.y:
			cell += Vector2i(0, signi(to_cell.y - cell.y))
	walkable[to_cell] = true
	for bridge in carved:
		bridge_cells[bridge] = true


func _compute_distances() -> void:
	distance.clear()
	distance[start_cell] = 0
	var queue: Array[Vector2i] = [start_cell]
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while queue.size() > 0:
		var cell: Vector2i = queue.pop_front()
		for dir in directions:
			var next: Vector2i = cell + dir
			if not walkable.get(next, false) or distance.has(next):
				continue
			distance[next] = int(distance[cell]) + 1
			queue.append(next)


func _rebuild_grid() -> void:
	grid = AStarGrid2D.new()
	grid.region = Rect2i(0, 0, GRID, GRID)
	grid.cell_size = Vector2(1, 1)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			grid.set_point_solid(cell, not bool(walkable.get(cell, false)))


func _cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3((float(cell.x) - float(GRID - 1) * 0.5) * CELL, 0.0, (float(cell.y) - float(GRID - 1) * 0.5) * CELL)


func _world_to_cell(point: Vector3) -> Vector2i:
	return Vector2i(roundi(point.x / CELL + float(GRID - 1) * 0.5), roundi(point.z / CELL + float(GRID - 1) * 0.5))


func _is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID and cell.y < GRID


func _nearest_walkable(cell: Vector2i) -> Vector2i:
	if walkable.get(cell, false):
		return cell
	var best := start_cell
	var best_dist := 1e9
	for c in walkable.keys():
		if not walkable[c]:
			continue
		var d := Vector2(c - cell).length_squared()
		if d < best_dist:
			best_dist = d
			best = c
	return best


func find_path(from_point: Vector3, to_point: Vector3) -> PackedVector3Array:
	var from_cell := _world_to_cell(from_point)
	var to_cell := _world_to_cell(to_point)
	if not _is_inside(from_cell):
		from_cell = _nearest_walkable(from_cell)
	if not _is_inside(to_cell):
		to_cell = _nearest_walkable(to_cell)
	from_cell = _nearest_walkable(from_cell)
	to_cell = _nearest_walkable(to_cell)
	var out := PackedVector3Array()
	if from_cell == to_cell:
		out.append(_cell_to_world(to_cell))
		return out
	var id_path := grid.get_id_path(from_cell, to_cell)
	for p in id_path:
		var cell := Vector2i(int(p.x), int(p.y))
		out.append(_cell_to_world(cell))
	if out.size() > 0:
		out.remove_at(0)
	return out


func _corner_jitter(lx: int, lz: int) -> Vector2:
	var h := (lx * 73856093) ^ (lz * 19349663) ^ 0x9E3779B9
	var a := float((h >> 3) & 255) / 255.0 - 0.5
	var b := float((h >> 11) & 255) / 255.0 - 0.5
	return Vector2(a, b) * 0.85


func _build_ground() -> void:
	var stone := SurfaceTool.new()
	stone.begin(Mesh.PRIMITIVE_TRIANGLES)
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = rng.randi()
	var half := CELL * 0.5
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			var center := _cell_to_world(cell)
			if not walkable.get(cell, false):
				continue
			var j00 := _corner_jitter(2 * x - 1, 2 * y - 1)
			var j10 := _corner_jitter(2 * x + 1, 2 * y - 1)
			var j11 := _corner_jitter(2 * x + 1, 2 * y + 1)
			var j01 := _corner_jitter(2 * x - 1, 2 * y + 1)
			var c0 := Vector3(center.x - half + j00.x, j00.x * 0.045, center.z - half + j00.y)
			var c1 := Vector3(center.x + half + j10.x, j10.y * 0.045, center.z - half + j10.y)
			var c2 := Vector3(center.x + half + j11.x, j11.x * 0.045, center.z + half + j11.y)
			var c3 := Vector3(center.x - half + j01.x, j01.y * 0.045, center.z + half + j01.y)
			var is_bridge := bridge_cells.has(cell)
			var shade := 0.94 + local_rng.randf() * 0.12
			var tint := Color(shade, shade * 0.95, shade * 0.93)
			if is_bridge:
				tint = Color(shade * 1.25, shade * 1.12, shade * 1.0)
			var dark_tint := Color(tint.r * 0.45, tint.g * 0.4, tint.b * 0.4, 0.16)
			_add_quad(stone, c0, c1, c2, c3, Vector3.UP, tint, 0.30)
			var lip := 0.16
			var corners := [c0, c1, c2, c3]
			var normals := [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)]
			var neighbors := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
			for e in 4:
				var a: Vector3 = corners[e]
				var b: Vector3 = corners[(e + 1) % 4]
				var next_cell: Vector2i = cell + neighbors[e]
				var depth := 4.6 if not walkable.get(next_cell, false) else lip
				var ab := Vector3(a.x, -depth, a.z)
				var bb := Vector3(b.x, -depth, b.z)
				_add_quad(stone, a, b, bb, ab, normals[e], dark_tint, 0.20)
				if is_bridge and not walkable.get(next_cell, false):
					var rail := 0.24
					var ra := Vector3(a.x, 0.0, a.z)
					var rb := Vector3(b.x, 0.0, b.z)
					var rt := Vector3(a.x, rail, a.z)
					var ru := Vector3(b.x, rail, b.z)
					_add_quad(stone, ra, rb, ru, rt, normals[e], Color(0.55, 0.4, 0.28, 0.35), 0.2)
	var stone_mesh := stone.commit()
	var ground := MeshInstance3D.new()
	ground.name = "Stone"
	ground.mesh = stone_mesh
	ground.material_override = _stone_material()
	floor_root.add_child(ground)
	var sea := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(420, 420)
	sea.mesh = plane
	sea.position.y = -1.05
	sea.material_override = _lava_material(0.9, 0.95)
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_root.add_child(sea)
	var body := StaticBody3D.new()
	body.name = "FloorBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(GRID * CELL, 1.0, GRID * CELL)
	shape.shape = box
	shape.position.y = -0.5
	body.add_child(shape)
	var wall_height := 3.0
	var half_arena := GRID * CELL * 0.5
	var walls := [
		[Vector3(half_arena * 2.0, wall_height, 0.5), Vector3(0.0, wall_height * 0.5, half_arena)],
		[Vector3(half_arena * 2.0, wall_height, 0.5), Vector3(0.0, wall_height * 0.5, -half_arena)],
		[Vector3(0.5, wall_height, half_arena * 2.0), Vector3(half_arena, wall_height * 0.5, 0.0)],
		[Vector3(0.5, wall_height, half_arena * 2.0), Vector3(-half_arena, wall_height * 0.5, 0.0)],
	]
	for wall in walls:
		var wall_shape := CollisionShape3D.new()
		var wall_box := BoxShape3D.new()
		wall_box.size = wall[0]
		wall_shape.shape = wall_box
		wall_shape.position = wall[1]
		body.add_child(wall_shape)
	floor_root.add_child(body)
func _add_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3, color: Color, uv_scale: float) -> void:
	for vertex in [a, b, c, a, c, d]:
		st.set_normal(normal)
		st.set_color(color)
		st.set_uv(Vector2(vertex.x, vertex.z) * uv_scale)
		st.add_vertex(vertex)


func _stone_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/basalt.gdshader")
	if ResourceLoader.exists(BASALT_TEX):
		mat.set_shader_parameter("basalt_tex", load(BASALT_TEX))
	mat.set_shader_parameter("tex_mix", 0.78)
	mat.set_shader_parameter("detail_scale", 6.4)
	mat.set_shader_parameter("bump_strength", 3.0)
	mat.set_shader_parameter("seed", rng.randf() * 40.0)
	var rock: Color = theme.get("rock", Color(0.17, 0.145, 0.145))
	mat.set_shader_parameter("rock_color", rock)
	mat.set_shader_parameter("rock_dark", Color(rock.r * 0.16, rock.g * 0.14, rock.b * 0.16))
	mat.set_shader_parameter("seam_color", theme.get("seam", Color(1.0, 0.42, 0.10)))
	mat.set_shader_parameter("plate_scale", float(theme.get("plate", 0.13)))
	mat.set_shader_parameter("glow_strength", minf(float(theme.get("glow", 1.4)), 0.92))
	return mat


func _lava_material(scale_value: float, glow: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/lava.gdshader")
	mat.set_shader_parameter("plate_scale", scale_value)
	mat.set_shader_parameter("glow_strength", glow)
	mat.set_shader_parameter("flow_speed", 0.08)
	mat.set_shader_parameter("crust_color", theme.get("lava_crust", Color(0.09, 0.03, 0.02)))
	mat.set_shader_parameter("hot_color", theme.get("lava_hot", Color(1.0, 0.38, 0.05)))
	mat.set_shader_parameter("core_color", theme.get("lava_core", Color(1.0, 0.78, 0.30)))
	return mat


func _build_decor() -> void:
	var rock_scene := _get_model(ROCK_PATH)
	var pillar_scene := _get_model(DUNGEON_DIR + "pillar-01.glb")
	var pot_scene := _get_model(DUNGEON_DIR + "pot.glb")
	var decor_mult := float(theme.get("decor", 1.0))
	if String(theme.get("name", "")) == "SUNKEN CATHEDRAL":
		pot_scene = _get_model(DUNGEON_DIR + "coffin.glb")
	var gate_cell := _portal_cell()
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			if walkable.get(cell, false):
				continue
			if (cell - gate_cell).length() < 2.4:
				continue
			var center := _cell_to_world(cell)
			var rim := _touches_walkable(cell)
			var roll := rng.randf()
			if rock_scene != null and roll < minf(0.9, (0.2 if rim else 0.1) * decor_mult):
				var size := rng.randf_range(1.8, 3.6) if rim else rng.randf_range(1.4, 3.4)
				var rock := _spawn_model_fit(rock_scene, size, floor_root, center + Vector3(rng.randf_range(-1, 1), -1.0, rng.randf_range(-1, 1)), rng.randf_range(0, 360))
				if rock != null:
					_apply_rock_material(rock, 1.4)
			elif pillar_scene != null and roll < minf(0.9, (0.26 if rim else 0.16) * decor_mult):
				var pillar := _spawn_model(pillar_scene, rng.randf_range(2.8, 5.5), floor_root, center + Vector3(0, -1.0, 0), rng.randf_range(0, 60))
				if pillar != null:
					pillar.rotate_x(deg_to_rad(rng.randf_range(-6, 6)))
					_apply_rock_material(pillar, 1.8)
			elif pot_scene != null and roll < minf(0.92, 0.245 * maxf(1.0, decor_mult)):
				var pot := _spawn_model(pot_scene, 0.9, floor_root, center + Vector3(rng.randf_range(-0.8, 0.8), -0.3, rng.randf_range(-0.8, 0.8)), rng.randf_range(0, 360))
				if pot != null:
					_apply_rock_material(pot, 2.2)
	_build_outer_cliffs()
	var placed := 0
	var guard := 0
	while placed < 7 and guard < 120:
		guard += 1
		var cell := Vector2i(rng.randi_range(1, GRID - 2), rng.randi_range(1, GRID - 2))
		if not walkable.get(cell, false):
			continue
		if int(distance.get(cell, 99)) < 2:
			continue
		var center := _cell_to_world(cell) + Vector3(rng.randf_range(-1.2, 1.2), 0.0, rng.randf_range(-1.2, 1.2))
		_build_brazier(center)
		placed += 1
	for offset in [Vector2i(0, -3), Vector2i(3, -2), Vector2i(-3, -1)]:
		var near_cell := _nearest_walkable(start_cell + offset)
		if near_cell == start_cell:
			continue
		var near := _cell_to_world(near_cell)
		_build_brazier(near)
	_scatter_stone_props(rock_scene, pillar_scene, pot_scene)
	_build_lava_gardens()
	var boulders := 0
	var guard2 := 0
	while boulders < 15 and guard2 < 220:
		guard2 += 1
		var cell := Vector2i(rng.randi_range(2, GRID - 3), rng.randi_range(2, GRID - 3))
		if not walkable.get(cell, false) or int(distance.get(cell, 99)) < 3:
			continue
		var at := _cell_to_world(cell) + Vector3(rng.randf_range(-1.2, 1.2), 0.0, rng.randf_range(-1.2, 1.2))
		var boulder := _spawn_model(rock_scene, rng.randf_range(0.5, 1.1), floor_root, at, rng.randf_range(0, 360))
		if boulder != null:
			_apply_rock_material(boulder, 1.6)
		boulders += 1


func _build_lava_gardens() -> void:
	var plant_scene := _get_model(_first_glb("res://art/generated/lava_plant"))
	var shard_scene := _get_model(_first_glb("res://art/generated/obsidian_spires"))
	var density := float(theme.get("plants", 0.5))
	var seam: Color = theme.get("seam", Color(1.0, 0.42, 0.10))
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			if not walkable.get(cell, false) or cell == start_cell:
				continue
			var open := 0
			for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if not walkable.get(cell + dir, true):
					open += 1
			if open <= 0:
				continue
			if rng.randf() > density * 0.20 * float(open):
				continue
			var center := _cell_to_world(cell)
			var at := center + Vector3(rng.randf_range(-1.3, 1.3), 0.0, rng.randf_range(-1.3, 1.3))
			if plant_scene != null:
				var plant := _spawn_model(plant_scene, rng.randf_range(0.7, 1.5), floor_root, at, rng.randf_range(0, 360))
				if plant != null and rng.randf() < 0.75:
					_tint_glow(plant, seam)
			else:
				_build_lava_plant(at)
			if shard_scene != null and rng.randf() < 0.3:
				var side := at + Vector3(rng.randf_range(-1.6, 1.6), 0.0, rng.randf_range(-1.6, 1.6))
				var shard := _spawn_model_fit(shard_scene, rng.randf_range(0.8, 1.4), floor_root, side, rng.randf_range(0, 360))
				if shard != null and rng.randf() < 0.45:
					_tint_glow(shard, seam, 0.4)
			elif rng.randf() < 0.22:
				_build_cinder_bloom(at + Vector3(rng.randf_range(-1.4, 1.4), 0.0, rng.randf_range(-1.4, 1.4)))
			var variant := rng.randf()
			if variant < 0.2:
				_build_lava_lotus(at + Vector3(rng.randf_range(-1.8, 1.8), 0.0, rng.randf_range(-1.8, 1.8)))
			elif variant < 0.36:
				_build_ember_shrub(at + Vector3(rng.randf_range(-1.8, 1.8), 0.0, rng.randf_range(-1.8, 1.8)))
	for cell in walkable.keys():
		if walkable[cell]:
			continue
		if not _touches_walkable(cell):
			continue
		if rng.randf() > float(theme.get("plants", 0.5)) * 0.14:
			continue
		_build_molten_pool(_cell_to_world(cell))


func _build_lava_lotus(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = rng.randf_range(0.0, TAU)
	floor_root.add_child(holder)
	var hot: Color = theme.get("lava_hot", Color(1.0, 0.4, 0.05))
	var petal_mat := FX.glow_material(hot.lerp(Color(1, 1, 1), 0.18), false)
	var petal_count := rng.randi_range(4, 6)
	for i in petal_count:
		var petal := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = rng.randf_range(0.17, 0.25)
		sphere.height = sphere.radius * 1.6
		sphere.radial_segments = 8
		sphere.rings = 4
		petal.mesh = sphere
		petal.material_override = petal_mat
		var angle := TAU * float(i) / float(petal_count) + rng.randf_range(-0.2, 0.2)
		petal.position = Vector3(cos(angle) * 0.24, rng.randf_range(0.12, 0.2), sin(angle) * 0.24)
		petal.rotation = Vector3(deg_to_rad(rng.randf_range(-34.0, -16.0)), angle, 0.0)
		petal.scale = Vector3(1.0, 0.45, 1.0)
		petal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		holder.add_child(petal)
	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.12
	core_mesh.height = 0.16
	core.mesh = core_mesh
	core.material_override = FX.glow_material(Color(1.0, 0.8, 0.36, 0.95), false)
	core.position.y = 0.2
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(core)
	if rng.randf() < 0.3:
		var light := OmniLight3D.new()
		light.light_color = hot
		light.light_energy = 0.7
		light.omni_range = 3.4
		light.shadow_enabled = false
		light.position.y = 0.5
		holder.add_child(light)


func _build_ember_shrub(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = rng.randf_range(0.0, TAU)
	floor_root.add_child(holder)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.05, 0.025, 0.025)
	wood.roughness = 0.95
	var hot: Color = theme.get("lava_hot", Color(1.0, 0.4, 0.05))
	var tip_mat := FX.glow_material(hot.lerp(Color(1, 0.9, 0.6), 0.25), false)
	var branches := rng.randi_range(4, 7)
	for i in branches:
		var pivot := Node3D.new()
		pivot.rotation.y = TAU * float(i) / float(branches) + rng.randf_range(-0.4, 0.4)
		pivot.rotation.z = deg_to_rad(rng.randf_range(18.0, 42.0))
		holder.add_child(pivot)
		var length := rng.randf_range(0.5, 1.05)
		var branch := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.012
		cylinder.bottom_radius = 0.045
		cylinder.height = length
		cylinder.radial_segments = 5
		branch.mesh = cylinder
		branch.material_override = wood
		branch.position.y = length * 0.5
		branch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(branch)
		var tip := MeshInstance3D.new()
		var ember := SphereMesh.new()
		ember.radius = rng.randf_range(0.04, 0.075)
		ember.height = ember.radius * 2.0
		ember.radial_segments = 6
		ember.rings = 3
		tip.mesh = ember
		tip.material_override = tip_mat
		tip.position.y = length
		tip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(tip)


func _build_molten_pool(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at + Vector3(rng.randf_range(-1.0, 1.0), 0.0, rng.randf_range(-1.0, 1.0))
	floor_root.add_child(holder)
	var radius := rng.randf_range(1.1, 1.9)
	var pool := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius * 0.94
	disc.height = 0.05
	disc.radial_segments = 24
	pool.mesh = disc
	var hot: Color = theme.get("lava_hot", Color(1.0, 0.4, 0.05))
	pool.material_override = FX.glow_material(hot.lerp(Color(1.0, 0.85, 0.45), 0.3), false)
	pool.position.y = -1.55
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(pool)
	var crust := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = radius * 0.98
	ring.outer_radius = radius * 1.16
	ring.rings = 28
	ring.ring_segments = 5
	crust.mesh = ring
	var crust_mat := StandardMaterial3D.new()
	crust_mat.albedo_color = theme.get("lava_crust", Color(0.09, 0.03, 0.02)) * 1.5
	crust_mat.roughness = 0.95
	crust.material_override = crust_mat
	crust.position.y = -1.5
	crust.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(crust)


func _tint_glow(root: Node3D, color: Color, strength := 0.75) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_inst := node as MeshInstance3D
		if mesh_inst.mesh == null:
			continue
		var source: Material = null
		for surface in mesh_inst.mesh.get_surface_count():
			var candidate := mesh_inst.mesh.surface_get_material(surface)
			if candidate != null:
				source = candidate
				break
		var mat: StandardMaterial3D
		if source is StandardMaterial3D:
			mat = (source as StandardMaterial3D).duplicate()
		else:
			mat = StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 0.55 * strength
		mesh_inst.material_override = mat


func _build_cinder_bloom(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = rng.randf_range(0.0, TAU)
	floor_root.add_child(holder)
	var stem := StandardMaterial3D.new()
	stem.albedo_color = Color(0.07, 0.03, 0.035)
	stem.roughness = 0.95
	var hot: Color = theme.get("lava_hot", Color(1.0, 0.38, 0.05))
	var cap_mat := FX.glow_material(hot.lerp(Color(1, 1, 1), 0.22), false)
	var stalks := rng.randi_range(3, 5)
	for i in stalks:
		var pivot := Node3D.new()
		pivot.position = Vector3(rng.randf_range(-0.55, 0.55), 0.0, rng.randf_range(-0.55, 0.55))
		pivot.rotation.z = deg_to_rad(rng.randf_range(-14.0, 14.0))
		holder.add_child(pivot)
		var height := rng.randf_range(0.32, 0.78)
		var stalk := MeshInstance3D.new()
		var stalk_mesh := CylinderMesh.new()
		stalk_mesh.top_radius = 0.045
		stalk_mesh.bottom_radius = 0.07
		stalk_mesh.height = height
		stalk_mesh.radial_segments = 6
		stalk.mesh = stalk_mesh
		stalk.material_override = stem
		stalk.position.y = height * 0.5
		stalk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(stalk)
		var cap := MeshInstance3D.new()
		var cap_mesh := SphereMesh.new()
		cap_mesh.radius = rng.randf_range(0.16, 0.28)
		cap_mesh.height = cap_mesh.radius * 1.15
		cap_mesh.radial_segments = 8
		cap_mesh.rings = 4
		cap.mesh = cap_mesh
		cap.material_override = cap_mat
		cap.scale.y = 0.55
		cap.position.y = height
		cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(cap)


func _build_lava_plant(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = rng.randf_range(0.0, TAU)
	floor_root.add_child(holder)
	var stem := StandardMaterial3D.new()
	stem.albedo_color = Color(0.10, 0.035, 0.035)
	stem.roughness = 0.9
	var tip := FX.glow_material(Color(1.0, 0.45, 0.10, 0.95), false)
	var blades := rng.randi_range(4, 6)
	for i in blades:
		var pivot := Node3D.new()
		pivot.rotation.y = TAU * float(i) / float(blades) + rng.randf_range(-0.3, 0.3)
		pivot.rotation.z = deg_to_rad(rng.randf_range(-34.0, -12.0))
		holder.add_child(pivot)
		var height := rng.randf_range(0.45, 1.0)
		var blade := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.008
		cone.bottom_radius = 0.045
		cone.height = height
		cone.radial_segments = 5
		blade.mesh = cone
		blade.material_override = stem
		blade.position.y = height * 0.5
		blade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(blade)
		var ember := MeshInstance3D.new()
		var bud := SphereMesh.new()
		bud.radius = 0.035
		bud.height = 0.07
		bud.radial_segments = 6
		bud.rings = 3
		ember.mesh = bud
		ember.material_override = tip
		ember.position.y = height
		ember.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pivot.add_child(ember)


func _build_brazier(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at
	floor_root.add_child(holder)
	var iron := StandardMaterial3D.new()
	iron.albedo_color = Color(0.09, 0.075, 0.08)
	iron.metallic = 0.75
	iron.roughness = 0.45
	var stand := MeshInstance3D.new()
	var stand_mesh := CylinderMesh.new()
	stand_mesh.top_radius = 0.16
	stand_mesh.bottom_radius = 0.34
	stand_mesh.height = 0.95
	stand_mesh.radial_segments = 10
	stand.mesh = stand_mesh
	stand.material_override = iron
	stand.position.y = 0.47
	holder.add_child(stand)
	var bowl := MeshInstance3D.new()
	var bowl_mesh := CylinderMesh.new()
	bowl_mesh.top_radius = 0.52
	bowl_mesh.bottom_radius = 0.26
	bowl_mesh.height = 0.34
	bowl_mesh.radial_segments = 14
	bowl.mesh = bowl_mesh
	bowl.material_override = iron
	bowl.position.y = 1.05
	holder.add_child(bowl)
	var coals := MeshInstance3D.new()
	var coal_mesh := CylinderMesh.new()
	coal_mesh.top_radius = 0.34
	coal_mesh.bottom_radius = 0.34
	coal_mesh.height = 0.06
	coal_mesh.radial_segments = 12
	coals.mesh = coal_mesh
	coals.material_override = FX.glow_material(Color(0.72, 0.22, 0.04, 0.9))
	coals.position.y = 1.22
	holder.add_child(coals)
	_add_fire(at + Vector3(0.0, 1.24, 0.0))


func _touches_walkable(cell: Vector2i) -> bool:
	for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if walkable.get(cell + dir, false):
			return true
	return false


func _build_outer_cliffs() -> void:
	var rock_scene := _get_model(ROCK_PATH)
	if rock_scene == null:
		return
	var radius := float(GRID) * CELL * 0.5
	for i in 54:
		var angle := TAU * float(i) / 54.0 + rng.randf_range(-0.05, 0.05)
		var span := rng.randf_range(7.0, 13.5) if i % 3 != 0 else rng.randf_range(4.0, 7.0)
		## Clear the arena by the boulder's own half width, or the ring eats
		## into the playable floor and the camera ends up inside the rock.
		var dist := radius + span * 0.55 + rng.randf_range(0.6, 5.0)
		var pos := Vector3(cos(angle) * dist, -2.4, sin(angle) * dist)
		var rock := _spawn_model_fit(rock_scene, span, floor_root, pos, rng.randf_range(0, 360))
		if rock != null:
			_apply_rock_material(rock, 1.2)
			_track_prop(rock)


func _scatter_stone_props(rock_scene: PackedScene, pillar_scene: PackedScene, pot_scene: PackedScene) -> void:
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		var center := _cell_to_world(cell)
		if center.distance_to(_cell_to_world(start_cell)) < 9.0:
			continue
		var roll := rng.randf()
		var angle := rng.randf() * TAU
		var offset := Vector3(cos(angle), 0.0, sin(angle)) * rng.randf_range(1.1, 1.5)
		if rock_scene != null and roll < 0.15:
			var rock := _spawn_model_fit(rock_scene, rng.randf_range(0.7, 1.5), floor_root, center + offset + Vector3(0.0, -0.12, 0.0), rng.randf_range(0, 360))
			if rock != null:
				_apply_rock_material(rock, 1.9)
				_track_prop(rock)
		elif pillar_scene != null and roll < 0.18:
			var ruined := _spawn_model(pillar_scene, rng.randf_range(1.1, 2.6), floor_root, center + offset, rng.randf_range(0, 360))
			if ruined != null:
				ruined.rotate_x(deg_to_rad(rng.randf_range(-10, 10)))
				_apply_rock_material(ruined, 2.0)
				_track_prop(ruined)
		elif pot_scene != null and roll < 0.22:
			var pot := _spawn_model(pot_scene, 0.85, floor_root, center + offset, rng.randf_range(0, 360))
			if pot != null:
				_apply_rock_material(pot, 2.2)
				_track_prop(pot)


func _track_prop(node: Node3D) -> void:
	var meshes: Array = []
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if mesh != null and mesh.material_override is StandardMaterial3D:
			meshes.append(mesh)
	if meshes.is_empty():
		return
	decor_props.append({"node": node, "meshes": meshes, "alpha": 1.0})


## Props that sit between the camera and the hero fade out, so a pillar never
## hides the fight. Each prop owns its own material copy, so this is per prop.
func _update_prop_fade(delta: float) -> void:
	if player == null or camera == null or decor_props.is_empty():
		return
	var cam_pos := camera.global_position
	var eye := player.global_position + Vector3(0.0, 1.1, 0.0)
	for entry in decor_props:
		var node: Node3D = entry.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var center := node.global_position + Vector3(0.0, 1.2, 0.0)
		var target_alpha := 1.0
		if cam_pos.distance_to(center) < 24.0:
			var seg := eye - cam_pos
			var seg_len := seg.length()
			if seg_len > 0.2:
				var t := clampf((center - cam_pos).dot(seg) / (seg_len * seg_len), 0.0, 1.0)
				var closest := cam_pos + seg * t
				if center.distance_to(closest) < 1.7 and t < 0.95:
					target_alpha = 0.2
		var alpha := lerpf(float(entry.get("alpha", 1.0)), target_alpha, clampf(delta * 10.0, 0.0, 1.0))
		entry["alpha"] = alpha
		for mesh in entry.get("meshes", []):
			var mat := (mesh as MeshInstance3D).material_override as StandardMaterial3D
			if mat == null:
				continue
			if alpha < 0.99:
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				var col := mat.albedo_color
				mat.albedo_color = Color(col.r, col.g, col.b, alpha)
			elif mat.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				var col2 := mat.albedo_color
				mat.albedo_color = Color(col2.r, col2.g, col2.b, 1.0)
				mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED


func _add_fire(at: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.amount = 22
	particles.lifetime = 0.5
	particles.preprocess = 0.6
	particles.position = at
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = 0.12
	proc.direction = Vector3.UP
	proc.spread = 12.0
	proc.initial_velocity_min = 0.9
	proc.initial_velocity_max = 2.1
	proc.gravity = Vector3(0.0, 1.2, 0.0)
	proc.scale_min = 0.045
	proc.scale_max = 0.11
	proc.color = Color(1.0, 0.42, 0.1, 0.55)
	particles.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	quad.material = FX.spark_material(Color(1, 1, 1, 1))
	particles.draw_pass_1 = quad
	floor_root.add_child(particles)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.5, 0.18)
	light.light_energy = 1.7
	light.omni_range = 9.0
	light.shadow_enabled = false
	light.position = at + Vector3(0.0, 0.3, 0.0)
	floor_root.add_child(light)


func _spawn_embers() -> void:
	ember_emitter = GPUParticles3D.new()
	ember_emitter.amount = 120
	ember_emitter.lifetime = 7.0
	ember_emitter.preprocess = 4.0
	ember_emitter.visibility_aabb = AABB(Vector3(-60, -6, -60), Vector3(120, 40, 120))
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	proc.emission_box_extents = Vector3(GRID * CELL * 0.5, 0.5, GRID * CELL * 0.5)
	proc.direction = Vector3.UP
	proc.spread = 25.0
	proc.initial_velocity_min = 0.6
	proc.initial_velocity_max = 1.9
	proc.gravity = Vector3(0.6, 0.7, 0.2)
	proc.scale_min = 0.012
	proc.scale_max = 0.035
	proc.color = Color(1.0, 0.45, 0.12, 0.28)
	ember_emitter.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	quad.material = FX.spark_material(Color(1, 1, 1, 1))
	ember_emitter.draw_pass_1 = quad
	ember_emitter.position.y = 0.5
	fx_root.add_child(ember_emitter)


func _get_model(path: String) -> PackedScene:
	if model_cache.has(path):
		return model_cache[path]
	if not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is PackedScene:
		model_cache[path] = res
		return res
	return null


func _measure(node: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var stack: Array = [node]
	while stack.size() > 0:
		var current: Node = stack.pop_back()
		if current is MeshInstance3D:
			var mesh_inst := current as MeshInstance3D
			var box := mesh_inst.get_aabb()
			var xform := Transform3D.IDENTITY
			var walker: Node = mesh_inst
			while walker != null and walker != node:
				if walker is Node3D:
					xform = (walker as Node3D).transform * xform
				walker = walker.get_parent()
			box = xform * box
			if first:
				result = box
				first = false
			else:
				result = result.merge(box)
		for child in current.get_children():
			stack.append(child)
	return result


func _spawn_model(scene: PackedScene, target_height: float, parent: Node3D, position: Vector3, yaw_deg: float) -> Node3D:
	if scene == null:
		return null
	var holder := Node3D.new()
	var inst := scene.instantiate()
	holder.add_child(inst)
	var box := _measure(inst)

	var scale_factor := 1.0
	if box.size.y > 0.001:
		scale_factor = target_height / box.size.y
	inst.scale = Vector3.ONE * scale_factor
	inst.position.y = -box.position.y * scale_factor
	holder.position = position
	holder.rotation_degrees.y = yaw_deg
	parent.add_child(holder)
	return holder


## Fit a prop so its largest dimension equals max_dim. Used for shard clusters
## whose bounding box is wide and flat, where height fitting would flatten them.
func _spawn_model_fit(scene: PackedScene, max_dim: float, parent: Node3D, position: Vector3, yaw_deg: float) -> Node3D:
	if scene == null:
		return null
	var holder := Node3D.new()
	var inst := scene.instantiate()
	holder.add_child(inst)
	var box := _measure(inst)
	var widest := maxf(box.size.x, maxf(box.size.y, box.size.z))
	if widest > 0.001:
		inst.scale = Vector3.ONE * (max_dim / widest)
		inst.position.y = -box.position.y * (max_dim / widest)
	holder.position = position
	holder.rotation_degrees.y = yaw_deg
	parent.add_child(holder)
	return holder


func _apply_rock_material(root: Node3D, scale_value: float) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_inst := node as MeshInstance3D
		if mesh_inst.mesh == null:
			continue
		var original: Material = null
		for surface in mesh_inst.mesh.get_surface_count():
			var candidate := mesh_inst.mesh.surface_get_material(surface)
			if candidate != null:
				original = candidate
				break
		var tinted: StandardMaterial3D
		if original is StandardMaterial3D:
			tinted = (original as StandardMaterial3D).duplicate()
		else:
			tinted = StandardMaterial3D.new()
		tinted.albedo_color = Color(0.185, 0.155, 0.15)
		tinted.roughness = 0.92
		tinted.metallic = 0.08
		mesh_inst.material_override = tinted


func _spawn_packs() -> void:
	total_enemies = 0
	var boss_floor := _is_boss_layer()
	var candidates: Array = []
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		if int(distance.get(cell, 0)) >= 5:
			candidates.append(cell)
	if candidates.is_empty():
		candidates.append(start_cell)
	var area_scale := clampf(float(_walkable_count()) / 220.0, 0.6, 1.0)
	var pack_count := int(round(float(2 if boss_floor else 2 + mini(2, (layer - 1) / 2)) * area_scale))
	pack_count = maxi(2, pack_count)
	for p in pack_count:
		var center: Vector2i = candidates[rng.randi() % candidates.size()]
		if p == 0:
			var near: Array = []
			for cell in candidates:
				var d := int(distance.get(cell, 0))
				if d >= 3 and cell.y <= start_cell.y - 4 and absi(cell.x - start_cell.x) <= 4:
					near.append(cell)
			if near.is_empty():
				for cell in candidates:
					var d := int(distance.get(cell, 0))
					if d >= 3 and d <= 7:
						near.append(cell)
			if not near.is_empty():
				center = near[rng.randi() % near.size()]
		var size := rng.randi_range(2, 4) + (1 if has_mod("swarming") else 0)
		for i in size:
			var cell := _nearby_walkable(center)
			_spawn_enemy(_pick_kind(p == pack_count - 1), cell)
	if boss_floor:
		var boss_cell := _nearby_walkable(candidates[rng.randi() % candidates.size()])
		var boss_index := clampi(layer / 6 - 1, 0, BOSS_ORDER.size() - 1)
		var boss_kind := String(BOSS_ORDER[boss_index])
		boss_enemy = _spawn_enemy(boss_kind, boss_cell)
		for i in 2:
			_spawn_enemy("brute", _nearby_walkable(boss_cell + Vector2i(rng.randi_range(-2, 2), rng.randi_range(-2, 2))))
	elif layer >= 2 and rng.randf() < 0.45:
		_spawn_enemy("alpha", _nearby_walkable(candidates[rng.randi() % candidates.size()]))
	total_enemies = enemies.size()


func _nearby_walkable(center: Vector2i) -> Vector2i:
	for attempt in 14:
		var cell := center + Vector2i(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
		if walkable.get(cell, false) and cell != start_cell:
			return cell
	return center


func _pick_kind(last_pack: bool) -> String:
	var roll := rng.randf()
	if layer == 1:
		if roll < 0.42:
			return "wolf"
		if roll < 0.72:
			return "acolyte"
		if roll < 0.88:
			return "crawler"
		return "bat"
	if last_pack and roll < 0.28:
		return "brute"
	var table := ["wolf", "acolyte", "bat", "slinger", "crawler", "wolf", "acolyte"]
	if _is_boss_layer() or layer % 6 == 5:
		table = ["brute", "acolyte", "slinger", "wolf", "brute", "crawler", "acolyte"]
	return String(table[rng.randi() % table.size()])


func _spawn_enemy(kind_key: String, cell: Vector2i) -> Enemy:
	var base: Dictionary = KINDS.get(kind_key, KINDS["wolf"]).duplicate()
	var health_scale := 1.0 + 0.16 * float(layer - 1)
	var damage_scale := 1.0 + 0.075 * float(layer - 1)
	if has_mod("brutal"):
		damage_scale *= 1.25
	if bool(base.get("boss", false)):
		health_scale = 1.0 + 0.2 * float(layer - 1)
	base.health = float(base.health) * health_scale
	base.damage = float(base.damage) * damage_scale
	if has_mod("frenzied"):
		base.speed = float(base.speed) * 1.2
	var enemy := Enemy.new()
	entity_root.add_child(enemy)
	var model_path := String(base.file)
	if not model_path.begins_with("res://"):
		model_path = DUNGEON_DIR + model_path
	var model: PackedScene = _find_hero_scene() if kind_key == "mirror" else _get_model(model_path)
	enemy.setup(base, model, player, find_path, _enemy_bolt, _boss_special, _request_attacker, _release_attacker)
	enemy.global_position = _cell_to_world(cell) + Vector3(0.0, 0.2, 0.0)
	enemy.frozen = not run_active
	enemy.died.connect(_on_enemy_died)
	enemies.append(enemy)
	FX.burst(fx_root, enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.65, 0.2, 1.0, 0.95), 22, 5.0, 0.4, 0.6)
	FX.ring(fx_root, enemy.global_position, Color(0.7, 0.25, 1.0, 0.7), 1.8, 0.5, 0.05)
	_style_enemy(enemy, base)
	return enemy


func _style_enemy(enemy: Enemy, kind: Dictionary) -> void:
	var is_boss := bool(kind.get("boss", false))
	var is_elite := bool(kind.get("elite", false))
	if not is_boss and not is_elite:
		return
	var color: Color = kind.get("tint", Color(1.0, 0.42, 0.12) if is_boss else Color(1.0, 0.62, 0.2))
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.95 if is_boss else 0.7
	torus.outer_radius = 1.12 if is_boss else 0.82
	torus.rings = 40
	torus.ring_segments = 4
	ring.mesh = torus
	ring.material_override = FX.glow_material(Color(color.r, color.g, color.b, 0.30 if is_boss else 0.5))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = 0.07
	enemy.add_child(ring)
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 0.85 if is_boss else 1.2
	light.omni_range = 5.0 if is_boss else 3.6
	light.shadow_enabled = false
	light.position.y = 1.4
	enemy.add_child(light)
	if enemy.model_root == null:
		return
	var tint := StandardMaterial3D.new()
	tint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tint.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tint.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	tint.albedo_color = Color(color.r, color.g, color.b, 0.10 if not is_boss else 0.07)
	tint.disable_receive_shadows = true
	for node in enemy.model_root.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh != null:
			mesh.material_overlay = tint


func _enemy_bolt(from: Vector3, to: Vector3, damage: float) -> void:
	var dir := (to - from)
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	var bolt := BloodBolt.new()
	bolt.hostile = true
	bolt.color = Color(0.7, 0.25, 1.0)
	bolt.direction = dir
	bolt.speed = 12.5
	bolt.damage = damage
	fx_root.add_child(bolt)
	bolt.global_position = from + dir * 0.6


func _request_attacker(enemy: Enemy) -> bool:
	var live: Array = []
	for e in attackers:
		if is_instance_valid(e) and not (e as Enemy).dead:
			live.append(e)
	attackers = live
	if enemy in attackers:
		return true
	var limit := MAX_MELEE_ATTACKERS + (1 if _is_boss_layer() else 0)
	if attackers.size() >= limit:
		return false
	attackers.append(enemy)
	return true


func _release_attacker(enemy: Enemy) -> void:
	attackers.erase(enemy)


func _boss_special(enemy: Enemy) -> void:
	if enemy == null or not is_instance_valid(enemy) or enemy.dead:
		return
	match enemy.kind_key:
		"prophet":
			_prophet_volley(enemy)
		"brood":
			_brood_call(enemy)
		"nail":
			_boss_slam(enemy)
		"tide":
			_boss_charge(enemy)
		"drowning":
			_boss_storm(enemy)
		"mirror":
			_mirror_special(enemy)
		_:
			_prophet_volley(enemy)


## The Iron Choir: a hammer dropped on the ground under the player.
func _boss_slam(enemy: Enemy) -> void:
	var target := player.global_position
	var radius := 4.6
	FX.ring(fx_root, target, Color(0.86, 0.92, 1.0, 0.9), radius, 0.6, 0.06)
	FX.disc(fx_root, target, Color(0.72, 0.82, 1.0, 0.20), radius, 0.75, 0.03)
	play_sfx("lava", -1.0, 0.06)
	await get_tree().create_timer(0.78).timeout
	if not is_instance_valid(enemy) or enemy.dead or not run_active:
		return
	FX.nova(fx_root, target, Color(0.90, 0.94, 1.0, 1.0), radius)
	FX.ring(fx_root, target, Color(1.0, 1.0, 1.0, 0.8), radius * 1.25, 0.45, 0.06)
	FX.burst(fx_root, target + Vector3(0.0, 0.3, 0.0), Color(0.9, 0.95, 1.0, 0.9), 30, 8.0, 0.5, 0.6)
	FX.fault(fx_root, target, Color(0.92, 0.96, 1.0, 0.85), radius * 1.1, 10, 1.2)
	FX.shards(fx_root, target, Color(0.95, 0.97, 1.0, 0.8), 12, radius * 0.55, 2.4, 0.6)
	_shake(0.7)
	if player.global_position.distance_to(target) <= radius:
		player.take_damage(enemy.damage * 1.5)


## The Bone Tide: a straight pounce that leaves a burning trail.
func _boss_charge(enemy: Enemy) -> void:
	var start := enemy.global_position
	var dir := player.global_position - start
	dir.y = 0.0
	if dir.length() < 0.4:
		return
	dir = dir.normalized()
	var finish := start + dir * 7.0
	for i in 7:
		var point := start.lerp(finish, float(i) / 6.0)
		FX.ring(fx_root, point, Color(0.9, 1.0, 0.7, 0.45), 1.5, 0.4, 0.05)
	play_sfx("cast", -2.0, 0.04)
	var tween := create_tween()
	tween.tween_property(enemy, "global_position", finish, 0.34)
	await tween.finished
	if not is_instance_valid(enemy) or enemy.dead or not run_active:
		return
	FX.burst(fx_root, finish + Vector3(0.0, 0.6, 0.0), Color(0.9, 1.0, 0.7, 0.9), 26, 7.0, 0.45, 0.55)
	_shake(0.4)
	var p := player.global_position
	var to_p := p - start
	var along := clampf(to_p.dot(dir), 0.0, dir.length() * 7.0)
	var closest := start + dir * along
	var flat := p - closest
	flat.y = 0.0
	if flat.length() <= 2.0:
		player.take_damage(enemy.damage * 1.35)


## The Drowning: a ring of bolts and three eruptions around the player.
func _boss_storm(enemy: Enemy) -> void:
	var origin := enemy.global_position + Vector3(0.0, 1.4, 0.0)
	var count := 16
	var gap := rng.randi_range(0, count - 1)
	for i in count:
		if absi(i - gap) <= 1:
			continue
		var angle := TAU * float(i) / float(count)
		var dir := Vector3(sin(angle), 0.0, cos(angle))
		var bolt := BloodBolt.new()
		bolt.hostile = true
		bolt.color = Color(1.0, 0.28, 0.18)
		bolt.direction = dir
		bolt.speed = 10.5
		bolt.damage = enemy.damage * 0.5
		fx_root.add_child(bolt)
		bolt.global_position = origin + dir * 1.2
	FX.burst(fx_root, origin, Color(1.0, 0.3, 0.22, 0.9), 34, 7.0, 0.5, 0.8)
	for i in 3:
		var spot := player.global_position + Vector3(rng.randf_range(-4.5, 4.5), 0.0, rng.randf_range(-4.5, 4.5))
		_storm_spot(spot, enemy.damage * 0.9)
	enemy.health = minf(enemy.max_health, enemy.health + enemy.max_health * 0.02)


func _storm_spot(spot: Vector3, damage: float) -> void:
	FX.ring(fx_root, spot, Color(1.0, 0.28, 0.18, 0.85), 2.5, 0.7, 0.06)
	FX.disc(fx_root, spot, Color(1.0, 0.22, 0.12, 0.18), 2.5, 0.8, 0.03)
	await get_tree().create_timer(0.72).timeout
	if not run_active or player == null or not player.alive:
		return
	FX.nova(fx_root, spot, Color(1.0, 0.32, 0.14, 1.0), 2.6)
	FX.embers(fx_root, spot, Color(1.0, 0.5, 0.2, 0.9), 14, 1.8)
	if player.global_position.distance_to(spot) <= 2.6:
		player.take_damage(damage)
	_shake(0.22)


func _mirror_special(enemy: Enemy) -> void:
	var origin := enemy.global_position + Vector3(0.0, 1.3, 0.0)
	var aim := player.global_position - origin
	aim.y = 0.0
	if aim.length() > 0.1:
		aim = aim.normalized()
		var count := 7
		var fan := deg_to_rad(74.0)
		for i in count:
			var t := float(i) / float(count - 1) - 0.5
			var dir := aim.rotated(Vector3.UP, t * fan)
			var bolt := BloodBolt.new()
			bolt.hostile = true
			bolt.color = Color(1.0, 0.26, 0.42)
			bolt.direction = dir
			bolt.speed = 11.0
			bolt.damage = enemy.damage * 0.55
			fx_root.add_child(bolt)
			bolt.global_position = origin + dir * 1.1
	enemy.health = minf(enemy.max_health, enemy.health + enemy.max_health * 0.04)
	FX.burst(fx_root, origin, Color(1.0, 0.3, 0.45, 0.9), 30, 6.5, 0.45, 0.75)
	FX.ring(fx_root, enemy.global_position, Color(1.0, 0.35, 0.45, 0.65), 4.0, 0.6, 0.07)
	hud.toast("SHE WEARS YOUR FACE", Color(1.0, 0.45, 0.55), 1.2)


func _prophet_volley(enemy: Enemy) -> void:
	var origin := enemy.global_position + Vector3(0.0, 1.4, 0.0)
	var aim := player.global_position - origin
	aim.y = 0.0
	if aim.length() < 0.1:
		return
	aim = aim.normalized()
	var count := 5
	var fan := deg_to_rad(58.0)
	for i in count:
		var t := 0.0 if count <= 1 else float(i) / float(count - 1) - 0.5
		var dir := aim.rotated(Vector3.UP, t * fan)
		var bolt := BloodBolt.new()
		bolt.hostile = true
		bolt.color = Color(0.78, 0.3, 1.0)
		bolt.direction = dir
		bolt.speed = 10.5
		bolt.damage = enemy.damage * 0.62
		fx_root.add_child(bolt)
		bolt.global_position = origin + dir * 1.1
	FX.burst(fx_root, origin, Color(0.8, 0.35, 1.0, 0.9), 26, 6.0, 0.4, 0.7)
	FX.ring(fx_root, enemy.global_position, Color(0.82, 0.35, 1.0, 0.6), 3.4, 0.5, 0.06)
	hud.toast("SOUL VOLLEY", Color(0.85, 0.45, 1.0), 1.1)


func _brood_call(enemy: Enemy) -> void:
	var alive_adds := 0
	for e in enemies:
		if is_instance_valid(e) and not e.dead and e.kind_key == "crawler":
			alive_adds += 1
	var center := _world_to_cell(enemy.global_position)
	FX.ring(fx_root, enemy.global_position, Color(1.0, 0.45, 0.2, 0.7), 6.5, 0.6, 0.08)
	FX.burst(fx_root, enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.95, 0.3, 0.15, 0.9), 30, 6.5, 0.5, 0.9)
	if alive_adds < 3:
		for i in 2:
			var cell := _nearby_walkable(center + Vector2i(rng.randi_range(-2, 2), rng.randi_range(-2, 2)))
			_spawn_enemy("crawler", cell)
			FX.burst(fx_root, _cell_to_world(cell) + Vector3(0.0, 0.6, 0.0), Color(1.0, 0.4, 0.2, 0.9), 18, 4.5, 0.4, 0.6)
	hud.toast("THE BROOD STIRS", Color(1.0, 0.5, 0.28), 1.2)


func _on_enemy_died(enemy: Enemy) -> void:
	kills += 1
	enemies.erase(enemy)
	if duel_mode:
		if enemy == rival:
			rival = null
			boss_enemy = null
			_duel_finished(true)
		return
	if enemy == boss_enemy:
		boss_enemy = null
		hud.set_boss("", 0.0, false)
		hud.toast("RIFT WARDEN SLAIN", Color(1.0, 0.6, 0.2), 3.0)
	var heal_on_kill := float(player.passive_bonus.get("heal_on_kill", 0.0))
	if heal_on_kill > 0.0:
		player.heal(player.max_health * heal_on_kill / 100.0)
	if character_class_id == "blood_sorceress":
		player.add_bloodrush()
	var xp_gain := 12.0 + 2.0 * float(layer)
	if enemy.elite:
		xp_gain *= 3.0
	if enemy.boss:
		xp_gain *= 10.0
	player.gain_xp(xp_gain)
	play_sfx("death", -4.0)
	FX.burst(fx_root, enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.55, 0.12, 0.9, 0.9), 30, 6.0, 0.5, 0.8)
	FX.ring(fx_root, player.global_position, Color(1.0, 0.35, 0.12, 0.35), 2.4, 0.4, 0.05)
	_drop_loot(enemy)
	_drop_coins(enemy)
	hud.set_layer_info(layer, enemies.size(), total_enemies, kills)
	if enemies.is_empty():
		_on_floor_cleared()


func _drop_loot(enemy: Enemy) -> void:
	var chance := 0.26 + 0.03 * float(layer)
	if has_mod("gilded"):
		chance *= 1.35
	chance *= 1.0 + boon_luck
	if enemy.boss:
		chance = 1.0
	elif enemy.elite:
		chance = 0.8
	if rng.randf() < chance:
		var force := ""
		if has_mod("gilded") and rng.randf() < 0.3:
			force = "rare"
		_spawn_item(enemy.global_position, force)
	if rng.randf() < 0.45:
		_spawn_life(enemy.global_position)


func _spawn_item(at: Vector3, force_rarity := "") -> void:
	var item := ItemDB.make_item(layer, rng, force_rarity)
	var drop := LootDrop.new()
	drop.item = item
	entity_root.add_child(drop)
	drop.global_position = at + Vector3(rng.randf_range(-0.7, 0.7), 0.2, rng.randf_range(-0.7, 0.7))
	drop.picked.connect(_on_loot_picked)
	if item.rarity == "legendary":
		FX.burst(fx_root, at + Vector3(0.0, 0.8, 0.0), Color(1.0, 0.45, 0.1, 1.0), 40, 8.0, 0.6, 1.2, -3.0)


func _drop_coins(enemy: Enemy) -> void:
	var value := 6 + int(round(float(layer) * 2.0)) + rng.randi_range(0, 5)
	if enemy.elite:
		value = int(round(float(value) * 3.0))
	if enemy.boss:
		value = int(round(float(value) * 9.0))
	_spawn_coin(enemy.global_position, value)


func _spawn_coin(at: Vector3, value: int) -> void:
	var coin := CoinDrop.new()
	coin.setup(value, player)
	entity_root.add_child(coin)
	coin.global_position = at + Vector3(rng.randf_range(-0.5, 0.5), 0.35, rng.randf_range(-0.5, 0.5))
	coin.collected.connect(_on_coin_collected)


func _on_coin_collected(amount: int) -> void:
	coins += amount
	hud.set_coins(coins, true)
	play_sfx("pickup", -10.0, 0.25)
	_save_run()


func _spawn_life(at: Vector3) -> void:
	var drop := LootDrop.new()
	drop.is_life = true
	drop.life_amount = 34.0
	entity_root.add_child(drop)
	drop.global_position = at + Vector3(rng.randf_range(-0.6, 0.6), 0.2, rng.randf_range(-0.6, 0.6))
	drop.picked.connect(_on_loot_picked)


func _on_loot_picked(drop: LootDrop) -> void:

	if drop.is_life:
		player.heal(drop.life_amount)
		FX.burst(fx_root, drop.global_position, Color(1.0, 0.2, 0.25, 1.0), 16, 3.5, 0.3, 0.5)
		play_sfx("pickup", -6.0)
		return
	play_sfx("pickup", -2.0)
	hud.offer_relic(drop.item)
	hud.toast("%s RELIC" % String(drop.item.get("rarity_name", "")).to_upper(), drop.item.get("color", Color.WHITE), 2.0)


func _on_equip_requested(item: Dictionary, slot: int) -> void:
	if not player.equip_slot(slot, item):
		hud.toast("FAMILY STACK FULL  ·  MAX 2", Color(1.0, 0.4, 0.3), 1.8)
		return
	hud.set_relics(player.relics)
	hud.close_relic_window()
	hud.toast("RELIC BOUND  ·  SLOT %d" % (slot + 1), Color(1.0, 0.55, 0.2), 2.0)
	play_sfx("cast", -4.0, 0.12)
	FX.ring(fx_root, player.global_position, Color(1.0, 0.6, 0.2, 0.9), 3.0, 0.6, 0.06)
	_save_run()


func _on_unequip_requested(slot: int) -> void:
	player.unequip_slot(slot)
	hud.set_relics(player.relics)
	play_sfx("pickup", -12.0, 0.2)
	_save_run()


func _on_discard_requested() -> void:
	hud.close_relic_window()


func _on_floor_cleared() -> void:
	hud.set_status("THE RIFT IS OPEN")
	hud.toast("PACKS CLEARED", Color(1.0, 0.8, 0.35), 3.0)
	player.heal(player.max_health * 0.2)
	_open_portal()
	if _is_boss_layer():
		_spawn_item(player.global_position + Vector3(0.0, 0.0, 1.6), "legendary")
		_spawn_item(player.global_position + Vector3(-1.8, 0.0, 1.0), "legendary")
		_spawn_item(player.global_position + Vector3(1.8, 0.0, 0.6), "rare")
	elif layer >= 2:
		_spawn_item(player.global_position + Vector3(0.0, 0.0, 1.4), "legendary")
		_spawn_item(player.global_position + Vector3(1.6, 0.0, 1.0), "rare")
	else:
		_spawn_item(player.global_position + Vector3(0.0, 0.0, 1.4), "rare")


func _farthest_cell() -> Vector2i:
	return _portal_cell()


func _open_portal(offer_boons := true) -> void:
	var cell := _farthest_cell()
	var pos := _cell_to_world(cell)
	portal = Node3D.new()
	portal.name = "RiftPortal"
	entity_root.add_child(portal)
	portal.global_position = pos
	var to_center := Vector3.ZERO - pos
	var yaw := rad_to_deg(atan2(to_center.x, to_center.z))
	_spawn_model(_get_model(GATE_PATH), 7.2, portal, Vector3.ZERO, yaw)
	var disc := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(3.8, 5.0)
	disc.mesh = quad
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/portal.gdshader")
	mat.set_shader_parameter("intensity", 1.9)
	disc.material_override = mat
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.position = Vector3(0.0, 2.6, 0.0)
	disc.rotation.y = deg_to_rad(yaw)
	portal.add_child(disc)
	var back := MeshInstance3D.new()
	var back_quad := QuadMesh.new()
	back_quad.size = Vector2(4.5, 5.7)
	back.mesh = back_quad
	var back_mat := StandardMaterial3D.new()
	back_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	back_mat.albedo_color = Color(0.03, 0.0, 0.06)
	back.material_override = back_mat
	back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	back.position = Vector3(0.0, 0.0, 0.08)
	disc.add_child(back)
	var frame := MeshInstance3D.new()
	var frame_torus := TorusMesh.new()
	frame_torus.inner_radius = 2.28
	frame_torus.outer_radius = 2.46
	frame_torus.rings = 64
	frame_torus.ring_segments = 8
	frame.mesh = frame_torus
	frame.material_override = FX.glow_material(Color(1.0, 0.24, 0.04, 0.85), false)
	frame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	frame.position = Vector3(0.0, 0.0, -0.04)
	disc.add_child(frame)
	portal_disc = disc
	var pool := MeshInstance3D.new()
	var pool_mesh := CylinderMesh.new()
	pool_mesh.top_radius = 3.0
	pool_mesh.bottom_radius = 3.0
	pool_mesh.height = 0.06
	pool_mesh.radial_segments = 40
	pool.mesh = pool_mesh
	pool.material_override = FX.glow_material(Color(1.0, 0.36, 0.1, 0.2))
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pool.position.y = 0.12
	portal.add_child(pool)
	var halo := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 2.32
	torus.outer_radius = 2.4
	torus.rings = 48
	torus.ring_segments = 6
	halo.mesh = torus
	halo.material_override = FX.glow_material(Color(1.0, 0.26, 0.05, 0.6))
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halo.position.y = 0.14
	portal.add_child(halo)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.45, 0.2)
	light.light_energy = 7.5
	light.omni_range = 16.0
	light.shadow_enabled = false
	light.position.y = 2.5
	portal.add_child(light)
	var swirl := GPUParticles3D.new()
	swirl.amount = 60
	swirl.lifetime = 2.0
	swirl.preprocess = 1.0
	swirl.position.y = 2.6
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	proc.emission_ring_radius = 1.6
	proc.emission_ring_inner_radius = 1.2
	proc.emission_ring_height = 0.4
	proc.emission_ring_axis = Vector3(0, 0, 1)
	proc.direction = Vector3.UP
	proc.spread = 40.0
	proc.initial_velocity_min = 0.8
	proc.initial_velocity_max = 2.4
	proc.gravity = Vector3(0, 1.2, 0)
	proc.scale_min = 0.1
	proc.scale_max = 0.3
	proc.color = Color(1.0, 0.55, 0.25, 0.9)
	swirl.process_material = proc
	var spark := QuadMesh.new()
	spark.size = Vector2(1, 1)
	spark.material = FX.spark_material(Color(1, 1, 1, 1))
	swirl.draw_pass_1 = spark
	portal.add_child(swirl)
	var label := Label3D.new()
	label.text = "ENTER THE RIFT"
	label.font_size = 56
	label.pixel_size = 0.0035
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.75, 0.35)
	label.outline_size = 12
	label.outline_modulate = Color(0.05, 0.0, 0.0, 0.9)
	label.position = Vector3(0.0, 5.9, 0.0)
	portal.add_child(label)
	portal_area = Area3D.new()
	portal_area.collision_layer = 0
	portal_area.collision_mask = 2
	portal_area.monitoring = true
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 2.6
	cylinder.height = 4.0
	shape.shape = cylinder
	shape.position.y = 2.0
	portal_area.add_child(shape)
	portal_area.body_entered.connect(_on_portal_entered)
	portal.add_child(portal_area)
	portal_active = true
	play_sfx("portal", 0.0, 0.03)
	FX.ring(fx_root, pos, Color(1.0, 0.55, 0.2, 0.9), 9.0, 1.2, 0.08)
	FX.burst(fx_root, pos + Vector3(0.0, 1.5, 0.0), Color(1.0, 0.5, 0.2, 1.0), 60, 10.0, 0.7, 1.4, -2.0)
	if offer_boons:
		_offer_boons()


func _offer_boons() -> void:
	if player == null or not player.alive or not run_active:
		return
	var pool := BOONS.duplicate()
	var picked: Array = []
	for i in 3:
		if pool.is_empty():
			break
		var index := rng.randi() % pool.size()
		picked.append(pool[index])
		pool.remove_at(index)
	var picks := 1
	if layer >= 12:
		picks = 2
	if layer >= 24:
		picks = 3
	hud.show_boons(picked, _story_line("warden", layer), picks)


func _on_boon_chosen(key: String) -> void:
	if player == null or not player.alive:
		return
	var claimed := _apply_boon(key)
	if claimed == "":
		return
	play_sfx("pickup", -2.0, 0.05)
	FX.ring(fx_root, player.global_position, Color(1.0, 0.6, 0.25, 0.8), 5.0, 0.7, 0.06)
	hud.toast("%s  CLAIMED" % claimed, Color(1.0, 0.8, 0.35), 2.4)
	_save_run()


func _apply_boon(key: String, record := true) -> String:
	var claimed := ""
	match key:
		"fury":
			player.add_boon("fury")
			claimed = "BLOOD FURY"
		"vitality":
			player.add_boon("vitality")
			player.heal(40.0)
			claimed = "DEEP VITAE"
		"haste":
			player.add_boon("haste")
			claimed = "QUICKENED BLOOD"
		"regen":
			player.add_boon("regen")
			claimed = "SANGUINE FLOW"
		"fortune":
			boon_luck += 0.3
			claimed = "GILDED HOUR"
		"swift":
			player.add_boon("swift")
			claimed = "CRIMSON STRIDE"
		_:
			return ""
	if record:
		run_boons.append(key)
	return claimed


func _is_merchant_layer() -> bool:
	return layer % 6 == 5


func _is_boss_layer() -> bool:
	return layer % 6 == 0


func _is_merchant_layer_at(value: int) -> bool:
	return value % 6 == 5


func _is_boss_layer_at(value: int) -> bool:
	return value % 6 == 0


func _first_glb(dir_path: String) -> String:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ""
	for file in dir.get_files():
		if String(file).get_extension().to_lower() == "glb":
			return dir_path.path_join(file)
	return ""


func _spawn_merchant() -> void:
	merchant_near = false
	var cell := _nearest_walkable(start_cell + Vector2i(2, -2))
	var pos := _cell_to_world(cell)
	merchant_npc = Node3D.new()
	merchant_npc.name = "Merchant"
	entity_root.add_child(merchant_npc)
	merchant_npc.global_position = pos
	var model_path := _first_glb(MERCHANT_DIR)
	if model_path == "":
		model_path = DUNGEON_DIR + "hushed-acolyte.glb"
	var to_player := player.global_position - pos
	var yaw := rad_to_deg(atan2(to_player.x, to_player.z))
	var model := _spawn_model(_get_model(model_path), 2.25, merchant_npc, Vector3.ZERO, yaw)
	if model != null:
		HandGrip.dress(model, "", 1.0, Color(0.22, 0.17, 0.15), "staff")
	var dais := MeshInstance3D.new()
	var dais_mesh := CylinderMesh.new()
	dais_mesh.top_radius = 1.9
	dais_mesh.bottom_radius = 2.1
	dais_mesh.height = 0.14
	dais_mesh.radial_segments = 24
	dais.mesh = dais_mesh
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.12, 0.09, 0.09)
	stone.roughness = 0.85
	dais.material_override = stone
	dais.position.y = 0.05
	dais.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	merchant_npc.add_child(dais)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 1.65
	ring_mesh.outer_radius = 1.78
	ring_mesh.rings = 40
	ring_mesh.ring_segments = 4
	ring.mesh = ring_mesh
	ring.material_override = FX.glow_material(Color(1.0, 0.66, 0.24, 0.6))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = 0.14
	merchant_npc.add_child(ring)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.66, 0.3)
	light.light_energy = 3.2
	light.omni_range = 8.0
	light.shadow_enabled = false
	light.position.y = 2.6
	merchant_npc.add_child(light)
	var label := Label3D.new()
	label.text = "THE ASHEN BROKER"
	label.font_size = 52
	label.pixel_size = 0.0038
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.78, 0.36)
	label.outline_size = 12
	label.outline_modulate = Color(0.05, 0.0, 0.0, 0.9)
	label.position = Vector3(0.0, 3.1, 0.0)
	merchant_npc.add_child(label)
	var crate_scene := _get_model(DUNGEON_DIR + "crate.glb")
	var pot_scene := _get_model(DUNGEON_DIR + "pot.glb")
	_spawn_model(crate_scene, 0.8, merchant_npc, Vector3(1.6, 0.0, 0.6), 24.0)
	_spawn_model(crate_scene, 0.6, merchant_npc, Vector3(1.9, 0.0, -0.4), -12.0)
	_spawn_model(pot_scene, 0.55, merchant_npc, Vector3(-1.6, 0.0, 0.5), 0.0)
	_build_brazier(pos + Vector3(2.1, 0.0, -1.3))
	_build_brazier(pos + Vector3(-2.1, 0.0, -1.3))
	merchant_area = Area3D.new()
	merchant_area.name = "MerchantArea"
	merchant_area.collision_layer = 16
	merchant_area.collision_mask = 2
	merchant_area.monitoring = true
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 3.4
	shape.shape = sphere
	shape.position.y = 1.2
	merchant_area.add_child(shape)
	merchant_area.body_entered.connect(_on_merchant_range.bind(true))
	merchant_area.body_exited.connect(_on_merchant_range.bind(false))
	merchant_npc.add_child(merchant_area)
	_roll_shop_offers()
	if model == null:
		push_warning("Merchant model missing; using fallback")


func _on_merchant_range(body: Node, near: bool) -> void:
	if not (body is Player):
		return
	merchant_near = near
	if near and not shop_open:
		hud.show_prompt("E  -  TRADE WITH THE ASHEN BROKER")
	else:
		hud.hide_prompt()


func _open_shop() -> void:
	if shop_open or merchant_npc == null or not run_active:
		return
	shop_open = true
	hud.hide_prompt()
	hud.show_shop(shop_offers, coins, layer, _story_line("broker", layer))


func _close_shop() -> void:
	if shop_open:
		hud.close_shop()


func _on_shop_closed() -> void:
	shop_open = false
	if merchant_near:
		hud.show_prompt("E  -  TRADE WITH THE ASHEN BROKER")


func _roll_shop_offers() -> void:
	shop_offers.clear()
	for i in 3:
		var item := ItemDB.make_item(layer + 2, rng)
		if i == 0 and layer >= 12 and rng.randf() < 0.55:
			item = ItemDB.make_item(layer + 2, rng, "rare")
		shop_offers.append({
			"kind": "relic",
			"item": item,
			"name": String(item.get("name", "Relic")),
			"detail": _item_detail(item),
			"color": item.get("color", Color(0.90, 0.86, 0.79)),
			"price": _relic_price(item),
		})
	var pool := BOONS.duplicate()
	for i in 2:
		if pool.is_empty():
			break
		var pick := rng.randi() % pool.size()
		var boon: Dictionary = pool[pick]
		pool.remove_at(pick)
		shop_offers.append({
			"kind": "boon",
			"boon": String(boon.get("key", "")),
			"name": String(boon.get("name", "Boon")),
			"detail": String(boon.get("text", "")),
			"color": boon.get("color", Color(1.0, 0.72, 0.28)),
			"price": 55 + layer * 4,
		})
	shop_offers.append({
		"kind": "heal",
		"name": "VITAE FLASK",
		"detail": "Restore all vitae.",
		"color": Color(0.95, 0.32, 0.34),
		"price": 20 + layer * 2,
	})


func _relic_price(item: Dictionary) -> int:
	var base := 20
	match String(item.get("rarity", "common")):
		"magic":
			base = 45
		"rare":
			base = 95
		"legendary":
			base = 180
	var price := float(base) * (1.0 + 0.05 * float(layer - 1))
	return int(round(price))


func _item_detail(item: Dictionary) -> String:
	var parts: Array = []
	var unique := String(item.get("unique_text", ""))
	if unique != "":
		parts.append(unique)
	for line in ItemDB.mod_lines(item):
		parts.append(String(line.text))
	return "   ".join(parts)


func _on_shop_buy(index: int) -> void:
	if not shop_open or index < 0 or index >= shop_offers.size():
		return
	var offer: Dictionary = shop_offers[index]
	var price := int(offer.get("price", 0))
	if coins < price:
		hud.toast("NOT ENOUGH COIN", Color(1.0, 0.4, 0.3), 1.8)
		play_sfx("hit", -9.0, 0.1)
		return
	var kind := String(offer.get("kind", ""))
	if kind == "relic":
		var has_room := player.relics.size() < Player.MAX_RELICS
		for owned in player.relics:
			if owned.is_empty():
				has_room = true
		if not has_room:
			hud.toast("RELICS FULL  -  REMOVE ONE FIRST", Color(1.0, 0.4, 0.3), 2.2)
			return
	coins -= price
	shop_offers.remove_at(index)
	hud.set_coins(coins, true)
	play_sfx("pickup", -3.0, 0.1)
	match kind:
		"relic":
			hud.close_shop()
			hud.offer_relic(offer.get("item", {}))
			hud.toast("BOUGHT  %s" % String(offer.get("name", "RELIC")), offer.get("color", Color(1.0, 0.72, 0.28)), 2.2)
		"boon":
			var claimed := _apply_boon(String(offer.get("boon", "")))
			hud.update_shop(shop_offers, coins)
			hud.toast("%s  CLAIMED" % claimed, offer.get("color", Color(1.0, 0.8, 0.35)), 2.2)
		"heal":
			player.heal(player.max_health)
			hud.update_shop(shop_offers, coins)
			hud.toast("VITAE RESTORED", Color(0.95, 0.4, 0.42), 2.0)
	_save_run()


func _on_portal_entered(body: Node) -> void:
	if body is Player and portal_active:
		_next_layer()


func _next_layer() -> void:
	_save_record()
	hud.flash_transition()
	portal_active = false
	layer += 1
	play_sfx("portal", -2.0, 0.02)
	var level_before := player.level
	player.heal(player.max_health * 0.3)
	FX.nova(fx_root, player.global_position, Color(0.75, 0.3, 1.0, 1.0), 6.0)
	_generate_floor()
	hud.toast("RIFT LAYER %d  ·  +%d%% ENEMY LIFE" % [layer, int(16.0 * float(layer - 1))], Color(1.0, 0.72, 0.3), 2.8)
	if player.level > level_before:
		hud.toast("BLOOD DEEPENS  ·  LEVEL %d" % player.level, Color(1.0, 0.58, 0.66), 2.4)


func _on_ui_click() -> void:
	play_sfx("pickup", -11.0, 0.2)


func begin_run() -> void:
	if started or player == null:
		return
	hud.set_hero(character_name, character_class)
	_apply_class_visuals()
	get_tree().paused = false
	duel_mode = false
	RunSave.clear()
	started = true
	run_active = true
	coins = 0
	layer = 1
	kills = 0
	run_boons.clear()
	attack_target = null
	player.set_progress(1, 0.0)
	player.set_passives([], 1)
	player.revive()
	hud.hide_title()
	hud.show_body()
	hud.set_coins(0)
	_generate_floor()
	for enemy in enemies:
		enemy.frozen = false
	hud.toast("RIFT LAYER 1", Color(1.0, 0.72, 0.3), 2.4)
	_save_run()


func _continue_from_title() -> void:
	if started:
		return
	var entry := Roster.last_played()
	if not entry.is_empty():
		RunSave.set_slot(String(entry.get("id", "")))
		character_name = String(entry.get("name", character_name))
		character_class_id = String(entry.get("class_id", character_class_id))
		character_class = HeroClasses.display_name(character_class_id)
	if not continue_run():
		begin_run()


func _open_roster() -> void:
	hud.show_roster(Roster.all())


func _on_roster_load(id: String) -> void:
	var entry := Roster.entry(id)
	if entry.is_empty():
		return
	RunSave.set_slot(id)
	character_name = String(entry.get("name", character_name))
	character_class_id = String(entry.get("class_id", character_class_id))
	character_class = HeroClasses.display_name(character_class_id)
	started = false
	run_active = false
	if not continue_run():
		begin_run()


func _on_roster_delete(id: String) -> void:
	if RunSave.slot == id:
		RunSave.set_slot("")
	Roster.remove(id)
	hud.show_roster(Roster.all())


func _on_roster_create() -> void:
	hud.show_creator()


## The one multiplayer surface: the home screen and the pause menu both call
## this panel and these handlers, so there is no second, disconnected system.
func _on_net_action(action: String, mode: String) -> void:
	if action == "character":
		hud.show_creator()
		return
	match action:
		"open":
			hud.show_net_panel(mode)
			_refresh_net_panel()
		"find":
			_net_find_match()
		"duel":
			_start_duel()


## The creator hands back a name and a class key; only the Blood Sorceress is
## implemented, so any other key is refused rather than silently replaced.
func _on_character_created(hero_name: String, klass: String) -> void:
	if not HeroClasses.CLASSES.has(klass):
		hud.toast("THAT CLASS IS NOT READY", Color(1.0, 0.5, 0.3), 2.2)
		return
	character_name = hero_name if not hero_name.is_empty() else "VESNA"
	character_class_id = klass
	character_class = HeroClasses.display_name(klass)
	started = false
	run_active = false
	var entry := Roster.create(character_name, character_class_id)
	RunSave.set_slot(String(entry.get("id", "")))
	RunSave.clear()
	begin_run()
	hud.show_story(INTRO_TITLE, INTRO_BODY.replace("%HERO%", character_name))


func _open_passives() -> void:
	if player == null:
		return
	get_tree().paused = true
	hud.show_passives(player.passive_nodes, player.passive_points)


func _on_passive_buy(id: String) -> void:
	if player == null or not run_active:
		return
	if player.buy_passive(id):
		play_sfx("pickup", -4.0, 0.1)
		hud.show_passives(player.passive_nodes, player.passive_points)
		_save_run()


func _refresh_net_panel() -> void:
	hud.set_party_roster(character_name, character_class, player.level if player != null else 1, layer, online_peers)
	if online_mode:
		hud.set_net_status(
			"CONNECTED  -  SEAT %d  -  %d IN RIFT" % [my_seat + 1, online_peers],
			"You are in a Summer World. Monsters are still simulated on each client in this build; positions, seats and the world seed are authoritative.",
			true)
	else:
		hud.set_net_status(
			"NOT CONNECTED",
			"No Summer World is joined. Start Debug > Local Multiplayer > 2 Players, or a hosted build, then press FIND MATCH.",
			false)


func _net_find_match() -> void:
	if online_mode:
		hud.set_net_status("ALREADY IN A PARTY  -  SEAT %d" % (my_seat + 1), "Leave the rift to search for another World.", true)
		return
	if net == null or not net.has_method("retry_join"):
		hud.set_net_status("NO MATCHMAKING", "The network client is not ready.", false)
		return
	hud.set_net_status("SEARCHING...", "Asking Summer matchmaking for a rift World.", true)
	var result: Dictionary = await net.retry_join()
	if bool(result.get("ok", false)):
		hud.hide_net_panel()
		hud.toast("WORLD JOINED  -  SEAT %d" % (my_seat + 1), Color(0.62, 0.95, 0.72), 2.6)
		return
	hud.set_net_status("NO WORLD FOUND", String(result.get("error", "Matchmaking is unavailable in this run.")), false)


## Entering a selected rift from the map. Online runs stay in their party's
## World, so entry is local-only until the authority owns floor transitions.
func _on_rift_enter(target_layer: int) -> void:
	if online_mode:
		hud.toast("RIFT ENTRY IS LOCAL FOR NOW", Color(1.0, 0.55, 0.3), 2.6)
		return
	var target := clampi(target_layer, 1, maxi(1, best_layer) + 1)
	get_tree().paused = false
	started = true
	run_active = true
	layer = target
	kills = 0
	hud.hide_title()
	hud.show_body()
	hud.hide_death()
	hud.hide_boons()
	hud.close_relic_window()
	player.revive()
	player.ensure_level(layer)
	_generate_floor()
	hud.flash_transition()
	hud.toast("RIFT LAYER %d" % layer, Color(1.0, 0.72, 0.3), 2.2)


func _open_rift_map() -> void:
	var entries: Array = []
	var count := THEMES.size()
	for i in count:
		var l := i + 1
		entries.append({
			"layer": l,
			"name": String(THEMES[i % THEMES.size()].get("name", "RIFT")),
			"merchant": l % 6 == 5,
			"boss": l % 6 == 0,
		})
	hud.show_rift_map(entries, layer, best_layer)


func _restart_run() -> void:
	get_tree().paused = false
	duel_mode = false
	mouse_held = false
	boon_luck = 0.0
	coins = 0
	RunSave.clear()
	hud.flash_transition()
	hud.hide_boons()
	hud.hide_prompt()
	hud.set_coins(0)
	layer = 1
	kills = 0
	run_active = true
	started = true
	hud.hide_death()
	hud.close_relic_window()
	hud.show_body()
	player.set_progress(1, 0.0)
	player.revive()
	_generate_floor()
	for enemy in enemies:
		enemy.frozen = false
	hud.toast("THE RIFT REMEMBERS", Color(1.0, 0.72, 0.3), 2.6)


func _input(event: InputEvent) -> void:
	if player == null or hud == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if not started:
			if key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_P:
				return
			if key_event.keycode == KEY_C and RunSave.has_save():
				continue_run()
				get_viewport().set_input_as_handled()
				return
			return
		var key: int = key_event.keycode

		if key == KEY_1:
			_cast_ability(0)
		elif key == KEY_2:
			_cast_ability(1)
		elif key == KEY_3:
			_cast_ability(2)
		elif key == KEY_SPACE:
			_cast_dash()
		elif key == KEY_ENTER or key == KEY_KP_ENTER:
			hud.equip_pending_best()
		elif key == KEY_TAB:
			hud.toggle_relic_window()
		elif key == KEY_E:
			if shop_open:
				_close_shop()
			elif merchant_near:
				_open_shop()
		elif key == KEY_R and not player.alive:
			_restart_run()
		elif key == KEY_F:
			camera_pan = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if player == null or hud == null:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_target = clampf(zoom_target - 0.06 * float(GameSettings.get_value("zoom_step")), 0.78, 1.4)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_target = clampf(zoom_target + 0.06 * float(GameSettings.get_value("zoom_step")), 0.78, 1.4)
			return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		pan_drag = event.pressed
		return
	if event is InputEventMouseMotion and pan_drag:
		var cam_basis := camera.global_transform.basis
		var right := Vector3(cam_basis.x.x, 0.0, cam_basis.x.z).normalized()
		var back := Vector3(cam_basis.z.x, 0.0, cam_basis.z.z).normalized()
		var pan_speed := 0.018 * float(GameSettings.get_value("cam_pan")) * camera_zoom
		camera_pan += (-right * event.relative.x - back * event.relative.y) * pan_speed
		camera_pan = camera_pan.limit_length(14.0)
		return
	if event is InputEventMouseButton and event.pressed:
		if not started:
			get_viewport().set_input_as_handled()
			return
		if not run_active or not player.alive:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			_primary_attack(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_secondary_attack(event.position)


## Left mouse is the primary attack. Loot and the Broker still answer a click,
## because in an ARPG the cursor is also how you talk to the world.
func _primary_attack(screen_pos: Vector2) -> void:
	var drop := _loot_under(screen_pos)
	if drop != null:
		_on_loot_picked(drop)
		drop.queue_free()
		return
	if _merchant_under(screen_pos):
		_open_shop()
		return
	var point := _aim_point(screen_pos)
	attack_target = null
	player.stop()
	_clear_move_marker()
	player.set_aim(point)
	_cast_ability(player.primary_index())


## Right mouse is the secondary attack: the close-range blood nova.
func _secondary_attack(screen_pos: Vector2) -> void:
	var point := _aim_point(screen_pos)
	attack_target = null
	player.stop()
	_clear_move_marker()
	player.set_aim(point)
	_cast_ability(player.secondary_index())


func _set_move_marker(point: Vector3) -> void:
	if move_marker == null or not is_instance_valid(move_marker):
		move_marker = Node3D.new()
		move_marker.name = "MoveMarker"
		fx_root.add_child(move_marker)
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.34
		torus.outer_radius = 0.44
		torus.rings = 36
		torus.ring_segments = 4
		ring.mesh = torus
		ring.material_override = FX.glow_material(Color(1.0, 0.64, 0.26, 0.8))
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		move_marker.add_child(ring)
	move_marker.global_position = point + Vector3(0.0, 0.08, 0.0)
	move_marker.visible = true
	move_marker_point = point


func _clear_move_marker() -> void:
	if move_marker != null and is_instance_valid(move_marker):
		move_marker.visible = false
	move_marker_point = Vector3(9999.0, 0.0, 9999.0)


func _aim_point(screen_pos: Vector2) -> Vector3:
	var from := camera.project_ray_origin(screen_pos)
	var normal := camera.project_ray_normal(screen_pos)
	var plane := Plane(Vector3.UP, 0.0)
	var hit = plane.intersects_ray(from, normal)
	if hit == null:
		return player.global_position + Vector3(0, 0, -3)
	return hit


func _enemy_under(screen_pos: Vector2) -> Enemy:
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 200.0)
	query.collision_mask = 4
	query.collide_with_areas = false
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider = result.get("collider")
	if collider is Enemy:
		return collider
	return null


func _loot_under(screen_pos: Vector2) -> LootDrop:
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 200.0)
	query.collision_mask = 8
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider = result.get("collider")
	if collider is LootDrop:
		return collider
	return null


func _merchant_under(screen_pos: Vector2) -> bool:
	if merchant_area == null or not is_instance_valid(merchant_area):
		return false
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 200.0)
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return false
	return result.get("collider") == merchant_area


func _on_hud_ability_pressed(index: int) -> void:
	if not started:
		begin_run()
	if not run_active or not player.alive:
		return
	if index >= 3:
		_cast_dash()
	else:
		_cast_ability(index)


func _refresh_map() -> void:
	var foes: Array = []
	var elites: Array = []
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		var enemy_cell := _world_to_cell(enemy.global_position)
		if enemy.elite or enemy.boss:
			elites.append(enemy_cell)
		else:
			foes.append(enemy_cell)
	var gate := Vector2i(-99, -99)
	if portal != null and is_instance_valid(portal):
		gate = _world_to_cell(portal.global_position)
	hud.update_map(_world_to_cell(player.global_position), foes, elites, gate, portal_active)
	if boss_enemy != null and is_instance_valid(boss_enemy) and not boss_enemy.dead:
		var ratio := boss_enemy.health / maxf(boss_enemy.max_health, 1.0)
		hud.set_boss(boss_enemy.display_name, ratio, true)


func _cast_ability(index: int) -> void:
	if not run_active or not player.alive:
		return
	if not player.try_ability(index):
		if index < player.cooldowns.size() and player.cooldowns[index] <= 0.0:
			var resource := "VITAE" if player.is_health_cost() else String(player.focus_name)
			hud.toast("NOT ENOUGH %s" % resource, Color(1.0, 0.34, 0.28), 1.1)
			hud.flash_damage(0.2)


func _on_focus_changed(current: float, maximum: float) -> void:
	if hud == null or player == null:
		return
	hud.set_focus(current, maximum, player.focus_name, player.focus_color)


func _cast_dash() -> void:
	if not run_active or not player.alive:
		return
	if player.try_dash():
		FX.burst(fx_root, player.global_position + Vector3(0.0, 0.6, 0.0), Color(1.0, 0.2, 0.15, 0.9), 20, 4.0, 0.35, 0.5)
		play_sfx("cast", -6.0, 0.2)
		if player.has_unique("dash_burn"):
			_dash_burn()


func _dash_burn() -> void:
	await get_tree().create_timer(0.2).timeout
	if not is_instance_valid(player) or not player.alive:
		return
	var center := player.global_position
	FX.nova(fx_root, center, Color(1.0, 0.35, 0.08, 1.0), 4.2)
	play_sfx("lava", -2.0, 0.1)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		if enemy.global_position.distance_to(center) <= 4.2:
			var roll := player.roll_damage(30.0)
			enemy.take_damage(roll[0], roll[1])


func _on_ability_used(index: int, aim: Vector3) -> void:
	if duel_mode:
		duel_casts += 1
	var ability: Dictionary = HeroClasses.ability(character_class_id, index)
	var effect := String(ability.get("effect", ""))
	var color: Color = ability.get("color", Color(1.0, 0.3, 0.2))
	match effect:
		"nova":
			_blood_nova()
		"lance":
			_crimson_lance(aim)
		"siphon":
			_siphon()
		"slam":
			_hammer_slam(ability, aim)
		"aegis":
			_aegis_rush(ability, aim)
		"consecrate":
			_consecrate(ability, aim)
		"shot":
			_piercing_shot(ability, aim)
		"volley":
			_fan_of_arrows(ability, aim)
		"blink":
			_shade_step(ability, aim)
		_:
			pass
	hud.flash_ability(color)
	play_sfx("cast", -1.0, 0.1)


func _blood_nova() -> void:
	var radius := 4.6
	if player.has_unique("nova_free"):
		radius *= 1.55
	var center := player.global_position
	FX.nova(fx_root, center, Color(1.0, 0.13, 0.1, 1.0), radius)
	FX.burst(fx_root, center + Vector3(0.0, 0.4, 0.0), Color(1.0, 0.32, 0.16, 0.95), 26, 6.5, 0.5, 0.6, 6.0, 55.0)
	FX.ring(fx_root, center, Color(1.0, 0.44, 0.2, 0.55), radius * 1.28, 0.45, 0.04)
	FX.shards(fx_root, center, Color(1.0, 0.30, 0.16, 0.95), 14, radius * 0.7, 2.6, 0.6)
	FX.fault(fx_root, center, Color(1.0, 0.22, 0.12, 0.75), radius * 0.9, 8, 0.8)
	_aftershock(center, radius)
	_shake(0.45)
	play_sfx("hit", -1.0, 0.14)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		if enemy.global_position.distance_to(center) <= radius + 0.7:
			var roll := player.roll_damage(34.0)
			enemy.take_damage(roll[0], roll[1])
			if is_instance_valid(enemy) and not enemy.dead:
				var push: Vector3 = enemy.global_position - center
				push.y = 0.0
				enemy.global_position += push.normalized() * 0.4


func _aftershock(center: Vector3, radius: float) -> void:
	await get_tree().create_timer(0.16).timeout
	if not is_inside_tree():
		return
	FX.ring(fx_root, center, Color(1.0, 0.28, 0.18, 0.42), radius * 1.45, 0.42, 0.05)
	FX.disc(fx_root, center, Color(0.9, 0.16, 0.1, 0.22), radius * 0.8, 0.5, 0.03)


func _crimson_lance(aim: Vector3) -> void:
	var dir := aim - player.global_position
	dir.y = 0.0
	if dir.length() < 0.2:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	var triple := player.has_unique("lance_triple")
	var count := 3 if triple else 1
	for i in count:
		var angle := 0.0
		if triple:
			angle = deg_to_rad(-9.0 + 9.0 * float(i))
		var shot_dir := dir.rotated(Vector3.UP, angle)
		var roll := player.roll_damage(26.0)
		var bolt := BloodBolt.new()
		bolt.direction = shot_dir
		bolt.speed = 36.0
		bolt.damage = roll[0]
		bolt.crit = roll[1]
		bolt.pierce = 2 if triple else 0
		bolt.color = Color(1.0, 0.12, 0.1)
		fx_root.add_child(bolt)
		bolt.global_position = player.global_position + Vector3(0.0, 1.05, 0.0) + shot_dir * 0.9
		FX.burst(fx_root, bolt.global_position, Color(1.0, 0.2, 0.16, 0.9), 10, 4.0, 0.28, 0.28)
		FX.beam(fx_root, player.global_position + Vector3(0.0, 1.05, 0.0), bolt.global_position + shot_dir * 2.2, Color(1.0, 0.24, 0.18, 0.55), 0.13, 0.14)
		FX.ring(fx_root, player.global_position, Color(1.0, 0.25, 0.2, 0.5), 1.4, 0.22, 0.05)


func _siphon() -> void:
	var greater := player.has_unique("siphon_greater")
	var damage_per_tick := 9.0 if greater else 7.0
	var heal_factor := 0.34 if greater else 0.2
	var radius := 7.5
	FX.nova(fx_root, player.global_position, Color(0.72, 0.18, 0.95, 1.0), 4.4)
	FX.ring(fx_root, player.global_position, Color(0.85, 0.35, 1.0, 0.6), radius, 0.7, 0.06)
	for tick in 8:
		if not is_instance_valid(player) or not player.alive or not run_active:
			return
		var drained := 0.0
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy) or enemy.dead:
				continue
			var offset: Vector3 = enemy.global_position - player.global_position
			offset.y = 0.0
			if offset.length() <= radius:
				var roll := player.roll_damage(damage_per_tick)
				enemy.take_damage(roll[0], roll[1])
				drained += roll[0]
				FX.beam(fx_root, player.global_position + Vector3(0.0, 1.1, 0.0), enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.95, 0.12, 0.15, 0.85), 0.06, 0.28)
		if drained > 0.0:
			player.heal(drained * heal_factor)
			FX.burst(fx_root, player.global_position + Vector3(0.0, 1.2, 0.0), Color(1.0, 0.25, 0.3, 0.9), 10, 3.0, 0.3, 0.4)
		FX.ring(fx_root, player.global_position, Color(0.85, 0.1, 0.12, 0.5), radius * 0.6, 0.3, 0.04)
		await get_tree().create_timer(0.24).timeout


## Iron Paladin: a heavy frontal blow that cracks the basalt.
func _hammer_slam(ability: Dictionary, aim: Vector3) -> void:
	var center := player.global_position
	var radius := float(ability.get("radius", 3.8))
	var dir := aim - center
	dir.y = 0.0
	if dir.length() < 0.3:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	var gold := Color(1.0, 0.82, 0.38, 1.0)
	var landing := center + dir * radius * 0.5
	FX.ring(fx_root, landing, Color(gold.r, gold.g, gold.b, 0.8), radius, 0.5, 0.06)
	var swing := landing - center
	swing.y = 0.0
	FX.slash(fx_root, center + Vector3(0.0, 1.1, 0.0), swing, Color(1.0, 0.86, 0.5, 0.9), radius * 0.85, 0.22, 150.0)
	FX.disc(fx_root, landing, Color(gold.r, gold.g, gold.b, 0.24), radius * 0.8, 0.45, 0.03)
	FX.nova(fx_root, landing, gold, radius * 0.75)
	FX.burst(fx_root, landing + Vector3(0.0, 0.3, 0.0), gold, 22, 6.5, 0.45, 0.55)
	FX.beam(fx_root, landing + Vector3(0.0, 2.6, 0.0), landing, Color(1.0, 0.9, 0.6, 0.7), 0.32, 0.2)
	FX.fault(fx_root, landing, Color(1.0, 0.78, 0.34, 0.8), radius * 1.05, 9, 1.1)
	FX.shards(fx_root, landing, Color(1.0, 0.86, 0.44, 0.95), 16, radius * 0.75, 3.2, 0.65)
	_shake(0.55)
	play_sfx("hit", -1.0, 0.08)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		var offset: Vector3 = enemy.global_position - center
		offset.y = 0.0
		if offset.length() > radius + 0.9:
			continue
		if offset.length() > 0.6 and offset.normalized().dot(dir) < -0.1:
			continue
		var roll := player.roll_damage(float(ability.get("power", 30.0)))
		enemy.take_damage(roll[0], roll[1])


## Iron Paladin: a short shield-first charge that leaves a sunlit guard.
func _aegis_rush(ability: Dictionary, aim: Vector3) -> void:
	var dir := aim - player.global_position
	dir.y = 0.0
	if dir.length() < 0.3:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	player.dash_direction = dir
	player.dash_time = 0.13
	player.invulnerable = maxf(player.invulnerable, 0.3)
	player.apply_shield(player.max_health * 0.4, 5.5)
	player.heal(player.max_health * 0.12)
	var gold := Color(1.0, 0.86, 0.5, 1.0)
	FX.burst(fx_root, player.global_position + Vector3(0.0, 1.0, 0.0), gold, 24, 5.0, 0.4, 0.5)
	FX.ring(fx_root, player.global_position, Color(gold.r, gold.g, gold.b, 0.7), float(ability.get("radius", 2.4)), 0.45, 0.06)
	FX.sparkle(fx_root, player.global_position + Vector3(0.0, 1.4, 0.0), gold)
	FX.shards(fx_root, player.global_position, Color(1.0, 0.9, 0.58, 0.9), 10, 1.5, 1.8, 0.42)
	_shake(0.3)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		var offset: Vector3 = enemy.global_position - player.global_position
		offset.y = 0.0
		if offset.length() > 3.0:
			continue
		if offset.length() > 0.4 and offset.normalized().dot(dir) < 0.0:
			continue
		var roll := player.roll_damage(float(ability.get("power", 18.0)))
		enemy.take_damage(roll[0], roll[1])


## Iron Paladin: hallow a patch of ground; it burns for four seconds.
func _consecrate(ability: Dictionary, aim: Vector3) -> void:
	var center := aim
	center.y = player.global_position.y
	var offset := center - player.global_position
	offset.y = 0.0
	if offset.length() > 6.5:
		center = player.global_position + offset.normalized() * 6.5
	var radius := float(ability.get("radius", 4.8))
	var gold := Color(1.0, 0.72, 0.26, 1.0)
	FX.disc(fx_root, center, Color(gold.r, gold.g, gold.b, 0.3), radius, 4.2, 0.04)
	FX.ring(fx_root, center, Color(gold.r, gold.g, gold.b, 0.85), radius, 0.5, 0.07)
	FX.embers(fx_root, center, gold, 18, radius * 0.7)
	FX.fault(fx_root, center, Color(1.0, 0.7, 0.3, 0.7), radius, 10, 1.3)
	for tick in 5:
		if not is_instance_valid(player) or not player.alive or not run_active:
			return
		FX.ring(fx_root, center, Color(gold.r, gold.g, gold.b, 0.55), radius * 0.92, 0.4, 0.05)
		FX.embers(fx_root, center, gold, 8, radius * 0.55)
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy) or enemy.dead:
				continue
			var dist: float = enemy.global_position.distance_to(center)
			if dist <= radius:
				var roll := player.roll_damage(float(ability.get("power", 15.0)))
				enemy.take_damage(roll[0], roll[1])
		await get_tree().create_timer(0.62).timeout


## Shadow Huntress: one flat, fast arrow that punches through a body.
func _piercing_shot(ability: Dictionary, aim: Vector3) -> void:
	var dir := aim - player.global_position
	dir.y = 0.0
	if dir.length() < 0.2:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	var teal: Color = ability.get("color", Color(0.55, 0.95, 0.85))
	var roll := player.roll_damage(float(ability.get("power", 24.0)))
	var bolt := BloodBolt.new()
	bolt.direction = dir
	bolt.speed = 46.0
	bolt.damage = roll[0]
	bolt.crit = roll[1]
	bolt.pierce = 1
	bolt.color = teal
	fx_root.add_child(bolt)
	bolt.global_position = player.global_position + Vector3(0.0, 1.05, 0.0) + dir * 0.9
	FX.burst(fx_root, bolt.global_position, Color(teal.r, teal.g, teal.b, 0.9), 10, 4.0, 0.25, 0.28)
	FX.beam(fx_root, player.global_position + Vector3(0.0, 1.05, 0.0), bolt.global_position + dir * 3.0, Color(teal.r, teal.g, teal.b, 0.4), 0.08, 0.12)
	FX.slash(fx_root, player.global_position + Vector3(0.0, 1.05, 0.0), dir, Color(teal.r, teal.g, teal.b, 0.55), 1.5, 0.18, 60.0)


## Shadow Huntress: five arrows in a fan.
func _fan_of_arrows(ability: Dictionary, aim: Vector3) -> void:
	var dir := aim - player.global_position
	dir.y = 0.0
	if dir.length() < 0.2:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	var violet: Color = ability.get("color", Color(0.62, 0.5, 1.0))
	for i in 5:
		var angle := deg_to_rad(-26.0 + 13.0 * float(i))
		var shot_dir := dir.rotated(Vector3.UP, angle)
		var roll := player.roll_damage(float(ability.get("power", 15.0)))
		var bolt := BloodBolt.new()
		bolt.direction = shot_dir
		bolt.speed = 38.0
		bolt.damage = roll[0]
		bolt.crit = roll[1]
		bolt.pierce = 0
		bolt.color = violet
		fx_root.add_child(bolt)
		bolt.global_position = player.global_position + Vector3(0.0, 1.05, 0.0) + shot_dir * 0.9
		FX.burst(fx_root, bolt.global_position, Color(violet.r, violet.g, violet.b, 0.7), 6, 3.0, 0.2, 0.22)
	FX.ring(fx_root, player.global_position, Color(violet.r, violet.g, violet.b, 0.5), 1.6, 0.25, 0.05)


## Shadow Huntress: slip through the seam toward the cursor, then sharpen.
func _shade_step(ability: Dictionary, aim: Vector3) -> void:
	var dir := aim - player.global_position
	dir.y = 0.0
	if dir.length() < 0.3:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	var from := player.global_position
	var max_dist := float(ability.get("radius", 6.5))
	var landing := from
	var steps := 14
	for i in range(1, steps + 1):
		var probe := from + dir * (max_dist * float(i) / float(steps))
		if walkable.has(_world_to_cell(probe)):
			landing = probe
	player.teleport_to(landing)
	player.invulnerable = maxf(player.invulnerable, 0.18)
	player.apply_crit_window(0.25, 3.0)
	var violet: Color = ability.get("color", Color(0.5, 0.42, 1.0))
	FX.burst(fx_root, from + Vector3(0.0, 1.0, 0.0), Color(violet.r, violet.g, violet.b, 0.85), 18, 4.0, 0.4, 0.45)
	FX.burst(fx_root, landing + Vector3(0.0, 1.0, 0.0), Color(violet.r, violet.g, violet.b, 0.9), 18, 4.0, 0.4, 0.45)
	FX.ring(fx_root, landing, Color(violet.r, violet.g, violet.b, 0.7), 1.8, 0.35, 0.05)
	FX.shards(fx_root, from, Color(violet.r, violet.g, violet.b, 0.8), 9, 1.1, 1.6, 0.4)
	FX.shards(fx_root, landing, Color(violet.r, violet.g, violet.b, 0.95), 11, 1.4, 2.0, 0.45)
	var trail := from
	for i in 6:
		trail = trail.lerp(landing, 0.18)
		FX.disc(fx_root, trail, Color(violet.r, violet.g, violet.b, 0.22), 0.55, 0.32, 0.03)


func _on_player_damaged(amount: float) -> void:
	hud.flash_damage(clampf(amount / 30.0, 0.25, 1.4))
	_shake(clampf(amount / 26.0, 0.1, 0.6))
	play_sfx("hit", -6.0, 0.15)


func _on_player_healed(amount: float) -> void:
	if amount > 3.0:
		FX.sparkle(fx_root, player.global_position + Vector3(0.0, 1.3, 0.0), Color(1.0, 0.25, 0.25, 0.9))


func _on_player_leveled(level: int) -> void:
	player.passive_points += 1
	player.passives_changed.emit()
	play_sfx("pickup", -2.0, 0.02)
	FX.nova(fx_root, player.global_position, Color(1.0, 0.82, 0.32, 1.0), 5.0)
	FX.ring(fx_root, player.global_position, Color(1.0, 0.7, 0.25, 0.8), 4.0, 0.8, 0.05)
	hud.toast("LEVEL %d  -  PASSIVE POINT" % level, Color(1.0, 0.84, 0.34), 2.2)
	hud.set_level(player.level, player.xp, player.xp_to_next())


func _on_life_spent(amount: float) -> void:
	FX.burst(fx_root, player.global_position + Vector3(0.0, 1.0, 0.0), Color(0.8, 0.05, 0.1, 0.85), 8, 3.0, 0.3, 0.4)


func _on_health_changed(current: float, maximum: float) -> void:
	hud.set_health(current, maximum, player.regen_now(), player.in_combat())


func _on_player_died() -> void:
	run_active = false
	if duel_mode:
		hud.set_boss("", 0.0, false)
		hud.hide_boons()
		hud.close_relic_window()
		play_sfx("death", 0.0, 0.05)
		FX.burst(fx_root, player.global_position + Vector3(0.0, 1.0, 0.0), Color(0.9, 0.1, 0.12, 1.0), 60, 8.0, 0.6, 1.2)
		FX.nova(fx_root, player.global_position, Color(0.9, 0.12, 0.1, 1.0), 5.0)
		_duel_finished(false)
		return
	RunSave.clear()
	hud.set_boss("", 0.0, false)
	_save_record()
	hud.hide_boons()
	hud.close_relic_window()
	hud.close_relic_window()
	play_sfx("death", 0.0, 0.05)
	FX.burst(fx_root, player.global_position + Vector3(0.0, 1.0, 0.0), Color(0.9, 0.1, 0.12, 1.0), 60, 8.0, 0.6, 1.2)
	FX.nova(fx_root, player.global_position, Color(0.9, 0.12, 0.1, 1.0), 5.0)
	var relic_name := player.relic_names()
	hud.show_death(layer, kills, relic_name)


func _shake(amount: float) -> void:
	if not bool(GameSettings.get_value("shake")):
		return
	camera_shake = maxf(camera_shake, amount)


func _process(delta: float) -> void:
	if player == null:
		return
	var mouse := get_viewport().get_mouse_position()
	player.set_aim(_aim_point(mouse))
	_update_move_input()
	var costs: Array = [player.ability_cost(0), player.ability_cost(1), player.ability_cost(2)]
	var available := player.health if player.is_health_cost() else player.focus
	hud.set_cooldowns(player.cooldowns, player.dash_cooldown, available, costs)
	hud.set_bloodrush(player.bloodrush, player.bloodrush_timer / Player.BLOODRUSH_TIME)
	hud.set_health(player.health, player.max_health, player.regen_now(), player.in_combat())
	hud.set_level(player.level, player.xp, player.xp_to_next())
	if merchant_npc != null and is_instance_valid(merchant_npc):
		var near := player.global_position.distance_to(merchant_npc.global_position) < 4.4
		if near != merchant_near:
			_on_merchant_range(player, near)
	map_timer -= delta
	if map_timer <= 0.0:
		map_timer = 0.12
		_refresh_map()
	if portal_disc != null and is_instance_valid(portal_disc):
		var flat_cam := Vector3(camera.global_position.x, portal_disc.global_position.y, camera.global_position.z)
		if flat_cam.distance_to(portal_disc.global_position) > 0.2:
			portal_disc.look_at(flat_cam, Vector3.UP)
	_update_camera(delta)
	_update_prop_fade(delta)
	_update_move_marker()
	if not run_active or not player.alive:
		mouse_held = false
		attack_target = null
		_clear_move_marker()
		player.set_move_direct(Vector3.ZERO)
		return
	_pull_loot(delta)
	hazard_timer -= delta
	if hazard_timer <= 0.0:
		hazard_timer = maxf(5.5, 11.0 - 0.35 * float(layer - 1)) * rng.randf_range(0.9, 1.25)
		if has_mod("unstable"):
			hazard_timer *= 0.7
		if not _is_merchant_layer():
			_spawn_hazard()
	lava_timer -= delta
	if lava_timer <= 0.0:
		lava_timer = 0.5
		lava_warn_timer = maxf(0.0, lava_warn_timer - 0.5)
		var cell := _world_to_cell(player.global_position)
		player.in_lava = _is_inside(cell) and not walkable.get(cell, false)
		if player.in_lava:
			player.take_damage(4.0 + 1.2 * float(layer))
			FX.burst(fx_root, player.global_position + Vector3(0.0, 0.3, 0.0), Color(1.0, 0.5, 0.15, 0.9), 12, 3.0, 0.4, 0.5)
			if lava_warn_timer <= 0.0:
				lava_warn_timer = 2.4
				hud.toast("MOLTEN GROUND  ·  MOVE", Color(1.0, 0.45, 0.2), 1.2)


func _update_move_marker() -> void:
	if move_marker == null or not is_instance_valid(move_marker) or not move_marker.visible:
		return
	var pulse := 1.0 + 0.14 * sin(Time.get_ticks_msec() * 0.009)
	move_marker.scale = Vector3(pulse, 1.0, pulse)
	if player.global_position.distance_to(move_marker_point) < 1.0:
		_clear_move_marker()


func _update_move_input() -> void:
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input.x += 1.0
	if input.length_squared() < 0.01:
		player.set_move_direct(Vector3.ZERO)
		return
	var cam_basis := camera.global_transform.basis
	var forward := Vector3(-cam_basis.z.x, 0.0, -cam_basis.z.z).normalized()
	var right := Vector3(cam_basis.x.x, 0.0, cam_basis.x.z).normalized()
	var direction := forward * -input.y + right * input.x
	player.set_move_direct(direction.normalized())


func _pull_loot(delta: float) -> void:
	for child in entity_root.get_children():
		if not (child is LootDrop):
			continue
		var drop := child as LootDrop
		var to_player := player.global_position - drop.global_position
		to_player.y = 0.0
		var dist := to_player.length()
		var stop := 1.0 if drop.is_life else 2.2
		if dist <= stop or dist > 6.5:
			continue
		drop.global_position += to_player.normalized() * minf(9.0 * delta, dist - stop)


func _update_camera(delta: float) -> void:
	var aim := player.aim_point
	var look := player.global_position + (aim - player.global_position).limit_length(4.0) * 0.10
	## Keep a warden in frame: lean toward it and pull the camera back, so a
	## three metre boss is never cropped by the top of the screen.
	var wanted_framing := 0.0
	if boss_enemy != null and is_instance_valid(boss_enemy) and not boss_enemy.dead:
		var to_boss := boss_enemy.global_position - player.global_position
		to_boss.y = 0.0
		var reach := to_boss.length()
		if reach < 18.0:
			wanted_framing = 0.16 + 0.14 * clampf(1.0 - reach / 18.0, 0.0, 1.0)
			look = look.lerp(boss_enemy.global_position, 0.24)
			look.y += 0.9
	boss_framing = lerpf(boss_framing, wanted_framing, clampf(delta * 2.2, 0.0, 1.0))
	_edge_pan(delta)
	look += camera_pan
	var follow := clampf(float(GameSettings.get_value("cam_follow")), 1.0, 12.0)
	camera_focus = camera_focus.lerp(look, clampf(delta * follow, 0.0, 1.0))
	camera_zoom = lerpf(camera_zoom, zoom_target, clampf(delta * 7.0, 0.0, 1.0))
	var desired := _camera_desired()
	camera.global_position = camera.global_position.lerp(desired, clampf(delta * 4.6, 0.0, 1.0))
	camera_shake = maxf(0.0, camera_shake - delta * 1.8)
	var jitter := Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), 0.0) * camera_shake * 0.6
	camera.look_at(camera_focus + Vector3(0.0, 1.0, 0.0) + jitter, Vector3.UP)


func _camera_desired() -> Vector3:
	var desired := camera_focus + CAMERA_OFFSET * (camera_zoom + boss_framing)
	var limit := float(GRID) * CELL * 0.5 - 7.0
	desired.x = clampf(desired.x, -limit, limit)
	desired.z = clampf(desired.z, -limit, limit)
	return desired


## Mouse-edge panning, off by default and never while dragging the camera.
func _edge_pan(delta: float) -> void:
	if not bool(GameSettings.get_value("edge_pan")) or pan_drag:
		return
	var size := get_viewport().get_visible_rect().size
	if size.x < 10.0 or size.y < 10.0:
		return
	var mouse := get_viewport().get_mouse_position()
	var margin := 18.0
	var push := Vector2.ZERO
	if mouse.x < margin:
		push.x = -1.0
	elif mouse.x > size.x - margin:
		push.x = 1.0
	if mouse.y < margin:
		push.y = -1.0
	elif mouse.y > size.y - margin:
		push.y = 1.0
	if push == Vector2.ZERO:
		return
	var cam_basis := camera.global_transform.basis
	var right := Vector3(cam_basis.x.x, 0.0, cam_basis.x.z).normalized()
	var back := Vector3(cam_basis.z.x, 0.0, cam_basis.z.z).normalized()
	var speed := 7.0 * float(GameSettings.get_value("cam_pan")) * delta * camera_zoom
	camera_pan += (right * push.x + back * -push.y) * speed
	camera_pan = camera_pan.limit_length(14.0)


func _spawn_hazard() -> void:
	if hazards_alive >= 1:
		return
	var options: Array = []
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		var pos := _cell_to_world(cell)
		var dist := pos.distance_to(player.global_position)
		if dist > 5.0 and dist < 22.0:
			options.append(cell)
	if options.is_empty():
		return
	var cell: Vector2i = options[rng.randi() % options.size()]
	var hazard := LavaEruption.new()
	fx_root.add_child(hazard)
	hazard.global_position = _cell_to_world(cell)
	hazard.radius = rng.randf_range(1.9, 2.6)
	hazard.damage = 16.0 + 4.0 * float(layer)
	hazard.telegraph = 1.5
	hazard.set_player(player)
	hazard.exploded.connect(_on_hazard_exploded)
	hazards_alive += 1


func _on_hazard_exploded(at: Vector3) -> void:
	hazards_alive = maxi(0, hazards_alive - 1)
	play_sfx("lava", -3.0, 0.12)
	_shake(0.25)

