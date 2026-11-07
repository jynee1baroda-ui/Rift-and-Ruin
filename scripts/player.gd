class_name Player
extends CharacterBody3D

signal died
signal health_changed(current: float, maximum: float)
signal ability_used(index: int, aim: Vector3)
signal damaged(amount: float)
signal healed(amount: float)
signal life_spent(amount: float)

const BASE_MAX_HEALTH := 220.0
const BASE_SPEED := 7.2
const GRAVITY := 28.0
const BASE_REGEN := 2.4
const COMBAT_REGEN := 0.5
const BLOODRUSH_TIME := 4.5
const BLOODRUSH_MAX := 10
const MAX_RELICS := 3
const FAMILY_STACK_LIMIT := 2

const ABILITIES := [
	{"name": "Blood Nova", "cost": 6.0, "cooldown": 3.2, "key": "1", "glyph": "NOVA", "desc": "Detonate your life force around you."},
	{"name": "Crimson Lance", "cost": 3.0, "cooldown": 0.85, "key": "2", "glyph": "LANCE", "desc": "Hurl a piercing spear of blood."},
	{"name": "Sanguine Siphon", "cost": 0.0, "cooldown": 7.5, "key": "3", "glyph": "SIPHON", "desc": "Drain nearby foes and drink their life."},
]

var max_health := BASE_MAX_HEALTH
var health := BASE_MAX_HEALTH
var move_speed := BASE_SPEED
var crit_chance := 0.06
var crit_damage := 1.75
var power := 1.0
var regen := BASE_REGEN
var life_cost_mult := 1.0
var relics: Array = []
var dash_cooldown_base := 2.2
var move_direct := Vector3.ZERO

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


func setup(model_scene: PackedScene) -> void:
	if model_scene != null:
		var inst := model_scene.instantiate()
		model_root.add_child(inst)
		model_root.scale = Vector3.ONE * 1.35
		anim = _find_animation_player(inst)
	else:
		_build_fallback_model()


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
	var rate := regen_now()
	if rate > 0.0 and health < max_health:
		heal(rate * delta)

	if dash_time > 0.0:
		dash_time -= delta
		velocity = dash_direction * 30.0
		move_and_slide()
		_fix_height()
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
	move_and_slide()
	_fix_height()
	moving = walking
	_update_anim(walking)
	if ground_ring != null:
		ground_ring.rotation.y += delta * 0.6


func _fix_height() -> void:
	if global_position.y < -4.0:
		global_position.y = 0.4
		velocity.y = 0.0


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var target := atan2(direction.x, direction.z)
	facing = lerp_angle(facing, target, minf(1.0, delta * 14.0))
	if model_root != null:
		model_root.rotation.y = facing + PI


func _update_anim(walking: bool) -> void:
	if cast_timer > 0.0:
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
	if index < 0 or index >= ABILITIES.size():
		return 0.0
	var cost: float = ABILITIES[index].cost
	if index == 0 and has_unique("nova_free"):
		cost = 0.0
	return cost * life_cost_mult


func ability_ready(index: int) -> bool:
	if not alive or index < 0 or index >= ABILITIES.size():
		return false
	if cooldowns[index] > 0.0:
		return false
	var cost := ability_cost(index)
	return cost <= 0.0 or health > cost + 1.0


func try_ability(index: int) -> bool:
	if not ability_ready(index):
		return false
	var aim := aim_point
	if (aim - global_position).length_squared() > 0.01:
		_face_direction((aim - global_position), 1.0)
	cooldowns[index] = float(ABILITIES[index].cooldown)
	var cost := ability_cost(index)
	if cost > 0.0:
		health = maxf(1.0, health - cost)
		life_spent.emit(cost)
		health_changed.emit(health, max_health)
	cast_timer = 0.42
	ability_used.emit(index, aim)
	return true


func add_bloodrush() -> void:
	bloodrush = mini(bloodrush + 1, BLOODRUSH_MAX)
	bloodrush_timer = BLOODRUSH_TIME


func in_combat() -> bool:
	return combat_timer > 0.0


func regen_now() -> float:
	var rate := COMBAT_REGEN
	if combat_timer <= 0.0:
		rate = regen * clampf(calm_time / 1.2, 0.2, 1.0)
	return rate + 0.07 * float(bloodrush)


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
	health = maxf(0.0, health - amount)
	combat_timer = 3.5
	invulnerable = 0.45
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
	max_health = BASE_MAX_HEALTH + relic_total("vitality") + float(syn.life)
	max_health *= 1.0 + float(syn.life_pct)
	move_speed = BASE_SPEED * (1.0 + (relic_total("move_speed") + float(syn.move_speed)) / 100.0)
	crit_chance = 0.06 + (relic_total("crit") + float(syn.crit)) / 100.0
	crit_damage = 1.75 + (relic_total("crit_damage") + float(syn.crit_damage)) / 100.0
	regen = BASE_REGEN + relic_total("regen") + float(syn.regen)
	life_cost_mult = (1.0 + relic_total("life_cost") / 100.0) * (1.0 - float(syn.cost_cut))
	power = (1.0 + relic_total("power") / 100.0) * (1.0 + float(syn.power))
	dash_cooldown_base = 2.2 - float(syn.dash)
	health = clampf(max_health * ratio, 1.0, max_health)
	health_changed.emit(health, max_health)


func roll_damage(base: float) -> Array:
	var crit := randf() < crit_chance
	var amount := base * power * (1.0 + 0.035 * float(bloodrush)) * (crit_damage if crit else 1.0)
	return [amount, crit]
