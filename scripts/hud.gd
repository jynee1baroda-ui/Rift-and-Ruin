class_name GameHUD
extends CanvasLayer

signal equip_requested(item: Dictionary)
signal start_pressed
signal ui_click
signal ability_pressed(index: int)
signal restart_pressed

const INK := Color(0.035, 0.025, 0.045, 0.92)
const AMBER := Color(1.0, 0.72, 0.28)
const CRIMSON := Color(0.92, 0.16, 0.14)
const BONE := Color(0.90, 0.86, 0.79)
const MUTED := Color(0.62, 0.56, 0.56)
const GOLD := Color(1.0, 0.83, 0.35)
const DISPLAY_FONT := "res://fonts/cinzel.ttf"

var root: Control
var body: Control
var minimap: RiftMap
var vitae_bar: VitaeBar
var health_label: Label
var regen_label: Label
var health_target := 100.0
var health_shown := 100.0
var ghost_shown := 100.0
var damage_flash := 0.0
var layer_label: Label
var wave_label: Label
var wave_bar: ProgressBar
var slots: Array = []
var bloodrush_label: Label
var bloodrush_bar: ProgressBar
var relic_name: Label
var relic_stats: Label
var toast_box: VBoxContainer
var compare_panel: PanelContainer
var compare_box: VBoxContainer
var compare_hint: Label
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
var status_label: Label
var pending_item: Dictionary = {}
var compare_shown_ms := 0
var vignette_alpha := 0.0
var low_health := 0.0
var display_font: FontFile
var title_font: FontVariation
var last_pause_ms := 0


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
	body = Control.new()
	body.name = "RunHUD"
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.visible = false
	body.modulate.a = 0.0
	root.add_child(body)
	_build_minimap()
	_build_top()
	_build_health()
	_build_abilities()
	_build_relic()
	_build_toasts()
	_build_compare()
	_build_death()
	_build_title()
	_build_pause_button()
	_build_pause()
	_build_fade()


func _build_minimap() -> void:
	var panel := Panel.new()
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
	var wave_gap := Control.new()
	wave_gap.custom_minimum_size = Vector2(0, 2)
	wave_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(wave_gap)
	var wave_holder := Control.new()
	wave_holder.custom_minimum_size = Vector2(0, 5)
	wave_holder.clip_contents = true
	wave_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(wave_holder)
	wave_bar = ProgressBar.new()
	wave_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	wave_bar.show_percentage = false
	wave_bar.max_value = 100.0
	wave_bar.value = 0.0
	var wave_bg := StyleBoxFlat.new()
	wave_bg.bg_color = Color(0.1, 0.03, 0.03, 0.8)
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
	var controls_hint := _label("LMB MOVE / ATTACK  ·  RMB LANCE  ·  1 2 3 CAST  ·  SPACE RIFTSTEP  ·  CLICK LOOT", 12, MUTED)
	controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(controls_hint)


func _build_health() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	box.offset_left = 30.0
	box.offset_bottom = -104.0
	box.offset_top = -196.0
	box.offset_right = 330.0
	box.add_theme_constant_override("separation", 3)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(box)
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
	box.offset_left = -290.0
	box.offset_right = 290.0
	box.alignment = BoxContainer.ALIGNMENT_END
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(box)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	for ability in Player.ABILITIES:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(150, 62)
		panel.add_theme_stylebox_override("panel", _stylebox(INK, Color(0.3, 0.16, 0.12, 1.0), 1))
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
		var key_label := _label(String(ability.key), 13, AMBER)
		key_label.position = Vector2(8, 3)
		panel.add_child(key_label)
		var name_label := _label(String(ability.glyph), 17, BONE)
		name_label.position = Vector2(8, 20)
		panel.add_child(name_label)
		var cost := float(ability.cost)
		var cost_label := _label("FREE" if cost <= 0.0 else "%d VITAE" % int(cost), 11, CRIMSON)
		cost_label.position = Vector2(8, 42)
		panel.add_child(cost_label)
		var cd_label := _label("", 20, GOLD)
		cd_label.anchor_left = 1.0
		cd_label.anchor_right = 1.0
		cd_label.anchor_top = 0.5
		cd_label.anchor_bottom = 0.5
		cd_label.offset_left = -56.0
		cd_label.offset_right = -8.0
		cd_label.offset_top = 6.0
		cd_label.offset_bottom = 30.0
		cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
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
		slots.append({"panel": panel, "overlay": overlay, "cd": cd_label, "name": name_label, "cost": cost_label, "was_cd": false})
	var dash := Panel.new()
	dash.custom_minimum_size = Vector2(96, 62)
	dash.add_theme_stylebox_override("panel", _stylebox(INK, Color(0.24, 0.2, 0.3, 1.0), 1))
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
	var dash_key := _label("SPACE", 13, AMBER)
	dash_key.position = Vector2(8, 3)
	dash.add_child(dash_key)
	var dash_name := _label("RIFTSTEP", 15, BONE)
	dash_name.position = Vector2(8, 20)
	dash.add_child(dash_name)
	var dash_cd := _label("", 20, GOLD)
	dash_cd.anchor_left = 1.0
	dash_cd.anchor_right = 1.0
	dash_cd.anchor_top = 0.5
	dash_cd.anchor_bottom = 0.5
	dash_cd.offset_left = -50.0
	dash_cd.offset_right = -8.0
	dash_cd.offset_top = 6.0
	dash_cd.offset_bottom = 30.0
	dash_cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dash.add_child(dash_cd)
	slots.append({"panel": dash, "overlay": null, "cd": dash_cd, "name": dash_name, "cost": null, "was_cd": false})


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
	panel.offset_left = -276.0
	panel.offset_right = -26.0
	panel.offset_top = -142.0
	panel.offset_bottom = -26.0
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.03, 0.02, 0.04, 0.86), Color(0.34, 0.22, 0.14, 1.0), 1))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	var title := _label("RELIC", 12, MUTED)
	box.add_child(title)
	relic_name = _label("Empty Binding", 17, BONE)
	relic_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(relic_name)
	relic_stats = _label("", 12, MUTED)
	relic_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(relic_stats)


func _build_toasts() -> void:
	toast_box = VBoxContainer.new()
	toast_box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_box.anchor_left = 0.5
	toast_box.anchor_right = 0.5
	toast_box.offset_left = -300.0
	toast_box.offset_right = 300.0
	toast_box.offset_top = 150.0
	toast_box.alignment = BoxContainer.ALIGNMENT_CENTER
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(toast_box)


func _build_compare() -> void:
	compare_panel = PanelContainer.new()
	compare_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	compare_panel.anchor_left = 1.0
	compare_panel.anchor_right = 1.0
	compare_panel.offset_left = -318.0
	compare_panel.offset_right = -26.0
	compare_panel.offset_top = -374.0
	compare_panel.offset_bottom = -196.0
	compare_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.04, 0.025, 0.045, 0.96), Color(0.5, 0.3, 0.1, 1.0), 2))
	compare_panel.visible = false
	compare_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	compare_panel.gui_input.connect(_on_compare_input)
	root.add_child(compare_panel)
	compare_box = VBoxContainer.new()
	compare_box.add_theme_constant_override("separation", 3)
	compare_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	compare_panel.add_child(compare_box)
	compare_hint = _label("CLICK TO EQUIP  ·  ENTER  ·  ESC TO DISCARD", 11, MUTED)
	compare_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	compare_box.add_child(compare_hint)


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
	title_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(title_panel)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.005, 0.015, 0.55)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_panel.add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -380.0
	box.offset_right = 380.0
	box.offset_top = -190.0
	box.offset_bottom = 190.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_panel.add_child(box)
	title_label = _label("RIFT & RUIN", 92, AMBER)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title_label)
	var sub := _label("THE BLOOD SORCERESS", 22, CRIMSON)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	record_label = _label("DEEPEST RIFT  ·  LAYER 1", 14, MUTED)
	record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(record_label)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 26)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(spacer)
	var lines := [
		"Click to move. Click a demon to lance it.",
		"1  BLOOD NOVA      detonate your life force",
		"2  CRIMSON LANCE   pierce the pack",
		"3  SANGUINE SIPHON drink their wounds closed",
		"SPACE  RIFTSTEP    slide over lava",
		"HOLD LEFT MOUSE to run  ·  click a skill card to cast  ·  ESC pauses",
		"Clear every pack, step into the rift, go deeper.",
	]
	for line in lines:
		var l := _label(line, 17, BONE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	box.add_child(spacer2)
	var begin := _label("CLICK ANYWHERE TO BEGIN", 22, AMBER)
	begin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(begin)
	title_panel.modulate.a = 0.0
	var fade := create_tween()
	fade.tween_property(title_panel, "modulate:a", 1.0, 0.7)


func _on_compare_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_equip_pending()


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
	pause_panel.offset_left = -250.0
	pause_panel.offset_right = 250.0
	pause_panel.offset_top = -190.0
	pause_panel.offset_bottom = 190.0
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
	var lines := [
		"CLICK / HOLD       move",
		"CLICK A FOE        crimson lance",
		"1   BLOOD NOVA     6 vitae",
		"2   CRIMSON LANCE  3 vitae",
		"3   SANGUINE SIPHON free",
		"SPACE   RIFTSTEP   dash over lava",
		"CLICK A SKILL CARD   cast without a hotkey",
		"CLICK LOOT CARD or ENTER   equip relic",
		"ESC   close card / pause",
	]
	for line in lines:
		var l := _label(line, 14, BONE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	box.add_child(spacer2)
	var resume := Button.new()
	resume.text = "RESUME"
	resume.custom_minimum_size = Vector2(200, 44)
	resume.add_theme_font_size_override("font_size", 18)
	resume.add_theme_color_override("font_color", AMBER)
	resume.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72))
	resume.add_theme_stylebox_override("normal", _stylebox(Color(0.1, 0.04, 0.05, 0.95), Color(0.5, 0.28, 0.1, 1.0), 1))
	resume.add_theme_stylebox_override("hover", _stylebox(Color(0.2, 0.08, 0.07, 0.98), Color(0.9, 0.55, 0.2, 1.0), 1))
	resume.add_theme_stylebox_override("pressed", _stylebox(Color(0.3, 0.1, 0.08, 1.0), Color(1.0, 0.7, 0.3, 1.0), 1))
	resume.button_down.connect(toggle_pause)
	var center := CenterContainer.new()
	center.add_child(resume)
	box.add_child(center)


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
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_P):
		if compare_panel.visible:
			hide_compare()
		elif not death_panel.visible:
			toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	if death_panel.visible:
		return
	var now := Time.get_ticks_msec()
	if now - last_pause_ms < 80:
		return
	last_pause_ms = now
	var paused := not get_tree().paused
	get_tree().paused = paused
	pause_shade.visible = paused
	pause_panel.visible = paused
	ui_click.emit()


func _equip_pending() -> void:
	if pending_item.is_empty():
		return
	if Time.get_ticks_msec() - compare_shown_ms < 400:
		return
	var item := pending_item
	pending_item = {}
	compare_panel.visible = false
	equip_requested.emit(item)


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


func set_layer_info(layer: int, remaining: int, total: int, kills := 0) -> void:
	layer_label.text = "RIFT LAYER %d" % layer
	wave_label.text = "HOSTILES REMAIN  %d / %d    ·    SOULS %d" % [remaining, total, kills]
	if wave_bar != null:
		var cleared := 0.0
		if total > 0:
			cleared = clampf(float(total - remaining) / float(total), 0.0, 1.0)
		wave_bar.value = cleared * 100.0


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
	for i in slots.size():
		var slot: Dictionary = slots[i]
		var cd := 0.0
		var total := 1.0
		var affordable := true
		if i < cooldowns.size():
			cd = float(cooldowns[i])
			total = float(Player.ABILITIES[i].cooldown)
			var cost := 0.0
			if i < costs.size():
				cost = float(costs[i])
			else:
				cost = float(Player.ABILITIES[i].cost)
			affordable = cost <= 0.0 or health > cost + 1.0
			var cost_label: Label = slot.get("cost")
			if cost_label != null:
				cost_label.text = "FREE" if cost <= 0.0 else "%d VITAE" % int(cost)
				if not affordable:
					cost_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.24))
				else:
					cost_label.add_theme_color_override("font_color", GOLD if cost <= 0.0 else CRIMSON)
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


func set_relic(item: Dictionary) -> void:
	if item.is_empty():
		relic_name.text = "Empty Binding"
		relic_name.add_theme_color_override("font_color", MUTED)
		relic_stats.text = "Walk over a relic to compare."
		return
	relic_name.text = String(item.get("name", "Relic"))
	relic_name.add_theme_color_override("font_color", item.get("color", BONE))
	var parts: Array = []
	for line in ItemDB.mod_lines(item):
		parts.append(String(line.text))
	if String(item.get("unique", "")) != "":
		parts.append(String(item.get("unique_text", "")))
	relic_stats.text = "\n".join(parts)


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


func show_compare(item: Dictionary, equipped: Dictionary) -> void:
	pending_item = item
	compare_shown_ms = Time.get_ticks_msec()
	for child in compare_box.get_children():
		if child != compare_hint:
			compare_box.remove_child(child)
			child.queue_free()
	var title := _label("%s  ·  %s RELIC" % [String(item.get("name", "")), String(item.get("rarity_name", "")).to_upper()], 20, item.get("color", BONE))
	compare_box.add_child(title)
	var accent: Color = item.get("color", Color(0.5, 0.3, 0.1))
	compare_panel.add_theme_stylebox_override("panel", _stylebox(Color(0.04, 0.025, 0.045, 0.96), accent, 2))
	var unique := String(item.get("unique_text", ""))
	if unique != "":
		var u := _label(unique, 14, GOLD)
		u.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		compare_box.add_child(u)
	var lines := ItemDB.mod_lines(item)
	for line in lines:
		var key := String(line.key)
		var new_value := float(line.value)
		var old_value := ItemDB.total(equipped, key)
		var delta := new_value - old_value
		var text := String(line.text)
		if not equipped.is_empty():
			if absf(delta) >= 0.05:
				text += "   (%s%s)" % ["+" if delta > 0.0 else "", str(snappedf(delta, 0.1))]
		var color := Color(0.72, 0.95, 0.6) if delta > 0.0 else (Color(1.0, 0.45, 0.4) if delta < 0.0 else MUTED)
		if equipped.is_empty():
			color = BONE
		var l := _label(text, 15, color, false)
		compare_box.add_child(l)
	compare_box.move_child(compare_hint, compare_box.get_child_count() - 1)
	compare_panel.visible = true
	compare_panel.modulate.a = 0.0
	var tween := compare_panel.create_tween()
	tween.tween_property(compare_panel, "modulate:a", 1.0, 0.14)


func hide_compare() -> void:
	pending_item = {}
	compare_panel.visible = false


func show_death(layer_reached: int, kills: int, relic_name_text: String) -> void:
	get_tree().paused = false
	pause_shade.visible = false
	pause_panel.visible = false
	death_panel.visible = true
	death_stats.text = "Layer %d reached  ·  %d souls shattered\nRelic carried: %s\nDeepest rift: layer %d" % [layer_reached, kills, relic_name_text, maxi(record_layer, layer_reached)]


func hide_death() -> void:
	death_panel.visible = false


func hide_title() -> void:
	if not title_panel.visible:
		return
	var tween := title_panel.create_tween()
	tween.tween_property(title_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: title_panel.visible = false)


func _process(delta: float) -> void:
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
	if compare_panel.visible and Time.get_ticks_msec() - compare_shown_ms > 10000:
		hide_compare()
	var pulse := 0.0
	if low_health > 0.0:
		pulse = 0.22 + 0.12 * sin(Time.get_ticks_msec() / 220.0)
	vignette.modulate.a = clampf(vignette_alpha + pulse, 0.0, 1.0)
