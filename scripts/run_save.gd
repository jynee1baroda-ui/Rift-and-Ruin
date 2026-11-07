class_name RunSave
extends RefCounted

const PATH := "user://run_save.cfg"
const SECTION := "run"


static func has_save() -> bool:
	return FileAccess.file_exists(PATH)


static func write(data: Dictionary) -> void:
	var cfg := ConfigFile.new()
	for key in data.keys():
		cfg.set_value(SECTION, key, data[key])
	cfg.save(PATH)


static func read() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return {}
	var data := {}
	if not cfg.has_section(SECTION):
		return data
	for key in cfg.get_section_keys(SECTION):
		data[key] = cfg.get_value(SECTION, key)
	return data


static func clear() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
