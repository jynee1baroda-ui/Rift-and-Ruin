class_name Roster
extends RefCounted

## The character list. One entry per hero, one run file per hero, so creating a
## new character never destroys another one's progress.

const PATH := "user://roster.cfg"
const SAVE_DIR := "user://saves"
const SECTION := "characters"


static func _load() -> ConfigFile:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	return cfg


static func _save(cfg: ConfigFile) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	cfg.save(PATH)


static func all() -> Array:
	var cfg := _load()
	var result: Array = []
	if not cfg.has_section(SECTION):
		return result
	for id in cfg.get_section_keys(SECTION):
		var entry: Variant = cfg.get_value(SECTION, id, {})
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var row: Dictionary = (entry as Dictionary).duplicate(true)
		row["id"] = id
		result.append(row)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("updated", 0.0)) > float(b.get("updated", 0.0))
	)
	return result


static func entry(id: String) -> Dictionary:
	var cfg := _load()
	if not cfg.has_section(SECTION) or not cfg.has_section_key(SECTION, id):
		return {}
	var row: Variant = cfg.get_value(SECTION, id, {})
	if typeof(row) != TYPE_DICTIONARY:
		return {}
	var result: Dictionary = (row as Dictionary).duplicate(true)
	result["id"] = id
	return result


static func create(hero_name: String, class_id: String) -> Dictionary:
	var cfg := _load()
	var id := "%d_%04d" % [Time.get_unix_time_from_system(), randi() % 10000]
	var row := {
		"name": hero_name,
		"class_id": class_id,
		"level": 1,
		"layer": 1,
		"best": 1,
		"coins": 0,
		"updated": Time.get_unix_time_from_system(),
	}
	cfg.set_value(SECTION, id, row)
	_save(cfg)
	var result := row.duplicate()
	result["id"] = id
	return result


static func update(id: String, fields: Dictionary) -> void:
	if id.is_empty():
		return
	var cfg := _load()
	var row: Variant = cfg.get_value(SECTION, id, {})
	var data: Dictionary = row if typeof(row) == TYPE_DICTIONARY else {}
	for key in fields.keys():
		data[key] = fields[key]
	data["updated"] = Time.get_unix_time_from_system()
	cfg.set_value(SECTION, id, data)
	_save(cfg)


static func remove(id: String) -> void:
	var cfg := _load()
	if cfg.has_section_key(SECTION, id):
		cfg.erase_section_key(SECTION, id)
		_save(cfg)
	var path := save_path(id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


static func last_played() -> Dictionary:
	var list := all()
	return list[0] if not list.is_empty() else {}


static func save_path(id: String) -> String:
	return SAVE_DIR.path_join("%s.cfg" % id)
