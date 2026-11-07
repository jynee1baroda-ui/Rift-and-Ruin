class_name LootDrop
extends Area3D

signal picked(drop: LootDrop)

var item: Dictionary = {}
var life_amount := 0.0
var is_life := false
var color := Color.WHITE
var gem: Node3D
var label: Label3D
var time := 0.0
var settled := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.0 if is_life else 1.35
	shape.shape = sphere
	add_child(shape)
	if is_life:
		collision_layer = 0
		collision_mask = 2
		monitoring = true
		body_entered.connect(_on_body_entered)
	else:
		collision_layer = 8
		collision_mask = 0
		monitoring = false
	gem = Node3D.new()
	add_child(gem)
	if is_life:
		_build_life_orb()
	else:
		_build_item_gem()


func _build_life_orb() -> void:
	color = Color(0.95, 0.1, 0.16)
	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.22
	mesh.height = 0.44
	sphere.mesh = mesh
	sphere.material_override = FX.glow_material(Color(1.0, 0.22, 0.24, 0.95))
	sphere.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gem.add_child(sphere)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.15, 0.15)
	light.light_energy = 1.6
	light.omni_range = 3.0
	light.shadow_enabled = false
	add_child(light)
	gem.position.y = 0.6


func _build_item_gem() -> void:
	color = item.get("color", Color.WHITE)
	var mesh_inst := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.56, 0.8, 0.56)
	mesh_inst.mesh = prism
	mesh_inst.material_override = FX.glow_material(Color(color.r, color.g, color.b, 0.95), false)
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gem.add_child(mesh_inst)
	var core := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.24
	sphere.height = 0.48
	core.mesh = sphere
	core.material_override = FX.glow_material(Color(color.r, color.g, color.b, 0.9))
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gem.add_child(core)
	var beam := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.1
	cylinder.bottom_radius = 0.26
	cylinder.height = 3.0
	cylinder.radial_segments = 12
	beam.mesh = cylinder
	beam.material_override = FX.glow_material(Color(color.r, color.g, color.b, 0.055))
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	beam.position.y = 1.3
	add_child(beam)
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 2.2 if item.get("rarity", "") == "legendary" else 1.2
	light.omni_range = 4.0 if item.get("rarity", "") == "legendary" else 2.8
	light.shadow_enabled = false
	light.position.y = 0.6
	add_child(light)
	var marker := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.62
	ring_mesh.outer_radius = 0.78
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 4
	marker.mesh = ring_mesh
	marker.material_override = FX.glow_material(Color(color.r, color.g, color.b, 0.6))
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	marker.position.y = 0.06
	add_child(marker)
	gem.position.y = 0.55
	label = Label3D.new()
	label.text = "%s  ·  CLICK" % String(item.get("name", "Relic"))
	label.font_size = 44
	label.pixel_size = 0.0032
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.outline_size = 10
	label.outline_modulate = Color(0.02, 0.0, 0.02, 0.9)
	label.position.y = 1.9
	add_child(label)


func _process(delta: float) -> void:
	time += delta
	if not settled:
		gem.position.y = lerpf(gem.position.y, 0.55 if not is_life else 0.6, delta * 6.0)
		if time > 0.45:
			settled = true
	gem.rotation.y += delta * 1.7
	gem.position.y += sin(time * 3.0) * delta * 0.16
	if label != null:
		label.position.y = 1.9 + sin(time * 2.0) * 0.06
		label.modulate.a = clampf(time * 2.0, 0.0, 1.0)


func _on_body_entered(body: Node) -> void:
	if body is Player and body.alive:
		picked.emit(self)
		queue_free()
