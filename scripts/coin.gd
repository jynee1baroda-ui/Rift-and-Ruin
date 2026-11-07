class_name CoinDrop
extends Node3D

signal collected(amount: int)

var amount := 1
var target: Player
var age := 0.0
var magnet_range := 8.5
var taken := false
var stack: Node3D


func setup(value: int, player_node: Player) -> void:
	amount = maxi(1, value)
	target = player_node


func _ready() -> void:
	stack = Node3D.new()
	add_child(stack)
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.95, 0.68, 0.22)
	gold.metallic = 0.95
	gold.roughness = 0.28
	gold.emission_enabled = true
	gold.emission = Color(1.0, 0.62, 0.16)
	gold.emission_energy_multiplier = 0.55
	var discs := 1 + mini(3, int(float(amount - 1) / 6.0))
	for i in discs:
		var coin := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.19
		cyl.bottom_radius = 0.19
		cyl.height = 0.05
		cyl.radial_segments = 14
		coin.mesh = cyl
		coin.material_override = gold
		coin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		coin.position = Vector3(0.0, 0.03 + float(i) * 0.055, 0.0)
		coin.rotation.y = float(i) * 0.6
		stack.add_child(coin)
	var halo := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.24
	ring_mesh.outer_radius = 0.31
	ring_mesh.rings = 24
	ring_mesh.ring_segments = 4
	halo.mesh = ring_mesh
	halo.material_override = FX.glow_material(Color(1.0, 0.72, 0.25, 0.5))
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halo.position.y = 0.04
	add_child(halo)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.66, 0.24)
	light.light_energy = 0.9
	light.omni_range = 2.4
	light.shadow_enabled = false
	light.position.y = 0.5
	add_child(light)
	stack.position.y = 0.5
	var tween := create_tween()
	tween.tween_property(stack, "position:y", 0.16, 0.28).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if taken:
		return
	age += delta
	stack.rotation.y += delta * 2.4
	if target == null or not is_instance_valid(target) or not target.alive:
		return
	var goal := target.global_position + Vector3(0.0, 0.75, 0.0)
	var offset := goal - global_position
	var distance := offset.length()
	if distance < 1.0:
		_collect()
		return
	if distance < magnet_range:
		var pull := clampf((magnet_range - distance) / magnet_range, 0.25, 1.0)
		global_position += offset.normalized() * (3.0 + 15.0 * pull) * delta


func _collect() -> void:
	if taken:
		return
	taken = true
	collected.emit(amount)
	queue_free()
