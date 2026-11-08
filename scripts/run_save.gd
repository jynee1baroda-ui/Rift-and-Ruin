class_name RunSave
extends RefCounted

const LEGACY_PATH := "user://run_save.cfg"
const SECTION := "run"

## Empty slot keeps the legacy single file (existing saves still open). The
## roster sets a slot id so every character owns its own run file.
static var slot := ""


static func set_slot(id: String) -> void:
	slot = id


static func path() -> String:
	return LEGACY_PATH if slot.is_empty() else Roster.save_path(slot)


static func has_save() -> bool:
	return FileAccess.file_exists(path())


static func write(data: Dictionary) -> void:
	var cfg := ConfigFile.new()
	for key in data.keys():
		cfg.set_value(SECTION, key, data[key])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(Roster.SAVE_DIR))
	cfg.save(path())


static func read() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(path()) != OK:
		return {}
	var data := {}
	if not cfg.has_section(SECTION):
		return data
	for key in cfg.get_section_keys(SECTION):
		data[key] = cfg.get_value(SECTION, key)
	return data


static func clear() -> void:
	if FileAccess.file_exists(path()):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path()))
