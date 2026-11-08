class_name FX
extends RefCounted

static var _soft_texture: Texture2D
static var _spark_materials: Dictionary = {}
static var _ring_textures: Dictionary = {}


static func soft_texture() -> Texture2D:
	if _soft_texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.18, 0.42, 0.7, 1.0])
		gradient.colors = PackedColorArray([
			Color(1, 1, 1, 0.92),
			Color(1, 1, 1, 0.66),
			Color(1, 1, 1, 0.3),
			Color(1, 1, 1, 0.08),
			Color(1, 1, 1, 0.0),
		])
		var tex := GradientTexture2D.new()
		tex.gradient = gradient
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 128
		tex.height = 128
		_soft_texture = tex
	return _soft_texture


static func ring_texture(thickness: float) -> Texture2D:
	var band := clampf(thickness, 0.02, 0.34)
	var key := "%.3f" % band
	if _ring_textures.has(key):
		return _ring_textures[key]
	var inner := clampf(1.0 - band * 3.2, 0.18, 0.94)
	var peak := inner + (1.0 - inner) * 0.55
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, inner, peak, 0.985, 1.0])
	gradient.colors = PackedColorArray([
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, 0.06),
		Color(1, 1, 1, 0.95),
		Color(1, 1, 1, 0.16),
		Color(1, 1, 1, 0.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256
	tex.height = 256
	_ring_textures[key] = tex
	return tex


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
	quad.size = Vector2(0.7, 0.7)
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
	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	mesh_inst.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_texture = ring_texture(thickness)
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	mesh_inst.scale = Vector3(0.16, 0.16, 1.0)
	parent.add_child(mesh_inst)
	mesh_inst.global_position = global_pos + Vector3(0.0, 0.12, 0.0)
	var tween := mesh_inst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_inst, "scale", Vector3(radius, radius, 1.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(mesh_inst.queue_free)


static func disc(parent: Node, global_pos: Vector3, color: Color, radius := 3.0, duration := 0.4, height := 0.05) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var mesh_inst := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	mesh_inst.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_texture = soft_texture()
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	mesh_inst.scale = Vector3(0.12, 0.12, 1.0)
	parent.add_child(mesh_inst)
	mesh_inst.global_position = global_pos + Vector3(0.0, height + 0.05, 0.0)
	var tween := mesh_inst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_inst, "scale", Vector3(radius, radius, 1.0), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(mesh_inst.queue_free)


## A held ground shape that warns exactly where an attack will land: it snaps
## on, stays lit for `duration`, then blazes and vanishes as the blow lands.
## `points` is a polygon in world space; the shape is drawn in its own plane.
static func telegraph_shape(parent: Node, points: PackedVector3Array, color: Color, duration := 0.7) -> void:
	if parent == null or not parent.is_inside_tree() or points.size() < 3:
		return
	var mid := Vector3.ZERO
	for p in points:
		mid += p
	mid /= float(points.size())
	var verts := PackedVector3Array([Vector3.ZERO])
	for p in points:
		var local := p - mid
		local.y = 0.0
		verts.append(local)
	var indices := PackedInt32Array()
	var count := points.size()
	for i in range(1, count):
		indices.append_array([0, i, i + 1])
	indices.append_array([0, count, 1])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(color.r, color.g, color.b, 0.0)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	mesh_inst.material_override = mat
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mesh_inst)
	mesh_inst.global_position = Vector3(mid.x, mid.y + 0.07, mid.z)
	var tween := mesh_inst.create_tween()
	tween.tween_property(mat, "albedo_color:a", color.a, 0.10)
	tween.tween_interval(maxf(0.02, duration - 0.22))
	tween.tween_property(mat, "albedo_color:a", minf(1.0, color.a * 2.2), 0.12)
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.10)
	tween.tween_callback(mesh_inst.queue_free)


## The warning corridor of a charge: a wide strip from the attacker to where it
## will stop, plus a bright seam down the middle.
static func telegraph_line(parent: Node, from: Vector3, dir: Vector3, length: float, half_width: float, color: Color, duration := 0.7) -> void:
	var flat := Vector3(dir.x, 0.0, dir.z)
	if flat.length_squared() < 0.0001:
		return
	flat = flat.normalized()
	var side := Vector3(-flat.z, 0.0, flat.x) * half_width
	var a := Vector3(from.x, from.y, from.z)
	var b := a + flat * length
	telegraph_shape(parent, PackedVector3Array([a + side, b + side, b - side, a - side]), color, duration)
	var seam := Color(color.r, color.g, color.b, minf(1.0, color.a * 1.7))
	telegraph_shape(parent, PackedVector3Array([
		a + side * 0.06, b + side * 0.06, b - side * 0.06, a - side * 0.06]), seam, duration)


## The warning cone of a fan or breath attack. `half_angle` is in degrees and
## the fan is drawn in the ground plane around `dir`.
static func telegraph_cone(parent: Node, origin: Vector3, dir: Vector3, reach: float, half_angle: float, color: Color, duration := 0.7, segments := 14) -> void:
	var flat := Vector3(dir.x, 0.0, dir.z)
	if flat.length_squared() < 0.0001 or reach <= 0.1:
		return
	flat = flat.normalized()
	var points := PackedVector3Array([Vector3(origin.x, 0.0, origin.z)])
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var angle := deg_to_rad(lerpf(-half_angle, half_angle, t))
		var edge := flat.rotated(Vector3.UP, angle) * reach
		points.append(Vector3(origin.x + edge.x, 0.0, origin.z + edge.z))
	telegraph_shape(parent, points, color, duration)


## The warning circle of a storm or slam: a filled disc with a hard rim, held
## for the full windup instead of blooming and fading like an impact.
static func telegraph_circle(parent: Node, centre: Vector3, radius: float, color: Color, duration := 0.7) -> void:
	if parent == null or not parent.is_inside_tree() or radius <= 0.1:
		return
	var fill := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	fill.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_texture = soft_texture()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.0)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	fill.material_override = mat
	fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fill.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	fill.scale = Vector3(radius, radius, 1.0)
	parent.add_child(fill)
	fill.global_position = centre + Vector3(0.0, 0.06, 0.0)
	var rim := MeshInstance3D.new()
	var rim_quad := QuadMesh.new()
	rim_quad.size = Vector2(2.0, 2.0)
	rim.mesh = rim_quad
	var rim_mat := StandardMaterial3D.new()
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rim_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	rim_mat.albedo_texture = ring_texture(0.035)
	rim_mat.albedo_color = Color(color.r, color.g, color.b, 0.0)
	rim_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	rim_mat.disable_receive_shadows = true
	rim_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	rim.material_override = rim_mat
	rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	rim.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	rim.scale = Vector3(radius, radius, 1.0)
	parent.add_child(rim)
	rim.global_position = centre + Vector3(0.0, 0.09, 0.0)
	var hold := maxf(0.02, duration - 0.22)
	for pair in [[mat, fill], [rim_mat, rim]]:
		var m: StandardMaterial3D = pair[0]
		var node: MeshInstance3D = pair[1]
		var tween := node.create_tween()
		tween.tween_property(m, "albedo_color:a", color.a, 0.10)
		tween.tween_interval(hold)
		tween.tween_property(m, "albedo_color:a", minf(1.0, color.a * 2.4), 0.12)
		tween.tween_property(m, "albedo_color:a", 0.0, 0.10)
		tween.tween_callback(node.queue_free)


static func mist(parent: Node, global_pos: Vector3, color: Color, amount := 16, radius := 2.4, lifetime := 1.2) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var particles := GPUParticles3D.new()
	particles.amount = maxi(4, amount)
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 0.5
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = radius * 0.3
	proc.direction = Vector3.UP
	proc.spread = 75.0
	proc.initial_velocity_min = 0.35
	proc.initial_velocity_max = 1.3
	proc.gravity = Vector3(0.0, 0.22, 0.0)
	proc.damping_min = 1.1
	proc.damping_max = 2.2
	proc.scale_min = radius * 0.3
	proc.scale_max = radius * 0.75
	proc.color = color
	particles.process_material = proc
	var quad := QuadMesh.new()
	quad.material = spark_material(Color(1, 1, 1, 1), false)
	particles.draw_pass_1 = quad
	parent.add_child(particles)
	particles.global_position = global_pos
	particles.emitting = true
	particles.finished.connect(particles.queue_free)


static func nova(parent: Node, global_pos: Vector3, color: Color, radius := 4.0) -> void:
	var reach := clampf(4.4 / maxf(radius, 0.6), 0.22, 1.0)
	var thin := clampf(radius * 0.016, 0.026, 0.085)
	disc(parent, global_pos, Color(color.r, color.g, color.b, 0.15 * reach), radius, 0.5)
	ring(parent, global_pos, Color(color.r, color.g, color.b, color.a * 0.9), radius, 0.55, thin)
	ring(parent, global_pos, Color(color.r, color.g, color.b, color.a * 0.4), radius * 0.58, 0.36, thin * 0.7)
	burst(parent, global_pos + Vector3(0.0, 0.5, 0.0), color, 54, 9.0, 0.52, 0.8)
	burst(parent, global_pos + Vector3(0.0, 0.2, 0.0), Color(1.0, 0.86, 0.55, 0.95), 22, 3.6, 0.22, 0.55, -1.5)
	mist(parent, global_pos + Vector3(0.0, 0.55, 0.0), Color(0.2, 0.04, 0.04, 0.16), 14, radius * 0.7, 1.4)
	embers(parent, global_pos, Color(1.0, 0.52, 0.2, 0.85), 16, radius * 0.55)
	if parent != null and parent.is_inside_tree():
		var light := OmniLight3D.new()
		light.light_color = color
		light.light_energy = 4.2
		light.omni_range = radius * 2.4
		light.shadow_enabled = false
		parent.add_child(light)
		light.global_position = global_pos + Vector3(0.0, 1.3, 0.0)
		var lt := light.create_tween()
		lt.tween_property(light, "light_energy", 0.0, 0.45).set_ease(Tween.EASE_IN)
		lt.tween_callback(light.queue_free)


static func embers(parent: Node, global_pos: Vector3, color: Color, amount := 14, radius := 2.0) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var particles := GPUParticles3D.new()
	particles.amount = maxi(4, amount)
	particles.lifetime = 1.6
	particles.one_shot = true
	particles.explosiveness = 0.7
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = radius
	proc.direction = Vector3.UP
	proc.spread = 42.0
	proc.initial_velocity_min = 0.8
	proc.initial_velocity_max = 2.6
	proc.gravity = Vector3(0.0, -3.4, 0.0)
	proc.damping_min = 0.4
	proc.damping_max = 1.0
	proc.scale_min = 0.05
	proc.scale_max = 0.13
	proc.color = color
	particles.process_material = proc
	var quad := QuadMesh.new()
	quad.material = spark_material(Color(1, 1, 1, 1))
	particles.draw_pass_1 = quad
	parent.add_child(particles)
	particles.global_position = global_pos + Vector3(0.0, 0.18, 0.0)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)


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


## Sharp flying fragments. Hard-edged additive shards read as struck stone and
## metal instead of the soft round motes a plain particle burst gives.
static func shards(parent: Node, global_pos: Vector3, color: Color, amount := 12, reach := 1.6, rise := 2.0, lifetime := 0.55) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var group := Node3D.new()
	parent.add_child(group)
	group.global_position = global_pos
	var mat := glow_material(color, true)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.035, 0.035, 0.19)
	for i in amount:
		var shard := MeshInstance3D.new()
		shard.mesh = mesh
		shard.material_override = mat
		shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var angle := TAU * float(i) / float(maxi(1, amount)) + randf_range(-0.25, 0.25)
		var out := Vector3(cos(angle), 0.0, sin(angle)) * reach * randf_range(0.55, 1.2)
		var up := Vector3(0.0, rise * randf_range(0.45, 1.0), 0.0)
		group.add_child(shard)
		shard.position = Vector3(0.0, 0.16, 0.0)
		shard.rotation = Vector3(randf_range(-0.5, 0.5), angle, randf_range(1.1, 2.0))
		var spin := shard.rotation + Vector3(randf_range(2.0, 6.0), randf_range(1.0, 3.5), randf_range(2.0, 7.0))
		var tween := shard.create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard, "position", shard.position + out + up, lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(shard, "rotation", spin, lifetime)
		tween.tween_property(shard, "scale", Vector3(0.15, 0.15, 0.15), lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var timer := parent.get_tree().create_timer(lifetime + 0.12)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(group):
			group.queue_free()
	)


## A crescent of light sweeping through the space in front of a body: the
## readable cue for a sword, hammer or shield blow.
static func slash(parent: Node, origin: Vector3, dir: Vector3, color: Color, reach := 2.0, duration := 0.28, arc_deg := 130.0) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var flat := Vector3(dir.x, 0.0, dir.z)
	if flat.length() < 0.05:
		return
	flat = flat.normalized()
	var group := Node3D.new()
	parent.add_child(group)
	group.global_position = origin
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = color
	mat.disable_receive_shadows = true
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	var segments := 7
	var spread := deg_to_rad(arc_deg)
	var start := atan2(flat.z, flat.x) - spread * 0.5
	var segment_len := maxf(0.22, reach * spread / float(maxi(1, segments - 1)) * 0.85)
	for i in segments:
		var t := float(i) / float(segments - 1)
		var angle := start + spread * t
		var tip := Vector3(cos(angle), 0.0, sin(angle)) * reach
		var blade := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(segment_len, 0.02, 0.045)
		blade.mesh = box
		blade.material_override = mat
		blade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		group.add_child(blade)
		blade.position = tip
		blade.rotation.y = -angle - PI * 0.5
		blade.scale = Vector3(0.85, 1.0, 0.6)
		var tween := blade.create_tween()
		tween.set_parallel(true)
		tween.tween_property(blade, "scale", Vector3(1.25, 1.0, 0.9), duration * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(blade, "scale", Vector3(0.2, 1.0, 0.2), duration * 0.65).set_delay(duration * 0.35)
	var fade := group.create_tween()
	fade.tween_interval(duration * 0.3)
	fade.tween_property(mat, "albedo_color:a", 0.0, duration * 0.7)
	fade.tween_callback(group.queue_free)


## A hot ground fault: glowing seams that split out of an impact point. Flat on
## the floor, so it sells weight under the effect and marks the hit radius.
static func fault(parent: Node, global_pos: Vector3, color: Color, radius := 2.6, branches := 7, duration := 0.9) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var group := Node3D.new()
	parent.add_child(group)
	group.global_position = global_pos + Vector3(0.0, 0.04, 0.0)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(color.r, color.g, color.b, color.a * 0.42)
	mat.disable_receive_shadows = true
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	for i in branches:
		var angle := TAU * float(i) / float(maxi(1, branches)) + randf_range(-0.18, 0.18)
		## Three short segments that kink as they run outward: a spider crack
		## rather than a beam fired from the middle of the floor.
		var steps := 3
		var step_len := radius * randf_range(0.15, 0.22)
		var cursor := Vector3.ZERO
		for s in steps:
			var seam := MeshInstance3D.new()
			var box := BoxMesh.new()
			var width := 0.062 * (1.0 - 0.26 * float(s))
			box.size = Vector3(width, 0.012, step_len)
			seam.mesh = box
			seam.material_override = mat
			seam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			group.add_child(seam)
			var dir := Vector3(0.0, 0.0, -1.0).rotated(Vector3.UP, angle)
			seam.position = cursor + dir * (step_len * 0.5) + Vector3(0.0, randf_range(0.0, 0.02), 0.0)
			seam.rotation.y = angle
			seam.scale = Vector3(1.0, 1.0, 0.01)
			var tween := seam.create_tween()
			tween.tween_interval(0.05 * float(s))
			tween.tween_property(seam, "scale", Vector3(0.85, 1.0, 1.0), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			cursor += dir * step_len
			angle += randf_range(-0.55, 0.55)
	tween_fade_group(group, mat, duration)


static func tween_fade_group(group: Node3D, mat: StandardMaterial3D, duration: float) -> void:
	var tween := group.create_tween()
	tween.tween_interval(duration * 0.35)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(group.queue_free)


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
