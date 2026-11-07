class_name LavaEruption
extends Node3D

signal exploded(at: Vector3)

var radius := 3.0
var damage := 20.0
var telegraph := 1.1
var elapsed := 0.0
var player: Player
var fired := false
var disc: MeshInstance3D
var disc_mat: StandardMaterial3D
var ring_mesh: MeshInstance3D
var ring_mat: StandardMaterial3D


func _ready() -> void:
	disc = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	disc.mesh = quad
	disc_mat = StandardMaterial3D.new()
	disc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	disc_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	disc_mat.albedo_texture = FX.soft_texture()
	disc_mat.albedo_color = Color(1.0, 0.34, 0.05, 0.3)
	disc_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	disc_mat.disable_receive_shadows = true
	disc.material_override = disc_mat
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	disc.position.y = 0.06
	disc.scale = Vector3(0.4, 0.4, 1.0)
	add_child(disc)
	var torus := TorusMesh.new()
	torus.inner_radius = 0.9
	torus.outer_radius = 1.0
	torus.rings = 88
	torus.ring_segments = 8
	ring_mesh = MeshInstance3D.new()
	ring_mesh.mesh = torus
	ring_mat = FX.glow_material(Color(1.0, 0.5, 0.12, 0.9))
	ring_mesh.material_override = ring_mat
	ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring_mesh.position.y = 0.09
	add_child(ring_mesh)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.4, 0.1)
	light.light_energy = 1.4
	light.omni_range = radius * 2.0
	light.shadow_enabled = false
	light.position.y = 0.6
	add_child(light)


func set_player(target: Player) -> void:
	player = target


func _process(delta: float) -> void:
	if fired:
		return
	elapsed += delta
	var t := clampf(elapsed / telegraph, 0.0, 1.0)
	var size := radius * (0.35 + 0.65 * t)
	disc.scale = Vector3(size, size, 1.0)
	ring_mesh.scale = Vector3(size, 1.0, size)
	var pulse := 0.5 + 0.5 * sin(elapsed * 16.0)
	disc_mat.albedo_color = Color(1.0, 0.32, 0.04, 0.12 + 0.26 * pulse)
	ring_mat.albedo_color = Color(1.0, 0.5, 0.12, 0.55 + 0.45 * pulse)
	if elapsed >= telegraph:
		_fire()


func _fire() -> void:
	fired = true
	FX.nova(get_parent(), global_position, Color(1.0, 0.42, 0.06, 1.0), radius)
	FX.burst(get_parent(), global_position + Vector3(0.0, 0.4, 0.0), Color(1.0, 0.45, 0.1, 1.0), 34, 8.0, 0.7, 0.9)
	if player != null and is_instance_valid(player) and player.alive:
		var offset := player.global_position - global_position
		offset.y = 0.0
		if offset.length() <= radius + 0.4:
			player.take_damage(damage)
	exploded.emit(global_position)
	queue_free()
