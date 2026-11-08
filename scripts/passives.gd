class_name Passives
extends RefCounted

## Three short branches, one point per character level. Every node is one point.
## Effects are summed here and applied in Player._recalculate, so a level-up can
## never wipe them.

const TREE := [
	# Might
	{"id": "m1", "branch": "might", "row": 0, "name": "IRON BLOOD", "desc": "+6% ability damage", "req": [],
		"effect": {"power_pct": 6.0}},
	{"id": "m2", "branch": "might", "row": 1, "name": "HONED EDGE", "desc": "+6% ability damage", "req": ["m1"],
		"effect": {"power_pct": 6.0}},
	{"id": "m3", "branch": "might", "row": 2, "name": "OPEN WOUNDS", "desc": "+8% critical chance", "req": ["m1"],
		"effect": {"crit": 8.0}},
	{"id": "m4", "branch": "might", "row": 3, "name": "DEEP CUT", "desc": "+20% critical damage", "req": ["m3"],
		"effect": {"crit_damage": 20.0}},
	{"id": "m5", "branch": "might", "row": 4, "name": "RIFT HUNGER", "desc": "+12% ability damage", "req": ["m2", "m4"],
		"effect": {"power_pct": 12.0}},
	{"id": "m6", "branch": "might", "row": 5, "name": "FINAL VERSE", "desc": "+10% ability damage", "req": ["m5"],
		"effect": {"power_pct": 10.0}},
	# Vitae
	{"id": "v1", "branch": "vitae", "row": 0, "name": "THICK BLOOD", "desc": "+30 maximum life", "req": [],
		"effect": {"health_flat": 30.0}},
	{"id": "v2", "branch": "vitae", "row": 1, "name": "SLOW PULSE", "desc": "+1.2 regeneration", "req": ["v1"],
		"effect": {"regen": 1.2}},
	{"id": "v3", "branch": "vitae", "row": 2, "name": "IRON SKIN", "desc": "+10% maximum life", "req": ["v1"],
		"effect": {"health_pct": 10.0}},
	{"id": "v4", "branch": "vitae", "row": 3, "name": "SECOND WIND", "desc": "+1.0 regeneration", "req": ["v3"],
		"effect": {"regen": 1.0}},
	{"id": "v5", "branch": "vitae", "row": 4, "name": "DEEP ROOTS", "desc": "+60 maximum life", "req": ["v2", "v4"],
		"effect": {"health_flat": 60.0}},
	{"id": "v6", "branch": "vitae", "row": 5, "name": "LAST BREATH", "desc": "Heal 12% of life on every kill", "req": ["v5"],
		"effect": {"heal_on_kill": 12.0}},
	# Grace
	{"id": "g1", "branch": "grace", "row": 0, "name": "LIGHT STEP", "desc": "+5% movement speed", "req": [],
		"effect": {"speed_pct": 5.0}},
	{"id": "g2", "branch": "grace", "row": 1, "name": "QUICK HANDS", "desc": "-6% cooldowns", "req": ["g1"],
		"effect": {"cooldown_pct": -6.0}},
	{"id": "g3", "branch": "grace", "row": 2, "name": "RIFT SENSE", "desc": "+6% movement speed", "req": ["g1"],
		"effect": {"speed_pct": 6.0}},
	{"id": "g4", "branch": "grace", "row": 3, "name": "FAST BLOOD", "desc": "-6% cooldowns", "req": ["g3"],
		"effect": {"cooldown_pct": -6.0}},
	{"id": "g5", "branch": "grace", "row": 4, "name": "WIDE LUNGS", "desc": "+25 resolve or focus", "req": ["g2", "g4"],
		"effect": {"focus_flat": 25.0}},
	{"id": "g6", "branch": "grace", "row": 5, "name": "MOMENTUM", "desc": "-10% ability cost", "req": ["g5"],
		"effect": {"cost_pct": -10.0}},
]

const BRANCH_NAMES := {"might": "MIGHT", "vitae": "VITAE", "grace": "GRACE"}
const BRANCH_COLORS := {
	"might": Color(1.0, 0.42, 0.28),
	"vitae": Color(0.95, 0.3, 0.42),
	"grace": Color(0.5, 0.9, 0.8),
}


static func node(id: String) -> Dictionary:
	for entry in TREE:
		if String(entry.get("id", "")) == id:
			return entry
	return {}


static func nodes_in(branch: String) -> Array:
	var result: Array = []
	for entry in TREE:
		if String(entry.get("branch", "")) == branch:
			result.append(entry)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("row", 0)) < int(b.get("row", 0))
	)
	return result


static func available(owned: Array, id: String) -> bool:
	if owned.has(id):
		return false
	var entry := node(id)
	if entry.is_empty():
		return false
	for req in entry.get("req", []):
		if not owned.has(String(req)):
			return false
	return true


static func totals(owned: Array) -> Dictionary:
	var sum := {"power_pct": 0.0, "crit": 0.0, "crit_damage": 0.0, "health_flat": 0.0,
		"health_pct": 0.0, "regen": 0.0, "speed_pct": 0.0, "cooldown_pct": 0.0,
		"focus_flat": 0.0, "cost_pct": 0.0, "heal_on_kill": 0.0}
	for id in owned:
		var entry := node(String(id))
		if entry.is_empty():
			continue
		var effect: Dictionary = entry.get("effect", {})
		for key in effect.keys():
			sum[key] = float(sum.get(key, 0.0)) + float(effect[key])
	return sum
