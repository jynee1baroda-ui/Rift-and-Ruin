class_name GameSettings
extends RefCounted

const PATH := "user://settings.cfg"

const DEFAULTS := {
	"master": 0.9,
	"music": 0.7,
	"ambience": 0.7,
	"sfx": 0.9,
	"fullscreen": false,
	"vsync": true,
	"brightness": 1.0,
	"fps_cap": 0,
	"camera_zoom": 1.0,
	"cam_follow": 3.2,
	"cam_pan": 1.0,
	"edge_pan": false,
	"zoom_step": 1.0,
	"shake": true,
	"damage_numbers": true,
	"enemy_health": true,
	"hold_move": true,
	"hud_scale": 1.0,
	"minimap": true,
	"toasts": true,
	"modifiers": true,
	"persist": true,
}

static var values: Dictionary = DEFAULTS.duplicate()


static func get_value(key: String):
	return values.get(key, DEFAULTS.get(key))


static func set_value(key: String, value) -> void:
	values[key] = value


static func load_all() -> void:
	values = DEFAULTS.duplicate()
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	for key in DEFAULTS.keys():
		values[key] = cfg.get_value("settings", key, DEFAULTS[key])


static func save_all() -> void:
	var cfg := ConfigFile.new()
	for key in values.keys():
		cfg.set_value("settings", key, values[key])
	cfg.save(PATH)


static func reset_all() -> void:
	values = DEFAULTS.duplicate()
	save_all()


static func snapshot() -> Dictionary:
	return values.duplicate()


static func apply_snapshot(data: Dictionary) -> void:
	for key in DEFAULTS.keys():
		if data.has(key):
			values[key] = data[key]


static func persist_now() -> void:
	if bool(values.get("persist", true)):
		save_all()
