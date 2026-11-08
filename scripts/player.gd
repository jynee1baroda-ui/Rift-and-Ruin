class_name Player
extends CharacterBody3D

signal died
signal health_changed(current: float, maximum: float)
signal ability_used(index: int, aim: Vector3)
signal damaged(amount: float)
signal healed(amount: float)
signal life_spent(amount: float)
signal leveled_up(level: int)
signal focus_changed(current: float, maximum: float)
signal passives_changed

const BASE_MAX_HEALTH := 220.0
const BASE_SPEED := 7.2
const GRAVITY := 28.0
const BASE_REGEN := 2.4
const COMBAT_REGEN := 0.5
const BLOODRUSH_TIME := 4.5
const BLOODRUSH_MAX := 10
const MAX_RELICS := 3
const FAMILY_STACK_LIMIT := 2

const ABILITY_SLOTS := 3

var max_health := BASE_MAX_HEALTH
var health := BASE_MAX_HEALTH
var class_id := "blood_sorceress"
var class_data: Dictionary = HeroClasses.definition("blood_sorceress")
var abilities: Array = HeroClasses.abilities("blood_sorceress")
var focus := 0.0
var focus_max := 0.0
var focus_regen := 0.0
var focus_name := ""
var focus_color := Color(0.95, 0.3, 0.32)
var shield := 0.0
var shield_timer := 0.0
var crit_bonus := 0.0
var crit_bonus_amount := 0.0
var level := 1
var xp := 0.0
var move_speed := BASE_SPEED
var crit_chance := 0.06
var crit_damage := 1.75
var power := 1.0
var regen := BASE_REGEN
var life_cost_mult := 1.0
var cooldown_mult := 1.0
var relics: Array = []
var dash_cooldown_base := 2.2
var move_direct := Vector3.ZERO

## Ground authority. The rift floor is basalt islands over lava, so the player
## may only stand where the generator marked a cell walkable. The game installs
## this on spawn; without it (duel plate, tests) movement is unconstrained.
var walkable_fn := Callable()
var walkable_radius := 0.5

var alive := true
var aim_point := Vector3.ZERO
var path := PackedVector3Array()
var cooldowns := [0.0, 0.0, 0.0]
var dash_cooldown := 0.0
var dash_time := 0.0
var dash_direction := Vector3.ZERO
var invulnerable := 0.0
var combat_timer := 0.0
var calm_time := 0.0
var cast_timer := 0.0
var facing := 0.0
var moving := false
var in_lava := false
var bloodrush := 0
var bloodrush_timer := 0.0
var passive_nodes: Array = []
var passive_points := 0
var passive_bonus: Dictionary = {}
var boons: Dictionary = {}

var model_root: Node3D
var anim: AnimationPlayer
var aura: GPUParticles3D
var ground_ring: MeshInstance3D


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.4
	model_root = Node3D.new()
	model_root.name = "Model"
	add_child(model_root)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_build_aura()


func setup(model_scene: PackedScene, model_scale := 1.35, tint := Color(0, 0, 0, 0)) -> void:
	if model_scene != null:
		var inst := model_scene.instantiate()
		model_root.add_child(inst)
		model_root.scale = Vector3.ONE * model_scale
		anim = _find_animation_player(inst)
		HandGrip.dress(inst, class_id, model_scale, class_data.get("glove", Color(0.24, 0.2, 0.2)))
		if tint.a > 0.0:
			tint_model(inst, tint)
	else:
		_build_fallback_model()


## While a class's own character model is still being generated, the shared rig
## is tinted so the class still reads at a glance.
func tint_model(node: Node, color: Color) -> void:
	var overlay := StandardMaterial3D.new()
	overlay.albedo_color = Color(color.r, color.g, color.b, 0.42)
	overlay.emission_enabled = true
	overlay.emission = color
	overlay.emission_energy_multiplier = 0.35
	overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	overlay.cull_mode = BaseMaterial3D.CULL_DISABLED
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if mesh != null:
			mesh.material_overlay = overlay


func set_model(model_scene: PackedScene, model_scale := 1.35, tint := Color(0, 0, 0, 0)) -> void:
	if model_root == null:
		return
	if anim != null:
		anim.stop()
		anim = null
	for child in model_root.get_children():
		model_root.remove_child(child)
		child.queue_free()
	model_root.rotation = Vector3.ZERO
	model_root.scale = Vector3.ONE
	setup(model_scene, model_scale, tint)


func set_class(id: String) -> void:
	var previous := class_id
	class_id = id if HeroClasses.CLASSES.has(id) else "blood_sorceress"
	class_data = HeroClasses.definition(class_id)
	abilities = class_data.get("abilities", [])
	focus_name = String(class_data.get("focus_name", ""))
	focus_max = float(class_data.get("focus_max", 0.0))
	focus_regen = float(class_data.get("focus_regen", 0.0))
	focus_color = class_data.get("focus_color", Color(0.95, 0.3, 0.32))
	focus = focus_max
	cooldowns = [0.0, 0.0, 0.0]
	_recalculate()
	health = max_health
	health_changed.emit(health, max_health)
	focus_changed.emit(focus, focus_max)
	if previous != class_id:
		## The model may already be in the scene, dressed for the previous
		## class. Rebuild its hands and weapon so a Paladin is never left
		## holding the Sorceress staff.
		_redress()


func _redress() -> void:
	if model_root == null or model_root.get_child_count() == 0:
		return
	var inst := model_root.get_child(0)
	HandGrip.undress(inst)
	HandGrip.dress(inst, class_id, model_root.scale.x, class_data.get("glove", Color(0.24, 0.2, 0.2)))


func set_passives(nodes: Array, points: int) -> void:
	passive_nodes.clear()
	for id in nodes:
		passive_nodes.append(String(id))
	passive_points = maxi(0, points)
	_recalculate()
	passives_changed.emit()


func buy_passive(id: String) -> bool:
	if passive_points <= 0 or not Passives.available(passive_nodes, id):
		return false
	passive_nodes.append(id)
	passive_points -= 1
	_recalculate()
	passives_changed.emit()
	return true


func add_boon(key: String) -> void:
	boons[key] = int(boons.get(key, 0)) + 1
	_recalculate()


func set_boons(keys: Array) -> void:
	boons.clear()
	for key in keys:
		boons[String(key)] = int(boons.get(String(key), 0)) + 1
	_recalculate()


func boon_count(key: String) -> int:
	return int(boons.get(key, 0))


func primary_index() -> int:
	return int(class_data.get("primary", 0))


func secondary_index() -> int:
	return int(class_data.get("secondary", 1))


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
	capsule.radius = 0.34
	capsule.height = 1.5
	body.mesh = capsule
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.32, 0.05, 0.08)
	mat.roughness = 0.6
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.02, 0.04)
	mat.emission_energy_multiplier = 0.4
	body.material_override = mat
	body.position.y = 0.78
	model_root.add_child(body)


func _build_aura() -> void:
	aura = GPUParticles3D.new()
	aura.amount = 18
	aura.lifetime = 1.4
	aura.preprocess = 1.0
	aura.position.y = 0.6
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = 0.55
	proc.direction = Vector3.UP
	proc.spread = 35.0
	proc.initial_velocity_min = 0.4
	proc.initial_velocity_max = 1.3
	proc.gravity = Vector3(0.0, 0.7, 0.0)
	proc.scale_min = 0.05
	proc.scale_max = 0.12
	proc.color = Color(1.0, 0.18, 0.12, 0.45)
	aura.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	quad.material = FX.spark_material(Color(1, 1, 1, 1))
	aura.draw_pass_1 = quad
	add_child(aura)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.22, 0.16)
	light.light_energy = 0.6
	light.omni_range = 4.0
	light.shadow_enabled = false
	light.position.y = 0.9
	add_child(light)
	var rim := OmniLight3D.new()
	rim.light_color = Color(0.75, 0.66, 1.0)
	rim.light_energy = 3.2
	rim.omni_range = 6.0
	rim.shadow_enabled = false
	rim.position = Vector3(0.0, 3.0, -1.4)
	add_child(rim)
	var key := OmniLight3D.new()
	key.light_color = Color(1.0, 0.78, 0.62)
	key.light_energy = 3.0
	key.omni_range = 5.5
	key.shadow_enabled = false
	key.position = Vector3(0.0, 3.4, 2.4)
	add_child(key)
	ground_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.52
	torus.outer_radius = 0.62
	torus.rings = 32
	torus.ring_segments = 4
	ground_ring.mesh = torus
	var mat := FX.glow_material(Color(0.85, 0.12, 0.08, 0.55))
	ground_ring.material_override = mat
	ground_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ground_ring.position.y = 0.05
	add_child(ground_ring)


func _physics_process(delta: float) -> void:
	if not alive:
		velocity = Vector3(0.0, velocity.y - GRAVITY * delta, 0.0)
		move_and_slide()
		return
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	invulnerable = maxf(0.0, invulnerable - delta)
	cast_timer = maxf(0.0, cast_timer - delta)
	combat_timer = maxf(0.0, combat_timer - delta)
	if combat_timer <= 0.0:
		calm_time = minf(calm_time + delta, 3.0)
	else:
		calm_time = 0.0
	if bloodrush_timer > 0.0:
		bloodrush_timer = maxf(0.0, bloodrush_timer - delta)
		if bloodrush_timer <= 0.0:
			bloodrush = 0
	if shield_timer > 0.0:
		shield_timer = maxf(0.0, shield_timer - delta)
		if shield_timer <= 0.0:
			shield = 0.0
	crit_bonus = maxf(0.0, crit_bonus - delta)
	if focus_max > 0.0 and focus < focus_max:
		focus = minf(focus_max, focus + focus_regen * delta)
		focus_changed.emit(focus, focus_max)
	var rate := regen_now()
	if rate > 0.0 and health < max_health:
		heal(rate * delta)

	if dash_time > 0.0:
		dash_time -= delta
		velocity = dash_direction * 30.0
		_step_grounded(delta)
		moving = true
		_face_direction(dash_direction, delta)
		_update_anim(true)
		return

	velocity.y -= GRAVITY * delta
	var walking := false
	if move_direct.length_squared() > 0.01:
		path.clear()
		velocity.x = move_direct.x * move_speed
		velocity.z = move_direct.z * move_speed
		walking = true
		if cast_timer <= 0.0:
			_face_direction(move_direct, delta)
	elif path.size() > 0:
		var point := path[0]
		var flat := Vector3(point.x - global_position.x, 0.0, point.z - global_position.z)
		if flat.length() < 0.5:
			path.remove_at(0)
		else:
			flat = flat.normalized()
			velocity.x = flat.x * move_speed
			velocity.z = flat.z * move_speed
			walking = true
			if cast_timer <= 0.0:
				_face_direction(flat, delta)
	if not walking:
		velocity.x = move_toward(velocity.x, 0.0, 45.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 45.0 * delta)
	_step_grounded(delta)
	moving = walking
	if not walking and cast_timer <= 0.0:
		var aim_dir := aim_point - global_position
		aim_dir.y = 0.0
		if aim_dir.length_squared() > 1.0:
			_face_direction(aim_dir, delta * 0.6)
	_update_anim(walking)
	if ground_ring != null:
		ground_ring.rotation.y += delta * 0.6


func _fix_height() -> void:
	if global_position.y < -4.0:
		global_position.y = 0.4
		velocity.y = 0.0


## Move, but never off the walkable stone. A step that would land on lava is
## split into its axes so the hero slides along the rim instead of stopping
## dead or dropping into the pit on a dash.
func _step_grounded(delta: float) -> void:
	if not walkable_fn.is_valid():
		move_and_slide()
		_fix_height()
		return
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	if flat.length_squared() < 0.0004:
		move_and_slide()
		_fix_height()
		return
	var lead := flat * delta * 2.5 + flat.normalized() * walkable_radius
	if _ground_at(global_position + lead):
		move_and_slide()
		_fix_height()
		return
	var along_x := Vector3(lead.x, 0.0, 0.0)
	var along_z := Vector3(0.0, 0.0, lead.z)
	if absf(along_x.x) > 0.001 and _ground_at(global_position + along_x):
		velocity.z = 0.0
	elif absf(along_z.z) > 0.001 and _ground_at(global_position + along_z):
		velocity.x = 0.0
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		dash_time = 0.0
	move_and_slide()
	_fix_height()


func _ground_at(point: Vector3) -> bool:
	if not walkable_fn.is_valid():
		return true
	return bool(walkable_fn.call(point))


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var target := atan2(direction.x, direction.z)
	facing = lerp_angle(facing, target, minf(1.0, delta * 14.0))
	if model_root != null:
		model_root.rotation.y = facing + PI


func _update_anim(walking: bool) -> void:
	if cast_timer > 0.0:
		match class_id:
			"iron_paladin":
				play_anim(["attack", "slash", "punch", "cast"])
			"shadow_huntress":
				play_anim(["attack", "shoot", "bow", "cast"])
			_:
				play_anim(["charged_spell", "cast", "attack", "spell", "punch"])
	elif dash_time > 0.0:
		play_anim(["run", "walk"], 1.6)
	elif walking:
		play_anim(["run", "walk"], clampf(move_speed / 6.4, 0.85, 1.7))
	else:
		play_anim(["idle", "stand"], 1.0)


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
					anim.play(name, 0.12)
				return true
	return false


func set_aim(point: Vector3) -> void:
	aim_point = point


func move_along(points: PackedVector3Array) -> void:
	if not alive:
		return
	path = points


func set_move_direct(direction: Vector3) -> void:
	move_direct = Vector3(direction.x, 0.0, direction.z)
	if move_direct.length_squared() > 1.0:
		move_direct = move_direct.normalized()


func stop() -> void:
	path.clear()


func ability_cost(index: int) -> float:
	if index < 0 or index >= abilities.size():
		return 0.0
	var entry: Dictionary = abilities[index]
	var cost := float(entry.get("cost", 0.0))
	if String(entry.get("id", "")) == "nova" and has_unique("nova_free"):
		cost = 0.0
	if is_health_cost():
		return cost * life_cost_mult
	return cost


func is_health_cost() -> bool:
	return String(class_data.get("cost_kind", "health")) == "health"


func ability_ready(index: int) -> bool:
	if not alive or index < 0 or index >= abilities.size():
		return false
	if cooldowns[index] > 0.0:
		return false
	var cost := ability_cost(index)
	if cost <= 0.0:
		return true
	if is_health_cost():
		return health > cost + 1.0
	return focus >= cost


func try_ability(index: int) -> bool:
	if not ability_ready(index):
		return false
	var aim := aim_point
	if (aim - global_position).length_squared() > 0.01:
		_face_direction((aim - global_position), 1.0)
	var entry: Dictionary = abilities[index]
	cooldowns[index] = float(entry.get("cooldown", 1.0)) * cooldown_mult
	var cost := ability_cost(index)
	if cost > 0.0:
		if is_health_cost():
			health = maxf(1.0, health - cost)
			life_spent.emit(cost)
			health_changed.emit(health, max_health)
		else:
			focus = maxf(0.0, focus - cost)
			focus_changed.emit(focus, focus_max)
	cast_timer = float(entry.get("cast", 0.22))
	ability_used.emit(index, aim)
	return true


func apply_shield(amount: float, duration: float) -> void:
	shield = maxf(shield, amount)
	shield_timer = maxf(shield_timer, duration)


func apply_crit_window(amount: float, duration: float) -> void:
	crit_bonus_amount = amount
	crit_bonus = duration


func teleport_to(point: Vector3) -> void:
	var target := Vector3(point.x, global_position.y, point.z)
	global_position = target
	velocity = Vector3.ZERO
	path.clear()


func add_bloodrush() -> void:
	bloodrush = mini(bloodrush + 1, BLOODRUSH_MAX)
	bloodrush_timer = BLOODRUSH_TIME


func in_combat() -> bool:
	return combat_timer > 0.0


func regen_now() -> float:
	var bloodrush_bonus := 0.07 * float(bloodrush)
	if combat_timer <= 0.0:
		var calm := maxf(regen, max_health * 0.035)
		return calm * clampf(calm_time / 1.2, 0.2, 1.0) + bloodrush_bonus
	return maxf(COMBAT_REGEN, max_health * 0.0035) + bloodrush_bonus


func try_dash() -> bool:
	if not alive or dash_cooldown > 0.0:
		return false
	var dir := aim_point - global_position
	dir.y = 0.0
	if dir.length() < 0.4:
		dir = Vector3(sin(facing), 0.0, cos(facing))
	dash_direction = dir.normalized()
	dash_time = 0.16
	dash_cooldown = dash_cooldown_base
	path.clear()
	invulnerable = 0.22
	cast_timer = 0.0
	return true


func take_damage(amount: float) -> void:
	if not alive or invulnerable > 0.0 or amount <= 0.0:
		return
	if shield > 0.0:
		var absorbed := minf(shield, amount)
		shield -= absorbed
		amount -= absorbed
		combat_timer = 3.5
		if shield <= 0.01:
			shield = 0.0
			shield_timer = 0.0
		if amount <= 0.01:
			damaged.emit(absorbed)
			return
	health = maxf(0.0, health - amount)
	combat_timer = 3.5
	# A short grace window only: long i-frames made swarms harmless.
	invulnerable = 0.12
	damaged.emit(amount)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		die()


func heal(amount: float) -> void:
	if not alive or amount <= 0.0:
		return
	var before := health
	health = minf(max_health, health + amount)
	if health - before > 0.01:
		healed.emit(health - before)
		health_changed.emit(health, max_health)


func die() -> void:
	if not alive:
		return
	alive = false
	bloodrush = 0
	bloodrush_timer = 0.0
	health = 0.0
	path.clear()
	health_changed.emit(0.0, max_health)
	var played := play_anim(["death", "die"])
	if not played and model_root != null:
		var tween := create_tween()
		tween.tween_property(model_root, "rotation:z", 1.5, 0.6)
		tween.parallel().tween_property(model_root, "position:y", -0.2, 0.6)
	if aura != null:
		aura.emitting = false
	died.emit()


func revive() -> void:
	alive = true
	health = max_health
	focus = focus_max
	shield = 0.0
	shield_timer = 0.0
	crit_bonus = 0.0
	path.clear()
	velocity = Vector3.ZERO
	cooldowns = [0.0, 0.0, 0.0]
	dash_cooldown = 0.0
	dash_time = 0.0
	cast_timer = 0.0
	bloodrush = 0
	bloodrush_timer = 0.0
	calm_time = 0.0
	if model_root != null:
		model_root.rotation = Vector3.ZERO
		model_root.position = Vector3.ZERO
	if aura != null:
		aura.emitting = true
	health_changed.emit(health, max_health)
	focus_changed.emit(focus, focus_max)


func has_unique(key: String) -> bool:
	for item in relics:
		if String(item.get("unique", "")) == key:
			return true
	return false


func family_count(family: String) -> int:
	var count := 0
	for item in relics:
		if String(item.get("family", "")) == family:
			count += 1
	return count


func can_equip(item: Dictionary, slot: int) -> bool:
	if slot < 0 or slot >= MAX_RELICS:
		return false
	var family := String(item.get("family", "blood"))
	var count := 0
	for i in relics.size():
		if i == slot:
			continue
		if String(relics[i].get("family", "")) == family:
			count += 1
	return count < FAMILY_STACK_LIMIT


func equip_slot(slot: int, item: Dictionary) -> bool:
	if not can_equip(item, slot):
		return false
	while relics.size() < MAX_RELICS:
		relics.append({})
	relics[slot] = item
	_recalculate()
	return true


func unequip_slot(slot: int) -> void:
	if slot < 0 or slot >= relics.size():
		return
	relics[slot] = {}
	_recalculate()


func equip(item: Dictionary) -> bool:
	for i in MAX_RELICS:
		if can_equip(item, i):
			return equip_slot(i, item)
	return false


func relic_total(key: String) -> float:
	var total := 0.0
	for item in relics:
		if item.is_empty():
			continue
		total += ItemDB.total(item, key)
	return total


func relic_names() -> String:
	var names: Array = []
	for item in relics:
		if not item.is_empty():
			names.append(String(item.get("name", "Relic")))
	if names.is_empty():
		return "None"
	return ", ".join(names)


func synergy() -> Dictionary:
	var syn := {
		"power": 0.0, "crit": 0.0, "crit_damage": 0.0, "move_speed": 0.0,
		"regen": 0.0, "life": 0.0, "life_pct": 0.0, "cost_cut": 0.0, "dash": 0.0,
		"active": [],
	}
	var blood := family_count("blood")
	var ember := family_count("ember")
	var rift := family_count("rift")
	if blood >= 2:
		syn.power += 0.18
		syn.life += 8.0
		syn.active.append("blood")
	if ember >= 2:
		syn.crit += 8.0
		syn.crit_damage += 30.0
		syn.active.append("ember")
	if rift >= 2:
		syn.move_speed += 10.0
		syn.regen += 1.2
		syn.dash += 0.5
		syn.active.append("rift")
	var families := 0
	for fam in ["blood", "ember", "rift"]:
		if family_count(fam) > 0:
			families += 1
	if families >= 3:
		syn.power += 0.06
		syn.life_pct += 0.05
		syn.cost_cut += 0.10
		syn.active.append("triad")
	return syn


func _recalculate() -> void:
	var ratio := 1.0
	if max_health > 0.0:
		ratio = health / max_health
	var syn := synergy()
	passive_bonus = Passives.totals(passive_nodes)
	var level_steps := float(level - 1)
	var base_health := float(class_data.get("health", BASE_MAX_HEALTH))
	var base_speed := float(class_data.get("speed", BASE_SPEED))
	var base_regen := float(class_data.get("regen", BASE_REGEN))
	var base_power := float(class_data.get("power", 1.0))
	var fury := float(boon_count("fury"))
	var vitality_boons := 40.0 * float(boon_count("vitality"))
	max_health = base_health + 14.0 * level_steps + relic_total("vitality") + float(syn.life) \
		+ float(passive_bonus.get("health_flat", 0.0)) + vitality_boons
	max_health *= 1.0 + float(syn.life_pct) + float(passive_bonus.get("health_pct", 0.0)) / 100.0
	move_speed = base_speed * (1.0 + 0.007 * level_steps + (relic_total("move_speed") + float(syn.move_speed)) / 100.0)
	move_speed *= 1.0 + float(passive_bonus.get("speed_pct", 0.0)) / 100.0
	move_speed *= pow(1.08, float(boon_count("swift")))
	crit_chance = 0.06 + (relic_total("crit") + float(syn.crit)) / 100.0 + float(passive_bonus.get("crit", 0.0)) / 100.0
	crit_damage = 1.75 + (relic_total("crit_damage") + float(syn.crit_damage)) / 100.0 + float(passive_bonus.get("crit_damage", 0.0)) / 100.0
	regen = base_regen + 0.09 * level_steps + relic_total("regen") + float(syn.regen) \
		+ float(passive_bonus.get("regen", 0.0)) + 0.9 * float(boon_count("regen"))
	life_cost_mult = (1.0 + relic_total("life_cost") / 100.0) * (1.0 - float(syn.cost_cut))
	life_cost_mult *= 1.0 + float(passive_bonus.get("cost_pct", 0.0)) / 100.0
	cooldown_mult = clampf(pow(0.85, float(boon_count("haste"))) * (1.0 + float(passive_bonus.get("cooldown_pct", 0.0)) / 100.0), 0.35, 1.0)
	power = base_power * (1.0 + relic_total("power") / 100.0) * (1.0 + float(syn.power)) \
		* (1.0 + 0.045 * level_steps) * (1.0 + float(passive_bonus.get("power_pct", 0.0)) / 100.0) * pow(1.15, fury)
	dash_cooldown_base = 2.2 - float(syn.dash)
	focus_max = float(class_data.get("focus_max", 0.0)) + 2.0 * level_steps + float(passive_bonus.get("focus_flat", 0.0))
	focus = clampf(focus, 0.0, focus_max)
	health = clampf(max_health * ratio, 1.0, max_health)
	health_changed.emit(health, max_health)
	focus_changed.emit(focus, focus_max)


func roll_damage(base: float) -> Array:
	var chance := crit_chance + (crit_bonus_amount if crit_bonus > 0.0 else 0.0)
	var crit := randf() < chance
	var amount := base * power * (1.0 + 0.035 * float(bloodrush)) * (crit_damage if crit else 1.0)
	return [amount, crit]


func xp_to_next() -> float:
	return 70.0 + 62.0 * float(level - 1)


func set_progress(level_value: int, xp_value: float) -> void:
	level = maxi(1, level_value)
	xp = maxf(0.0, xp_value)
	_recalculate()


func ensure_level(target_level: int) -> bool:
	if target_level <= level:
		return false
	var gained := target_level - level
	level = target_level
	xp = 0.0
	_recalculate()
	health = minf(max_health, health + 45.0 * float(gained))
	health_changed.emit(health, max_health)
	for i in gained:
		leveled_up.emit(level)
	return true


func gain_xp(amount: float) -> void:
	if not alive or amount <= 0.0:
		return
	xp += amount
	var gained := 0
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		gained += 1
	if gained <= 0:
		return
	_recalculate()
	health = minf(max_health, health + 40.0 * float(gained))
	health_changed.emit(health, max_health)
	for i in gained:
		leveled_up.emit(level)

