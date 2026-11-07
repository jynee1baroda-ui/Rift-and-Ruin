class_name FX
extends RefCounted

static var _soft_texture: Texture2D
static var _spark_materials: Dictionary = {}


static func soft_texture() -> Texture2D:
	if _soft_texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
		gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0)])
		var tex := GradientTexture2D.new()
		tex.gradient = gradient
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 64
		tex.height = 64
		_soft_texture = tex
	return _soft_texture


static func spark_material(color: Color, additive := true) -> StandardMaterial3D:
	var key := color.to_html() + str(additive)
	if _spark_materials.has(key):
		return _spark_materials[key]
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	mat.albedo_texture = soft_texture()
	mat.albedo_color = Color(color.r * 0.55, color.g * 0.55, color.b * 0.55, color.a)
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	_spark_materials[key] = mat
	return mat


static func glow_material(color: Color, additive := true) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	return mat


static func burst(parent: Node, global_pos: Vector3, color: Color, amount := 26, speed := 7.0, size := 0.5, lifetime := 0.7, gravity := -7.0, spread := 180.0) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var particles := GPUParticles3D.new()
	particles.amount = maxi(4, amount)
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 0.92
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = 0.4
	proc.direction = Vector3.UP
	proc.spread = spread
	proc.initial_velocity_min = speed * 0.35
	proc.initial_velocity_max = speed
	proc.gravity = Vector3(0.0, gravity, 0.0)
	proc.damping_min = 1.5
	proc.damping_max = 4.0
	proc.scale_min = size * 0.45
	proc.scale_max = size
	proc.color = color
	particles.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1.0, 1.0)
	quad.material = spark_material(Color(1, 1, 1, 1))
	particles.draw_pass_1 = quad
	parent.add_child(particles)
	particles.global_position = global_pos
	particles.emitting = true
	particles.finished.connect(particles.queue_free)


static func ring(parent: Node, global_pos: Vector3, color: Color, radius := 3.0, duration := 0.45, thickness := 0.06) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var mesh_inst := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(0.05, 1.0 - thickness)
	torus.outer_radius = 1.0
	torus.rings = 48
	torus.ring_segments = 6
	mesh_inst.mesh = torus
	var mat := glow_material(color)
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.scale = Vector3(0.25, 1.0, 0.25)
	parent.add_child(mesh_inst)
	mesh_inst.global_position = global_pos + Vector3(0.0, 0.12, 0.0)
	var tween := mesh_inst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_inst, "scale", Vector3(radius, 1.0, radius), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(mesh_inst.queue_free)


static func disc(parent: Node, global_pos: Vector3, color: Color, radius := 3.0, duration := 0.4, height := 0.05) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var mesh_inst := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 1.0
	cylinder.bottom_radius = 1.0
	cylinder.height = height
	cylinder.radial_segments = 32
	cylinder.rings = 1
	mesh_inst.mesh = cylinder
	var mat := glow_material(color)
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.scale = Vector3(0.15, 1.0, 0.15)
	parent.add_child(mesh_inst)
	mesh_inst.global_position = global_pos + Vector3(0.0, 0.1, 0.0)
	var tween := mesh_inst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_inst, "scale", Vector3(radius, 1.0, radius), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(mesh_inst.queue_free)


static func nova(parent: Node, global_pos: Vector3, color: Color, radius := 4.0) -> void:
	disc(parent, global_pos, Color(color.r, color.g, color.b, 0.55), radius, 0.4)
	ring(parent, global_pos, color, radius, 0.5, 0.09)
	ring(parent, global_pos, Color(color.r, color.g, color.b, 0.45), radius * 0.62, 0.34, 0.05)
	burst(parent, global_pos + Vector3(0.0, 0.5, 0.0), color, 40, 9.0, 0.7, 0.75)
	burst(parent, global_pos + Vector3(0.0, 0.2, 0.0), Color(1.0, 0.86, 0.55, 0.95), 16, 3.4, 0.34, 0.5, -1.5)
	if parent != null and parent.is_inside_tree():
		var light := OmniLight3D.new()
		light.light_color = color
		light.light_energy = 5.0
		light.omni_range = radius * 2.4
		light.shadow_enabled = false
		parent.add_child(light)
		light.global_position = global_pos + Vector3(0.0, 1.3, 0.0)
		var lt := light.create_tween()
		lt.tween_property(light, "light_energy", 0.0, 0.45).set_ease(Tween.EASE_IN)
		lt.tween_callback(light.queue_free)


static func flash_mesh(root: Node, color: Color, duration := 0.18) -> void:
	if root == null or not root.is_inside_tree():
		return
	var entries: Array = []
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh == null:
			continue
		var previous: Material = mesh.material_overlay
		var mat := glow_material(Color(color.r, color.g, color.b, 0.55))
		mesh.material_overlay = mat
		entries.append({"mesh": mesh, "mat": mat, "prev": previous})
	if entries.is_empty():
		return
	var tween := root.create_tween()
	for entry in entries:
		tween.parallel().tween_property(entry.mat, "albedo_color:a", 0.0, duration)
	tween.chain().tween_callback(func() -> void:
		for entry in entries:
			if is_instance_valid(entry.mesh):
				entry.mesh.material_overlay = entry.prev
	)


static func damage_number(parent: Node, global_pos: Vector3, amount: float, crit := false, color := Color(1.0, 0.82, 0.42)) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	if not bool(GameSettings.get_value("damage_numbers")):
		return
	var label := Label3D.new()
	label.text = str(int(round(amount)))
	label.font_size = 72 if crit else 48
	label.pixel_size = 0.0032
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = color
	label.outline_size = 14
	label.outline_modulate = Color(0.02, 0.0, 0.02, 0.9)
	label.scale = Vector3(1.25, 1.25, 1.25) if crit else Vector3.ONE
	parent.add_child(label)
	label.global_position = global_pos + Vector3(randf_range(-0.45, 0.45), 0.0, randf_range(-0.45, 0.45))
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y + 1.7, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.85).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


static func sparkle(parent: Node, global_pos: Vector3, color: Color) -> void:
	burst(parent, global_pos, color, 18, 4.0, 0.35, 0.9, -1.0, 90.0)
	ring(parent, global_pos, Color(color.r, color.g, color.b, 0.8), 1.6, 0.5, 0.05)


static func beam(parent: Node, from: Vector3, target: Vector3, color: Color, width := 0.09, duration := 0.3) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var dir := target - from
	var dist := dir.length()
	if dist < 0.05:
		return
	var mesh_inst := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = width
	cylinder.bottom_radius = width * 0.5
	cylinder.height = dist
	cylinder.radial_segments = 6
	mesh_inst.mesh = cylinder
	var mat := glow_material(color)
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mesh_inst)
	mesh_inst.global_position = (from + target) * 0.5
	dir = dir.normalized()
	var axis := Vector3.UP.cross(dir)
	if axis.length() > 0.0001:
		mesh_inst.global_transform.basis = Basis(axis.normalized(), Vector3.UP.angle_to(dir))
	var tween := mesh_inst.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, duration)
	tween.tween_callback(mesh_inst.queue_free)
