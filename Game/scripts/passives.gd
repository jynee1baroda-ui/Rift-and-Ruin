class_name Passives
extends RefCounted

## Five branches, eight rows each, with a fork halfway and a keystone at the
## bottom. One point per character level, so a deep run can afford roughly half
## the tree: the forks and keystones are where a build actually gets decided.
## `req` needs every listed node, `req_any` needs one of them. Effects are
## summed here and applied in Player._recalculate, so a level-up can never wipe
## them.

const TREE := [
	# Might - raw ability damage and critical strikes
	{"id": "m1", "branch": "might", "row": 0, "name": "IRON BLOOD", "desc": "+6% ability damage", "req": [],
		"effect": {"power_pct": 6.0}},
	{"id": "m2", "branch": "might", "row": 1, "name": "HONED EDGE", "desc": "+7% ability damage", "req": ["m1"],
		"effect": {"power_pct": 7.0}},
	{"id": "m3", "branch": "might", "row": 2, "name": "OPEN WOUNDS", "desc": "+8% critical chance", "req": ["m2"],
		"effect": {"crit": 8.0}},
	{"id": "m4", "branch": "might", "row": 2, "name": "HEAVY HAND", "desc": "+18% critical damage", "req": ["m2"],
		"effect": {"crit_damage": 18.0}},
	{"id": "m5", "branch": "might", "row": 3, "name": "DEEP CUT", "desc": "+24% critical damage, +4% critical chance", "req": ["m3"],
		"effect": {"crit_damage": 24.0, "crit": 4.0}},
	{"id": "m6", "branch": "might", "row": 3, "name": "BLEEDING STRIKE", "desc": "+10% critical chance, -4% ability cost", "req": ["m4"],
		"effect": {"crit": 10.0, "cost_pct": -4.0}},
	{"id": "m7", "branch": "might", "row": 4, "name": "RIFT HUNGER", "desc": "+15% ability damage", "req": [], "req_any": ["m5", "m6"],
		"effect": {"power_pct": 15.0}},
	{"id": "m8", "branch": "might", "row": 5, "name": "FINAL VERSE", "desc": "KEYSTONE: +30% ability damage, -12% maximum life", "req": ["m7"],
		"effect": {"power_pct": 30.0, "health_pct": -12.0}},
	# Vitae - staying alive through raw flesh
	{"id": "v1", "branch": "vitae", "row": 0, "name": "THICK BLOOD", "desc": "+30 maximum life", "req": [],
		"effect": {"health_flat": 30.0}},
	{"id": "v2", "branch": "vitae", "row": 1, "name": "SLOW PULSE", "desc": "+1.4 regeneration", "req": ["v1"],
		"effect": {"regen": 1.4}},
	{"id": "v3", "branch": "vitae", "row": 2, "name": "IRON SKIN", "desc": "+10% maximum life", "req": ["v2"],
		"effect": {"health_pct": 10.0}},
	{"id": "v4", "branch": "vitae", "row": 2, "name": "SECOND WIND", "desc": "+1.6 regeneration", "req": ["v2"],
		"effect": {"regen": 1.6}},
	{"id": "v5", "branch": "vitae", "row": 3, "name": "DEEP ROOTS", "desc": "+70 maximum life", "req": ["v3"],
		"effect": {"health_flat": 70.0}},
	{"id": "v6", "branch": "vitae", "row": 3, "name": "QUICK CLOT", "desc": "+10% maximum life, -6% ability cost", "req": ["v4"],
		"effect": {"health_pct": 10.0, "cost_pct": -6.0}},
	{"id": "v7", "branch": "vitae", "row": 4, "name": "MARROW", "desc": "+14% maximum life", "req": [], "req_any": ["v5", "v6"],
		"effect": {"health_pct": 14.0}},
	{"id": "v8", "branch": "vitae", "row": 5, "name": "LAST BREATH", "desc": "KEYSTONE: heal 12% of life on every kill, +1.5 regeneration", "req": ["v7"],
		"effect": {"heal_on_kill": 12.0, "regen": 1.5}},
	# Grace - speed, tempo and resource
	{"id": "g1", "branch": "grace", "row": 0, "name": "LIGHT STEP", "desc": "+5% movement speed", "req": [],
		"effect": {"speed_pct": 5.0}},
	{"id": "g2", "branch": "grace", "row": 1, "name": "QUICK HANDS", "desc": "-6% cooldowns", "req": ["g1"],
		"effect": {"cooldown_pct": -6.0}},
	{"id": "g3", "branch": "grace", "row": 2, "name": "RIFT SENSE", "desc": "+7% movement speed", "req": ["g2"],
		"effect": {"speed_pct": 7.0}},
	{"id": "g4", "branch": "grace", "row": 2, "name": "FAST BLOOD", "desc": "-7% cooldowns", "req": ["g2"],
		"effect": {"cooldown_pct": -7.0}},
	{"id": "g5", "branch": "grace", "row": 3, "name": "WIDE LUNGS", "desc": "+28 focus", "req": ["g3"],
		"effect": {"focus_flat": 28.0}},
	{"id": "g6", "branch": "grace", "row": 3, "name": "SLIPSTREAM", "desc": "+8% movement speed, +8 focus", "req": ["g4"],
		"effect": {"speed_pct": 8.0, "focus_flat": 8.0}},
	{"id": "g7", "branch": "grace", "row": 4, "name": "MOMENTUM", "desc": "-10% ability cost", "req": [], "req_any": ["g5", "g6"],
		"effect": {"cost_pct": -10.0}},
	{"id": "g8", "branch": "grace", "row": 5, "name": "TEMPO", "desc": "KEYSTONE: -16% cooldowns, -6% ability damage", "req": ["g7"],
		"effect": {"cooldown_pct": -16.0, "power_pct": -6.0}},
	# Sanguine - power bought with life
	{"id": "s1", "branch": "sanguine", "row": 0, "name": "BLOOD TITHE", "desc": "+5% ability damage", "req": [],
		"effect": {"power_pct": 5.0}},
	{"id": "s2", "branch": "sanguine", "row": 1, "name": "VEIN CUT", "desc": "-6% ability cost", "req": ["s1"],
		"effect": {"cost_pct": -6.0}},
	{"id": "s3", "branch": "sanguine", "row": 2, "name": "CRIMSON EDGE", "desc": "+9% critical chance", "req": ["s2"],
		"effect": {"crit": 9.0}},
	{"id": "s4", "branch": "sanguine", "row": 2, "name": "RED THIRST", "desc": "Heal 6% of life on every kill", "req": ["s2"],
		"effect": {"heal_on_kill": 6.0}},
	{"id": "s5", "branch": "sanguine", "row": 3, "name": "OPEN VEIN", "desc": "+13% ability damage", "req": ["s3"],
		"effect": {"power_pct": 13.0}},
	{"id": "s6", "branch": "sanguine", "row": 3, "name": "SCARLET FOCUS", "desc": "+22 focus, +1.0 regeneration", "req": ["s4"],
		"effect": {"focus_flat": 22.0, "regen": 1.0}},
	{"id": "s7", "branch": "sanguine", "row": 4, "name": "HEMORRHAGE", "desc": "+20% critical damage", "req": [], "req_any": ["s5", "s6"],
		"effect": {"crit_damage": 20.0}},
	{"id": "s8", "branch": "sanguine", "row": 5, "name": "EXSANGUINATE", "desc": "KEYSTONE: +32% ability damage, -18% maximum life", "req": ["s7"],
		"effect": {"power_pct": 32.0, "health_pct": -18.0}},
	# Echo - repeating and cycling abilities
	{"id": "e1", "branch": "echo", "row": 0, "name": "RESONANCE", "desc": "-4% cooldowns", "req": [],
		"effect": {"cooldown_pct": -4.0}},
	{"id": "e2", "branch": "echo", "row": 1, "name": "RIPPLE", "desc": "+10 focus", "req": ["e1"],
		"effect": {"focus_flat": 10.0}},
	{"id": "e3", "branch": "echo", "row": 2, "name": "AFTERIMAGE", "desc": "+5% movement speed", "req": ["e2"],
		"effect": {"speed_pct": 5.0}},
	{"id": "e4", "branch": "echo", "row": 2, "name": "PULSE", "desc": "+8% ability damage", "req": ["e2"],
		"effect": {"power_pct": 8.0}},
	{"id": "e5", "branch": "echo", "row": 3, "name": "REFRAIN", "desc": "-8% cooldowns", "req": ["e3"],
		"effect": {"cooldown_pct": -8.0}},
	{"id": "e6", "branch": "echo", "row": 3, "name": "CHORUS", "desc": "+8% critical chance", "req": ["e4"],
		"effect": {"crit": 8.0}},
	{"id": "e7", "branch": "echo", "row": 4, "name": "OVERTONE", "desc": "-9% ability cost", "req": [], "req_any": ["e5", "e6"],
		"effect": {"cost_pct": -9.0}},
	{"id": "e8", "branch": "echo", "row": 5, "name": "SHATTERPOINT", "desc": "KEYSTONE: +24% critical damage, +8% critical chance", "req": ["e7"],
		"effect": {"crit_damage": 24.0, "crit": 8.0}},
]

const BRANCH_NAMES := {"might": "MIGHT", "vitae": "VITAE", "grace": "GRACE", "sanguine": "SANGUINE", "echo": "ECHO"}
const BRANCH_ORDER := ["might", "vitae", "grace", "sanguine", "echo"]
const BRANCH_COLORS := {
	"might": Color(1.0, 0.42, 0.28),
	"vitae": Color(0.95, 0.3, 0.42),
	"grace": Color(0.5, 0.9, 0.8),
	"sanguine": Color(0.78, 0.24, 0.5),
	"echo": Color(0.72, 0.62, 1.0),
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
	var any_of: Array = entry.get("req_any", [])
	if not any_of.is_empty():
		var satisfied := false
		for req in any_of:
			if owned.has(String(req)):
				satisfied = true
				break
		if not satisfied:
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
