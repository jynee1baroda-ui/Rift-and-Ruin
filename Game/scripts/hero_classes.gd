class_name HeroClasses
extends RefCounted

## Every playable class is data. Adding a class means adding one entry here and
## one effect branch in game.gd, never a new player script.
## cost_kind is the class resource: "health" for the Blood Sorceress (she pays
## in vitae) or "focus" for the others (a second bar that regenerates).

const CLASSES := {
	"blood_sorceress": {
		"id": "blood_sorceress",
		"name": "BLOOD SORCERESS",
		"role": "Life is the fuel",
		"blurb": "She burns her own blood to cast. Every spell is a decision about how much of herself she is willing to spend, and the rift always takes the wager.",
		"color": Color(0.95, 0.3, 0.32),
		"glow": Color(1.0, 0.2, 0.16),
		"sigil": "BLOOD",
		"glove": Color(0.30, 0.11, 0.13),
		"portrait": "res://art/portraits/blood_sorceress.png",
		"model": "res://art/generated/blood_sorceress/character.tscn",
		"model_scale": 1.35,
		"health": 220.0, "speed": 7.2, "regen": 2.4, "power": 1.0,
		"cost_kind": "health",
		"focus_name": "", "focus_max": 0.0, "focus_regen": 0.0,
		"focus_color": Color(0.95, 0.3, 0.32),
		"primary": 1, "secondary": 0,
		"dash": "Riftstep",
		"abilities": [
			{"id": "nova", "name": "Blood Nova", "glyph": "NOVA", "effect": "nova",
				"desc": "Detonate your life force around you.", "cost": 6.0, "cooldown": 3.2,
				"cast": 0.24, "power": 34.0, "radius": 4.6, "color": Color(1.0, 0.2, 0.14),
				"icon": "res://art/generated/icon_nova/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037296460-0_1794037296461_2fben6it.png"},
			{"id": "lance", "name": "Crimson Lance", "glyph": "LANCE", "effect": "lance",
				"desc": "Hurl a piercing spear of blood.", "cost": 3.0, "cooldown": 0.6,
				"cast": 0.12, "power": 26.0, "radius": 0.0, "color": Color(1.0, 0.24, 0.18),
				"icon": "res://art/generated/icon_lance/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037334226-0_1794037334226_0jajynkv.png"},
			{"id": "siphon", "name": "Sanguine Siphon", "glyph": "SIPHON", "effect": "siphon",
				"desc": "Drain nearby foes and drink their life.", "cost": 0.0, "cooldown": 7.5,
				"cast": 0.3, "power": 7.0, "radius": 7.5, "color": Color(0.8, 0.3, 1.0),
				"icon": "res://art/generated/icon_siphon/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037347430-0_1794037347430_d38c0j6p.png"},
		],
	},
	"iron_paladin": {
		"id": "iron_paladin",
		"name": "IRON PALADIN",
		"role": "The wall that walks",
		"blurb": "A knight in rift-scarred plate carrying the last lit sun of a drowned city. He holds the line so the others can breathe, and he does not move when the ground does.",
		"color": Color(0.95, 0.78, 0.42),
		"glow": Color(1.0, 0.78, 0.3),
		"sigil": "IRON",
		"glove": Color(0.19, 0.19, 0.21),
		"portrait": "res://art/portraits/iron_paladin.png",
		"model": "res://art/generated/iron_paladin/character.tscn",
		"model_scale": 1.5,
		"health": 320.0, "speed": 6.6, "regen": 3.4, "power": 1.0,
		"cost_kind": "focus",
		"focus_name": "RESOLVE", "focus_max": 110.0, "focus_regen": 10.0,
		"focus_color": Color(1.0, 0.78, 0.32),
		"primary": 0, "secondary": 1,
		"dash": "Shieldrush",
		"abilities": [
			{"id": "hammer", "name": "Hammer of Noon", "glyph": "HAMMER", "effect": "slam",
				"desc": "A heavy overhead blow that cracks the ground in front of you.", "cost": 10.0, "cooldown": 0.85,
				"cast": 0.26, "power": 30.0, "radius": 3.8, "color": Color(1.0, 0.8, 0.35),
				"icon": "res://art/icons/paladin_hammer.png"},
			{"id": "aegis", "name": "Aegis Rush", "glyph": "AEGIS", "effect": "aegis",
				"desc": "Charge a short distance behind a sunlit shield.", "cost": 26.0, "cooldown": 9.0,
				"cast": 0.2, "power": 18.0, "radius": 2.4, "color": Color(1.0, 0.86, 0.5),
				"icon": "res://art/icons/paladin_aegis.png"},
			{"id": "consecrate", "name": "Consecrate", "glyph": "HALLOW", "effect": "consecrate",
				"desc": "Hallow the ground: it burns the rift's own for four seconds.", "cost": 34.0, "cooldown": 11.0,
				"cast": 0.36, "power": 15.0, "radius": 4.8, "color": Color(1.0, 0.72, 0.26),
				"icon": "res://art/icons/paladin_consecrate.png"},
		],
	},
	"shadow_huntress": {
		"id": "shadow_huntress",
		"name": "SHADOW HUNTRESS",
		"role": "Nothing is out of range",
		"blurb": "She hunts what the rift lets loose and never lets it close. Her arrows remember every name the seam has taken, and she says them out loud before she fires.",
		"color": Color(0.55, 0.9, 0.82),
		"glow": Color(0.4, 0.95, 0.8),
		"sigil": "SHADE",
		"glove": Color(0.21, 0.20, 0.26),
		"portrait": "res://art/portraits/shadow_huntress.png",
		"model": "res://art/generated/shadow_huntress/character.tscn",
		"model_scale": 1.35,
		"health": 190.0, "speed": 8.2, "regen": 2.2, "power": 1.05,
		"cost_kind": "focus",
		"focus_name": "FOCUS", "focus_max": 120.0, "focus_regen": 12.0,
		"focus_color": Color(0.5, 0.95, 0.84),
		"primary": 0, "secondary": 1,
		"dash": "Shadestep",
		"abilities": [
			{"id": "shot", "name": "Piercing Shot", "glyph": "SHOT", "effect": "shot",
				"desc": "A flat, fast arrow that punches through the first body.", "cost": 4.0, "cooldown": 0.5,
				"cast": 0.1, "power": 24.0, "radius": 0.0, "color": Color(0.55, 0.95, 0.85),
				"icon": "res://art/icons/huntress_shot.png"},
			{"id": "volley", "name": "Fan of Arrows", "glyph": "VOLLEY", "effect": "volley",
				"desc": "Five shadowed arrows in a wide fan.", "cost": 22.0, "cooldown": 5.0,
				"cast": 0.24, "power": 15.0, "radius": 0.0, "color": Color(0.62, 0.5, 1.0),
				"icon": "res://art/icons/huntress_volley.png"},
			{"id": "shade_step", "name": "Shade Step", "glyph": "STEP", "effect": "blink",
				"desc": "Step through the seam and sharpen your aim for three seconds.", "cost": 24.0, "cooldown": 8.0,
				"cast": 0.1, "power": 0.0, "radius": 6.5, "color": Color(0.5, 0.42, 1.0),
				"icon": "res://art/icons/huntress_step.png"},
		],
	},
}


static func ids() -> Array:
	return CLASSES.keys()


static func definition(id: String) -> Dictionary:
	var key := id if CLASSES.has(id) else "blood_sorceress"
	return CLASSES[key]


static func abilities(id: String) -> Array:
	return definition(id).get("abilities", [])


static func ability(id: String, index: int) -> Dictionary:
	var list := abilities(id)
	if index < 0 or index >= list.size():
		return {}
	return list[index]


static func display_name(id: String) -> String:
	return String(definition(id).get("name", "BLOOD SORCERESS"))


static func color(id: String) -> Color:
	return definition(id).get("color", Color(0.95, 0.3, 0.32))

