class_name BloodBolt
extends Area3D

signal hit_something(position: Vector3)

var direction := Vector3.FORWARD
var speed := 26.0
var damage := 20.0
var crit := false
var hostile := false
var pierce := 0
var hits := 0
var life := 2.2
var color := Color(1.0, 0.16, 0.1)
var already_hit: Array = []
var mesh_inst: MeshInstance3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.55
	shape.shape = sphere
	add_child(shape)
	collision_layer = 8 if hostile else 16
	collision_mask = 2 if hostile else 4
	monitoring = true
	body_entered.connect(_on_body_entered)
	_build_visual()
	var timer := Timer.new()
	timer.wait_time = life
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()


func _build_visual() -> void:
	mesh_inst = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.24
	sphere.height = 0.48
	mesh_inst.mesh = sphere
	mesh_inst.material_override = FX.glow_material(color)
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_inst)
	var trail := MeshInstance3D.new()
	var trail_quad := QuadMesh.new()
	trail_quad.size = Vector2(0.55, 1.9)
	trail.mesh = trail_quad
	var trail_mat := StandardMaterial3D.new()
	trail_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	trail_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	trail_mat.albedo_texture = FX.soft_texture()
	trail_mat.albedo_color = Color(color.r, color.g, color.b, 0.6)
	trail_mat.disable_receive_shadows = true
	trail_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	trail.material_override = trail_mat
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	trail.position = Vector3(0.0, 0.0, -0.85)
	add_child(trail)
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 2.4
	light.omni_range = 4.0
	light.shadow_enabled = false
	add_child(light)
	var particles := GPUParticles3D.new()
	particles.amount = 16
	particles.lifetime = 0.5
	particles.local_coords = false
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = 0.2
	proc.direction = Vector3.ZERO
	proc.spread = 180.0
	proc.initial_velocity_min = 0.2
	proc.initial_velocity_max = 1.2
	proc.gravity = Vector3.ZERO
	proc.scale_min = 0.12
	proc.scale_max = 0.34
	proc.color = Color(color.r, color.g, color.b, 0.8)
	particles.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	quad.material = FX.spark_material(Color(1, 1, 1, 1))
	particles.draw_pass_1 = quad
	add_child(particles)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	if direction.length_squared() > 0.001:
		look_at(global_position + direction, Vector3.UP)


func _on_body_entered(body: Node) -> void:
	if body == null or already_hit.has(body):
		return
	if hostile and body is Player:
		already_hit.append(body)
		body.take_damage(damage)
		_impact()
		return
	if not hostile and body is Enemy:
		already_hit.append(body)
		body.take_damage(damage, crit)
		hits += 1
		FX.burst(get_parent(), body.global_position + Vector3(0.0, 1.0, 0.0), Color(color.r, color.g, color.b, 0.9), 10, 4.5, 0.3, 0.35)
		if hits > pierce:
			_impact()


func _impact() -> void:
	hit_something.emit(global_position)
	queue_free()
