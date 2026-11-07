class_name Enemy
extends CharacterBody3D

signal died(enemy: Enemy)
signal struck(enemy: Enemy, amount: float)

const GRAVITY := 28.0

var kind_key := "wolf"
var display_name := "Rift Fiend"
var max_health := 50.0
var health := 50.0
var damage := 9.0
var speed := 4.2
var attack_range := 1.9
var attack_interval := 1.5
var windup_time := 0.45
var elite := false
var boss := false
var ranged := false
var aggro_range := 11.0
var alerted := false

var target: Player
var path := PackedVector3Array()
var repath_timer := 0.0
var attack_timer := 0.0
var windup := 0.0
var dead := false
var frozen := true
var facing := 0.0

var model_root: Node3D
var anim: AnimationPlayer
var path_fn: Callable
var bolt_fn: Callable
var hp_root: Node3D
var hp_fill: MeshInstance3D
var hp_width := 1.1
var ring: MeshInstance3D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = 0.4
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	model_root = Node3D.new()
	model_root.name = "Model"
	add_child(model_root)


func setup(kind: Dictionary, model_scene: PackedScene, player: Player, path_callable: Callable, bolt_callable: Callable) -> void:
	kind_key = String(kind.get("key", "wolf"))
	display_name = String(kind.get("name", "Rift Fiend"))
	max_health = float(kind.get("health", 50.0))
	health = max_health
	damage = float(kind.get("damage", 9.0))
	speed = float(kind.get("speed", 4.2))
	attack_range = float(kind.get("range", 1.9))
	attack_interval = float(kind.get("interval", 1.5))
	windup_time = float(kind.get("windup", 0.45))
	ranged = bool(kind.get("ranged", false))
	elite = bool(kind.get("elite", false))
	boss = bool(kind.get("boss", false))
	target = player
	path_fn = path_callable
	bolt_fn = bolt_callable
	var model_scale := float(kind.get("scale", 1.0))
	if model_scene != null:
		var inst := model_scene.instantiate()
		model_root.add_child(inst)
		anim = _find_animation_player(inst)
		model_root.scale = Vector3.ONE * model_scale
	else:
		_build_fallback_model()
	_build_hp_bar()
	if boss:
		hp_width = 2.2
		_rebuild_hp_bar_size()
	attack_timer = randf_range(1.1, 2.1)
	repath_timer = randf_range(0.0, 0.3)
	play_anim(["idle", "walk"], 1.0)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _build_fallback_model() -> void:
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.4
	body.mesh = capsule
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.16, 0.2)
	mat.roughness = 0.8
	body.material_override = mat
	body.position.y = 0.7
	model_root.add_child(body)


func _build_hp_bar() -> void:
	hp_root = Node3D.new()
	hp_root.position.y = 2.15
	add_child(hp_root)
	var bg := MeshInstance3D.new()
	var bg_mesh := QuadMesh.new()
	bg_mesh.size = Vector2(hp_width + 0.06, 0.16)
	bg.mesh = bg_mesh
	var bg_mat := FX.glow_material(Color(0.02, 0.01, 0.02, 0.85), false)
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg.material_override = bg_mat
	bg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bg.extra_cull_margin = 4.0
	hp_root.add_child(bg)
	hp_fill = MeshInstance3D.new()
	var fill_mesh := QuadMesh.new()
	fill_mesh.size = Vector2(hp_width, 0.11)
	hp_fill.mesh = fill_mesh
	var fill_mat := FX.glow_material(Color(0.85, 0.09, 0.12, 0.95), false)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hp_fill.material_override = fill_mat
	hp_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hp_fill.position = Vector3(0.0, 0.0, 0.02)
	hp_root.add_child(hp_fill)
	_face_camera_static(hp_root)
	hp_root.visible = false


func _face_camera_static(node: Node3D) -> void:
	var bg := node.get_child(0) as MeshInstance3D
	var fill := node.get_child(1) as MeshInstance3D
	for mi in [bg, fill]:
		if mi != null:
			var mat := mi.material_override as StandardMaterial3D
			if mat != null:
				mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED


func _rebuild_hp_bar_size() -> void:
	if hp_root == null:
		return
	var bg := hp_root.get_child(0) as MeshInstance3D
	var bg_mesh := bg.mesh as QuadMesh
	var new_bg := QuadMesh.new()
	new_bg.size = Vector2(hp_width + 0.08, 0.2)
	bg.mesh = new_bg
	var fill_mesh := QuadMesh.new()
	fill_mesh.size = Vector2(hp_width, 0.14)
	hp_fill.mesh = fill_mesh


func _physics_process(delta: float) -> void:
	if dead:
		velocity.y -= GRAVITY * delta
		move_and_slide()
		return
	if frozen:
		velocity = Vector3.ZERO
		play_anim(["idle", "walk"], 0.8)
		return
	if target == null or not is_instance_valid(target) or not target.alive:
		velocity.x = move_toward(velocity.x, 0.0, 30.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 30.0 * delta)
		velocity.y -= GRAVITY * delta
		move_and_slide()
		play_anim(["idle", "walk"], 0.7)
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	velocity.y -= GRAVITY * delta
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	var dist := to_target.length()
	if dist > 0.01:
		var wanted := atan2(to_target.x, to_target.z)
		facing = lerp_angle(facing, wanted, minf(1.0, delta * 9.0))
		model_root.rotation.y = facing

	if not alerted:
		if dist <= aggro_range:
			alerted = true
			play_anim(["scream", "howl", "attack"], 1.0)
		else:
			velocity.x = move_toward(velocity.x, 0.0, 30.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 30.0 * delta)
			move_and_slide()
			play_anim(["idle", "walk"], 0.8)
			return

	if windup > 0.0:
		windup -= delta
		velocity.x = move_toward(velocity.x, 0.0, 40.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 40.0 * delta)
		move_and_slide()
		if windup <= 0.0:
			_strike(dist)
		return

	if dist <= attack_range:
		velocity.x = move_toward(velocity.x, 0.0, 40.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 40.0 * delta)
		move_and_slide()
		play_anim(["idle"], 1.0)
		if attack_timer <= 0.0:
			_begin_attack(dist)
		return

	if ranged and dist < attack_range * 0.45:
		var away := -to_target.normalized()
		velocity.x = away.x * speed * 0.7
		velocity.z = away.z * speed * 0.7
		move_and_slide()
		play_anim(["walk", "run"], 1.0)
		return

	_advance(delta, to_target)
	play_anim(["run", "walk"], clampf(speed / 4.0, 0.8, 1.8))


func _advance(delta: float, to_target: Vector3) -> void:
	repath_timer -= delta
	if repath_timer <= 0.0 and path_fn.is_valid():
		repath_timer = randf_range(0.35, 0.6)
		path = path_fn.call(global_position, target.global_position)
	if path.size() > 0:
		var point := path[0]
		var flat := Vector3(point.x - global_position.x, 0.0, point.z - global_position.z)
		if flat.length() < 0.6:
			path.remove_at(0)
		else:
			flat = flat.normalized()
			velocity.x = flat.x * speed
			velocity.z = flat.z * speed
			move_and_slide()
			return
	velocity.x = to_target.normalized().x * speed
	velocity.z = to_target.normalized().z * speed
	move_and_slide()


func _begin_attack(dist: float) -> void:
	attack_timer = attack_interval
	windup = windup_time
	play_anim(["attack", "cast", "hit"], 1.2)
	if not ranged:
		FX.ring(get_parent(), global_position, Color(0.9, 0.15, 0.1, 0.55), attack_range + 0.4, 0.35, 0.04)


func _strike(dist: float) -> void:
	if target == null or not target.alive:
		return
	if ranged:
		if bolt_fn.is_valid():
			bolt_fn.call(global_position + Vector3(0.0, 1.2, 0.0), target.global_position + Vector3(0.0, 0.8, 0.0), damage)
		return
	if dist <= attack_range * 1.4:
		target.take_damage(damage)
		FX.burst(get_parent(), target.global_position + Vector3(0.0, 1.0, 0.0), Color(0.9, 0.12, 0.1, 0.9), 12, 4.0, 0.3, 0.4)


func take_damage(amount: float, crit := false) -> void:
	if dead:
		return
	health -= amount
	hp_root.visible = true
	_update_hp_bar()
	FX.damage_number(get_parent(), global_position + Vector3(0.0, 1.9, 0.0), amount, crit, Color(1.0, 0.9, 0.5) if crit else Color(1.0, 0.78, 0.42))
	if health <= 0.0:
		_die()


func _update_hp_bar() -> void:
	var ratio := clampf(health / max_health, 0.0, 1.0)
	hp_fill.scale.x = maxf(0.001, ratio)
	hp_fill.position.x = -hp_width * 0.5 * (1.0 - ratio)


func _die() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	hp_root.visible = false
	var played := play_anim(["death", "die"], 1.0)
	if anim != null:
		anim.speed_scale = 1.0
	var tween := create_tween()
	if not played:
		tween.tween_property(model_root, "rotation:z", 1.5, 0.4)
	tween.tween_interval(1.4)
	tween.tween_property(model_root, "position:y", -1.6, 0.8)
	tween.tween_callback(queue_free)
	died.emit(self)


func play_anim(prefixes: Array, speed := 1.0) -> bool:
	if anim == null:
		return false
	if anim.speed_scale != speed:
		anim.speed_scale = speed
	var names := anim.get_animation_list()
	for prefix in prefixes:
		var wanted := String(prefix).to_lower()
		for name in names:
			if String(name).to_lower().contains(wanted):
				if anim.current_animation != name:
					anim.play(name, 0.1)
				return true
	return false
