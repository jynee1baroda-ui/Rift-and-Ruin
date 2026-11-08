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
var attack_gate: Callable
var attack_release: Callable
var holds_token := false
var special_fn: Callable
var special_timer := 7.0
var special_windup := 0.0
var special_pending := false
var enraged := false
var stagger := 0.0
var gait := 0.0
## Procedural combat pose, used by every mob: generated models arrive without
## clips, and library rigs do not all carry attack or hit takes either.
var attack_pose := 0.0
var flinch := 0.0


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


func setup(kind: Dictionary, model_scene: PackedScene, player: Player, path_callable: Callable, bolt_callable: Callable, special_callable := Callable(), gate := Callable(), release := Callable()) -> void:
	kind_key = String(kind.get("key", "wolf"))
	display_name = String(kind.get("name", "Rift Fiend"))
	max_health = float(kind.get("health", 50.0))
	health = max_health
	damage = float(kind.get("damage", 9.0))
	speed = float(kind.get("speed", 4.2))
	attack_range = float(kind.get("range", 1.9))
	attack_interval = float(kind.get("interval", 1.5))
	windup_time = float(kind.get("windup", 0.45))
	aggro_range = float(kind.get("aggro", 9.5))
	ranged = bool(kind.get("ranged", false))
	elite = bool(kind.get("elite", false))
	boss = bool(kind.get("boss", false))
	target = player
	path_fn = path_callable
	bolt_fn = bolt_callable
	special_fn = special_callable
	attack_gate = gate
	attack_release = release
	special_timer = randf_range(5.0, 7.0)
	var model_scale := float(kind.get("scale", 1.0))
	if model_scene != null:
		var inst := model_scene.instantiate()
		model_root.add_child(inst)
		anim = _find_animation_player(inst)
		var tex_path := String(kind.get("texture", ""))
		if not tex_path.is_empty() and ResourceLoader.exists(tex_path):
			var body_mat := StandardMaterial3D.new()
			body_mat.albedo_texture = load(tex_path)
			body_mat.roughness = 0.82
			body_mat.metallic = 0.12
			body_mat.albedo_color = kind.get("tint", Color.WHITE)
			## Only the imported body takes the texture: hands and weapon are
			## built after this, so they keep their own materials.
			for node in inst.find_children("*", "MeshInstance3D", true, false):
				var piece := node as MeshInstance3D
				if piece != null:
					piece.material_override = body_mat
		if kind.has("height"):
			var span := _mesh_bounds(inst)
			if span.size.y > 0.05:
				inst.position.y -= span.position.y
				model_root.scale = Vector3.ONE * (float(kind.get("height", 1.8)) / span.size.y)
			else:
				model_root.scale = Vector3.ONE * model_scale
		else:
			model_root.scale = Vector3.ONE * model_scale
		HandGrip.dress(inst, "", model_scale, kind.get("glove", Color(0.20, 0.17, 0.16)), String(kind.get("weapon", "")))
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
	_static_gait(delta)
	if frozen:
		velocity = Vector3.ZERO
		play_anim(["idle", "walk"], 0.8)
		return
	if stagger > 0.0:
		stagger = maxf(0.0, stagger - delta)
		velocity.x = move_toward(velocity.x, 0.0, 70.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 70.0 * delta)
		velocity.y -= GRAVITY * delta
		move_and_slide()
		play_anim(["hit", "stagger", "idle"], 1.2)
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

	if boss and special_fn.is_valid():
		if special_pending:
			special_windup -= delta
			velocity.x = move_toward(velocity.x, 0.0, 40.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 40.0 * delta)
			move_and_slide()
			if special_windup <= 0.0:
				special_pending = false
				special_fn.call(self)
				special_timer = 5.2 if enraged else 8.0
			return
		special_timer -= delta
		if special_timer <= 0.0 and alerted and dist <= 17.0:
			special_pending = true
			special_windup = 0.85
			play_anim(["cast", "attack", "scream"], 1.1)
			FX.flash_mesh(model_root, Color(1.0, 0.55, 0.22), 0.5)
			FX.ring(get_parent(), global_position, Color(1.0, 0.48, 0.16, 0.55), attack_range + 3.4, 0.85, 0.07)

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
		if attack_timer <= 0.0 and not special_pending:
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
	if attack_gate.is_valid() and not bool(attack_gate.call(self)):
		attack_timer = 0.35
		return
	holds_token = true
	attack_timer = attack_interval
	windup = windup_time
	play_anim(["attack", "cast", "hit"], 1.2)
	FX.flash_mesh(model_root, Color(1.0, 0.28, 0.18), maxf(0.16, windup_time * 0.7))
	FX.ring(get_parent(), global_position, Color(1.0, 0.24, 0.14, 0.5), attack_range + 0.15, windup_time, 0.045)


func _strike(dist: float) -> void:
	if target == null or not target.alive:
		_release_token()
		return
	attack_pose = 1.0
	if ranged:
		if bolt_fn.is_valid():
			bolt_fn.call(global_position + Vector3(0.0, 1.2, 0.0), target.global_position + Vector3(0.0, 0.8, 0.0), damage)
			FX.beam(get_parent(), global_position + Vector3(0.0, 1.25, 0.0), target.global_position + Vector3(0.0, 0.85, 0.0), Color(1.0, 0.42, 0.2, 0.55), 0.07, 0.16)
		_release_token()
		return
	if dist <= attack_range * 1.4:
		var swing := target.global_position - global_position
		swing.y = 0.0
		if swing.length() > 0.05:
			var hit_color := Color(1.0, 0.52, 0.24, 0.9) if boss else Color(1.0, 0.3, 0.2, 0.85)
			FX.slash(get_parent(), global_position + Vector3(0.0, 1.05, 0.0), swing, hit_color, attack_range + 0.7, 0.24, 140.0)
		target.take_damage(damage)
		FX.burst(get_parent(), target.global_position + Vector3(0.0, 1.0, 0.0), Color(0.9, 0.12, 0.1, 0.9), 12, 4.0, 0.3, 0.4)
		FX.shards(get_parent(), target.global_position + Vector3(0.0, 0.8, 0.0), Color(1.0, 0.55, 0.4, 0.9), 6, 0.9, 1.2, 0.3)
		if boss:
			FX.nova(get_parent(), global_position, Color(1.0, 0.5, 0.14, 0.9), 6.4)
			FX.ring(get_parent(), global_position, Color(1.0, 0.72, 0.32, 0.85), attack_range + 2.8, 0.5, 0.09)
	_release_token()


func _release_token() -> void:
	if not holds_token:
		return
	holds_token = false
	if attack_release.is_valid():
		attack_release.call(self)


func take_damage(amount: float, crit := false) -> void:
	if dead:
		return
	health -= amount
	# Ordinary foes flinch and lose their windup on a solid hit; bosses and
	# elites keep their footing so their mechanics stay readable.
	if not boss and amount >= max_health * 0.06:
		stagger = 0.17 if not elite else 0.1
		flinch = 1.0
		if windup > 0.0:
			windup = 0.0
			_release_token()
		var push := global_position - (target.global_position if target != null and is_instance_valid(target) else global_position)
		push.y = 0.0
		if push.length() > 0.01:
			velocity += push.normalized() * 2.2
	FX.flash_mesh(model_root, Color(1.0, 0.62, 0.42), 0.12)
	FX.burst(get_parent(), global_position + Vector3(0.0, 1.05, 0.0), Color(1.0, 0.42, 0.24, 0.9), 7, 3.4, 0.2, 0.26)
	hp_root.visible = bool(GameSettings.get_value("enemy_health"))
	_update_hp_bar()
	FX.damage_number(get_parent(), global_position + Vector3(0.0, 1.9, 0.0), amount, crit, Color(1.0, 0.9, 0.5) if crit else Color(1.0, 0.78, 0.42))
	if boss and not enraged and health <= max_health * 0.5:
		enraged = true
		speed *= 1.22
		attack_interval = maxf(0.9, attack_interval * 0.75)
		windup_time = maxf(0.35, windup_time * 0.8)
		special_timer = 1.4
		FX.nova(get_parent(), global_position, Color(1.0, 0.45, 0.12, 1.0), 7.0)
		FX.flash_mesh(model_root, Color(1.0, 0.4, 0.2), 0.8)
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
	_release_token()
	var death_color := Color(0.95, 0.22, 0.16, 0.95)
	if boss:
		death_color = Color(1.0, 0.62, 0.18, 1.0)
	elif elite:
		death_color = Color(1.0, 0.46, 0.18, 0.95)
	FX.burst(get_parent(), global_position + Vector3(0.0, 1.0, 0.0), death_color, 40 if boss else 18, 7.5 if boss else 5.0, 0.46, 0.85, -8.0)
	FX.ring(get_parent(), global_position, death_color, 4.2 if boss else 1.8, 0.55, 0.08)
	if boss:
		FX.nova(get_parent(), global_position, Color(1.0, 0.5, 0.15, 0.9), 8.5)
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


## Generated boss models arrive as static meshes without clips. Give them a
## readable gait and windup lean so they never slide around like statues.
func _static_gait(delta: float) -> void:
	if model_root == null or dead:
		return
	gait += delta
	attack_pose = maxf(0.0, attack_pose - delta * 2.6)
	flinch = maxf(0.0, flinch - delta * 3.4)
	## Rigged models with real clips only get a light secondary motion; static
	## generated meshes carry the whole read on this cycle.
	var rig := 0.4 if anim != null else 1.0
	var move_speed := Vector2(velocity.x, velocity.z).length()
	var amp := clampf(move_speed / maxf(1.0, speed), 0.0, 1.0)
	var cycle := gait * (6.5 + amp * 5.0)
	var bob := sin(cycle) * (0.02 + 0.10 * amp) * rig
	var sway := sin(cycle * 0.5) * (0.02 + 0.07 * amp) * rig
	## Lean into a run, coil back on the windup, drive through the swing.
	var pitch := amp * 0.10 * rig
	if windup > 0.0:
		var coil := minf(1.0, windup * 2.0)
		bob -= 0.12 * coil * rig
		sway *= 1.6
		pitch -= 0.16 * coil * rig
	if attack_pose > 0.0:
		pitch += 0.34 * attack_pose * rig
		bob += 0.05 * attack_pose * rig
	if flinch > 0.0:
		pitch -= 0.26 * flinch * rig
		sway += sin(flinch * 20.0) * 0.05 * flinch * rig
	model_root.position.y = bob
	model_root.rotation.z = sway * 0.6
	model_root.rotation.x = pitch


## World-space bounds of every mesh under a freshly instanced model, used to
## fit imported boss rigs that arrive at an arbitrary real-world scale.
func _mesh_bounds(root: Node) -> AABB:
	var result := AABB()
	var first := true
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh == null or mesh.mesh == null:
			continue
		var box := mesh.global_transform * mesh.get_aabb()
		if first:
			result = box
			first = false
		else:
			result = result.merge(box)
	return result


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
