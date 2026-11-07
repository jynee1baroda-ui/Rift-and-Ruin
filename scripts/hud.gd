class_name GameHUD
extends CanvasLayer

signal equip_requested(item: Dictionary)
signal start_pressed

const INK := Color(0.035, 0.025, 0.045, 0.92)
const AMBER := Color(1.0, 0.72, 0.28)
const CRIMSON := Color(0.92, 0.16, 0.14)
const BONE := Color(0.90, 0.86, 0.79)
const MUTED := Color(0.62, 0.56, 0.56)
const GOLD := Color(1.0, 0.83, 0.35)

var root: Control
var health_bar: ProgressBar
var health_label: Label
var layer_label: Label
var wave_label: Label
var slots: Array = []
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
var status_label: Label
var pending_item: Dictionary = {}
var compare_shown_ms := 0
var vignette_alpha := 0.0
var low_health := 0.0


func _ready() -> void:
	layer = 10
	_build()


func _stylebox(color: Color, border: Color, width := 1, radius := 3) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
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
	_build_vignette()
	_build_top()
	_build_health()
	_build_abilities()
	_build_relic()
	_build_toasts()
	_build_compare()
	_build_death()
	_build_title()


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
	root.add_child(box)
	layer_label = _label("RIFT LAYER 1", 34, AMBER)
	layer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(layer_label)
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
	box.offset_bottom = -108.0
	box.offset_top = -164.0
	box.offset_right = 320.0
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(box)
	health_label = _label("VITAE 140 / 140", 15, BONE)
	box.add_child(health_label)
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(280, 22)
	health_bar.show_percentage = false
	health_bar.max_value = 100.0
	health_bar.value = 100.0
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.06, 0.02, 0.03, 0.9)
	bg.border_color = Color(0.35, 0.12, 0.12, 1.0)
	bg.set_border_width_all(1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.72, 0.06, 0.09, 1.0)
	health_bar.add_theme_stylebox_override("background", bg)
	health_bar.add_theme_stylebox_override("fill", fill)
	box.add_child(health_bar)


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
	root.add_child(box)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	for ability in Player.ABILITIES:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(150, 62)
		panel.add_theme_stylebox_override("panel", _stylebox(INK, Color(0.3, 0.16, 0.12, 1.0), 1))
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(panel)
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
		slots.append({"panel": panel, "overlay": overlay, "cd": cd_label, "name": name_label})
	var dash := Panel.new()
	dash.custom_minimum_size = Vector2(96, 62)
	dash.add_theme_stylebox_override("panel", _stylebox(INK, Color(0.24, 0.2, 0.3, 1.0), 1))
	dash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dash)
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
	slots.append({"panel": dash, "overlay": null, "cd": dash_cd, "name": dash_name})
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
	root.add_child(panel)
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
	toast_box.offset_top = 122.0
	toast_box.alignment = BoxContainer.ALIGNMENT_CENTER
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(toast_box)


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
	var title := _label("RIFT & RUIN", 92, AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := _label("THE BLOOD SORCERESS", 22, CRIMSON)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
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


func _on_compare_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_equip_pending()


func _equip_pending() -> void:
	if pending_item.is_empty():
		return
	if Time.get_ticks_msec() - compare_shown_ms < 400:
		return
	var item := pending_item
	pending_item = {}
	compare_panel.visible = false
	equip_requested.emit(item)


func set_health(current: float, maximum: float) -> void:
	var ratio := 0.0
	if maximum > 0.0:
		ratio = clampf(current / maximum, 0.0, 1.0)
	health_bar.value = ratio * 100.0
	health_label.text = "VITAE  %d / %d" % [int(ceil(current)), int(maximum)]
	low_health = 1.0 if ratio < 0.32 else 0.0


func set_layer_info(layer: int, remaining: int, total: int) -> void:
	layer_label.text = "RIFT LAYER %d" % layer
	wave_label.text = "HOSTILES REMAIN  %d / %d" % [remaining, total]


func set_status(text: String) -> void:
	status_label.text = text


func set_cooldowns(cooldowns: Array, dash_cooldown: float) -> void:
	for i in slots.size():
		var slot: Dictionary = slots[i]
		var cd := 0.0
		var total := 1.0
		if i < cooldowns.size():
			cd = float(cooldowns[i])
			total = float(Player.ABILITIES[i].cooldown)
		else:
			cd = dash_cooldown
			total = 2.2
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
	toast_box.add_child(l)
	var tween := l.create_tween()
	tween.tween_property(l, "modulate:a", 0.0, 0.5).set_delay(duration)
	tween.tween_callback(l.queue_free)


func flash_damage(strength := 1.0) -> void:
	vignette_alpha = minf(1.0, maxf(vignette_alpha, 0.55 * strength))


func show_compare(item: Dictionary, equipped: Dictionary) -> void:
	pending_item = item
	compare_shown_ms = Time.get_ticks_msec()
	for child in compare_box.get_children():
		if child != compare_hint:
			compare_box.remove_child(child)
			child.queue_free()
	var title := _label("%s  ·  %s RELIC" % [String(item.get("name", "")), String(item.get("rarity_name", "")).to_upper()], 20, item.get("color", BONE))
	compare_box.add_child(title)
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


func hide_compare() -> void:
	pending_item = {}
	compare_panel.visible = false


func show_death(layer_reached: int, kills: int, relic_name_text: String) -> void:
	death_panel.visible = true
	death_stats.text = "Layer %d reached  ·  %d souls shattered\nRelic carried: %s" % [layer_reached, kills, relic_name_text]


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
	var pulse := 0.0
	if low_health > 0.0:
		pulse = 0.22 + 0.12 * sin(Time.get_ticks_msec() / 220.0)
	vignette.modulate.a = clampf(vignette_alpha + pulse, 0.0, 1.0)
