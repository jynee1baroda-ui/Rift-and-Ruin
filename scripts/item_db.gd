class_name ItemDB
extends RefCounted

const SLOT_NAME := "Relic"

const RARITIES := [
	{"key": "common", "name": "Common", "color": Color(0.80, 0.78, 0.74), "mods": 1, "weight": 44.0},
	{"key": "magic", "name": "Magic", "color": Color(0.34, 0.62, 1.0), "mods": 2, "weight": 32.0},
	{"key": "rare", "name": "Rare", "color": Color(1.0, 0.83, 0.28), "mods": 3, "weight": 22.0},
	{"key": "legendary", "name": "Legendary", "color": Color(1.0, 0.42, 0.10), "mods": 2, "weight": 11.0},
]

const FAMILIES := {
	"blood": {"name": "Blood", "color": Color(0.95, 0.22, 0.24), "rite": "+18% spell damage, +8 max life"},
	"ember": {"name": "Ember", "color": Color(1.0, 0.56, 0.14), "rite": "+8% crit chance, +30% crit damage"},
	"rift": {"name": "Rift", "color": Color(0.64, 0.5, 1.0), "rite": "+10% move speed, +1.2 life/s, Riftstep -0.5s"},
}

const TRIAD_TEXT := "one relic of each family: +6% spell damage, +5% max life, -10% spell cost"

const MOD_FAMILY := {
	"power": "blood", "vitality": "blood", "regen": "blood",
	"crit": "ember", "crit_damage": "ember", "life_cost": "ember",
	"move_speed": "rift",
}

const UNIQUE_FAMILY := {
	"nova_free": "blood", "lance_triple": "rift", "siphon_greater": "blood", "dash_burn": "ember",
}

const MODS := {
	"power": {"label": "Spell Damage", "suffix": "%", "min": 6.0, "max": 17.0, "decimals": 0},
	"vitality": {"label": "Max Life", "suffix": "", "min": 12.0, "max": 34.0, "decimals": 0},
	"crit": {"label": "Crit Chance", "suffix": "%", "min": 2.0, "max": 7.0, "decimals": 0},
	"crit_damage": {"label": "Crit Damage", "suffix": "%", "min": 8.0, "max": 28.0, "decimals": 0},
	"move_speed": {"label": "Move Speed", "suffix": "%", "min": 2.0, "max": 6.0, "decimals": 0},
	"regen": {"label": "Life Regen", "suffix": "/s", "min": 0.3, "max": 1.3, "decimals": 1},
	"life_cost": {"label": "Spell Cost", "suffix": "%", "min": -9.0, "max": -3.0, "decimals": 0},
}

const UNIQUES := [
	{"key": "nova_free", "name": "Bloodmoon Crown", "text": "Blood Nova costs no life and strikes 55% wider."},
	{"key": "lance_triple", "name": "Riftfang Diadem", "text": "Crimson Lance pierces and fires three lances."},
	{"key": "siphon_greater", "name": "Sanguine Chalice", "text": "Sanguine Siphon drains and heals twice as much."},
	{"key": "dash_burn", "name": "Emberwake Sigil", "text": "Riftstep ends in a burning detonation."},
]

const PREFIXES := ["Ashen", "Cracked", "Ember", "Basalt", "Cinder", "Rift", "Scorched", "Molten", "Grave"]
const NOUNS := ["Signet", "Sigil", "Charm", "Relic", "Talisman", "Band", "Idol", "Ward"]


static func make_item(layer: int, rng: RandomNumberGenerator, force_rarity := "") -> Dictionary:
	var rarity: Dictionary = _roll_rarity(layer, rng)
	if force_rarity != "":
		for candidate in RARITIES:
			if candidate.key == force_rarity:
				rarity = candidate
				break
	var item := {
		"rarity": rarity.key,
		"rarity_name": rarity.name,
		"color": rarity.color,
		"mods": {},
		"unique": "",
		"unique_text": "",
		"ilvl": layer,
		"name": "",
		"family": "blood",
	}
	if rarity.key == "legendary":
		var unique: Dictionary = UNIQUES[rng.randi() % UNIQUES.size()]
		item.name = unique.name
		item.unique = unique.key
		item.unique_text = unique.text
	else:
		item.name = "%s %s" % [PREFIXES[rng.randi() % PREFIXES.size()], NOUNS[rng.randi() % NOUNS.size()]]
	var mod_count: int = rarity.mods
	var keys: Array = MODS.keys()
	for i in mod_count:
		if keys.is_empty():
			break
		var pick: int = rng.randi() % keys.size()
		var key: String = keys[pick]
		keys.remove_at(pick)
		var def: Dictionary = MODS[key]
		var value := lerpf(float(def.min), float(def.max), rng.randf())
		value *= 1.0 + 0.06 * float(layer - 1)
		if int(def.decimals) == 0:
			value = roundf(value)
		else:
			value = snappedf(value, 0.1)
		item.mods[key] = value
	var family := String(UNIQUE_FAMILY.get(item.unique, ""))
	if family == "":
		for key in item.mods.keys():
			family = String(MOD_FAMILY.get(String(key), "blood"))
			break
	item["family"] = family
	return item


static func _roll_rarity(layer: int, rng: RandomNumberGenerator) -> Dictionary:
	var weights: Array[float] = []
	var total := 0.0
	for i in RARITIES.size():
		var def: Dictionary = RARITIES[i]
		var weight: float = def.weight
		if def.key != "common":
			weight += float(layer - 1) * 5.0
		else:
			weight = maxf(5.0, weight - float(layer - 1) * 8.0)
		weights.append(weight)
		total += weight
	var roll := rng.randf() * total
	for i in RARITIES.size():
		roll -= weights[i]
		if roll <= 0.0:
			return RARITIES[i]
	return RARITIES[0]


static func mod_text(key: String, value: float) -> String:
	if not MODS.has(key):
		return ""
	var def: Dictionary = MODS[key]
	var suffix := String(def.suffix)
	var body := ""
	if int(def.decimals) == 0:
		body = "%d" % int(round(value))
	else:
		body = "%.1f" % value
	if value > 0.0 and key != "life_cost":
		body = "+" + body
	return "%s%s %s" % [body, suffix, String(def.label)]


static func mod_lines(item: Dictionary) -> Array:
	var lines: Array = []
	if item.is_empty():
		return lines
	var mods: Dictionary = item.get("mods", {})
	for key in mods.keys():
		lines.append({"text": mod_text(String(key), float(mods[key])), "key": key, "value": float(mods[key])})
	return lines


static func total(item: Dictionary, key: String) -> float:
	if item.is_empty():
		return 0.0
	var mods: Dictionary = item.get("mods", {})
	return float(mods.get(key, 0.0))
