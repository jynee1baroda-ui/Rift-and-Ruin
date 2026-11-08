class_name GameHUD
extends CanvasLayer

signal equip_requested(item: Dictionary, slot: int)
signal unequip_requested(slot: int)
signal discard_requested
signal start_pressed
signal continue_pressed
signal ui_click
signal ability_pressed(index: int)
signal restart_pressed
signal settings_changed
signal boon_chosen(key: String)
signal shop_buy(index: int)
signal shop_close
signal rift_map_requested
signal duel_pressed
signal duel_again_pressed
signal home_pressed
signal net_action(action: String, mode: String)
signal rift_enter_requested(layer: int)
signal leave_run_pressed
signal character_created(hero_name: String, klass: String)
signal story_closed
signal passives_requested
signal passive_buy(id: String)
signal roster_requested
signal roster_load(id: String)
signal roster_delete(id: String)
signal roster_create

const INK := Color(0.035, 0.025, 0.045, 0.92)
const AMBER := Color(1.0, 0.72, 0.28)
const CRIMSON := Color(0.92, 0.16, 0.14)
const BONE := Color(0.90, 0.86, 0.79)
const MUTED := Color(0.62, 0.56, 0.56)
const GOLD := Color(1.0, 0.83, 0.35)
const DISPLAY_FONT := "res://fonts/cinzel.ttf"
const ICON_NOVA := "res://art/generated/icon_nova/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037296460-0_1794037296461_2fben6it.png"
const ICON_LANCE := "res://art/generated/icon_lance/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037334226-0_1794037334226_0jajynkv.png"
const ICON_SIPHON := "res://art/generated/icon_siphon/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037347430-0_1794037347430_d38c0j6p.png"
const ICON_RIFTSTEP_DIR := "res://art/generated/icon_riftstep"

var root: Control
var body: Control
var minimap: RiftMap
var vitae_bar: VitaeBar
var health_label: Label
var regen_label: Label
var coin_label: Label
var level_label: Label
var xp_bar: ProgressBar
var health_target := 100.0
var health_shown := 100.0
var ghost_shown := 100.0
var damage_flash := 0.0
var layer_label: Label
var theme_label: Label
var mod_row: HBoxContainer
var current_mods: Array = []
var wave_label: Label
var wave_bar: ProgressBar
var slots: Array = []
var bloodrush_label: Label
var bloodrush_bar: ProgressBar
var relic_stats: Label
var toast_box: VBoxContainer
var relic_window: PanelContainer
var relic_tabs: HBoxContainer
var relic_body: VBoxContainer
var boss_panel: PanelContainer
var boss_name: Label
var boss_bar: ProgressBar
var pause_summary: Label
var controls_hint: Label
var run_layer := 1
var run_level := 1
var run_coins := 0
var run_kills := 0
var relic_rows: Array = []
var relics: Array = []
var relic_tab := "relics"
var relic_opened_ms := 0
var minimap_panel: Panel
var settings_window: PanelContainer
var settings_tabs: HBoxContainer
var settings_body: VBoxContainer
var settings_tab := "audio"
var settings_open := false
var settings_was_paused := false
var settings_from_pause := false
var boon_panel: PanelContainer
var boon_shade: ColorRect
var boon_cards: HBoxContainer
var boons_open := false
var boon_keys: Array = []
var boon_picks := 1
var prompt_label: Label
var shop_window: PanelContainer
var shop_body: VBoxContainer
var shop_coins: Label
var shop_title: Label
var shop_open := false
var vignette: TextureRect
var death_panel: PanelContainer
var death_stats: Label
var title_panel: Control
var title_label: Label
var record_label: Label
var record_layer := 1
var pause_panel: PanelContainer
var pause_shade: ColorRect
var fade_rect: ColorRect
var ability_flash_rect: ColorRect
var status_label: Label
var pending_item: Dictionary = {}
var vignette_alpha := 0.0
var low_health := 0.0
var display_font: FontFile
var title_font: FontVariation
var last_pause_ms := 0
var loading_panel: Control
var loading_bar: ProgressBar
var rift_map_panel: PanelContainer
var rift_map_body: VBoxContainer
var rift_map_footer: Label
var save_chip: PanelContainer
var save_chip_last_ms := 0
var title_shown_ms := 0
var title_mouse_moved := false
var title_continue_btn: Button
var title_begin_btn: Button
var title_lore_label: Label
var title_lore_title: Label
var hall_index := 0
var duel_panel: PanelContainer
var duel_title: Label
var duel_sub: Label
var duel_stats: Label
var settings_btn: Button
var duel_shown_ms := 0
var whisper_label: Label
var online_chip: PanelContainer
var online_label: Label
var boon_sub: Label
var shop_lore: Label
var net_panel: PanelContainer
var net_title: Label
var net_status: Label
var net_party_box: VBoxContainer
var net_detail: Label
var net_mode := "coop"
var rift_detail: Label
var rift_enter_btn: Button
var selected_rift := 0
var rift_unlock := 1
var rift_entries: Array = []
var rift_index := 0
var leave_btn: Button
var leave_armed_ms := 0
var creator_panel: Control
var creator_name: LineEdit
var creator_lore: Label
var creator_preview: Node3D
var creator_stage: Node3D
var creator_class := "blood_sorceress"
var creator_locked := false
var creator_create_btn: Button
var creator_portrait: TextureRect
var creator_scene_holder: Control
var creator_hint: Label
var creator_glyph: Label
var ability_row: HBoxContainer
var dash_action_label: Label
var active_class: Dictionary = {}
var focus_row: VBoxContainer
var focus_bar: ProgressBar
var focus_label: Label
var focus_fill: StyleBoxFlat
var focus_shown := -1.0
var focus_color_now := Color(1, 1, 1)
var codex_panel: PanelContainer
var codex_title: Label
var codex_body: Label
var codex_page_label: Label
var codex_page := 0
var passive_panel: PanelContainer
var passive_points_label: Label
var passive_owned: Array = []
var passive_points := 0
var passive_buttons: Array = []
var roster_panel: PanelContainer
var roster_list: VBoxContainer
var roster_delete_armed := ""
var roster_delete_ms := 0
var hero_name_label: Label
var hero_class_label: Label
var story_panel: PanelContainer
var story_title: Label
var story_body: Label
var story_body_box: VBoxContainer
var story_scroll: ScrollContainer

const LORE_BOOK := [
	{"title": "THE DROWNING",
		"body": "Nine hundred years ago the sea did not boil away. It went down into a seam in the crust, all of it, at once, with a sound the survivors described as a held breath finally let go. Nothing was left but salt flats, steam, and a wind that smelled of iron.\n\nThirty years later the first lava well opened under what is now the Ashen Bastion. The water had not vanished. It had gone somewhere with a floor, and the floor was hot."},
	{"title": "THE WOUND",
		"body": "The lava is not weather and it is not punishment. It is the world's blood, and the rift is the cut that lets it out.\n\nIt moves like a tide. Every eruption raises the level of every pit a little; every quiet year lowers it. The seam breathes, and when it breathes in, the rivers draw back and show you what has been lying under them. When it breathes out, the islands you are standing on become islands again.\n\nNobody has ever mapped the bottom. Everyone who tried came back with the same sentence: it is deeper than the sea was."},
	{"title": "THE FIRST SEAL",
		"body": "The first sorceresses did not build a lock. They made one out of themselves.\n\nThey cut the rift wide on purpose, to let the pressure out before the whole crust split, and then they stood in the wound and spent their blood closing it to a single narrow throat. Eight went down. One came back up, and she never spoke again.\n\nThe seal is not a wall. It is a promise, kept by whoever carries the blood that made it."},
	{"title": "THE ASHEN BASTION",
		"body": "Raised by deserters who refused to kneel to the rift's first warden. Its braziers have not gone out in a hundred years, fed on cinder that never cools.\n\nThe Bastion is built on the seal itself. That is the arrangement: the order keeps the wound shut, and the wound keeps the order honest. The wells are turning to steam now. Children are born with ember in their lungs. The bargain is coming due."},
	{"title": "THE BLOODED LINE",
		"body": "A seal needs a keeper, and a keeper needs the right blood. There has only ever been one family with it, and it has been getting smaller for nine centuries.\n\nVesna is the last of it. She can feel the seal in her teeth when she sleeps, the way other people feel a tooth before a storm. When the rift shifts, her pulse shifts with it.\n\nThis is not a gift. It is a debt with interest."},
	{"title": "THE FIRST WARDEN",
		"body": "Forty years ago the First Warden took a lantern, a blade, and the only map of the throat, and went down to check the seal by hand. He promised to be back before the braziers dimmed.\n\nHe is still down there. The Warden who speaks to you now is not him; it is the office, passed to whoever survives the descent long enough to hold it.\n\nSometimes, on the lower layers, you can hear the first one counting."},
	{"title": "THE ASHEN BROKER",
		"body": "He sells relics he should not have, and he takes payment in coin because the rift will not accept it.\n\nEvery item on his stall was pulled out of the wound or off somebody the wound kept. He does not set the prices; the depth does. He never tells the same story about where a relic came from, but every story is true.\n\nHe is not on your side. He is on the side of the transaction."},
	{"title": "THE HUSHED PROPHET",
		"body": "A saint who traded his voice for prophecy, and got exactly what he paid for.\n\nHe speaks now only in volleys of stolen souls, and each one is a sentence of the future that has already happened. He is not guarding the rift. He is waiting at the point where it stops being a place and starts being a mouth."},
	{"title": "THE BROOD MOTHER",
		"body": "The rift's answer to the Blood Sorceress. She births her army from the stone and calls it love, and the stone agrees with her.\n\nShe was a keeper once, of a different seal, on a different coast. When her seal failed she did not die. She made more of herself."},
	{"title": "THE LAST FURNACE",
		"body": "Where the rift was made. It is still running, and it has never been given an off switch.\n\nEverything the wound has swallowed is being rendered down there into something that comes back up as fire. The first sealers built the throat above it and called the work finished. It was not finished. It was only narrow."},
]


class RiftMap extends Control:
	var walkable_cells: Array = []
	var lava_cells: Array = []
	var bridge_cells: Array = []
	var enemy_cells: Array = []
	var elite_cells: Array = []
	var player_cell := Vector2i(-99, -99)
	var portal_cell := Vector2i(-99, -99)
	var portal_on := false
	var grid_size := 17

	func _draw() -> void:
		var span := float(maxi(grid_size, 1))
		var side := minf(size.x, size.y)
		if side <= 1.0:
			return
		var cell_px := side / span
		var origin := (size - Vector2(side, side)) * 0.5
		draw_rect(Rect2(origin, Vector2(side, side)), Color(0.06, 0.025, 0.03, 0.92))
		for c in lava_cells:
			var lr := Rect2(origin + Vector2(c) * cell_px, Vector2(cell_px, cell_px))
			lr = lr.grow(-cell_px * 0.16)
			draw_rect(lr, Color(0.78, 0.22, 0.05, 0.5))
		for c in walkable_cells:
			var wr := Rect2(origin + Vector2(c) * cell_px, Vector2(cell_px, cell_px))
			wr = wr.grow(-0.35)
			draw_rect(wr, Color(0.29, 0.25, 0.26, 0.95))
		for c in bridge_cells:
			var br := Rect2(origin + Vector2(c) * cell_px, Vector2(cell_px, cell_px))
			draw_rect(br.grow(-0.2), Color(0.62, 0.48, 0.32, 0.95))
		if portal_cell.x >= 0:
			var pc := origin + (Vector2(portal_cell) + Vector2(0.5, 0.5)) * cell_px
			var col := Color(0.88, 0.6, 1.0, 1.0) if portal_on else Color(0.5, 0.4, 0.62, 0.75)
			draw_circle(pc, cell_px * 0.62, Color(col.r, col.g, col.b, 0.18))
			draw_circle(pc, cell_px * 0.3, col)
		for c in enemy_cells:
			var ep := origin + (Vector2(c) + Vector2(0.5, 0.5)) * cell_px
			draw_circle(ep, maxf(1.5, cell_px * 0.22), Color(0.95, 0.22, 0.18, 0.95))
		for c in elite_cells:
			var ep := origin + (Vector2(c) + Vector2(0.5, 0.5)) * cell_px
			draw_circle(ep, maxf(2.4, cell_px * 0.33), Color(1.0, 0.65, 0.22, 1.0))
		if player_cell.x >= 0:
			var pp := origin + (Vector2(player_cell) + Vector2(0.5, 0.5)) * cell_px
			draw_circle(pp, maxf(3.2, cell_px * 0.46), Color(1.0, 0.8, 0.32, 0.2))
			draw_circle(pp, maxf(2.1, cell_px * 0.29), Color(1.0, 0.88, 0.45, 1.0))


class VitaeBar extends Control:
	var shown := 1.0
	var ghost := 1.0
	var flash := 0.0
	var grad: GradientTexture2D

	func _draw() -> void:
		var full := Rect2(Vector2.ZERO, size)
		draw_rect(full, Color(0.055, 0.016, 0.026, 0.94))
		var ghost_w := clampf(ghost, 0.0, 1.0) * size.x
		if ghost_w > 1.0:
			draw_rect(Rect2(0.0, 0.0, ghost_w, size.y), Color(0.95, 0.52, 0.26, 0.5))
		var fill_w := clampf(shown, 0.0, 1.0) * size.x
		if fill_w > 1.0:
			if grad != null:
				draw_texture_rect(grad, Rect2(0.0, 0.0, fill_w, size.y), false)
			else:
				draw_rect(Rect2(0.0, 0.0, fill_w, size.y), Color(0.82, 0.12, 0.1, 1.0))
			draw_rect(Rect2(0.0, 0.0, fill_w, size.y * 0.34), Color(1.0, 0.5, 0.38, 0.22))
		if flash > 0.01:
			draw_rect(full, Color(1.0, 0.55, 0.5, 0.35 * clampf(flash, 0.0, 1.0)))
		draw_rect(full, Color(0.52, 0.18, 0.13, 0.95), false, 1.0)


class RelicGem extends Control:
	var gem_color := Color(0.5, 0.5, 0.5)

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.5
		var pts := PackedVector2Array([
			center + Vector2(0.0, -radius),
			center + Vector2(radius, 0.0),
			center + Vector2(0.0, radius),
			center + Vector2(-radius, 0.0),
		])
		draw_colored_polygon(pts, gem_color)
		pts.append(pts[0])
		draw_polyline(pts, gem_color.lightened(0.45), 1.0)


class FrameCorners extends Control:
	var line_color := Color(0.85, 0.62, 0.26, 0.3)
	var inset := 16.0
	var arm := 30.0

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var paths := [
			PackedVector2Array([Vector2(inset, inset + arm), Vector2(inset, inset), Vector2(inset + arm, inset)]),
			PackedVector2Array([Vector2(w - inset - arm, inset), Vector2(w - inset, inset), Vector2(w - inset, inset + arm)]),
			PackedVector2Array([Vector2(inset, h - inset - arm), Vector2(inset, h - inset), Vector2(inset + arm, h - inset)]),
			PackedVector2Array([Vector2(w - inset - arm, h - inset), Vector2(w - inset, h - inset), Vector2(w - inset, h - inset - arm)]),
		]
		for path in paths:
			draw_polyline(path, line_color, 1.5, true)


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	_load_fonts()
	_build()


func _load_fonts() -> void:
	if not ResourceLoader.exists(DISPLAY_FONT):
		return
	var res := load(DISPLAY_FONT)
	if res is FontFile:
		display_font = res as FontFile
		title_font = FontVariation.new()
		title_font.base_font = display_font
		title_font.variation_embolden = 0.4


func _first_png(dir_path: String) -> String:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ""
	for file in dir.get_files():
		if String(file).get_extension().to_lower() == "png":
			return dir_path.path_join(file)
	return ""


func _stylebox(color: Color, border: Color, width := 1, radius := 3) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	sb.shadow_size = 5
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb


func _label(text: String, size: int, color: Color, outline := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title_font != null and size >= 16:
		l.add_theme_font_override("font", title_font)
	if outline:
		l.add_theme_constant_override("outline_size", 5)
		l.add_theme_color_override("font_outline_color", Color(0.01, 0.0, 0.01, 0.9))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _build() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_backdrop()
	_build_vignette()
	_build_ability_flash()
	body = Control.new()
	body.name = "RunHUD"
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.visible = false
	body.modulate.a = 0.0
	root.add_child(body)
	_build_minimap()
	_build_online_chip()
	_build_top()
	_build_boss()
	_build_health()
	_build_abilities()
	_build_relic()
	_build_toasts()
	_build_relic_window()
	_build_death()
	_build_duel_result()
	_build_title()
	_build_pause_button()
	_build_pause()
	_build_settings_button()
	_build_settings_window()
	_build_boon_panel()
	_build_prompt()
	_build_shop()
	_build_net_panel()
	_build_creator()
	_build_story_card()
	_build_codex()
	_build_passives()
	_build_roster()
	_build_fade()
	_build_save_chip()
	_build_rift_map()
	_build_loading()
	_apply_ui_settings()
	_kill_button_focus()


func _kill_button_focus() -> void:
	if root == null:
		return
	for node in root.find_children("*", "Button", true, false):
		var btn := node as Button
		if btn != null:
			btn.focus_mode = Control.FOCUS_NONE


func _build_save_chip() -> void:
	save_chip = PanelContainer.new()
	save_chip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	save_chip.offset_left = -196.0
	save_chip.offset_right = -24.0
	save_chip.offset_top = 64.0
	save_chip.offset_bottom = 94.0
	save_chip.add_theme_stylebox_override("panel", _stylebox(Color(0.04, 0.025, 0.03, 0.9), Color(0.45, 0.32, 0.14, 0.9), 1, 2))
	save_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	save_chip.modulate.a = 0.0
	root.add_child(save_chip)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	save_chip.add_child(row)
	var dot := ColorRect.new()
	dot.color = Color(0.85, 0.62, 0.24, 1.0)
	dot.custom_minimum_size = Vector2(7, 7)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	var text := _label("RIFT SAVED", 11, GOLD, false)
	row.add_child(text)


func show_saved() -> void:
	if save_chip == null:
		return
	var now := Time.get_ticks_msec()
	if now - save_chip_last_ms < 1400:
		return
	save_chip_last_ms = now
	save_chip.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(save_chip, "modulate:a", 1.0, 0.18)
	tween.tween_interval(1.1)
	tween.tween_property(save_chip, "modulate:a", 0.0, 0.5)


func _build_loading() -> void:
	loading_panel = Control.new()
	loading_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	loading_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	loading_panel.visible = false
	root.add_child(loading_panel)
	var bg := ColorRect.new()
	bg.color = Color(0.014, 0.007, 0.014, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_panel.add_child(bg)
	var glow := TextureRect.new()
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	grad.colors = PackedColorArray([Color(1.0, 0.45, 0.1, 0.16), Color(1.0, 0.3, 0.05, 0.0)])
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill = GradientTexture2D.FILL_RADIAL
	gtex.fill_from = Vector2(0.5, 0.5)
	gtex.fill_to = Vector2(1.0, 0.5)
	gtex.width = 512
	gtex.height = 512
	glow.texture = gtex
	glow.set_anchors_preset(Control.PRESET_CENTER)
	glow.offset_left = -320.0
	glow.offset_right = 320.0
	glow.offset_top = -320.0
	glow.offset_bottom = 320.0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_panel.add_child(glow)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_panel.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box)
	var mark := _label("RIFT & RUIN", 54, AMBER)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(mark)
	var sub := _label("THE BLOOD SORCERESS DESCENDS", 12, CRIMSON)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 16)
	box.add_child(gap)
	var bar_holder := CenterContainer.new()
	box.add_child(bar_holder)
	loading_bar = ProgressBar.new()
	loading_bar.custom_minimum_size = Vector2(360, 4)
	loading_bar.show_percentage = false
	loading_bar.max_value = 100.0
	loading_bar.value = 0.0
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.09, 0.04, 0.03, 0.9)
	bg_style.set_corner_radius_all(2)
	var fill_grad := Gradient.new()
	fill_grad.set_color(0, Color(0.75, 0.18, 0.06, 1.0))
	fill_grad.set_color(1, Color(1.0, 0.72, 0.28, 1.0))
	var fill_tex := GradientTexture2D.new()
	fill_tex.gradient = fill_grad
	fill_tex.fill_from = Vector2(0.0, 0.5)
	fill_tex.fill_to = Vector2(1.0, 0.5)
	fill_tex.width = 128
	fill_tex.height = 4
	var fill_style := StyleBoxTexture.new()
	fill_style.texture = fill_tex
	loading_bar.add_theme_stylebox_override("background", bg_style)
	loading_bar.add_theme_stylebox_override("fill", fill_style)
	bar_holder.add_child(loading_bar)
	var hint := _label("FORGING THE RIFT", 11, MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)


func show_loading() -> void:
	if loading_panel == null:
		return
	loading_panel.visible = true
	loading_panel.modulate.a = 1.0
	loading_bar.value = 6.0
	var tween := create_tween()
	tween.tween_property(loading_bar, "value", 90.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func hide_loading() -> void:
	if loading_panel == null or not loading_panel.visible:
		return
	loading_bar.value = 100.0
	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_property(loading_panel, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() -> void:
		loading_panel.visible = false
		loading_panel.modulate.a = 1.0
	)
	tween.tween_callback(func() -> void: loading_panel.visible = false)


func _build_rift_map() -> void:
	rift_map_panel = PanelContainer.new()
	rift_map_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rift_map_panel.anchor_left = 0.5
	rift_map_panel.anchor_right = 0.5
	rift_map_panel.anchor_top = 0.0
	rift_map_panel.anchor_bottom = 0.0
	rift_map_panel.offset_left = -382.0
	rift_map_panel.offset_right = 382.0
	rift_map_panel.offset_top = 118.0
	rift_map_panel.offset_bottom = 118.0
	rift_map_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.016, 0.035, 0.97), Color(0.52, 0.3, 0.14, 1.0), 2, 5))
	rift_map_panel.visible = false
	rift_map_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(rift_map_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	rift_map_panel.add_child(box)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	box.add_child(head)
	var title := _label("THE RIFT LADDER", 26, AMBER)
	head.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	var close := Button.new()
	close.text = "CLOSE  M"
	close.custom_minimum_size = Vector2(104, 30)
	close.add_theme_font_size_override("font_size", 11)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(hide_rift_map)
	head.add_child(close)
	var sub := _label("Every fifth layer the Ashen Broker opens his stall with no hostiles. Every sixth, a Rift Warden hunts you. There is no floor below the last one you survive.", 11, MUTED)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(sub)
	box.add_child(HSeparator.new())
	rift_map_body = VBoxContainer.new()
	rift_map_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rift_map_body.add_theme_constant_override("separation", 2)
	box.add_child(rift_map_body)
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	box.add_child(foot)
	rift_map_footer = _label("", 11, GOLD)
	rift_map_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(rift_map_footer)
	rift_detail = _label("SELECT A RIFT", 11, BONE, false)
	rift_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(rift_detail)
	rift_enter_btn = Button.new()
	rift_enter_btn.text = "ENTER RIFT"
	rift_enter_btn.custom_minimum_size = Vector2(150, 34)
	rift_enter_btn.add_theme_font_size_override("font_size", 13)
	rift_enter_btn.add_theme_color_override("font_color", AMBER)
	rift_enter_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.7))
	rift_enter_btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.36, 0.38))
	rift_enter_btn.add_theme_stylebox_override("normal", _stylebox(Color(0.1, 0.05, 0.05, 0.96), Color(0.55, 0.32, 0.12, 1.0), 1, 3))
	rift_enter_btn.add_theme_stylebox_override("hover", _stylebox(Color(0.2, 0.09, 0.07, 0.99), Color(1.0, 0.66, 0.24, 1.0), 1, 3))
	rift_enter_btn.add_theme_stylebox_override("disabled", _stylebox(Color(0.06, 0.04, 0.05, 0.9), Color(0.22, 0.18, 0.16, 1.0), 1, 3))
	rift_enter_btn.pressed.connect(_enter_selected_rift)
	foot.add_child(rift_enter_btn)


func show_rift_map(entries: Array, current_layer: int, deepest: int) -> void:
	if rift_map_panel == null:
		return
	if net_panel != null and net_panel.visible:
		net_panel.visible = false
	for child in rift_map_body.get_children():
		rift_map_body.remove_child(child)
		child.queue_free()
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 26)
	rift_map_body.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 2)
	columns.add_child(left)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 2)
	columns.add_child(right)
	var half := int(ceil(float(entries.size()) / 2.0))
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var row := _rift_map_row(entry, current_layer, deepest)
		if i < half:
			left.add_child(row)
		else:
			right.add_child(row)
	var legend := _label("THIS LAYER in gold   ·   CLEARED in violet   ·   AHEAD dim", 10, MUTED)
	rift_map_body.add_child(legend)
	rift_unlock = maxi(1, deepest + 1)
	selected_rift = 0
	rift_entries = entries.duplicate()
	rift_index = 0
	if rift_enter_btn != null:
		rift_enter_btn.disabled = true
	if rift_detail != null:
		rift_detail.text = "SELECT A RIFT TO READ IT"
	for i in rift_entries.size():
		if int((rift_entries[i] as Dictionary).get("layer", 0)) == current_layer:
			rift_index = i
			break
	if not rift_entries.is_empty():
		_select_rift(rift_entries[rift_index])
	if rift_map_footer != null:
		rift_map_footer.text = "CURRENT LAYER %d   ·   LEVEL %d   ·   COIN %d   ·   DEEPEST %d" % [current_layer, run_level, run_coins, maxi(deepest, current_layer)]
	rift_map_panel.visible = true
	rift_map_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(rift_map_panel, "modulate:a", 1.0, 0.18)


func _rift_map_row(entry: Dictionary, current_layer: int, deepest: int) -> Control:
	var layer_num := int(entry.get("layer", 1))
	var is_merchant := bool(entry.get("merchant", false))
	var is_boss := bool(entry.get("boss", false))
	var button := Button.new()
	button.flat = true
	button.custom_minimum_size = Vector2(0, 26)
	button.add_theme_stylebox_override("normal", _stylebox(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0))
	button.add_theme_stylebox_override("hover", _stylebox(Color(0.16, 0.09, 0.07, 0.6), Color(0.6, 0.36, 0.16, 0.8), 1, 2))
	button.add_theme_stylebox_override("pressed", _stylebox(Color(0.24, 0.12, 0.08, 0.7), Color(0.9, 0.55, 0.2, 1.0), 1, 2))
	button.pressed.connect(_select_rift.bind(entry))
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 4.0
	row.offset_right = -4.0
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	row.custom_minimum_size = Vector2(0, 26)
	var marker := ColorRect.new()
	marker.custom_minimum_size = Vector2(6, 18)
	marker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var color := Color(0.3, 0.26, 0.3)
	if layer_num == current_layer:
		color = GOLD
	elif layer_num <= deepest:
		color = Color(0.62, 0.4, 0.95)
	marker.color = color
	row.add_child(marker)
	var number := _label("%02d" % layer_num, 12, color, false)
	number.custom_minimum_size = Vector2(24, 0)
	row.add_child(number)
	var name_color := BONE if layer_num <= deepest or layer_num == current_layer else Color(0.42, 0.38, 0.42)
	var name_label := _label(String(entry.get("name", "RIFT")), 12, name_color, false)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var tag_text := ""
	var tag_color := MUTED
	if is_merchant:
		tag_text = "BROKER"
		tag_color = GOLD
	elif is_boss:
		tag_text = "WARDEN"
		tag_color = Color(1.0, 0.45, 0.3)
	if tag_text != "":
		var tag := _label(tag_text, 10, tag_color, false)
		row.add_child(tag)
	button.add_child(row)
	return button


func _select_rift(entry: Dictionary) -> void:
	selected_rift = int(entry.get("layer", 1))
	for i in rift_entries.size():
		if int((rift_entries[i] as Dictionary).get("layer", 0)) == selected_rift:
			rift_index = i
			break
	if rift_detail == null:
		return
	var parts: Array = [String(entry.get("name", "RIFT"))]
	parts.append("TIER %d" % selected_rift)
	parts.append("LEVEL %d+" % maxi(1, selected_rift))
	if bool(entry.get("boss", false)):
		parts.append("RIFT WARDEN")
	if bool(entry.get("merchant", false)):
		parts.append("BROKER")
	var locked: bool = selected_rift > rift_unlock
	if locked:
		parts.append("LOCKED - CLEAR LAYER %d FIRST" % rift_unlock)
	rift_detail.text = "   ".join(parts)
	rift_detail.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5) if locked else BONE)
	if rift_enter_btn != null:
		rift_enter_btn.disabled = locked
		rift_enter_btn.text = "LOCKED" if locked else "ENTER RIFT %d" % selected_rift


func _enter_selected_rift() -> void:
	if selected_rift <= 0 or rift_enter_btn == null or rift_enter_btn.disabled:
		return
	hide_rift_map()
	rift_enter_requested.emit(selected_rift)


func _move_rift_selection(step: int) -> void:
	if rift_entries.is_empty():
		return
	rift_index = clampi(rift_index + step, 0, rift_entries.size() - 1)
	_select_rift(rift_entries[rift_index])


func hide_rift_map() -> void:
	if rift_map_panel == null or not rift_map_panel.visible:
		return
	rift_map_panel.visible = false
	get_tree().paused = false


func toggle_rift_map() -> void:
	if rift_map_panel == null:
		return
	if rift_map_panel.visible:
		hide_rift_map()
		return
	get_tree().paused = true
	rift_map_requested.emit()


func _build_minimap() -> void:
	var panel := Panel.new()
	minimap_panel = panel
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 26.0
	panel.offset_top = 24.0
	panel.offset_right = 182.0
	panel.offset_bottom = 180.0
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.04, 0.02, 0.03, 0.82), Color(0.4, 0.26, 0.12, 0.95), 1, 3))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(panel)
	minimap = RiftMap.new()
	minimap.set_anchors_preset(Control.PRESET_FULL_RECT)
	minimap.offset_left = 7.0
	minimap.offset_top = 7.0
	minimap.offset_right = -7.0
	minimap.offset_bottom = -7.0
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(minimap)
	var caption := _label("RIFT LAYER", 9, MUTED)
	caption.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	caption.offset_left = 9.0
	caption.offset_top = -15.0
	caption.offset_right = 120.0
	caption.offset_bottom = -2.0
	panel.add_child(caption)


func set_map_cells(walk: Dictionary, bridges: Dictionary, grid_size := 17) -> void:
	if minimap == null:
		return
	var walk_list: Array = []
	var lava_list: Array = []
	for cell in walk.keys():
		if bool(walk[cell]):
			walk_list.append(cell)
		else:
			lava_list.append(cell)
	minimap.walkable_cells = walk_list
	minimap.lava_cells = lava_list
	minimap.bridge_cells = bridges.keys()
	minimap.grid_size = grid_size
	minimap.queue_redraw()


func update_map(player_cell: Vector2i, enemy_cells: Array, elite_cells: Array, portal_cell: Vector2i, portal_on: bool) -> void:
	if minimap == null:
		return
	minimap.player_cell = player_cell
	minimap.enemy_cells = enemy_cells
	minimap.elite_cells = elite_cells
	minimap.portal_cell = portal_cell
	minimap.portal_on = portal_on
	minimap.queue_redraw()


func show_body() -> void:
	if body == null:
		return
	if body.visible and body.modulate.a >= 0.99:
		return
	body.visible = true
	var tween := create_tween()
	tween.tween_property(body, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func hide_body() -> void:
	if body == null:
		return
	if not body.visible:
		return
	var tween := create_tween()
	tween.tween_property(body, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func() -> void: body.visible = false)


func _build_backdrop() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color(0.0, 0.0, 0.0, 0.0), Color(0.02, 0.005, 0.015, 0.35), Color(0.01, 0.0, 0.01, 0.72)])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0.0, 0.0)
	tex.fill_to = Vector2(0.0, 1.0)
	var bottom := TextureRect.new()
	bottom.texture = tex
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.anchor_top = 1.0
	bottom.offset_top = -250.0
	bottom.offset_bottom = 0.0
	bottom.stretch_mode = TextureRect.STRETCH_SCALE
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bottom)
	var noise := FastNoiseLite.new()
	noise.frequency = 0.4
	noise.fractal_octaves = 3
	var grain_tex := NoiseTexture2D.new()
	grain_tex.width = 128
	grain_tex.height = 128
	grain_tex.noise = noise
	grain_tex.seamless = true
	var grain := TextureRect.new()
	grain.texture = grain_tex
	grain.set_anchors_preset(Control.PRESET_FULL_RECT)
	grain.stretch_mode = TextureRect.STRETCH_TILE
	grain.modulate = Color(1.0, 0.95, 0.9, 0.035)
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(grain)


func _build_vignette() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color(0.75, 0.0, 0.02, 0.0), Color(0.7, 0.0, 0.02, 0.0), Color(0.72, 0.0, 0.03, 1.0)])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 512
	tex.height = 288
	vignette = TextureRect.new()
	vignette.texture = tex
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.modulate = Color(1, 1, 1, 0)
	root.add_child(vignette)


func _build_ability_flash() -> void:
	ability_flash_rect = ColorRect.new()
	ability_flash_rect.color = Color(1.0, 0.2, 0.15, 0.0)
	ability_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	ability_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(ability_flash_rect)


func flash_ability(color: Color) -> void:
	if ability_flash_rect == null:
		return
	ability_flash_rect.color = Color(color.r, color.g, color.b, 0.16)
	var tween := create_tween()
	tween.tween_property(ability_flash_rect, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _build_online_chip() -> void:
	online_chip = PanelContainer.new()
	online_chip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	online_chip.offset_left = 34.0
	online_chip.offset_top = 204.0
	online_chip.offset_right = 214.0
	online_chip.offset_bottom = 228.0
	online_chip.add_theme_stylebox_override("panel", _stylebox(Color(0.05, 0.03, 0.05, 0.82), Color(0.32, 0.52, 0.34, 1.0), 1, 2))
	online_chip.visible = false
	body.add_child(online_chip)
	online_label = _label("ONLINE", 10, Color(0.68, 0.92, 0.72), false)
	online_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_chip.add_child(online_label)


## seat is 1-based for display; 0 means a solo run, which hides the chip.
func set_online(seat: int, peers: int) -> void:
	if online_chip == null:
		return
	if seat < 1:
		online_chip.visible = false
		return
	online_chip.visible = true
	online_chip.add_theme_stylebox_override("panel", _stylebox(Color(0.05, 0.03, 0.05, 0.82), Color(0.32, 0.52, 0.34, 1.0), 1, 2))
	online_label.text = "ONLINE  -  %d IN RIFT  -  SEAT %d" % [maxi(1, peers), seat]


func _build_top() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.offset_top = 18.0
	box.offset_left = -260.0
	box.offset_right = 260.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(box)
	layer_label = _label("RIFT LAYER 1", 34, AMBER)
	layer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(layer_label)
	theme_label = _label("", 12, MUTED)
	theme_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(theme_label)
	mod_row = HBoxContainer.new()
	mod_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mod_row.add_theme_constant_override("separation", 12)
	mod_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(mod_row)
	var wave_gap := Control.new()
	wave_gap.custom_minimum_size = Vector2(0, 5)
	wave_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(wave_gap)
	var wave_holder := Control.new()
	wave_holder.custom_minimum_size = Vector2(0, 6)
	wave_holder.clip_contents = true
	wave_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(wave_holder)
	wave_bar = ProgressBar.new()
	wave_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	wave_bar.show_percentage = false
	wave_bar.max_value = 100.0
	wave_bar.value = 0.0
	var wave_bg := StyleBoxFlat.new()
	wave_bg.bg_color = Color(0.08, 0.025, 0.03, 0.9)
	wave_bg.set_corner_radius_all(2)
	var wave_grad := Gradient.new()
	wave_grad.set_color(0, Color(0.5, 0.12, 0.05, 1.0))
	wave_grad.set_color(1, Color(1.0, 0.62, 0.2, 1.0))
	var wave_tex := GradientTexture2D.new()
	wave_tex.gradient = wave_grad
	wave_tex.fill_from = Vector2(0.0, 0.0)
	wave_tex.fill_to = Vector2(1.0, 0.0)
	wave_tex.width = 128
	wave_tex.height = 4
	var wave_fill := StyleBoxTexture.new()
	wave_fill.texture = wave_tex
	wave_bar.add_theme_stylebox_override("background", wave_bg)
	wave_bar.add_theme_stylebox_override("fill", wave_fill)
	wave_holder.add_child(wave_bar)
	wave_label = _label("HOSTILES REMAIN 0", 16, MUTED)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(wave_label)
	status_label = _label("", 20, GOLD)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(status_label)
	controls_hint = _label("WASD MOVE  ·  LMB LANCE  ·  RMB NOVA  ·  1 2 3 CAST  ·  SPACE RIFTSTEP  ·  TAB RELICS", 12, MUTED)
	controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(controls_hint)


func _build_boss() -> void:
	boss_panel = PanelContainer.new()
	boss_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_panel.anchor_left = 0.5
	boss_panel.anchor_right = 0.5
	boss_panel.offset_left = -270.0
	boss_panel.offset_right = 270.0
	boss_panel.offset_top = 262.0
	boss_panel.offset_bottom = 316.0
	boss_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.05, 0.012, 0.02, 0.92), Color(0.62, 0.14, 0.1, 1.0), 1))
	boss_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_panel.visible = false
	body.add_child(boss_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_panel.add_child(box)
	boss_name = _label("RIFT WARDEN", 17, Color(1.0, 0.55, 0.35))
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(boss_name)
	boss_bar = ProgressBar.new()
	boss_bar.custom_minimum_size = Vector2(0, 12)
	boss_bar.show_percentage = false
	boss_bar.max_value = 100.0
	boss_bar.value = 100.0
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.02, 0.02, 0.95)
	bg.set_corner_radius_all(2)
	var grad := Gradient.new()
	grad.set_color(0, Color(0.55, 0.05, 0.03, 1.0))
	grad.set_color(1, Color(1.0, 0.35, 0.12, 1.0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.0, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 8
	var fill := StyleBoxTexture.new()
	fill.texture = tex
	boss_bar.add_theme_stylebox_override("background", bg)
	boss_bar.add_theme_stylebox_override("fill", fill)
	box.add_child(boss_bar)


func _build_health() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	box.offset_left = 30.0
	box.offset_bottom = -104.0
	box.offset_top = -252.0
	box.offset_right = 366.0
	box.add_theme_constant_override("separation", 3)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(box)
	hero_name_label = _label("", 14, Color(0.88, 0.74, 0.60))
	box.add_child(hero_name_label)
	hero_class_label = _label("", 11, Color(0.70, 0.55, 0.47))
	box.add_child(hero_class_label)
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 8)
	level_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(level_row)
	level_label = _label("LEVEL 1", 13, GOLD)
	level_row.add_child(level_label)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(0, 4)
	xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	xp_bar.show_percentage = false
	xp_bar.max_value = 100.0
	xp_bar.value = 0.0
	var xp_bg := StyleBoxFlat.new()
	xp_bg.bg_color = Color(0.09, 0.05, 0.02, 0.9)
	xp_bg.set_corner_radius_all(2)
	var xp_fill := StyleBoxFlat.new()
	xp_fill.bg_color = Color(1.0, 0.74, 0.26, 0.95)
	xp_fill.set_corner_radius_all(2)
	xp_bar.add_theme_stylebox_override("background", xp_bg)
	xp_bar.add_theme_stylebox_override("fill", xp_fill)
	level_row.add_child(xp_bar)
	coin_label = _label("COIN  0", 14, GOLD)
	box.add_child(coin_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	health_label = _label("VITAE 140 / 140", 16, BONE)
	row.add_child(health_label)
	regen_label = _label("", 11, GOLD)
	regen_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	regen_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	regen_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(regen_label)
	var grad := Gradient.new()
	grad.set_color(0, Color(0.42, 0.02, 0.05, 1.0))
	grad.set_color(1, Color(0.98, 0.22, 0.15, 1.0))
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill_from = Vector2(0.0, 0.5)
	gtex.fill_to = Vector2(1.0, 0.5)
	gtex.width = 256
	gtex.height = 8
	vitae_bar = VitaeBar.new()
	vitae_bar.grad = gtex
	vitae_bar.custom_minimum_size = Vector2(0, 22)
	vitae_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(vitae_bar)
	focus_row = VBoxContainer.new()
	focus_row.add_theme_constant_override("separation", 1)
	focus_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_row.visible = false
	box.add_child(focus_row)
	focus_label = _label("", 11, GOLD)
	focus_row.add_child(focus_label)
	focus_bar = ProgressBar.new()
	focus_bar.custom_minimum_size = Vector2(0, 9)
	focus_bar.show_percentage = false
	focus_bar.max_value = 100.0
	focus_bar.value = 100.0
	var focus_bg := StyleBoxFlat.new()
	focus_bg.bg_color = Color(0.05, 0.04, 0.02, 0.9)
	focus_bg.set_corner_radius_all(2)
	focus_fill = StyleBoxFlat.new()
	focus_fill.bg_color = Color(0.95, 0.75, 0.3, 0.95)
	focus_fill.set_corner_radius_all(2)
	focus_bar.add_theme_stylebox_override("background", focus_bg)
	focus_bar.add_theme_stylebox_override("fill", focus_fill)
	focus_row.add_child(focus_bar)
	bloodrush_label = _label("BLOODRUSH ×0", 11, GOLD)
	bloodrush_label.visible = false
	box.add_child(bloodrush_label)
	bloodrush_bar = ProgressBar.new()
	bloodrush_bar.custom_minimum_size = Vector2(280, 6)
	bloodrush_bar.show_percentage = false
	bloodrush_bar.max_value = 100.0
	bloodrush_bar.value = 0.0
	var br_bg := StyleBoxFlat.new()
	br_bg.bg_color = Color(0.06, 0.03, 0.02, 0.85)
	br_bg.set_corner_radius_all(2)
	var br_grad := Gradient.new()
	br_grad.set_color(0, Color(0.85, 0.35, 0.05, 1.0))
	br_grad.set_color(1, Color(1.0, 0.85, 0.35, 1.0))
	var br_tex := GradientTexture2D.new()
	br_tex.gradient = br_grad
	br_tex.fill_from = Vector2(0.0, 0.0)
	br_tex.fill_to = Vector2(1.0, 0.0)
	br_tex.width = 64
	br_tex.height = 4
	var br_fill := StyleBoxTexture.new()
	br_fill.texture = br_tex
	bloodrush_bar.add_theme_stylebox_override("background", br_bg)
	bloodrush_bar.add_theme_stylebox_override("fill", br_fill)
	bloodrush_bar.visible = false
	box.add_child(bloodrush_bar)


func _build_abilities() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.offset_bottom = -22.0
	box.offset_top = -128.0
	box.offset_left = -304.0
	box.offset_right = 304.0
	box.alignment = BoxContainer.ALIGNMENT_END
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(box)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	ability_row = row
	var start_class: Dictionary = HeroClasses.definition("blood_sorceress")
	var start_list: Array = start_class.get("abilities", [])
	for ability_index in start_list.size():
		var ability: Dictionary = start_list[ability_index]
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(148, 70)
		panel.add_theme_stylebox_override("panel", _stylebox(Color(0.045, 0.028, 0.05, 0.94), Color(0.34, 0.2, 0.14, 1.0), 1, 2))
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var slot_index := slots.size()
		panel.gui_input.connect(_on_slot_input.bind(slot_index))
		panel.mouse_entered.connect(_hover_slot.bind(panel, true, Color(0.3, 0.16, 0.12, 1.0)))
		panel.mouse_exited.connect(_hover_slot.bind(panel, false, Color(0.3, 0.16, 0.12, 1.0)))
		row.add_child(panel)
		var accent := ColorRect.new()
		accent.color = Color(0.78, 0.45, 0.16, 0.85)
		accent.set_anchors_preset(Control.PRESET_TOP_WIDE)
		accent.offset_bottom = 2.0
		accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(accent)
		var key_label := _label(str(ability_index + 1), 13, AMBER)
		key_label.position = Vector2(8, 3)
		panel.add_child(key_label)
		var mouse_hint := _label("", 10, Color(0.74, 0.6, 0.48))
		mouse_hint.position = Vector2(110, 52)
		panel.add_child(mouse_hint)
		var icon_path := String(ability.get("icon", ""))
		var icon_box := Panel.new()
		icon_box.position = Vector2(8, 18)
		icon_box.size = Vector2(46, 46)
		icon_box.custom_minimum_size = Vector2(46, 46)
		icon_box.clip_contents = true
		icon_box.add_theme_stylebox_override("panel", _stylebox(Color(0.015, 0.01, 0.02, 0.95), Color(0.58, 0.38, 0.17, 0.95), 1, 2))
		icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(icon_box)
		var icon := TextureRect.new()
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 2.0
		icon.offset_top = 2.0
		icon.offset_right = -2.0
		icon.offset_bottom = -2.0
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_box.add_child(icon)
		var name_label := _label(String(ability.glyph), 16, BONE)
		name_label.position = Vector2(60, 8)
		panel.add_child(name_label)
		var cost := float(ability.get("cost", 0.0))
		var cost_label := _label("FREE" if cost <= 0.0 else "%d VITAE" % int(cost), 11, CRIMSON)
		cost_label.position = Vector2(60, 30)
		panel.add_child(cost_label)
		var cd_label := _label("", 15, Color(1.0, 0.92, 0.7))
		cd_label.position = Vector2(8, 32)
		cd_label.size = Vector2(46, 20)
		cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(cd_label)
		var overlay := ColorRect.new()
		overlay.color = Color(0.02, 0.0, 0.02, 0.72)
		overlay.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		overlay.anchor_top = 1.0
		overlay.anchor_bottom = 1.0
		overlay.offset_top = 0.0
		overlay.offset_bottom = 0.0
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(overlay)
		cd_label.move_to_front()
		slots.append({"panel": panel, "overlay": overlay, "cd": cd_label, "name": name_label, "cost": cost_label,
			"was_cd": false, "accent": accent, "icon": icon, "hint": mouse_hint, "icon_box": icon_box})
	var dash := Panel.new()
	dash.custom_minimum_size = Vector2(124, 70)
	dash.add_theme_stylebox_override("panel", _stylebox(Color(0.045, 0.028, 0.06, 0.94), Color(0.3, 0.24, 0.4, 1.0), 1, 2))
	dash.mouse_filter = Control.MOUSE_FILTER_STOP
	dash.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	dash.gui_input.connect(_on_slot_input.bind(3))
	dash.mouse_entered.connect(_hover_slot.bind(dash, true, Color(0.24, 0.2, 0.3, 1.0)))
	dash.mouse_exited.connect(_hover_slot.bind(dash, false, Color(0.24, 0.2, 0.3, 1.0)))
	row.add_child(dash)
	var dash_accent := ColorRect.new()
	dash_accent.color = Color(0.45, 0.34, 0.62, 0.8)
	dash_accent.set_anchors_preset(Control.PRESET_TOP_WIDE)
	dash_accent.offset_bottom = 2.0
	dash_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dash.add_child(dash_accent)
	var dash_key := _label("SPACE", 11, AMBER)
	dash_key.position = Vector2(6, 5)
	dash.add_child(dash_key)
	var dash_icon_path := _first_png(ICON_RIFTSTEP_DIR)
	if dash_icon_path != "":
		var dash_box := Panel.new()
		dash_box.position = Vector2(6, 24)
		dash_box.size = Vector2(40, 40)
		dash_box.custom_minimum_size = Vector2(40, 40)
		dash_box.clip_contents = true
		dash_box.add_theme_stylebox_override("panel", _stylebox(Color(0.015, 0.01, 0.02, 0.95), Color(0.5, 0.4, 0.62, 0.95), 1, 2))
		dash_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dash.add_child(dash_box)
		var dash_icon := TextureRect.new()
		dash_icon.texture = load(dash_icon_path)
		dash_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		dash_icon.offset_left = 2.0
		dash_icon.offset_top = 2.0
		dash_icon.offset_right = -2.0
		dash_icon.offset_bottom = -2.0
		dash_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dash_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		dash_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dash_box.add_child(dash_icon)
	dash_action_label = _label("RIFTSTEP", 11, BONE)
	dash_action_label.position = Vector2(50, 20)
	dash_action_label.size = Vector2(70, 18)
	dash_action_label.clip_text = true
	dash.add_child(dash_action_label)
	var dash_cd := _label("", 20, GOLD)
	dash_cd.anchor_left = 1.0
	dash_cd.anchor_right = 1.0
	dash_cd.anchor_top = 0.5
	dash_cd.anchor_bottom = 0.5
	dash_cd.offset_left = -46.0
	dash_cd.offset_right = -6.0
	dash_cd.offset_top = 2.0
	dash_cd.offset_bottom = 24.0
	dash_cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dash.add_child(dash_cd)
	slots.append({"panel": dash, "overlay": null, "cd": dash_cd, "name": dash_action_label, "cost": null, "was_cd": false})


func _on_slot_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		ability_pressed.emit(index)
		get_viewport().set_input_as_handled()


func _hover_slot(panel: Panel, hovered: bool, base_border: Color) -> void:
	if panel == null:
		return
	if hovered:
		panel.add_theme_stylebox_override("panel", _stylebox(Color(0.14, 0.055, 0.06, 0.95), Color(0.95, 0.6, 0.2, 1.0), 1))
	else:
		panel.add_theme_stylebox_override("panel", _stylebox(INK, base_border, 1))
func _build_relic() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -252.0
	panel.offset_right = -24.0
	panel.offset_top = -158.0
	panel.offset_bottom = -26.0
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.02, 0.04, 0.9), Color(0.34, 0.22, 0.14, 1.0), 1))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.gui_input.connect(_on_relic_panel_input)
	body.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	var title := _label("RELIC LOADOUT   ·   TAB", 11, MUTED)
	box.add_child(title)
	for i in Player.MAX_RELICS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 7)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(row)
		var gem := RelicGem.new()
		gem.custom_minimum_size = Vector2(13, 13)
		gem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(gem)
		var name_label := _label("Empty", 14, MUTED)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_child(name_label)
		relic_rows.append({"gem": gem, "name": name_label})
	relic_stats = _label("Click a glowing drop to claim", 11, MUTED)
	relic_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(relic_stats)


func _build_toasts() -> void:
	toast_box = VBoxContainer.new()
	toast_box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_box.anchor_left = 0.5
	toast_box.anchor_right = 0.5
	toast_box.offset_left = -300.0
	toast_box.offset_right = 300.0
	toast_box.offset_top = 262.0
	toast_box.alignment = BoxContainer.ALIGNMENT_CENTER
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(toast_box)
	whisper_label = _label("", 13, Color(0.72, 0.62, 0.6, 0.92), false)
	whisper_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	whisper_label.anchor_left = 0.5
	whisper_label.anchor_right = 0.5
	whisper_label.offset_left = -380.0
	whisper_label.offset_right = 380.0
	whisper_label.offset_top = 248.0
	whisper_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	whisper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	whisper_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	whisper_label.modulate.a = 0.0
	body.add_child(whisper_label)


func whisper(text: String) -> void:
	if whisper_label == null or text.is_empty():
		return
	whisper_label.text = text
	whisper_label.modulate.a = 0.0
	var tween := whisper_label.create_tween()
	tween.tween_property(whisper_label, "modulate:a", 1.0, 0.6)
	tween.tween_interval(4.4)
	tween.tween_property(whisper_label, "modulate:a", 0.0, 1.2)


func _build_relic_window() -> void:
	relic_window = PanelContainer.new()
	relic_window.set_anchors_preset(Control.PRESET_CENTER)
	relic_window.anchor_left = 0.5
	relic_window.anchor_right = 0.5
	relic_window.anchor_top = 0.5
	relic_window.anchor_bottom = 0.5
	relic_window.offset_left = -320.0
	relic_window.offset_right = 320.0
	relic_window.offset_top = -238.0
	relic_window.offset_bottom = 208.0
	relic_window.add_theme_stylebox_override("panel", _stylebox(Color(0.035, 0.02, 0.04, 0.97), Color(0.55, 0.34, 0.14, 1.0), 2, 4))
	relic_window.visible = false
	relic_window.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(relic_window)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	relic_window.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	relic_tabs = HBoxContainer.new()
	relic_tabs.add_theme_constant_override("separation", 6)
	header.add_child(relic_tabs)
	relic_tabs.add_child(_tab_button("RELICS", "relics"))
	relic_tabs.add_child(_tab_button("SYNERGY", "synergy"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var close := Button.new()
	close.text = "ESC"
	close.custom_minimum_size = Vector2(58, 30)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(close_relic_window)
	header.add_child(close)
	relic_body = VBoxContainer.new()
	relic_body.add_theme_constant_override("separation", 5)
	relic_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(relic_body)
	var foot := _label("Families stack at most twice. Legends rewrite a skill. TAB closes this.", 11, MUTED)
	foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(foot)


func _tab_button(text: String, tab: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(126, 32)
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", MUTED)
	btn.add_theme_color_override("font_hover_color", AMBER)
	btn.add_theme_color_override("font_pressed_color", GOLD)
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.06, 0.03, 0.05, 0.92), Color(0.24, 0.16, 0.12, 1.0), 1))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.14, 0.07, 0.06, 0.96), Color(0.7, 0.45, 0.16, 1.0), 1))
	btn.add_theme_stylebox_override("pressed", _stylebox(Color(0.2, 0.09, 0.07, 1.0), Color(1.0, 0.65, 0.25, 1.0), 1))
	btn.set_meta("tab", tab)
	btn.pressed.connect(_select_tab.bind(tab))
	return btn


func _select_tab(tab: String) -> void:
	relic_tab = tab
	_refresh_relic_window()


func _on_relic_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		toggle_relic_window()
		get_viewport().set_input_as_handled()


func _build_death() -> void:
	death_panel = PanelContainer.new()
	death_panel.set_anchors_preset(Control.PRESET_CENTER)
	death_panel.anchor_left = 0.5
	death_panel.anchor_right = 0.5
	death_panel.anchor_top = 0.5
	death_panel.anchor_bottom = 0.5
	death_panel.offset_left = -300.0
	death_panel.offset_right = 300.0
	death_panel.offset_top = -170.0
	death_panel.offset_bottom = 170.0
	death_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.005, 0.01, 0.95), Color(0.55, 0.08, 0.08, 1.0), 2))
	death_panel.visible = false
	root.add_child(death_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	death_panel.add_child(box)
	var title := _label("YOU HAVE FALLEN", 42, CRIMSON)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := _label("The rift closes over your ashes.", 17, MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	death_stats = _label("", 18, BONE)
	death_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(death_stats)
	var hint := _label("PRESS  R  TO DESCEND AGAIN", 20, AMBER)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)
	var btn := Button.new()
	btn.text = "DESCEND AGAIN"
	btn.custom_minimum_size = Vector2(220, 44)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", AMBER)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.75))
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.12, 0.03, 0.04, 0.95), Color(0.55, 0.14, 0.12, 1.0), 1))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.24, 0.07, 0.06, 0.98), Color(1.0, 0.55, 0.25, 1.0), 1))
	btn.add_theme_stylebox_override("pressed", _stylebox(Color(0.32, 0.1, 0.08, 1.0), Color(1.0, 0.7, 0.35, 1.0), 1))
	btn.button_down.connect(func() -> void: restart_pressed.emit())
	var center := CenterContainer.new()
	center.add_child(btn)
	box.add_child(center)


func _build_title() -> void:
	title_panel = Control.new()
	title_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(title_panel)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.005, 0.015, 0.68)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_panel.add_child(shade)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_right = 0.5
	card.anchor_top = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -368.0
	card.offset_right = 368.0
	card.offset_top = -214.0
	card.offset_bottom = 214.0
	card.add_theme_stylebox_override("panel", _stylebox(Color(0.028, 0.014, 0.03, 0.95), Color(0.5, 0.32, 0.14, 1.0), 2, 5))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	title_panel.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(box)
	title_label = _label("RIFT & RUIN", 62, AMBER)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title_label)
	var sub := _label("AN ACTION RPG OF THE DROWNING WORLD", 14, CRIMSON)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	record_label = _label("DEEPEST RIFT  ·  LAYER 1", 12, MUTED)
	record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(record_label)
	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(0, 12)
	box.add_child(rule)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 12)
	box.add_child(buttons)
	var continue_btn := Button.new()
	title_continue_btn = continue_btn
	continue_btn.text = _continue_text(Roster.last_played())
	continue_btn.visible = not Roster.last_played().is_empty() or RunSave.has_save()
	continue_btn.custom_minimum_size = Vector2(292, 58)
	continue_btn.add_theme_font_size_override("font_size", 15)
	continue_btn.add_theme_color_override("font_color", GOLD)
	continue_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.75))
	continue_btn.add_theme_stylebox_override("normal", _stylebox(Color(0.12, 0.05, 0.05, 0.96), Color(0.75, 0.5, 0.18, 1.0), 1, 3))
	continue_btn.add_theme_stylebox_override("hover", _stylebox(Color(0.22, 0.09, 0.07, 0.99), Color(1.0, 0.7, 0.28, 1.0), 1, 3))
	continue_btn.mouse_entered.connect(func() -> void: _set_lore("continue"))
	continue_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		continue_pressed.emit()
	)
	buttons.add_child(continue_btn)
	var begin_btn := Button.new()
	title_begin_btn = begin_btn
	begin_btn.text = "NEW RIFT" if RunSave.has_save() else "ENTER THE RIFT"
	begin_btn.custom_minimum_size = Vector2(292, 58)
	begin_btn.add_theme_font_size_override("font_size", 17)
	begin_btn.add_theme_color_override("font_color", AMBER)
	begin_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.78))
	begin_btn.add_theme_stylebox_override("normal", _stylebox(Color(0.14, 0.06, 0.05, 0.96), Color(0.55, 0.3, 0.12, 1.0), 1, 3))
	begin_btn.add_theme_stylebox_override("hover", _stylebox(Color(0.24, 0.1, 0.07, 0.99), Color(1.0, 0.66, 0.24, 1.0), 1, 3))
	begin_btn.mouse_entered.connect(func() -> void: _set_lore("new"))
	begin_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		show_creator()
	)
	buttons.add_child(begin_btn)
	var menu2 := HBoxContainer.new()
	menu2.alignment = BoxContainer.ALIGNMENT_CENTER
	menu2.add_theme_constant_override("separation", 8)
	box.add_child(menu2)
	var coop_btn := _title_small("CO-OP", Color(0.62, 0.92, 0.7))
	coop_btn.tooltip_text = "Online co-op: matchmaking, party and connection state"
	coop_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		net_action.emit("open", "coop")
	)
	menu2.add_child(coop_btn)
	var pvp_btn := _title_small("PVP", Color(0.85, 0.6, 1.0))
	pvp_btn.tooltip_text = "Duel the Mirror and competitive modes"
	pvp_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		duel_pressed.emit()
	)
	menu2.add_child(pvp_btn)
	var map_btn := _title_small("WORLD MAP", GOLD)
	map_btn.tooltip_text = "Rift ladder, tiers and rewards"
	map_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		rift_map_requested.emit()
	)
	menu2.add_child(map_btn)
	var chars_btn := _title_small("CHARACTERS", Color(0.95, 0.8, 0.55))
	chars_btn.tooltip_text = "Load, create or delete heroes"
	chars_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		roster_requested.emit()
	)
	menu2.add_child(chars_btn)
	var hall_btn := _title_small("HALL", MUTED)
	hall_btn.tooltip_text = "Hall of Wardens: the rift's history"
	hall_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		_cycle_hall()
	)
	menu2.add_child(hall_btn)
	var options_btn := _title_small("OPTIONS", MUTED)
	options_btn.pressed.connect(func() -> void:
		if not _title_input_ok():
			return
		open_settings()
	)
	menu2.add_child(options_btn)
	var lore_panel := PanelContainer.new()
	lore_panel.custom_minimum_size = Vector2(0, 62)
	lore_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.05, 0.025, 0.04, 0.9), Color(0.32, 0.22, 0.14, 1.0), 1, 2))
	box.add_child(lore_panel)
	var lore_box := VBoxContainer.new()
	lore_box.add_theme_constant_override("separation", 2)
	lore_panel.add_child(lore_box)
	title_lore_title = _label("THE ASHEN BASTION", 10, GOLD, false)
	lore_box.add_child(title_lore_title)
	title_lore_label = _label("", 11, BONE, false)
	title_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_box.add_child(title_lore_label)
	var hint := _label("WASD MOVE  ·  LMB LANCE  ·  RMB NOVA  ·  1 2 3 CAST  ·  SPACE RIFTSTEP  ·  TAB RELICS  ·  M RIFT MAP", 10, Color(0.5, 0.45, 0.46))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)
	var footer := _label("A DARK FANTASY ACTION RPG  ·  THE RIFT NEVER ENDS", 9, Color(0.42, 0.37, 0.4))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(footer)
	title_panel.modulate.a = 0.0
	title_shown_ms = Time.get_ticks_msec()
	_set_lore("hall")
	var fade := create_tween()
	fade.tween_property(title_panel, "modulate:a", 1.0, 0.7)


func _title_small(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(104, 34)
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.85))
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.06, 0.035, 0.06, 0.96), color.darkened(0.6), 1, 3))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.15, 0.07, 0.12, 0.99), color, 1, 3))
	return btn


func _title_input_ok() -> bool:
	# Only the fade-in is protected: a click after the card is visible counts.
	title_mouse_moved = true
	return Time.get_ticks_msec() - title_shown_ms > 450


func _set_lore(key: String) -> void:
	if title_lore_label == null:
		return
	var heading := "THE ASHEN BASTION"
	var body := "The Bastion clings to the rim of a wound in the world. Below it the rift breathes, and every layer remembers the last hand that broke it."
	match key:
		"continue":
			var saved := RunSave.read()
			heading = "CONTINUE THE DESCENT"
			body = "The rift remembers your shape. Layer %d waits below, and it has already learned how you move." % int(saved.get("layer", 1))
		"new":
			heading = "A NEW SORCERESS"
			body = "Her blood is the only fuel the rift respects. She does not go down to win. She goes down to find out how far she can make it."
		"duel":
			heading = "THE MIRROR RING"
			body = "A rival sorceress with your own blood and your own spells. No relics, no coin, no mercy: only proof that your hands are the sharper ones."
		"hall":
			var entry: Dictionary = LORE_BOOK[hall_index % LORE_BOOK.size()]
			heading = "HALL OF WARDENS  ·  %s" % String(entry.get("title", ""))
			body = String(entry.get("body", "")).split("\n\n")[0]
		"options":
			heading = "OPTIONS"
			body = "Sound, screen, controls and the shape of the HUD. Every rift save carries its own settings."
	title_lore_title.text = heading
	title_lore_label.text = body


func _cycle_hall() -> void:
	hall_index = (hall_index + 1) % LORE_BOOK.size()
	_set_lore("hall")


func refresh_title() -> void:
	var entry := Roster.last_played()
	var has_save := not entry.is_empty() or RunSave.has_save()
	if title_continue_btn != null:
		title_continue_btn.visible = has_save
		if has_save:
			title_continue_btn.text = _continue_text(entry)
	if title_begin_btn != null:
		title_begin_btn.text = "NEW RIFT" if has_save else "ENTER THE RIFT"
	if record_label != null:
		record_label.text = "DEEPEST RIFT  ·  LAYER %d" % record_layer


func _continue_text(entry: Dictionary) -> String:
	if entry.is_empty():
		var saved := RunSave.read()
		return "CONTINUE  ·  LAST HERO\nLAYER %d  ·  LEVEL %d  ·  %d COIN" % [
			int(saved.get("layer", 1)), int(saved.get("level", 1)), int(saved.get("coins", 0))]
	var class_text := HeroClasses.display_name(String(entry.get("class_id", "blood_sorceress")))
	return "CONTINUE  %s\n%s  ·  LEVEL %d  ·  LAYER %d" % [
		String(entry.get("name", "VESNA")), class_text, int(entry.get("level", 1)), int(entry.get("layer", 1))]


func show_title_again() -> void:
	if title_panel == null:
		return
	title_panel.visible = true
	title_panel.modulate.a = 0.0
	if settings_btn != null:
		settings_btn.visible = false
	title_shown_ms = Time.get_ticks_msec()
	title_mouse_moved = false
	_set_lore("hall")
	refresh_title()
	var tween := create_tween()
	tween.tween_property(title_panel, "modulate:a", 1.0, 0.5)


func _build_pause() -> void:
	pause_shade = ColorRect.new()
	pause_shade.color = Color(0.01, 0.0, 0.015, 0.62)
	pause_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_shade.visible = false
	root.add_child(pause_shade)
	pause_panel = PanelContainer.new()
	pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_panel.anchor_left = 0.5
	pause_panel.anchor_right = 0.5
	pause_panel.anchor_top = 0.5
	pause_panel.anchor_bottom = 0.5
	pause_panel.offset_left = -382.0
	pause_panel.offset_right = 382.0
	pause_panel.offset_top = -284.0
	pause_panel.offset_bottom = 284.0
	pause_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.04, 0.02, 0.05, 0.97), Color(0.55, 0.34, 0.14, 1.0), 2, 4))
	pause_panel.visible = false
	root.add_child(pause_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	pause_panel.add_child(box)
	var title := _label("PAUSED", 46, AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := _label("The rift holds its breath.", 15, MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	box.add_child(spacer)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 30)
	box.add_child(columns)
	var controls := VBoxContainer.new()
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 1)
	columns.add_child(controls)
	controls.add_child(_label("CONTROLS", 12, GOLD))
	for line in [
		"WASD / ARROWS    move",
		"LMB  CRIMSON LANCE",
		"RMB  BLOOD NOVA",
		"1  BLOOD NOVA    6 vitae",
		"2  CRIMSON LANCE 3 vitae",
		"3  SANGUINE SIPHON free",
		"SPACE  RIFTSTEP",
		"MMB pan  F recenter",
		"TAB relics  M map  ESC pause",
	]:
		controls.add_child(_label(line, 12, BONE, false))
	var tips := VBoxContainer.new()
	tips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tips.add_theme_constant_override("separation", 1)
	columns.add_child(tips)
	tips.add_child(_label("RIFT LAW", 12, GOLD))
	for line in [
		"Clear the packs, then claim a boon (1 - 3).",
		"Kills drop coin. Elites and bosses pay more.",
		"THE ASHEN BROKER waits on every 5th layer.",
		"A different RIFT WARDEN stalks every 6th layer.",
		"Relics stack at most twice per family.",
		"Click a glowing drop to claim the relic.",
		"Your level rises with kills and depth.",
	]:
		var tip := _label(line, 12, BONE, false)
		tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tips.add_child(tip)
	pause_summary = _label("", 13, MUTED)
	pause_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(pause_summary)
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 2)
	box.add_child(spacer2)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	var center := CenterContainer.new()
	center.add_child(grid)
	box.add_child(center)
	var resume := _pause_button("RESUME")
	resume.pressed.connect(toggle_pause)
	grid.add_child(resume)
	var character := _pause_button("CHARACTER")
	character.pressed.connect(func() -> void:
		_close_pause_for_overlay()
		get_tree().paused = false
		toggle_relic_window()
	)
	grid.add_child(character)
	var passives := _pause_button("PASSIVES", Color(0.6, 0.9, 0.8))
	passives.tooltip_text = "Spend one point per level on the Bloodied Path"
	passives.pressed.connect(func() -> void:
		_close_pause_for_overlay()
		passives_requested.emit()
	)
	grid.add_child(passives)
	var map_btn := _pause_button("WORLD MAP")
	map_btn.pressed.connect(func() -> void:
		_close_pause_for_overlay()
		get_tree().paused = true
		toggle_rift_map()
	)
	grid.add_child(map_btn)
	var coop := _pause_button("CO-OP ONLINE", Color(0.62, 0.92, 0.7))
	coop.pressed.connect(func() -> void:
		_close_pause_for_overlay()
		get_tree().paused = true
		net_action.emit("open", "coop")
	)
	grid.add_child(coop)
	var pvp := _pause_button("PVP ARENA", Color(0.85, 0.6, 1.0))
	pvp.pressed.connect(func() -> void:
		_close_pause_for_overlay()
		get_tree().paused = true
		net_action.emit("open", "pvp")
	)
	grid.add_child(pvp)
	var options := _pause_button("OPTIONS")
	options.pressed.connect(open_settings)
	grid.add_child(options)
	var lore := _pause_button("LORE", GOLD)
	lore.tooltip_text = "The Ledger of the Drowning: why the rift is here"
	lore.pressed.connect(open_codex)
	grid.add_child(lore)
	leave_btn = _pause_button("LEAVE TO HUB", Color(0.95, 0.55, 0.45))
	leave_btn.pressed.connect(_on_leave_pressed)
	grid.add_child(leave_btn)
	var back := _label("Every run is saved at each floor, each purchase and each relic.", 11, MUTED, false)
	back.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(back)


func _pause_button(text: String, color := AMBER) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(190, 40)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.8))
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.1, 0.04, 0.05, 0.95), color.darkened(0.55), 1, 2))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.2, 0.08, 0.07, 0.98), color, 1, 2))
	btn.add_theme_stylebox_override("pressed", _stylebox(Color(0.3, 0.1, 0.08, 1.0), color, 1, 2))
	return btn


func _close_pause_for_overlay() -> void:
	if pause_shade != null:
		pause_shade.visible = false
	if pause_panel != null:
		pause_panel.visible = false


## The same two-step confirmation pattern as the content buttons: one press
## arms it, a second press within four seconds leaves.
func _on_leave_pressed() -> void:
	if leave_btn == null:
		return
	var now := Time.get_ticks_msec()
	if leave_armed_ms > 0 and now - leave_armed_ms < 4000:
		leave_armed_ms = 0
		leave_btn.text = "LEAVE TO HUB"
		_close_pause_for_overlay()
		get_tree().paused = false
		leave_run_pressed.emit()
		return
	leave_armed_ms = now
	leave_btn.text = "CONFIRM LEAVE"
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func() -> void:
		if leave_armed_ms > 0 and Time.get_ticks_msec() - leave_armed_ms >= 3900:
			leave_armed_ms = 0
			if leave_btn != null:
				leave_btn.text = "LEAVE TO HUB"
	)


func _build_pause_button() -> void:
	var btn := Button.new()
	btn.text = "II"
	btn.tooltip_text = "Pause  (Esc)"
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.offset_left = -68.0
	btn.offset_right = -26.0
	btn.offset_top = 24.0
	btn.offset_bottom = 64.0
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", AMBER)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.65))
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.02, 0.04, 0.72), Color(0.42, 0.27, 0.12, 0.9), 1))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.92), Color(0.95, 0.62, 0.24, 1.0), 1))
	btn.button_down.connect(toggle_pause)
	body.add_child(btn)


func _build_settings_button() -> void:
	var btn := Button.new()
	settings_btn = btn
	btn.text = "SET"
	btn.tooltip_text = "Settings"
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.offset_left = -114.0
	btn.offset_right = -72.0
	btn.offset_top = 24.0
	btn.offset_bottom = 64.0
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", AMBER)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.65))
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.02, 0.04, 0.72), Color(0.42, 0.27, 0.12, 0.9), 1))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.92), Color(0.95, 0.62, 0.24, 1.0), 1))
	btn.pressed.connect(open_settings)
	btn.visible = false
	root.add_child(btn)


func _build_settings_window() -> void:
	settings_window = PanelContainer.new()
	settings_window.set_anchors_preset(Control.PRESET_CENTER)
	settings_window.anchor_left = 0.5
	settings_window.anchor_right = 0.5
	settings_window.anchor_top = 0.5
	settings_window.anchor_bottom = 0.5
	settings_window.offset_left = -340.0
	settings_window.offset_right = 340.0
	settings_window.offset_top = -192.0
	settings_window.offset_bottom = 192.0
	settings_window.add_theme_stylebox_override("panel", _stylebox(Color(0.035, 0.02, 0.04, 0.98), Color(0.55, 0.34, 0.14, 1.0), 2, 4))
	settings_window.visible = false
	settings_window.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(settings_window)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	settings_window.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	settings_tabs = HBoxContainer.new()
	settings_tabs.add_theme_constant_override("separation", 6)
	header.add_child(settings_tabs)
	for entry in [["AUDIO", "audio"], ["VIDEO", "video"], ["GAMEPLAY", "gameplay"], ["INTERFACE", "interface"]]:
		settings_tabs.add_child(_settings_tab_button(String(entry[0]), String(entry[1])))
	var spacer := Control.new()

	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var close := Button.new()
	close.text = "ESC"
	close.custom_minimum_size = Vector2(58, 30)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(close_settings)
	header.add_child(close)
	settings_body = VBoxContainer.new()
	settings_body.add_theme_constant_override("separation", 6)
	settings_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(settings_body)


func open_settings() -> void:
	if settings_window == null:
		return
	settings_open = true
	settings_window.visible = true
	settings_was_paused = get_tree().paused
	settings_from_pause = pause_panel != null and pause_panel.visible
	if settings_from_pause:
		pause_panel.visible = false
	get_tree().paused = true
	_build_settings_body()


func _build_boon_panel() -> void:
	boon_shade = ColorRect.new()
	boon_shade.color = Color(0.02, 0.0, 0.02, 0.66)
	boon_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	boon_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	boon_shade.visible = false
	root.add_child(boon_shade)
	boon_panel = PanelContainer.new()
	boon_panel.set_anchors_preset(Control.PRESET_CENTER)
	boon_panel.anchor_left = 0.5
	boon_panel.anchor_right = 0.5
	boon_panel.anchor_top = 0.5
	boon_panel.anchor_bottom = 0.5
	boon_panel.offset_left = -430.0
	boon_panel.offset_right = 430.0
	boon_panel.offset_top = -120.0
	boon_panel.offset_bottom = 120.0
	boon_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.012, 0.03, 0.97), Color(0.62, 0.36, 0.14, 1.0), 2, 4))
	boon_panel.visible = false
	boon_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(boon_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	boon_panel.add_child(box)
	var title := _label("THE RIFT YIELDS", 34, AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	boon_sub = _label("Claim one boon. It holds until you fall.", 14, MUTED)
	boon_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boon_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(boon_sub)
	boon_cards = HBoxContainer.new()
	boon_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	boon_cards.add_theme_constant_override("separation", 18)
	box.add_child(boon_cards)
	var hint := _label("Click a boon, or press 1 - 3.", 12, MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)


func _boon_card(entry: Dictionary) -> Button:
	var col: Color = entry.get("color", AMBER)
	var btn := Button.new()
	btn.text = "%s\n\n%s" % [str(entry.get("name", "BOON")), str(entry.get("text", ""))]
	btn.custom_minimum_size = Vector2(250, 132)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", BONE)
	btn.add_theme_color_override("font_hover_color", col)
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.07, 0.03, 0.05, 0.96), col, 2, 4))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.16, 0.07, 0.06, 0.99), col.lightened(0.3), 2, 4))
	btn.add_theme_stylebox_override("pressed", _stylebox(Color(0.24, 0.1, 0.08, 1.0), col.lightened(0.45), 2, 4))
	btn.pressed.connect(func() -> void: _choose_boon(String(entry.get("key", ""))))
	btn.set_meta("key", String(entry.get("key", "")))
	return btn


func show_boons(list: Array, warden_line := "", picks := 1) -> void:
	if boon_panel == null:
		return
	boon_picks = maxi(1, picks)
	if boon_sub != null:
		var prompt := "Claim one boon. It holds until you fall." if boon_picks <= 1 else "The rift yields twice at this depth. Choose two."
		boon_sub.text = warden_line if not warden_line.is_empty() else prompt
	for child in boon_cards.get_children():
		child.queue_free()
	boon_keys.clear()
	for entry in list:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		boon_keys.append(String(entry.get("key", "")))
		boon_cards.add_child(_boon_card(entry))
	boon_panel.visible = true
	boon_shade.visible = true
	boons_open = true
	if relic_window != null and relic_window.visible:
		close_relic_window()
	if shop_window != null and shop_window.visible:
		shop_open = false
		shop_window.visible = false
	get_tree().paused = true
	pause_shade.visible = false
	pause_panel.visible = false
	boon_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(boon_panel, "modulate:a", 1.0, 0.22)
	ui_click.emit()
	_kill_button_focus()


func _choose_boon(key: String) -> void:
	if not boons_open:
		return
	boon_chosen.emit(key)
	boon_picks -= 1
	if boon_picks > 0:
		for child in boon_cards.get_children():
			if child is Button and String(child.get_meta("key", "")) == key:
				(child as Button).disabled = true
		if boon_sub != null:
			boon_sub.text = "The rift yields again. Choose one more."
		return
	boons_open = false
	boon_panel.visible = false
	boon_shade.visible = false
	get_tree().paused = false


func hide_boons() -> void:
	if boon_panel == null:
		return
	boons_open = false
	boon_panel.visible = false
	if boon_shade != null:
		boon_shade.visible = false


func _build_prompt() -> void:
	prompt_label = _label("E  -  TRADE", 16, GOLD)
	prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_label.anchor_left = 0.5
	prompt_label.anchor_right = 0.5
	prompt_label.offset_left = -220.0
	prompt_label.offset_right = 220.0
	prompt_label.offset_top = -206.0
	prompt_label.offset_bottom = -178.0
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_label.visible = false
	body.add_child(prompt_label)


func show_prompt(text: String) -> void:
	if prompt_label == null:
		return
	prompt_label.text = text
	prompt_label.visible = text != ""


func hide_prompt() -> void:
	if prompt_label != null:
		prompt_label.visible = false


func _build_shop() -> void:
	shop_window = PanelContainer.new()
	shop_window.set_anchors_preset(Control.PRESET_CENTER)
	shop_window.anchor_left = 0.5
	shop_window.anchor_right = 0.5
	shop_window.anchor_top = 0.5
	shop_window.anchor_bottom = 0.5
	shop_window.offset_left = -392.0
	shop_window.offset_right = 392.0
	shop_window.offset_top = -250.0
	shop_window.offset_bottom = 250.0
	shop_window.add_theme_stylebox_override("panel", _stylebox(Color(0.035, 0.02, 0.03, 0.98), Color(0.66, 0.42, 0.16, 1.0), 2, 4))
	shop_window.visible = false
	shop_window.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shop_window)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	shop_window.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	box.add_child(header)
	shop_title = _label("THE ASHEN BROKER", 30, AMBER)
	header.add_child(shop_title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	shop_coins = _label("COIN  0", 17, GOLD)
	header.add_child(shop_coins)
	var close := Button.new()
	close.text = "ESC"
	close.custom_minimum_size = Vector2(58, 30)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(close_shop)
	header.add_child(close)
	shop_lore = _label("", 14, Color(0.8, 0.68, 0.56), false)
	shop_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(shop_lore)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	shop_body = VBoxContainer.new()
	shop_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_body.add_theme_constant_override("separation", 8)
	scroll.add_child(shop_body)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	box.add_child(footer)
	var hint := _label("Coin buys relics, boons and vitae. The gate stays open.", 12, MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(hint)
	var leave := Button.new()
	leave.text = "WALK ON  -  E"
	leave.custom_minimum_size = Vector2(150, 30)
	leave.add_theme_font_size_override("font_size", 12)
	leave.add_theme_color_override("font_color", AMBER)
	leave.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72))
	leave.add_theme_stylebox_override("normal", _stylebox(Color(0.08, 0.04, 0.04, 0.95), Color(0.42, 0.24, 0.1, 1.0), 1))
	leave.add_theme_stylebox_override("hover", _stylebox(Color(0.18, 0.07, 0.06, 0.98), Color(0.9, 0.55, 0.2, 1.0), 1))
	leave.pressed.connect(close_shop)
	footer.add_child(leave)


func show_shop(offers: Array, coin_count: int, layer_num: int, broker_line := "") -> void:
	if shop_window == null:
		return
	shop_open = true
	if relic_window != null and relic_window.visible:
		close_relic_window()
	if boons_open:
		hide_boons()
	shop_title.text = "THE ASHEN BROKER  -  LAYER %d" % layer_num
	if shop_lore != null:
		shop_lore.text = broker_line
	shop_window.visible = true
	shop_window.modulate.a = 0.0
	get_tree().paused = true
	if pause_shade != null:
		pause_shade.visible = false
	if pause_panel != null:
		pause_panel.visible = false
	update_shop(offers, coin_count)
	var tween := create_tween()
	tween.tween_property(shop_window, "modulate:a", 1.0, 0.22)


func update_shop(offers: Array, coin_count: int) -> void:
	if shop_window == null or not shop_window.visible:
		return
	shop_coins.text = "COIN  %d" % coin_count
	for child in shop_body.get_children():
		child.queue_free()
	for i in offers.size():
		var offer: Dictionary = offers[i]
		var color: Color = offer.get("color", BONE)
		var price := int(offer.get("price", 0))
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _stylebox(Color(0.055, 0.03, 0.045, 0.95), color.darkened(0.35), 1, 3))
		shop_body.add_child(row)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		row.add_child(line)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 1)
		line.add_child(info)
		var name_label := _label(String(offer.get("name", "Offer")), 16, color, false)
		info.add_child(name_label)
		var detail := _label(String(offer.get("detail", "")), 12, MUTED, false)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(detail)
		var price_label := _label("%d COIN" % price, 14, GOLD if coin_count >= price else Color(0.62, 0.3, 0.3), false)
		price_label.custom_minimum_size = Vector2(96, 0)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(price_label)
		var buy := Button.new()
		buy.text = "BUY"
		buy.custom_minimum_size = Vector2(74, 34)
		buy.add_theme_font_size_override("font_size", 13)
		buy.add_theme_color_override("font_color", AMBER)
		buy.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.76))
		buy.disabled = coin_count < price
		buy.add_theme_stylebox_override("normal", _stylebox(Color(0.1, 0.04, 0.05, 0.95), Color(0.5, 0.28, 0.1, 1.0), 1))
		buy.add_theme_stylebox_override("hover", _stylebox(Color(0.2, 0.08, 0.07, 0.98), Color(0.9, 0.55, 0.2, 1.0), 1))
		buy.add_theme_stylebox_override("pressed", _stylebox(Color(0.3, 0.1, 0.08, 1.0), Color(1.0, 0.7, 0.3, 1.0), 1))
		buy.pressed.connect(func() -> void: shop_buy.emit(i))
		line.add_child(buy)
	_kill_button_focus()


func close_shop() -> void:
	if shop_window == null:
		return
	shop_open = false
	shop_window.visible = false
	get_tree().paused = false
	shop_close.emit()


func close_settings() -> void:
	if settings_window == null:
		return
	settings_open = false
	settings_window.visible = false
	get_tree().paused = settings_was_paused
	if settings_from_pause and pause_panel != null:
		pause_panel.visible = settings_was_paused
		if pause_shade != null:
			pause_shade.visible = settings_was_paused
	settings_from_pause = false


func _select_settings_tab(tab: String) -> void:
	settings_tab = tab
	_build_settings_body()


func _settings_tab_button(text: String, tab: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(126, 32)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", MUTED)
	btn.add_theme_color_override("font_hover_color", AMBER)
	btn.add_theme_color_override("font_pressed_color", GOLD)
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.06, 0.03, 0.05, 0.92), Color(0.24, 0.16, 0.12, 1.0), 1))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.14, 0.07, 0.06, 0.96), Color(0.7, 0.45, 0.16, 1.0), 1))
	btn.add_theme_stylebox_override("pressed", _stylebox(Color(0.2, 0.09, 0.07, 1.0), Color(1.0, 0.65, 0.25, 1.0), 1))
	btn.set_meta("tab", tab)
	btn.pressed.connect(_select_settings_tab.bind(tab))
	return btn


func _settings_row(label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var name_label := _label(label_text, 15, BONE, false)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	return row


func _add_slider(label_text: String, key: String, minv: float, maxv: float, step: float, suffix := "") -> void:
	var row := _settings_row(label_text)
	var value := float(GameSettings.get_value(key))
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(210, 26)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.min_value = minv
	slider.max_value = maxv
	slider.step = step
	slider.value = value
	var value_label := _label(_format_value(value, key, suffix), 13, GOLD, false)
	value_label.custom_minimum_size = Vector2(96, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(slider)
	row.add_child(value_label)
	settings_body.add_child(row)
	slider.value_changed.connect(func(v: float) -> void:
		GameSettings.set_value(key, v)
		GameSettings.persist_now()
		value_label.text = _format_value(v, key, suffix)
		_apply_ui_settings()
		settings_changed.emit()
	)


func _add_toggle(label_text: String, key: String) -> void:
	var row := _settings_row(label_text)
	var check := CheckButton.new()
	check.button_pressed = bool(GameSettings.get_value(key))
	check.custom_minimum_size = Vector2(210, 30)
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(check)
	settings_body.add_child(row)
	check.toggled.connect(func(on: bool) -> void:
		GameSettings.set_value(key, on)
		GameSettings.persist_now()
		_apply_ui_settings()
		settings_changed.emit()
	)


func _format_value(value: float, key: String, suffix: String) -> String:
	if key == "fps_cap":
		return "UNLIMITED" if value <= 0.0 else "%d FPS" % int(value)
	if key == "brightness" or key == "camera_zoom" or key == "hud_scale":
		return "%d%%" % int(round(value * 100.0))
	return "%d%s" % [int(round(value * 100.0)), suffix]


func _build_settings_body() -> void:
	if settings_body == null:
		return
	_clear_children(settings_body)
	if settings_tabs != null:
		for btn in settings_tabs.get_children():
			if btn is Button:
				var active := String(btn.get_meta("tab", "")) == settings_tab
				btn.add_theme_color_override("font_color", GOLD if active else MUTED)
				btn.add_theme_stylebox_override("normal", _stylebox(
					Color(0.16, 0.07, 0.05, 0.96) if active else Color(0.06, 0.03, 0.05, 0.92),
					Color(0.95, 0.6, 0.22, 1.0) if active else Color(0.24, 0.16, 0.12, 1.0), 1))
	match settings_tab:
		"audio":
			settings_body.add_child(_label("Audio is applied immediately.", 12, MUTED, false))
			_add_slider("Master Volume", "master", 0.0, 1.0, 0.05, "%")
			_add_slider("Music Volume", "music", 0.0, 1.0, 0.05, "%")
			_add_slider("Ambience", "ambience", 0.0, 1.0, 0.05, "%")
			_add_slider("Effects Volume", "sfx", 0.0, 1.0, 0.05, "%")
		"video":
			settings_body.add_child(_label("Display and camera.", 12, MUTED, false))
			_add_toggle("Fullscreen", "fullscreen")
			_add_toggle("Vertical Sync", "vsync")
			_add_slider("Brightness", "brightness", 0.75, 1.35, 0.05, "%")
			_add_slider("Camera Distance", "camera_zoom", 0.8, 1.3, 0.05, "%")
			_add_slider("Frame Rate Cap", "fps_cap", 0.0, 240.0, 30.0, " FPS")
		"gameplay":
			settings_body.add_child(_label("Combat and controls.", 12, MUTED, false))
			_add_toggle("Screen Shake", "shake")
			_add_toggle("Damage Numbers", "damage_numbers")
			_add_toggle("Enemy Health Bars", "enemy_health")
			_add_toggle("Hold Mouse to Move", "hold_move")
			_add_toggle("Show Rift Modifiers", "modifiers")
		"interface":
			settings_body.add_child(_label("HUD and readouts.", 12, MUTED, false))
			_add_slider("HUD Scale", "hud_scale", 0.85, 1.15, 0.05, "%")
			_add_toggle("Rift Minimap", "minimap")
			_add_toggle("Announcement Toasts", "toasts")
			_add_toggle("Save Settings Automatically", "persist")
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	settings_body.add_child(footer)
	var reset := Button.new()
	reset.text = "RESET DEFAULTS"
	reset.custom_minimum_size = Vector2(170, 34)
	reset.add_theme_font_size_override("font_size", 13)
	reset.add_theme_color_override("font_color", CRIMSON)
	reset.add_theme_color_override("font_hover_color", Color(1.0, 0.75, 0.65))
	reset.add_theme_stylebox_override("normal", _stylebox(Color(0.08, 0.03, 0.04, 0.95), Color(0.45, 0.18, 0.14, 1.0), 1))
	reset.add_theme_stylebox_override("hover", _stylebox(Color(0.16, 0.06, 0.05, 0.98), Color(0.95, 0.45, 0.25, 1.0), 1))
	reset.pressed.connect(reset_settings)
	footer.add_child(reset)
	var save := Button.new()
	save.text = "SAVE SETTINGS"
	save.custom_minimum_size = Vector2(170, 34)
	save.add_theme_font_size_override("font_size", 13)
	save.add_theme_color_override("font_color", GOLD)
	save.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.76))
	save.add_theme_stylebox_override("normal", _stylebox(Color(0.1, 0.05, 0.04, 0.95), Color(0.55, 0.36, 0.12, 1.0), 1))
	save.add_theme_stylebox_override("hover", _stylebox(Color(0.2, 0.09, 0.05, 0.98), Color(0.95, 0.62, 0.24, 1.0), 1))
	save.pressed.connect(save_settings_now)
	footer.add_child(save)
	if settings_window != null:
		var panel_height: float = settings_body.get_combined_minimum_size().y + 78.0
		panel_height = clampf(panel_height, 300.0, 560.0)
		settings_window.offset_top = -panel_height * 0.5
		settings_window.offset_bottom = panel_height * 0.5
	_kill_button_focus()


func reset_settings() -> void:
	GameSettings.reset_all()
	_apply_ui_settings()
	settings_changed.emit()
	_build_settings_body()
	toast("SETTINGS RESTORED TO DEFAULTS", GOLD, 2.0)


func save_settings_now() -> void:
	GameSettings.save_all()
	toast("SETTINGS SAVED", GOLD, 1.8)


func _apply_ui_settings() -> void:
	if root != null:
		var scale_value := float(GameSettings.get_value("hud_scale"))
		root.scale = Vector2.ONE * scale_value
		root.pivot_offset = root.get_viewport_rect().size * 0.5
	if minimap_panel != null:
		minimap_panel.visible = bool(GameSettings.get_value("minimap"))
	if toast_box != null:
		toast_box.visible = bool(GameSettings.get_value("toasts"))
	if mod_row != null:
		mod_row.visible = bool(GameSettings.get_value("modifiers")) and not current_mods.is_empty()


## One multiplayer surface, used by the home screen and the pause menu. It is
## the same panel and the same callbacks in both places, so there is only one
## set of matchmaking/party controls to keep working.
func _build_net_panel() -> void:
	net_panel = PanelContainer.new()
	net_panel.set_anchors_preset(Control.PRESET_CENTER)
	net_panel.anchor_left = 0.5
	net_panel.anchor_right = 0.5
	net_panel.anchor_top = 0.5
	net_panel.anchor_bottom = 0.5
	net_panel.offset_left = -330.0
	net_panel.offset_right = 330.0
	net_panel.offset_top = -232.0
	net_panel.offset_bottom = 78.0
	net_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.015, 0.045, 0.98), Color(0.55, 0.35, 0.72, 1.0), 2, 5))
	net_panel.visible = false
	net_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(net_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	net_panel.add_child(box)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)
	net_title = _label("CO-OP ONLINE", 32, AMBER)
	net_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(net_title)
	var close := Button.new()
	close.text = "ESC"
	close.custom_minimum_size = Vector2(58, 30)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(hide_net_panel)
	header.add_child(close)
	net_status = _label("CHECKING CONNECTION", 15, GOLD, false)
	box.add_child(net_status)
	net_detail = _label("", 13, BONE, false)
	net_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(net_detail)
	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(0, 10)
	box.add_child(rule)
	net_party_box = VBoxContainer.new()
	net_party_box.add_theme_constant_override("separation", 3)
	box.add_child(net_party_box)
	var rule2 := HSeparator.new()
	rule2.custom_minimum_size = Vector2(0, 6)
	box.add_child(rule2)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	box.add_child(actions)
	var find_btn := _net_button("FIND MATCH", AMBER)
	find_btn.pressed.connect(func() -> void:
		ui_click.emit()
		net_action.emit("find", net_mode)
	)
	actions.add_child(find_btn)
	var duel_btn := _net_button("DUEL THE MIRROR", Color(0.85, 0.55, 1.0))
	duel_btn.name = "NetDuel"
	duel_btn.pressed.connect(func() -> void:
		ui_click.emit()
		hide_net_panel()
		net_action.emit("duel", "pvp")
	)
	actions.add_child(duel_btn)
	var hint := _label("Online play runs on a headless Summer authority. Local testing: Debug > Local Multiplayer > 2 Players.", 11, MUTED, false)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)
	_kill_button_focus()


func _net_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(190, 44)
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.85))
	btn.add_theme_stylebox_override("normal", _stylebox(Color(0.09, 0.05, 0.11, 0.96), color.darkened(0.45), 1, 3))
	btn.add_theme_stylebox_override("hover", _stylebox(Color(0.17, 0.09, 0.2, 0.99), color, 1, 3))
	return btn


func show_net_panel(mode: String) -> void:
	if net_panel == null:
		return
	if rift_map_panel != null and rift_map_panel.visible:
		rift_map_panel.visible = false
	net_mode = mode
	net_title.text = "PVP ARENA" if mode == "pvp" else "CO-OP ONLINE"
	var duel := net_panel.find_child("NetDuel", true, false) as Button
	if duel != null:
		duel.visible = mode == "pvp"
	net_panel.visible = true
	net_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(net_panel, "modulate:a", 1.0, 0.16)


func hide_net_panel() -> void:
	if net_panel != null:
		net_panel.visible = false
	if body.visible:
		get_tree().paused = false


## Called by the game with the real connection state; never faked.
## The created character's name and class, shown above the level readout.
func set_hero(name_text: String, class_text: String) -> void:
	if hero_name_label == null:
		return
	hero_name_label.text = name_text.to_upper() if not name_text.is_empty() else ""
	if hero_class_label != null:
		hero_class_label.text = class_text.to_upper() if not class_text.is_empty() else ""


## Swap the ability bar to a class: labels, costs, mouse hints, icons, accent.
func apply_class(data: Dictionary) -> void:
	active_class = data
	var list: Array = data.get("abilities", [])
	var is_health := String(data.get("cost_kind", "health")) == "health"
	var noun := "VITAE" if is_health else String(data.get("focus_name", "FOCUS"))
	var accent: Color = data.get("color", AMBER)
	var primary := int(data.get("primary", 0))
	var secondary := int(data.get("secondary", 1))
	for i in mini(list.size(), 3):
		if i >= slots.size():
			break
		var ability: Dictionary = list[i]
		var slot: Dictionary = slots[i]
		slot["name"].text = String(ability.get("glyph", ""))
		var cost := float(ability.get("cost", 0.0))
		slot["cost"].text = "FREE" if cost <= 0.0 else "%d %s" % [int(cost), noun]
		slot["cost"].add_theme_color_override("font_color", CRIMSON if is_health else accent)
		var icon_path := String(ability.get("icon", ""))
		if slot["icon"] != null and not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			slot["icon"].texture = load(icon_path)
		if slot["accent"] != null:
			slot["accent"].color = Color(accent.r, accent.g, accent.b, 0.85)
		if slot["hint"] != null:
			slot["hint"].text = "LMB" if i == primary else ("RMB" if i == secondary else "")
	if dash_action_label != null:
		dash_action_label.text = String(data.get("dash", "RIFTSTEP")).to_upper()
	if controls_hint != null:
		var primary_key := String(list[primary].get("glyph", "PRIMARY")) if primary < list.size() else "PRIMARY"
		var secondary_key := String(list[secondary].get("glyph", "SECONDARY")) if secondary < list.size() else "SECONDARY"
		controls_hint.text = "WASD MOVE  ·  LMB %s  ·  RMB %s  ·  1 2 3 CAST  ·  SPACE %s  ·  TAB RELICS  ·  K PASSIVES  ·  M MAP" % [
			primary_key, secondary_key, String(data.get("dash", "DASH")).to_upper()]
	if focus_row != null:
		focus_row.visible = not is_health


func set_focus(value: float, maximum: float, label_text: String, color: Color) -> void:
	if focus_row == null or focus_bar == null:
		return
	if maximum <= 0.0:
		focus_row.visible = false
		return
	focus_row.visible = true
	focus_bar.max_value = maximum
	focus_bar.value = clampf(value, 0.0, maximum)
	if focus_label != null:
		focus_label.text = "%s  %d / %d" % [label_text, int(value), int(maximum)]
		focus_label.add_theme_color_override("font_color", color.lightened(0.3))
	if color != focus_color_now:
		focus_color_now = color
		focus_fill.bg_color = color


func set_net_status(status_text: String, detail_text: String, ok: bool) -> void:
	if net_status == null:
		return
	net_status.text = status_text
	net_status.add_theme_color_override("font_color", Color(0.62, 0.95, 0.72) if ok else Color(1.0, 0.62, 0.4))
	net_detail.text = detail_text


## The party roster. Only what the client actually knows is shown: your own
## character from local save data, then one chip per peer entity the Summer
## World has spawned on this client. No invented names or fake lobbies.
func set_party_roster(self_name: String, self_class: String, self_level: int, self_layer: int, peers: int) -> void:
	if net_party_box == null:
		return
	for child in net_party_box.get_children():
		child.queue_free()
	var members := maxi(1, peers)
	var head := _label("RIFT PARTY  -  %d MEMBER%s" % [members, "" if members == 1 else "S"], 12, MUTED, false)
	net_party_box.add_child(head)
	var color: Color = HeroClasses.color(String(self_class).to_lower().replace(" ", "_"))
	var you := _label("1   %s  -  %s  -  LV %d  -  LAYER %d" % [self_name.to_upper(), self_class.to_upper(), self_level, self_layer], 13, color, false)
	net_party_box.add_child(you)
	for i in range(1, members):
		var peer := _label("%d   RIFT RUNNER  -  CONNECTED" % (i + 1), 13, Color(0.66, 0.62, 0.7), false)
		net_party_box.add_child(peer)
	if peers <= 1:
		var solo := _label("No other runners in this World yet.", 11, Color(0.5, 0.46, 0.5), false)
		net_party_box.add_child(solo)


## Create-character: three playable classes plus the unwritten fourth seat,
const CLASS_SEATS := [
	{"key": "blood_sorceress", "name": "BLOOD SORCERESS", "role": "Life is the fuel",
		"default_name": "VESNA",
		"pose_clip": "Charged_Spell_Cast", "pose_at": 0.42,
		"text": "She burns her own blood to cast. Every spell is a decision about how much of herself she is willing to spend.",
		"seal": "", "color": Color(0.95, 0.3, 0.32), "playable": true,
		"model": "res://art/generated/blood_sorceress/character.tscn", "model_scale": 1.35,
		"portrait": "res://art/portraits/blood_sorceress.png"},
	{"key": "iron_paladin", "name": "IRON PALADIN", "role": "The wall that walks",
		"default_name": "ARDEN",
		"pose_clip": "Attack", "pose_at": 0.34,
		"text": "A knight in rift-scarred plate, carrying the last lit sun of a drowned city. He holds the line so the others can breathe, and he does not move when the ground does.",
		"seal": "SECOND SEAT", "color": Color(0.78, 0.72, 0.5), "playable": true,
		"model": "res://art/generated/iron_paladin/character.tscn", "model_scale": 1.0,
		"portrait": "res://art/portraits/iron_paladin.png"},
	{"key": "shadow_huntress", "name": "SHADOW HUNTRESS", "role": "Nothing is out of range",
		"default_name": "SERA",
		"pose_clip": "Attack", "pose_at": 0.40,
		"text": "She hunts what the rift lets loose and she never lets it close. Her arrows remember every name the seam has taken, and she says them out loud before she fires.",
		"seal": "THIRD SEAT", "color": Color(0.55, 0.8, 0.75), "playable": true,
		"model": "res://art/generated/shadow_huntress/character.tscn", "model_scale": 1.0,
		"portrait": "res://art/portraits/shadow_huntress.png"},
	{"key": "fourth_seat", "name": "THE FOURTH SEAT", "role": "Unwritten",
		"default_name": "UNNAMED",
		"text": "The rift has room for one more. Nobody has come back up to say who it is, only that the seat is warm.",
		"seal": "FOURTH SEAT  ·  UNWRITTEN", "color": Color(0.62, 0.5, 0.7), "playable": false,
		"model": "", "model_scale": 1.0, "portrait": ""},
]


func _build_creator() -> void:
	creator_panel = Control.new()
	creator_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	creator_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	creator_panel.visible = false
	root.add_child(creator_panel)
	var shade := ColorRect.new()
	shade.color = Color(0.008, 0.004, 0.012, 0.9)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	creator_panel.add_child(shade)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -470.0
	card.offset_right = 470.0
	card.offset_top = -290.0
	card.offset_bottom = 290.0
	card.add_theme_stylebox_override("panel", _stylebox(Color(0.028, 0.014, 0.032, 0.98), Color(0.5, 0.32, 0.14, 1.0), 2, 5))
	creator_panel.add_child(card)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	card.add_child(outer)
	var head := HBoxContainer.new()
	outer.add_child(head)
	var title := _label("CREATE YOUR CHARACTER", 34, AMBER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var back := Button.new()
	back.text = "BACK"
	back.custom_minimum_size = Vector2(80, 30)
	back.add_theme_font_size_override("font_size", 12)
	back.add_theme_color_override("font_color", MUTED)
	back.add_theme_color_override("font_hover_color", AMBER)
	back.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	back.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	back.pressed.connect(hide_creator)
	head.add_child(back)
	var sub := _label("THREE SEATS ARE OPEN  ·  ONE REMAINS SEALED", 11, CRIMSON)
	outer.add_child(sub)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 18)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(columns)
	var classes := VBoxContainer.new()
	classes.add_theme_constant_override("separation", 6)
	classes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(classes)
	for seat in CLASS_SEATS:
		classes.add_child(_class_card(seat))
	var filler := PanelContainer.new()
	filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
	filler.add_theme_stylebox_override("panel", _stylebox(Color(0.035, 0.018, 0.03, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1, 2))
	classes.add_child(filler)
	var fbox := VBoxContainer.new()
	fbox.alignment = BoxContainer.ALIGNMENT_CENTER
	fbox.add_theme_constant_override("separation", 4)
	filler.add_child(fbox)
	fbox.add_child(_label("THE OTHER SEATS", 11, GOLD))
	var fbody := _label("The Blood Sorceress pays in vitae. The Iron Paladin holds the line behind a sunlit shield. The Shadow Huntress kills from beyond the seam with focus and speed. One seat is still unwritten, and the rift has not given up its name.\n\nClick any seat to read it and see it turn.", 12, BONE, false)
	fbody.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fbox.add_child(fbody)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(340, 0)
	right.add_theme_constant_override("separation", 8)
	columns.add_child(right)
	right.add_child(_build_creator_preview())
	creator_name = LineEdit.new()
	creator_name.text = "VESNA"
	creator_name.placeholder_text = "NAME"
	creator_name.max_length = 16
	creator_name.custom_minimum_size = Vector2(0, 40)
	creator_name.add_theme_font_size_override("font_size", 18)
	creator_name.add_theme_color_override("font_color", BONE)
	creator_name.add_theme_color_override("font_placeholder_color", Color(0.45, 0.4, 0.42))
	creator_name.add_theme_stylebox_override("normal", _stylebox(Color(0.06, 0.03, 0.04, 0.96), Color(0.5, 0.3, 0.14, 1.0), 1, 3))
	creator_name.add_theme_stylebox_override("focus", _stylebox(Color(0.09, 0.045, 0.05, 0.98), Color(1.0, 0.7, 0.3, 1.0), 1, 3))
	right.add_child(creator_name)
	var create := Button.new()
	create.text = "ENTER THE RIFT"
	create.custom_minimum_size = Vector2(0, 46)
	create.add_theme_font_size_override("font_size", 18)
	create.add_theme_color_override("font_color", AMBER)
	create.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.8))
	create.add_theme_stylebox_override("normal", _stylebox(Color(0.15, 0.06, 0.05, 0.97), Color(0.6, 0.34, 0.13, 1.0), 1, 3))
	create.add_theme_stylebox_override("hover", _stylebox(Color(0.26, 0.11, 0.07, 0.99), Color(1.0, 0.68, 0.24, 1.0), 1, 3))
	create.pressed.connect(_confirm_character)
	creator_create_btn = create
	right.add_child(create)
	creator_lore = _label("", 13, BONE, false)
	creator_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	creator_lore.custom_minimum_size = Vector2(0, 54)
	outer.add_child(creator_lore)
	_set_creator_class("blood_sorceress")


func _class_card(seat: Dictionary) -> Control:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 78)
	var color: Color = seat.get("color", BONE)
	var playable := bool(seat.get("playable", false))
	var portrait := String(seat.get("portrait", ""))
	var has_art := not portrait.is_empty() and ResourceLoader.exists(portrait)
	var normal_box := _stylebox(Color(0.05, 0.028, 0.035, 0.95), color.darkened(0.6) if playable else Color(0.26, 0.22, 0.26), 1, 3)
	var hover_box := _stylebox(Color(0.11, 0.05, 0.05, 0.98), color if playable else Color(0.34, 0.3, 0.34), 1, 3)
	normal_box.content_margin_left = 10.0
	hover_box.content_margin_left = 10.0
	btn.add_theme_stylebox_override("normal", normal_box)
	btn.add_theme_stylebox_override("hover", hover_box)
	# The row is a real layout, not button text: the portrait can never sit on
	# top of the class name at any UI scale.
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 12.0
	row.offset_right = -12.0
	row.offset_top = 7.0
	row.offset_bottom = -7.0
	row.add_theme_constant_override("h_separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row)
	if has_art:
		var tex: Variant = load(portrait)
		if tex is Texture2D:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(170.0, 60.0, 560.0, 660.0)
			var tile := TextureRect.new()
			tile.texture = atlas
			tile.custom_minimum_size = Vector2(50, 64)
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.modulate = Color(1, 1, 1, 1) if playable else Color(0.72, 0.68, 0.7, 1.0)
			row.add_child(tile)
	var info := VBoxContainer.new()
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_theme_constant_override("separation", 1)
	row.add_child(info)
	var name_label := _label(String(seat.get("name", "")), 15, color if playable else Color(0.62, 0.57, 0.59), false)
	info.add_child(name_label)
	var sub := String(seat.get("role", "")) + ("" if playable else "   ·   SEALED")
	var role_label := _label(sub, 11, Color(0.86, 0.78, 0.66) if playable else Color(0.5, 0.46, 0.48), false)
	info.add_child(role_label)
	btn.mouse_entered.connect(func() -> void:
		name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	)
	btn.mouse_exited.connect(func() -> void:
		name_label.add_theme_color_override("font_color", color if playable else Color(0.62, 0.57, 0.59))
	)
	btn.pressed.connect(_set_creator_class.bind(String(seat.get("key", ""))))
	return btn


func _build_creator_preview() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(340, 300)
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", _stylebox(Color(0.02, 0.012, 0.022, 0.95), Color(0.34, 0.24, 0.34, 1.0), 1, 3))
	var stage_box := Control.new()
	stage_box.custom_minimum_size = Vector2(336, 296)
	stage_box.clip_contents = true
	stage_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(stage_box)
	var holder := SubViewportContainer.new()
	holder.stretch = true
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_box.add_child(holder)
	creator_scene_holder = holder
	var viewport := SubViewport.new()
	viewport.size = Vector2i(336, 296)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	holder.add_child(viewport)
	var stage := Node3D.new()
	viewport.add_child(stage)
	creator_stage = stage
	var cam := Camera3D.new()
	cam.fov = 32.0
	cam.look_at_from_position(Vector3(0.0, 1.2, 4.6), Vector3(0.0, 0.95, 0.0), Vector3.UP)
	stage.add_child(cam)
	var key := OmniLight3D.new()
	key.light_color = Color(1.0, 0.82, 0.7)
	key.light_energy = 5.0
	key.omni_range = 9.0
	key.position = Vector3(1.6, 3.0, 2.4)
	stage.add_child(key)
	var rim := OmniLight3D.new()
	rim.light_color = Color(0.72, 0.5, 1.0)
	rim.light_energy = 4.0
	rim.omni_range = 8.0
	rim.position = Vector3(-2.0, 2.4, -2.2)
	stage.add_child(rim)
	creator_portrait = TextureRect.new()
	creator_portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	creator_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creator_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	creator_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	creator_portrait.visible = false
	stage_box.add_child(creator_portrait)
	creator_glyph = _label("?", 96, Color(0.5, 0.42, 0.55))
	creator_glyph.set_anchors_preset(Control.PRESET_FULL_RECT)
	creator_glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	creator_glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	creator_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	creator_glyph.visible = false
	stage_box.add_child(creator_glyph)
	creator_hint = _label("", 10, GOLD)
	creator_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	creator_hint.offset_top = -30.0
	creator_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	creator_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	creator_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	creator_hint.visible = false
	stage_box.add_child(creator_hint)
	return frame


func _set_creator_class(key: String) -> void:
	if key.is_empty():
		return
	for seat in CLASS_SEATS:
		if String(seat.get("key", "")) == key:
			creator_class = key
			creator_locked = not bool(seat.get("playable", false))
			creator_lore.text = String(seat.get("text", ""))
			if creator_name != null:
				var current := creator_name.text.strip_edges()
				var is_default := current.is_empty()
				for other in CLASS_SEATS:
					if current.to_upper() == String(other.get("default_name", "")).to_upper():
						is_default = true
				if is_default:
					creator_name.text = String(seat.get("default_name", "VESNA"))
			_preview_class(seat)
			if creator_hint != null:
				creator_hint.text = String(seat.get("seal", ""))
				creator_hint.visible = creator_locked and not creator_hint.text.is_empty()
			if creator_create_btn != null:
				creator_create_btn.disabled = creator_locked
				creator_create_btn.text = "ENTER THE RIFT" if not creator_locked else "CLASS SEALED"
			return


## Swap the 3D turntable to the selected class. A class without a model yet
## shows its concept portrait, and the unnamed seat shows its mark.
func _preview_class(seat: Dictionary) -> void:
	if creator_stage == null:
		return
	if creator_preview != null and is_instance_valid(creator_preview):
		creator_preview.queue_free()
	creator_preview = null
	var path := String(seat.get("model", "res://art/generated/blood_sorceress/character.tscn"))
	var has_model := ResourceLoader.exists(path)
	if has_model:
		var scene: Variant = load(path)
		if scene is PackedScene:
			creator_preview = (scene as PackedScene).instantiate()
			creator_preview.rotation.y = 0.0
			creator_stage.add_child(creator_preview)
			HandGrip.dress(creator_preview, String(seat.get("key", "")), 1.0, seat.get("glove", Color(0.22, 0.18, 0.18)))
			var box := _preview_bounds(creator_preview)
			var height := maxf(0.4, box.size.y)
			var fit := 1.72 / height
			creator_preview.scale = Vector3.ONE * fit
			var centre := box.get_center()
			creator_preview.position = Vector3(-centre.x * fit, -box.position.y * fit + 0.04, -centre.z * fit)
			var idle_anim := creator_preview.find_child("AnimationPlayer", true, false) as AnimationPlayer
			if idle_anim != null:
				idle_anim.stop()
			var skeleton := HandGrip.find_skeleton(creator_preview)
			HeroPose.stance(skeleton, String(seat.get("key", "")))
	var portrait := String(seat.get("portrait", ""))
	var show_portrait := not has_model and not portrait.is_empty() and ResourceLoader.exists(portrait)
	if creator_scene_holder != null:
		creator_scene_holder.visible = has_model
	if creator_portrait != null:
		creator_portrait.visible = show_portrait
		if show_portrait:
			creator_portrait.texture = load(portrait)
	if creator_glyph != null:
		creator_glyph.visible = not has_model and not show_portrait


## Bounds of every mesh in a freshly built preview, measured in the preview's
## own space so the turntable can centre and fit it exactly.
func _preview_bounds(node: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var to_local := node.global_transform.affine_inverse()
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if mesh == null or mesh.mesh == null:
			continue
		var box := (to_local * mesh.global_transform) * mesh.get_aabb()
		if first:
			result = box
			first = false
		else:
			result = result.merge(box)
	var skeleton := HandGrip.find_skeleton(node)
	if skeleton != null:
		for i in skeleton.get_bone_count():
			var point := to_local * (skeleton.global_transform * skeleton.get_bone_global_rest(i).origin)
			var dot := AABB(point - Vector3(0.02, 0.0, 0.02), Vector3(0.04, 0.0, 0.04))
			if first:
				result = dot
				first = false
			else:
				result = result.merge(dot)
	return result


func show_creator() -> void:
	if creator_panel == null:
		return
	if not creator_panel.visible:
		_set_creator_class("blood_sorceress")
	creator_panel.visible = true
	creator_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(creator_panel, "modulate:a", 1.0, 0.22)
	if creator_name != null:
		creator_name.grab_focus()


func hide_creator() -> void:
	if creator_panel != null:
		creator_panel.visible = false
	if creator_name != null:
		creator_name.release_focus()


func _confirm_character() -> void:
	if creator_locked:
		return
	var hero := creator_name.text.strip_edges() if creator_name != null else ""
	if hero.is_empty():
		hero = "VESNA"
	hide_creator()
	character_created.emit(hero.to_upper(), creator_class)


func _process_creator(delta: float) -> void:
	if creator_panel != null and creator_panel.visible and creator_preview != null:
		creator_preview.rotation.y += delta * 0.5


## The opening of a new run: what the lava is and why she went down.
func _build_story_card() -> void:
	story_panel = PanelContainer.new()
	story_panel.set_anchors_preset(Control.PRESET_CENTER)
	story_panel.offset_left = -372.0
	story_panel.offset_right = 372.0
	story_panel.offset_top = -186.0
	story_panel.offset_bottom = 186.0
	story_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.02, 0.01, 0.024, 0.98), Color(0.5, 0.3, 0.13, 1.0), 2, 5))
	story_panel.visible = false
	story_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(story_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	story_panel.add_child(box)
	story_title = _label("THE DROWNING", 24, AMBER)
	story_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(story_title)
	story_scroll = ScrollContainer.new()
	story_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	story_scroll.custom_minimum_size = Vector2(0, 226)
	story_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(story_scroll)
	story_body_box = VBoxContainer.new()
	story_body_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	story_body_box.add_theme_constant_override("separation", 7)
	story_scroll.add_child(story_body_box)
	var begin := Button.new()
	begin.text = "DESCEND"
	begin.custom_minimum_size = Vector2(190, 38)
	begin.add_theme_font_size_override("font_size", 15)
	begin.add_theme_color_override("font_color", AMBER)
	begin.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.8))
	begin.add_theme_stylebox_override("normal", _stylebox(Color(0.14, 0.06, 0.05, 0.97), Color(0.55, 0.3, 0.12, 1.0), 1, 3))
	begin.add_theme_stylebox_override("hover", _stylebox(Color(0.24, 0.1, 0.07, 0.99), Color(1.0, 0.66, 0.24, 1.0), 1, 3))
	begin.pressed.connect(close_story)
	var center := CenterContainer.new()
	center.add_child(begin)
	box.add_child(center)


func show_story(title_text: String, body_text: String) -> void:
	if story_panel == null:
		return
	story_title.text = title_text
	if story_body_box != null:
		for child in story_body_box.get_children():
			child.queue_free()
		var clean := body_text.replace("\r\n", "\n").replace("\r", "\n")
		for paragraph in clean.split("\n\n", false):
			var text := String(paragraph).strip_edges()
			if text.is_empty():
				continue
			var line := _label(text, 13, BONE, false)
			line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			story_body_box.add_child(line)
	if story_scroll != null:
		story_scroll.set_deferred("scroll_vertical", 0)
	story_panel.visible = true
	story_panel.modulate.a = 0.0
	get_tree().paused = true
	var tween := create_tween()
	tween.tween_property(story_panel, "modulate:a", 1.0, 0.5)


func close_story() -> void:
	if story_panel == null or not story_panel.visible:
		return
	story_panel.visible = false
	get_tree().paused = false
	story_closed.emit()


## The full codex page, opened from the pause menu. Same data as the title's
## HALL of Wardens, so the two never drift apart.
func _build_codex() -> void:
	codex_panel = PanelContainer.new()
	codex_panel.set_anchors_preset(Control.PRESET_CENTER)
	codex_panel.offset_left = -400.0
	codex_panel.offset_right = 400.0
	codex_panel.offset_top = -286.0
	codex_panel.offset_bottom = 286.0
	codex_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.022, 0.011, 0.026, 0.98), Color(0.5, 0.3, 0.13, 1.0), 2, 5))
	codex_panel.visible = false
	codex_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(codex_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	codex_panel.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var kicker := _label("THE LEDGER OF THE DROWNING  ·  %d PAGES" % LORE_BOOK.size(), 11, GOLD)
	kicker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(kicker)
	var close := Button.new()
	close.text = "CLOSE"
	close.custom_minimum_size = Vector2(78, 30)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(close_codex)
	head.add_child(close)
	codex_title = _label("", 30, AMBER)
	box.add_child(codex_title)
	var rule := HSeparator.new()
	rule.custom_minimum_size = Vector2(0, 4)
	box.add_child(rule)
	codex_body = _label("", 14, BONE, false)
	codex_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(codex_body)
	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_CENTER
	foot.add_theme_constant_override("separation", 14)
	box.add_child(foot)
	var prev := Button.new()
	prev.text = "PREV"
	prev.custom_minimum_size = Vector2(92, 34)
	prev.add_theme_font_size_override("font_size", 13)
	prev.add_theme_color_override("font_color", MUTED)
	prev.add_theme_color_override("font_hover_color", AMBER)
	prev.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.028, 0.035, 0.95), Color(0.3, 0.2, 0.14, 1.0), 1, 2))
	prev.add_theme_stylebox_override("hover", _stylebox(Color(0.12, 0.06, 0.06, 0.98), Color(0.9, 0.58, 0.24, 1.0), 1, 2))
	prev.pressed.connect(func() -> void: _set_codex_page(codex_page - 1))
	foot.add_child(prev)
	codex_page_label = _label("1 / %d" % LORE_BOOK.size(), 12, MUTED)
	codex_page_label.custom_minimum_size = Vector2(70, 20)
	codex_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_child(codex_page_label)
	var next := Button.new()
	next.text = "NEXT"
	next.custom_minimum_size = Vector2(92, 34)
	next.add_theme_font_size_override("font_size", 13)
	next.add_theme_color_override("font_color", MUTED)
	next.add_theme_color_override("font_hover_color", AMBER)
	next.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.028, 0.035, 0.95), Color(0.3, 0.2, 0.14, 1.0), 1, 2))
	next.add_theme_stylebox_override("hover", _stylebox(Color(0.12, 0.06, 0.06, 0.98), Color(0.9, 0.58, 0.24, 1.0), 1, 2))
	next.pressed.connect(func() -> void: _set_codex_page(codex_page + 1))
	foot.add_child(next)


func _set_codex_page(index: int) -> void:
	if codex_panel == null:
		return
	codex_page = wrapi(index, 0, LORE_BOOK.size())
	var entry: Dictionary = LORE_BOOK[codex_page]
	codex_title.text = String(entry.get("title", ""))
	codex_body.text = String(entry.get("body", ""))
	if codex_page_label != null:
		codex_page_label.text = "%d / %d" % [codex_page + 1, LORE_BOOK.size()]


func open_codex() -> void:
	if codex_panel == null:
		return
	_close_pause_for_overlay()
	get_tree().paused = true
	codex_panel.visible = true
	codex_panel.modulate.a = 0.0
	_set_codex_page(codex_page)
	var tween := create_tween()
	tween.tween_property(codex_panel, "modulate:a", 1.0, 0.18)


func close_codex() -> void:
	if codex_panel != null:
		codex_panel.visible = false
	show_pause()


func hide_codex() -> void:
	if codex_panel != null:
		codex_panel.visible = false


## The passive tree: three short branches, one point per level. It reads state
## from the game every time it opens, so it never shows a stale tree.
func _build_passives() -> void:
	passive_panel = PanelContainer.new()
	passive_panel.set_anchors_preset(Control.PRESET_CENTER)
	passive_panel.offset_left = -460.0
	passive_panel.offset_right = 460.0
	passive_panel.offset_top = -306.0
	passive_panel.offset_bottom = 306.0
	passive_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.022, 0.011, 0.026, 0.99), Color(0.5, 0.3, 0.13, 1.0), 2, 5))
	passive_panel.visible = false
	passive_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(passive_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	passive_panel.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := _label("THE BLOODIED PATH", 30, AMBER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	passive_points_label = _label("POINTS  0", 15, GOLD)
	passive_points_label.custom_minimum_size = Vector2(120, 30)
	passive_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	passive_points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(passive_points_label)
	var close := Button.new()
	close.text = "CLOSE"
	close.custom_minimum_size = Vector2(82, 30)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(close_passives)
	head.add_child(close)
	var hint := _label("One point per level. Follow a branch in order; deeper nodes need the ones above them.", 11, MUTED, false)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)
	var cols := HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 14)
	box.add_child(cols)
	for branch in ["might", "vitae", "grace"]:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 7)
		cols.add_child(col)
		var color: Color = Passives.BRANCH_COLORS.get(branch, AMBER)
		var heading := _label(String(Passives.BRANCH_NAMES.get(branch, branch)), 12, color)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(heading)
		for entry in Passives.nodes_in(branch):
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(0, 62)
			btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.add_theme_font_size_override("font_size", 12)
			btn.add_theme_color_override("font_color", BONE)
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.85))
			btn.add_theme_color_override("font_disabled_color", Color(0.42, 0.38, 0.4))
			btn.text = "%s\n%s" % [String(entry.get("name", "")), String(entry.get("desc", ""))]
			var id := String(entry.get("id", ""))
			btn.pressed.connect(func() -> void: passive_buy.emit(id))
			col.add_child(btn)
			passive_buttons.append({"id": id, "button": btn, "branch": branch})


func show_passives(owned: Array, points: int) -> void:
	if passive_panel == null:
		return
	passive_owned = owned.duplicate()
	passive_points = points
	if passive_points_label != null:
		passive_points_label.text = "POINTS  %d" % points
		passive_points_label.add_theme_color_override("font_color", GOLD if points > 0 else Color(0.55, 0.5, 0.45))
	for entry in passive_buttons:
		var id := String(entry.get("id", ""))
		var btn: Button = entry.get("button")
		if btn == null:
			continue
		var data := Passives.node(id)
		var color: Color = Passives.BRANCH_COLORS.get(String(entry.get("branch", "")), AMBER)
		var is_owned := passive_owned.has(id)
		var can_buy := points > 0 and Passives.available(passive_owned, id)
		btn.disabled = not is_owned and not can_buy
		btn.text = "%s\n%s" % [String(data.get("name", id)), String(data.get("desc", ""))]
		if is_owned:
			btn.add_theme_stylebox_override("normal", _stylebox(Color(color.r * 0.18, color.g * 0.12, color.b * 0.12, 0.98), color, 1, 3))
			btn.add_theme_color_override("font_color", color.lightened(0.35))
		elif can_buy:
			btn.add_theme_stylebox_override("normal", _stylebox(Color(0.07, 0.035, 0.04, 0.96), color.darkened(0.25), 1, 3))
			btn.add_theme_stylebox_override("hover", _stylebox(Color(0.16, 0.07, 0.06, 0.99), color, 1, 3))
			btn.add_theme_color_override("font_color", BONE)
		else:
			btn.add_theme_stylebox_override("normal", _stylebox(Color(0.04, 0.025, 0.03, 0.9), Color(0.2, 0.16, 0.18, 1.0), 1, 3))
	passive_panel.visible = true
	passive_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(passive_panel, "modulate:a", 1.0, 0.18)


func close_passives() -> void:
	if passive_panel != null:
		passive_panel.visible = false
	if body != null and body.visible:
		show_pause()


## The character list: every hero on this computer, with the run summary its
## own save file carries. Load, delete (two presses) or open the creator.
func _build_roster() -> void:
	roster_panel = PanelContainer.new()
	roster_panel.set_anchors_preset(Control.PRESET_CENTER)
	roster_panel.offset_left = -410.0
	roster_panel.offset_right = 410.0
	roster_panel.offset_top = -300.0
	roster_panel.offset_bottom = 300.0
	roster_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.026, 0.013, 0.03, 0.99), Color(0.5, 0.32, 0.14, 1.0), 2, 5))
	roster_panel.visible = false
	roster_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(roster_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	roster_panel.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := _label("YOUR CHARACTERS", 30, AMBER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var create := Button.new()
	create.text = "CREATE NEW"
	create.custom_minimum_size = Vector2(140, 32)
	create.add_theme_font_size_override("font_size", 12)
	create.add_theme_color_override("font_color", Color(0.7, 0.95, 0.78))
	create.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.9))
	create.add_theme_stylebox_override("normal", _stylebox(Color(0.06, 0.09, 0.06, 0.96), Color(0.3, 0.55, 0.35, 1.0), 1, 3))
	create.add_theme_stylebox_override("hover", _stylebox(Color(0.1, 0.18, 0.1, 0.99), Color(0.6, 0.95, 0.65, 1.0), 1, 3))
	create.pressed.connect(func() -> void:
		roster_panel.visible = false
		roster_create.emit()
	)
	head.add_child(create)
	var close := Button.new()
	close.text = "CLOSE"
	close.custom_minimum_size = Vector2(82, 32)
	close.add_theme_font_size_override("font_size", 12)
	close.add_theme_color_override("font_color", MUTED)
	close.add_theme_color_override("font_hover_color", AMBER)
	close.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
	close.add_theme_stylebox_override("hover", _stylebox(Color(0.13, 0.06, 0.05, 0.95), Color(0.9, 0.55, 0.2, 1.0), 1))
	close.pressed.connect(func() -> void: roster_panel.visible = false)
	head.add_child(close)
	var hint := _label("Each hero keeps its own run: layer, level, relics, boons and passive tree.", 11, MUTED, false)
	box.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	roster_list = VBoxContainer.new()
	roster_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_list.add_theme_constant_override("separation", 8)
	scroll.add_child(roster_list)


func show_roster(entries: Array) -> void:
	if roster_panel == null:
		return
	for child in roster_list.get_children():
		roster_list.remove_child(child)
		child.queue_free()
	roster_delete_armed = ""
	if entries.is_empty():
		var empty := _label("No heroes yet. Create one and the rift will remember them.", 13, MUTED, false)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		roster_list.add_child(empty)
	for entry in entries:
		if typeof(entry) == TYPE_DICTIONARY:
			roster_list.add_child(_roster_row(entry))
	roster_panel.visible = true
	roster_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(roster_panel, "modulate:a", 1.0, 0.18)


func _roster_row(entry: Dictionary) -> Control:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _stylebox(Color(0.045, 0.025, 0.035, 0.96), Color(0.28, 0.2, 0.14, 1.0), 1, 3))
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 12)
	row.add_child(line)
	var class_id := String(entry.get("class_id", "blood_sorceress"))
	var data := HeroClasses.definition(class_id)
	var color: Color = data.get("color", AMBER)
	var portrait := String(data.get("portrait", ""))
	if not portrait.is_empty() and ResourceLoader.exists(portrait):
		var tex: Variant = load(portrait)
		if tex is Texture2D:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(170.0, 60.0, 560.0, 660.0)
			var tile := TextureRect.new()
			tile.texture = atlas
			tile.custom_minimum_size = Vector2(40, 52)
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			line.add_child(tile)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 0)
	line.add_child(info)
	info.add_child(_label(String(entry.get("name", "UNNAMED")), 17, color, false))
	var summary := "%s  ·  LEVEL %d  ·  LAYER %d  ·  DEEPEST %d  ·  %d COIN" % [
		String(data.get("name", "BLOOD SORCERESS")), int(entry.get("level", 1)),
		int(entry.get("layer", 1)), int(entry.get("best", 1)), int(entry.get("coins", 0))]
	info.add_child(_label(summary, 11, Color(0.78, 0.7, 0.62), false))
	var load_btn := Button.new()
	load_btn.text = "LOAD"
	load_btn.custom_minimum_size = Vector2(94, 34)
	load_btn.add_theme_font_size_override("font_size", 13)
	load_btn.add_theme_color_override("font_color", GOLD)
	load_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.8))
	load_btn.add_theme_stylebox_override("normal", _stylebox(Color(0.12, 0.07, 0.04, 0.96), Color(0.6, 0.42, 0.16, 1.0), 1, 3))
	load_btn.add_theme_stylebox_override("hover", _stylebox(Color(0.22, 0.12, 0.06, 0.99), Color(1.0, 0.7, 0.28, 1.0), 1, 3))
	var id := String(entry.get("id", ""))
	load_btn.pressed.connect(func() -> void:
		roster_panel.visible = false
		roster_load.emit(id)
	)
	line.add_child(load_btn)
	var del := Button.new()
	del.text = "DELETE"
	del.custom_minimum_size = Vector2(86, 34)
	del.add_theme_font_size_override("font_size", 11)
	del.add_theme_color_override("font_color", Color(0.85, 0.5, 0.45))
	del.add_theme_color_override("font_hover_color", Color(1.0, 0.75, 0.65))
	del.add_theme_stylebox_override("normal", _stylebox(Color(0.09, 0.04, 0.04, 0.96), Color(0.42, 0.2, 0.16, 1.0), 1, 3))
	del.add_theme_stylebox_override("hover", _stylebox(Color(0.18, 0.07, 0.06, 0.99), Color(0.85, 0.35, 0.25, 1.0), 1, 3))
	del.pressed.connect(func() -> void:
		var now := Time.get_ticks_msec()
		if roster_delete_armed == id and now - roster_delete_ms < 4000:
			roster_delete_armed = ""
			roster_delete.emit(id)
			return
		roster_delete_armed = id
		roster_delete_ms = now
		del.text = "CONFIRM"
		var timer := get_tree().create_timer(4.0)
		timer.timeout.connect(func() -> void:
			if roster_delete_armed == id and is_instance_valid(del):
				roster_delete_armed = ""
				del.text = "DELETE"
		)
	)
	line.add_child(del)
	return row


func _build_fade() -> void:
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0
	root.add_child(fade_rect)


func flash_transition() -> void:
	if fade_rect == null:
		return
	fade_rect.modulate.a = 0.92
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.6)


func set_record(best: int) -> void:
	record_layer = best
	if record_label != null:
		record_label.text = "DEEPEST RIFT  ·  LAYER %d" % best


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE):
		var focused := get_viewport().gui_get_focus_owner()
		if focused != null:
			focused.release_focus()
	if creator_panel != null and creator_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				hide_creator()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				_confirm_character()
				get_viewport().set_input_as_handled()
		return
	if story_panel != null and story_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo \
				and (event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			close_story()
			get_viewport().set_input_as_handled()
		return
	if codex_panel != null and codex_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				close_codex()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_LEFT or event.keycode == KEY_UP:
				_set_codex_page(codex_page - 1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_RIGHT or event.keycode == KEY_DOWN:
				_set_codex_page(codex_page + 1)
				get_viewport().set_input_as_handled()
		return
	if passive_panel != null and passive_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			close_passives()
			get_viewport().set_input_as_handled()
		return
	if roster_panel != null and roster_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			roster_panel.visible = false
			get_viewport().set_input_as_handled()
		return
	if net_panel != null and net_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			hide_net_panel()
			get_viewport().set_input_as_handled()
		return
	if rift_map_panel != null and rift_map_panel.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_UP or event.keycode == KEY_LEFT:
				_move_rift_selection(-1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_DOWN or event.keycode == KEY_RIGHT:
				_move_rift_selection(1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				_enter_selected_rift()
				get_viewport().set_input_as_handled()
		return
	if title_panel != null and title_panel.visible and not settings_open:
		if event is InputEventKey and event.pressed and not event.echo \
				and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE):
			if _title_input_ok():
				if title_continue_btn != null and title_continue_btn.visible:
					continue_pressed.emit()
				else:
					show_creator()
			get_viewport().set_input_as_handled()
		return
	if shop_open:
		if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_P or event.keycode == KEY_E):
			close_shop()
			get_viewport().set_input_as_handled()
		return
	if boons_open:
		if event is InputEventKey and event.pressed and not event.echo:
			var index: int = event.keycode - KEY_1
			if index >= 0 and index < boon_keys.size():
				_choose_boon(String(boon_keys[index]))
				get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		if rift_map_panel != null and rift_map_panel.visible:
			hide_rift_map()
		elif not settings_open and not relic_window.visible and not death_panel.visible:
			toggle_rift_map()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_K:
		if not settings_open and not relic_window.visible and not death_panel.visible and body.visible:
			passives_requested.emit()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_P):
		if rift_map_panel != null and rift_map_panel.visible:
			hide_rift_map()
			get_viewport().set_input_as_handled()
			return
		if not body.visible:
			return
		if settings_open:
			close_settings()
		elif relic_window.visible:
			close_relic_window()
		elif not death_panel.visible:
			toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	if death_panel.visible or not body.visible:
		return
	var now := Time.get_ticks_msec()
	if now - last_pause_ms < 80:
		return
	last_pause_ms = now
	if get_tree().paused:
		hide_pause()
	else:
		show_pause()
	ui_click.emit()


func show_pause() -> void:
	if death_panel.visible or not body.visible:
		return
	if pause_summary != null:
		pause_summary.text = "LAYER %d    ·    LEVEL %d    ·    COIN %d    ·    SOULS %d" % [run_layer, run_level, run_coins, run_kills]
	get_tree().paused = true
	pause_shade.visible = true
	pause_panel.visible = true


func hide_pause() -> void:
	get_tree().paused = false
	pause_shade.visible = false
	pause_panel.visible = false


func set_health(current: float, maximum: float, regen_rate := -1.0, in_combat := false) -> void:
	var ratio := 0.0
	if maximum > 0.0:
		ratio = clampf(current / maximum, 0.0, 1.0)
	health_target = ratio * 100.0
	health_label.text = "VITAE  %d / %d" % [int(ceil(current)), int(maximum)]
	low_health = 1.0 if ratio < 0.32 else 0.0
	if regen_label != null:
		if regen_rate < 0.0:
			regen_label.text = ""
		elif in_combat:
			regen_label.text = "REGEN +%.1f/s" % regen_rate
			regen_label.add_theme_color_override("font_color", MUTED)
		else:
			regen_label.text = "REGEN +%.1f/s" % regen_rate
			regen_label.add_theme_color_override("font_color", GOLD)


func set_coins(value: int, pulse := false) -> void:
	if coin_label == null:
		return
	run_coins = value
	coin_label.text = "COIN  %d" % value
	if not pulse:
		return
	coin_label.scale = Vector2.ONE * 1.16
	coin_label.pivot_offset = coin_label.size * 0.5
	var tween := create_tween()
	tween.tween_property(coin_label, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_level(level: int, xp: float, need: float) -> void:
	if level_label == null:
		return
	run_level = level
	level_label.text = "LEVEL %d" % level
	if xp_bar != null:
		var ratio := 0.0
		if need > 0.0:
			ratio = clampf(xp / need, 0.0, 1.0)
		xp_bar.value = ratio * 100.0


func set_layer_info(layer: int, remaining: int, total: int, kills := 0) -> void:
	run_layer = layer
	run_kills = kills
	layer_label.text = "RIFT LAYER %d" % layer
	wave_label.text = "HOSTILES REMAIN  %d / %d    ·    SOULS %d" % [remaining, total, kills]
	if wave_bar != null:
		var cleared := 0.0
		if total > 0:
			cleared = clampf(float(total - remaining) / float(total), 0.0, 1.0)
		wave_bar.value = cleared * 100.0


func set_theme_name(text: String) -> void:
	if theme_label != null:
		theme_label.text = text


func set_modifiers(list: Array) -> void:
	current_mods = list.duplicate()
	if mod_row == null:
		return
	for child in mod_row.get_children():
		child.queue_free()
	for entry in list:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var chip := PanelContainer.new()
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.10, 0.03, 0.05, 0.72)
		style.border_color = Color(entry.get("color", GOLD))
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		chip.add_theme_stylebox_override("panel", style)
		var label := Label.new()
		label.text = str(entry.get("name", "MODIFIER"))
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(entry.get("color", GOLD)))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(label)
		chip.tooltip_text = str(entry.get("text", ""))
		mod_row.add_child(chip)
	mod_row.visible = bool(GameSettings.get_value("modifiers")) and not list.is_empty()


func set_boss(name_text: String, ratio: float, active: bool) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = active
	if controls_hint != null:
		controls_hint.visible = not active
	if not active:
		return
	boss_name.text = name_text
	boss_bar.value = clampf(ratio, 0.0, 1.0) * 100.0


func set_status(text: String) -> void:
	status_label.text = text


func set_bloodrush(count: int, ratio: float) -> void:
	var active := count > 0
	if bloodrush_label == null:
		return
	bloodrush_label.visible = active
	bloodrush_bar.visible = active
	if not active:
		return
	bloodrush_label.text = "BLOODRUSH  ×%d" % count
	bloodrush_bar.value = clampf(ratio, 0.0, 1.0) * 100.0


func set_cooldowns(cooldowns: Array, dash_cooldown: float, health := 0.0, costs: Array = []) -> void:
	var list: Array = active_class.get("abilities", HeroClasses.abilities("blood_sorceress"))
	var is_health := String(active_class.get("cost_kind", "health")) == "health"
	var noun := "VITAE" if is_health else String(active_class.get("focus_name", "FOCUS"))
	var accent: Color = active_class.get("color", CRIMSON)
	for i in slots.size():
		var slot: Dictionary = slots[i]
		var cd := 0.0
		var total := 1.0
		var affordable := true
		if i < cooldowns.size():
			cd = float(cooldowns[i])
			if i < list.size():
				total = float(list[i].get("cooldown", 1.0))
			var cost := 0.0
			if i < costs.size():
				cost = float(costs[i])
			elif i < list.size():
				cost = float(list[i].get("cost", 0.0))
			affordable = cost <= 0.0 or health > cost + 1.0
			var cost_label: Label = slot.get("cost")
			if cost_label != null:
				cost_label.text = "FREE" if cost <= 0.0 else "%d %s" % [int(cost), noun]
				if not affordable:
					cost_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.24))
				else:
					cost_label.add_theme_color_override("font_color", GOLD if cost <= 0.0 else (CRIMSON if is_health else accent))
		else:
			cd = dash_cooldown
			total = 2.2
		var panel: Panel = slot.panel
		panel.modulate = Color(1.0, 0.62, 0.58, 0.85) if not affordable else Color.WHITE
		var label: Label = slot.cd
		var overlay: ColorRect = slot.overlay
		if cd > 0.05:
			label.text = "%.1f" % cd
			if overlay != null:
				overlay.visible = true
				overlay.offset_top = -62.0 * (cd / maxf(total, 0.01))
		else:
			label.text = ""
			if overlay != null:
				overlay.visible = false
		var was_cd: bool = bool(slot.get("was_cd", false))
		if was_cd and cd <= 0.05:
			panel.pivot_offset = panel.size * 0.5
			var tween := panel.create_tween()
			tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.08)
			tween.tween_property(panel, "scale", Vector2.ONE, 0.12)
		slot["was_cd"] = cd > 0.05


func set_relics(list: Array) -> void:
	relics = list.duplicate()
	for i in relic_rows.size():
		var row: Dictionary = relic_rows[i]
		var item: Dictionary = relics[i] if i < relics.size() else {}
		var name_label: Label = row.name
		var gem: RelicGem = row.gem
		if item.is_empty():
			name_label.text = "%d   empty" % (i + 1)
			name_label.add_theme_color_override("font_color", Color(0.42, 0.38, 0.4))
			gem.gem_color = Color(0.24, 0.2, 0.22)
		else:
			var family := String(item.get("family", "blood"))
			var family_name := String(ItemDB.FAMILIES.get(family, {}).get("name", ""))
			name_label.text = "%d   %s  ·  %s" % [i + 1, String(item.get("name", "Relic")), family_name]
			name_label.add_theme_color_override("font_color", item.get("color", BONE))
			gem.gem_color = ItemDB.FAMILIES.get(family, {}).get("color", Color(0.8, 0.5, 0.2))
		gem.queue_redraw()
	if relic_stats != null:
		relic_stats.text = _synergy_summary()
	if relic_window != null and relic_window.visible:
		_refresh_relic_window()


func _family_count(family: String) -> int:
	var count := 0
	for item in relics:
		if not item.is_empty() and String(item.get("family", "")) == family:
			count += 1
	return count


func _can_fit(item: Dictionary, slot: int) -> bool:
	if slot < 0 or slot >= Player.MAX_RELICS:
		return false
	var family := String(item.get("family", "blood"))
	var count := 0
	for i in relics.size():
		if i == slot:
			continue
		if not relics[i].is_empty() and String(relics[i].get("family", "")) == family:
			count += 1
	return count < Player.FAMILY_STACK_LIMIT


func _synergy_summary() -> String:
	var parts: Array = []
	for family in ["blood", "ember", "rift"]:
		if _family_count(family) >= 2:
			parts.append(String(ItemDB.FAMILIES[family].name).to_upper() + " RITE")
	var filled := 0
	for family in ["blood", "ember", "rift"]:
		if _family_count(family) > 0:
			filled += 1
	if filled >= 3:
		parts.append("BLOODMOON TRIAD")
	if parts.is_empty():
		return "No rite active  ·  stack 2 of one family"
	return "  ·  ".join(parts)


func offer_relic(item: Dictionary) -> void:
	pending_item = item
	relic_tab = "relics"
	if relic_window == null:
		return
	relic_window.visible = true
	relic_window.modulate.a = 1.0
	relic_opened_ms = Time.get_ticks_msec()
	_refresh_relic_window()


func open_relic_window() -> void:
	if relic_window == null:
		return
	relic_window.visible = true
	relic_window.modulate.a = 1.0
	relic_opened_ms = Time.get_ticks_msec()
	_refresh_relic_window()


func close_relic_window() -> void:
	pending_item = {}
	if relic_window != null:
		relic_window.visible = false


func toggle_relic_window() -> void:
	if relic_window == null:
		return
	if relic_window.visible:
		close_relic_window()
	else:
		pending_item = {}
		open_relic_window()


func is_relic_window_open() -> bool:
	return relic_window != null and relic_window.visible


func equip_pending_best() -> void:
	if pending_item.is_empty():
		return
	for i in Player.MAX_RELICS:
		if _can_fit(pending_item, i):
			_pick_slot(i)
			return
	toast("FAMILY STACK FULL", Color(1.0, 0.4, 0.3), 1.6)


func _pick_slot(slot: int) -> void:
	if Time.get_ticks_msec() - relic_opened_ms < 350:
		return
	if pending_item.is_empty():
		return
	var item := pending_item
	pending_item = {}
	equip_requested.emit(item, slot)


func _remove_slot(slot: int) -> void:
	if Time.get_ticks_msec() - relic_opened_ms < 300:
		return
	unequip_requested.emit(slot)


func _discard() -> void:
	if Time.get_ticks_msec() - relic_opened_ms < 300:
		return
	pending_item = {}
	discard_requested.emit()


func _clear_children(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _refresh_relic_window() -> void:
	if relic_body == null:
		return
	_clear_children(relic_body)
	if relic_tabs != null:
		for btn in relic_tabs.get_children():
			if btn is Button:
				var active := String(btn.get_meta("tab", "")) == relic_tab
				btn.add_theme_color_override("font_color", GOLD if active else MUTED)
				btn.add_theme_stylebox_override("normal", _stylebox(
					Color(0.16, 0.07, 0.05, 0.96) if active else Color(0.06, 0.03, 0.05, 0.92),
					Color(0.95, 0.6, 0.22, 1.0) if active else Color(0.24, 0.16, 0.12, 1.0), 1))
	if relic_tab == "synergy":
		_build_synergy_body()
	else:
		_build_relic_body()
	_kill_button_focus()


func _build_relic_body() -> void:
	if not pending_item.is_empty():
		var item := pending_item
		var family := String(item.get("family", "blood"))
		var family_def: Dictionary = ItemDB.FAMILIES.get(family, ItemDB.FAMILIES["blood"])
		var headline := _label("%s" % String(item.get("name", "Relic")), 24, item.get("color", BONE))
		relic_body.add_child(headline)
		var sub := _label("%s  ·  %s FAMILY" % [String(item.get("rarity_name", "")).to_upper(), String(family_def.name).to_upper()], 12, family_def.color)
		relic_body.add_child(sub)
		var unique := String(item.get("unique_text", ""))
		if unique != "":
			var u := _label(unique, 14, GOLD)
			u.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			relic_body.add_child(u)
		for line in ItemDB.mod_lines(item):
			relic_body.add_child(_label(String(line.text), 15, BONE, false))
		relic_body.add_child(_label("BIND TO SLOT   (max %d per family)" % Player.FAMILY_STACK_LIMIT, 11, MUTED))
		var slot_row := HBoxContainer.new()
		slot_row.add_theme_constant_override("separation", 8)
		relic_body.add_child(slot_row)
		for i in Player.MAX_RELICS:
			var btn := Button.new()
			btn.text = "SLOT %d" % (i + 1)
			btn.custom_minimum_size = Vector2(104, 36)
			btn.add_theme_font_size_override("font_size", 14)
			btn.add_theme_color_override("font_color", AMBER)
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72))
			btn.add_theme_stylebox_override("normal", _stylebox(Color(0.1, 0.04, 0.05, 0.95), Color(0.5, 0.28, 0.1, 1.0), 1))
			btn.add_theme_stylebox_override("hover", _stylebox(Color(0.2, 0.08, 0.07, 0.98), Color(0.9, 0.55, 0.2, 1.0), 1))
			btn.add_theme_stylebox_override("pressed", _stylebox(Color(0.3, 0.1, 0.08, 1.0), Color(1.0, 0.7, 0.3, 1.0), 1))
			btn.disabled = not _can_fit(item, i)
			btn.pressed.connect(_pick_slot.bind(i))
			slot_row.add_child(btn)
		var discard := Button.new()
		discard.text = "DISCARD"
		discard.custom_minimum_size = Vector2(104, 36)
		discard.add_theme_font_size_override("font_size", 13)
		discard.add_theme_color_override("font_color", MUTED)
		discard.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
		discard.pressed.connect(_discard)
		slot_row.add_child(discard)
		relic_body.add_child(HSeparator.new())
	else:
		var hint := _label("No relic in hand. Click a glowing drop on the floor to claim it.", 14, MUTED)
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		relic_body.add_child(hint)
		relic_body.add_child(HSeparator.new())
	var title := _label("EQUIPPED", 12, MUTED)
	relic_body.add_child(title)
	for i in Player.MAX_RELICS:
		var item: Dictionary = relics[i] if i < relics.size() else {}
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		relic_body.add_child(row)
		var gem := RelicGem.new()
		gem.custom_minimum_size = Vector2(14, 14)
		gem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(gem)
		var text := "%d   empty" % (i + 1)
		var color := Color(0.45, 0.4, 0.42)
		if not item.is_empty():
			var family := String(item.get("family", "blood"))
			gem.gem_color = ItemDB.FAMILIES.get(family, {}).get("color", Color(0.8, 0.5, 0.2))
			text = "%d   %s  ·  %s" % [i + 1, String(item.get("name", "Relic")), String(ItemDB.FAMILIES.get(family, {}).get("name", ""))]
			color = item.get("color", BONE)
		else:
			gem.gem_color = Color(0.24, 0.2, 0.22)
		var label := _label(text, 15, color, false)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var remove := Button.new()
		remove.text = "REMOVE"
		remove.custom_minimum_size = Vector2(90, 28)
		remove.add_theme_font_size_override("font_size", 11)
		remove.add_theme_color_override("font_color", MUTED)
		remove.disabled = item.is_empty()
		remove.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.03, 0.04, 0.9), Color(0.24, 0.16, 0.12, 1.0), 1))
		remove.add_theme_stylebox_override("hover", _stylebox(Color(0.14, 0.06, 0.05, 0.95), Color(0.85, 0.45, 0.2, 1.0), 1))
		remove.pressed.connect(_remove_slot.bind(i))
		row.add_child(remove)


func _build_synergy_body() -> void:
	var intro := _label("Two relics of one family unlock its rite. One of each unlocks the triad.", 13, MUTED)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	relic_body.add_child(intro)
	for family in ["blood", "ember", "rift"]:
		var def: Dictionary = ItemDB.FAMILIES[family]
		var count := _family_count(family)
		var active := count >= 2
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		relic_body.add_child(row)
		var gem := RelicGem.new()
		gem.custom_minimum_size = Vector2(14, 14)
		gem.gem_color = def.color if active else def.color.darkened(0.5)
		gem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(gem)
		var title := _label("%s RITE   %d / 2" % [String(def.name).to_upper(), count], 16, def.color if active else MUTED, false)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(title)
		row.add_child(_label("ACTIVE" if active else "NEEDS 2", 12, GOLD if active else Color(0.4, 0.36, 0.38), false))
		relic_body.add_child(_label(String(def.rite), 13, BONE if active else Color(0.52, 0.48, 0.5), false))
	var families := 0
	for family in ["blood", "ember", "rift"]:
		if _family_count(family) > 0:
			families += 1
	var triad_row := HBoxContainer.new()
	triad_row.add_theme_constant_override("separation", 8)
	relic_body.add_child(triad_row)
	var triad_title := _label("BLOODMOON TRIAD   %d / 3" % families, 16, GOLD if families >= 3 else MUTED, false)
	triad_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	triad_row.add_child(triad_title)
	triad_row.add_child(_label("ACTIVE" if families >= 3 else "NEEDS 1 OF EACH", 12, GOLD if families >= 3 else Color(0.4, 0.36, 0.38), false))
	relic_body.add_child(_label(ItemDB.TRIAD_TEXT, 13, BONE if families >= 3 else Color(0.52, 0.48, 0.5), false))


func toast(text: String, color := AMBER, duration := 2.6) -> void:
	while toast_box.get_child_count() >= 4:
		var oldest := toast_box.get_child(0)
		toast_box.remove_child(oldest)
		oldest.queue_free()
	var l := _label(text, 22, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.modulate.a = 0.0
	toast_box.add_child(l)
	var tween := l.create_tween()
	tween.tween_property(l, "modulate:a", 1.0, 0.14)
	tween.tween_interval(duration)
	tween.tween_property(l, "modulate:a", 0.0, 0.45)
	tween.tween_callback(l.queue_free)


func flash_damage(strength := 1.0) -> void:
	vignette_alpha = minf(1.0, maxf(vignette_alpha, 0.55 * strength))
	damage_flash = minf(1.0, damage_flash + 0.45 * strength)


func show_death(layer_reached: int, kills: int, relic_name_text: String) -> void:
	get_tree().paused = false
	pause_shade.visible = false
	pause_panel.visible = false
	death_panel.visible = true
	death_stats.text = "Layer %d reached  ·  %d souls shattered\nRelic carried: %s\nDeepest rift: layer %d" % [layer_reached, kills, relic_name_text, maxi(record_layer, layer_reached)]


func hide_death() -> void:
	death_panel.visible = false


func _build_duel_result() -> void:
	duel_panel = PanelContainer.new()
	duel_panel.set_anchors_preset(Control.PRESET_CENTER)
	duel_panel.anchor_left = 0.5
	duel_panel.anchor_right = 0.5
	duel_panel.anchor_top = 0.5
	duel_panel.anchor_bottom = 0.5
	duel_panel.offset_left = -320.0
	duel_panel.offset_right = 320.0
	duel_panel.offset_top = -186.0
	duel_panel.offset_bottom = 186.0
	duel_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.01, 0.045, 0.96), Color(0.55, 0.32, 0.72, 1.0), 2, 5))
	duel_panel.visible = false
	root.add_child(duel_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	duel_panel.add_child(box)
	duel_title = _label("", 40, GOLD)
	duel_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(duel_title)
	duel_sub = _label("", 16, MUTED)
	duel_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(duel_sub)
	duel_stats = _label("", 15, BONE)
	duel_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(duel_stats)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	var again := Button.new()
	again.text = "DUEL AGAIN"
	again.custom_minimum_size = Vector2(200, 46)
	again.add_theme_font_size_override("font_size", 17)
	again.add_theme_color_override("font_color", GOLD)
	again.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.8))
	again.add_theme_stylebox_override("normal", _stylebox(Color(0.13, 0.05, 0.16, 0.96), Color(0.6, 0.36, 0.8, 1.0), 1, 3))
	again.add_theme_stylebox_override("hover", _stylebox(Color(0.22, 0.09, 0.26, 0.99), Color(0.9, 0.6, 1.0, 1.0), 1, 3))
	again.pressed.connect(func() -> void:
		if Time.get_ticks_msec() - duel_shown_ms < 800:
			return
		ui_click.emit()
		duel_again_pressed.emit()
	)
	row.add_child(again)
	var home := Button.new()
	home.text = "RETURN TO BASTION"
	home.custom_minimum_size = Vector2(220, 46)
	home.add_theme_font_size_override("font_size", 15)
	home.add_theme_color_override("font_color", MUTED)
	home.add_theme_color_override("font_hover_color", AMBER)
	home.add_theme_stylebox_override("normal", _stylebox(Color(0.05, 0.035, 0.05, 0.96), Color(0.3, 0.22, 0.16, 1.0), 1, 3))
	home.add_theme_stylebox_override("hover", _stylebox(Color(0.12, 0.06, 0.05, 0.99), Color(0.75, 0.5, 0.2, 1.0), 1, 3))
	home.pressed.connect(func() -> void:
		if Time.get_ticks_msec() - duel_shown_ms < 800:
			return
		ui_click.emit()
		home_pressed.emit()
	)
	row.add_child(home)
	_kill_button_focus()


func show_duel_result(won: bool, casts: int) -> void:
	get_tree().paused = false
	pause_shade.visible = false
	pause_panel.visible = false
	duel_panel.visible = true
	duel_panel.modulate.a = 0.0
	duel_shown_ms = Time.get_ticks_msec()
	duel_title.text = "THE MIRROR SHATTERS" if won else "THE MIRROR PREVAILS"
	duel_title.add_theme_color_override("font_color", GOLD if won else Color(0.85, 0.45, 1.0))
	duel_sub.text = "Your blood was the sharper blade." if won else "She wore your face, and she was faster."
	duel_stats.text = "%d spells cast  -  no relics, no coin\nOnly hands, and the face you were born with." % casts
	var tween := create_tween()
	tween.tween_property(duel_panel, "modulate:a", 1.0, 0.35)


func hide_duel_result() -> void:
	if duel_panel != null:
		duel_panel.visible = false


func hide_title() -> void:
	if not title_panel.visible:
		return
	var tween := title_panel.create_tween()
	tween.tween_property(title_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: title_panel.visible = false)
	if settings_btn != null:
		settings_btn.visible = true


func _process(delta: float) -> void:
	_process_creator(delta)
	vignette_alpha = maxf(0.0, vignette_alpha - delta * 1.4)
	damage_flash = maxf(0.0, damage_flash - delta * 3.0)
	health_shown = lerpf(health_shown, health_target, clampf(delta * 9.0, 0.0, 1.0))
	ghost_shown = lerpf(ghost_shown, health_target, clampf(delta * 1.9, 0.0, 1.0))
	if ghost_shown < health_shown:
		ghost_shown = health_shown
	if vitae_bar != null:
		vitae_bar.shown = health_shown / 100.0
		vitae_bar.ghost = ghost_shown / 100.0
		vitae_bar.flash = damage_flash
		vitae_bar.queue_redraw()
	if title_label != null and title_panel.visible:
		var glow := 0.9 + 0.1 * sin(Time.get_ticks_msec() / 620.0)
		title_label.modulate = Color(glow, glow, glow, 1.0)
	var pulse := 0.0
	if low_health > 0.0:
		pulse = 0.22 + 0.12 * sin(Time.get_ticks_msec() / 220.0)
	vignette.modulate.a = clampf(vignette_alpha + pulse, 0.0, 1.0)

