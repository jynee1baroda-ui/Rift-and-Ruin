class_name GameHUD
extends CanvasLayer

signal equip_requested(item: Dictionary, slot: int)
signal unequip_requested(slot: int)
signal discard_requested
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
const ICON_NOVA := "res://art/generated/icon_nova/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037296460-0_1794037296461_2fben6it.png"
const ICON_LANCE := "res://art/generated/icon_lance/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037334226-0_1794037334226_0jajynkv.png"
const ICON_SIPHON := "res://art/generated/icon_siphon/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794037347430-0_1794037347430_d38c0j6p.png"

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
var theme_label: Label
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
var relic_rows: Array = []
var relics: Array = []
var relic_tab := "relics"
var relic_opened_ms := 0
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
	_build_ability_flash()
	body = Control.new()
	body.name = "RunHUD"
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.visible = false
	body.modulate.a = 0.0
	root.add_child(body)
	_build_minimap()
	_build_top()
	_build_boss()
	_build_health()
	_build_abilities()
	_build_relic()
	_build_toasts()
	_build_relic_window()
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
	var controls_hint := _label("WASD MOVE  ·  LMB ATTACK  ·  RMB LANCE  ·  1 2 3 CAST  ·  SPACE RIFTSTEP  ·  TAB RELICS", 12, MUTED)
	controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(controls_hint)


func _build_boss() -> void:
	boss_panel = PanelContainer.new()
	boss_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_panel.anchor_left = 0.5
	boss_panel.anchor_right = 0.5
	boss_panel.offset_left = -270.0
	boss_panel.offset_right = 270.0
	boss_panel.offset_top = 196.0
	boss_panel.offset_bottom = 250.0
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
	var icon_paths := [ICON_NOVA, ICON_LANCE, ICON_SIPHON]
	for ability_index in Player.ABILITIES.size():
		var ability: Dictionary = Player.ABILITIES[ability_index]
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
		var icon_path := String(icon_paths[ability_index])
		if ResourceLoader.exists(icon_path):
			var icon_box := Control.new()
			icon_box.position = Vector2(8, 21)
			icon_box.size = Vector2(36, 36)
			icon_box.custom_minimum_size = Vector2(36, 36)
			icon_box.clip_contents = true
			icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			panel.add_child(icon_box)
			var icon := TextureRect.new()
			icon.texture = load(icon_path)
			icon.set_anchors_preset(Control.PRESET_FULL_RECT)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon_box.add_child(icon)
		var name_label := _label(String(ability.glyph), 15, BONE)
		name_label.position = Vector2(50, 8)
		panel.add_child(name_label)
		var cost := float(ability.cost)
		var cost_label := _label("FREE" if cost <= 0.0 else "%d VITAE" % int(cost), 11, CRIMSON)
		cost_label.position = Vector2(50, 28)
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
	panel.offset_left = -300.0
	panel.offset_right = -26.0
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
	relic_window.offset_bottom = 238.0
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
	box.offset_top = -215.0
	box.offset_bottom = 215.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_panel.add_child(box)
	title_label = _label("RIFT & RUIN", 84, AMBER)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title_label)
	var sub := _label("THE BLOOD SORCERESS", 20, CRIMSON)
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
		"WASD to move. Click a demon to lance it.",
		"1  BLOOD NOVA      detonate your life force",
		"2  CRIMSON LANCE   pierce the pack",
		"3  SANGUINE SIPHON drink their wounds closed",
		"SPACE  RIFTSTEP    slide over lava",
		"TAB  relic loadout   ·   click a glowing drop to claim it",
		"Click ground to walk  ·  click skill cards to cast  ·  ESC pauses",
		"Clear every pack, step into the rift, go deeper.",
	]
	for line in lines:
		var l := _label(line, 15, BONE)
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
		"WASD / ARROWS      move",
		"CLICK GROUND       walk there",
		"CLICK A FOE        crimson lance",
		"1   BLOOD NOVA     6 vitae",
		"2   CRIMSON LANCE  3 vitae",
		"3   SANGUINE SIPHON free",
		"SPACE   RIFTSTEP   dash over lava",
		"TAB   relic loadout and synergies",
		"CLICK A SKILL CARD   cast without a hotkey",
		"MOUSE WHEEL   camera zoom",
		"ESC   close card / pause",
	]
	for line in lines:
		var l := _label(line, 13, BONE)
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
		if relic_window.visible:
			close_relic_window()
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


func set_theme_name(text: String) -> void:
	if theme_label != null:
		theme_label.text = text


func set_boss(name_text: String, ratio: float, active: bool) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = active
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
	var pulse := 0.0
	if low_health > 0.0:
		pulse = 0.22 + 0.12 * sin(Time.get_ticks_msec() / 220.0)
	vignette.modulate.a = clampf(vignette_alpha + pulse, 0.0, 1.0)
