extends Node3D
## Someone else's sorceress. She is only a drawing on your screen: her owner
## decides where she is, and this node glides between the poses it published.

const VIEW_DELAY := 0.1
const HERO_SCENE := "res://art/generated/blood_sorceress/character.tscn"

var group: SummerNetworkStateGroup
var _samples: Array = []
var _offsets: Array = []
var _anim: AnimationPlayer
var _shown := Vector3.ZERO
var _moving := 0.0


func _ready() -> void:
	_build_visual()


func _build_visual() -> void:
	var model_root := Node3D.new()
	model_root.name = "Model"
	add_child(model_root)
	var scene: Variant = load(HERO_SCENE)
	if scene is PackedScene:
		var inst: Node = (scene as PackedScene).instantiate()
		model_root.add_child(inst)
		model_root.scale = Vector3.ONE * 1.35
		_anim = _find_animation(inst)
	var plate := Label3D.new()
	plate.text = "ALLY"
	plate.font_size = 40
	plate.pixel_size = 0.0035
	plate.position.y = 2.45
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.modulate = Color(1.0, 0.72, 0.66, 0.92)
	plate.no_depth_test = true
	plate.outline_size = 8
	add_child(plate)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.62
	torus.outer_radius = 0.74
	torus.rings = 64
	torus.ring_segments = 6
	ring.mesh = torus
	ring.material_override = FX.glow_material(Color(1.0, 0.35, 0.28, 0.55))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = 0.06
	add_child(ring)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.32, 0.24)
	light.light_energy = 0.9
	light.omni_range = 3.2
	light.shadow_enabled = false
	light.position.y = 1.4
	add_child(light)


func _find_animation(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation(child)
		if found != null:
			return found
	return null


func bind(motion: SummerNetworkStateGroup) -> void:
	group = motion
	group.state_installed.connect(_on_installed)
	_on_installed(group.get_state(), group.get_revision(), true)


func _on_installed(state: Dictionary, _revision: int, reset: bool) -> void:
	if state.is_empty():
		return
	var now := Time.get_ticks_usec() / 1000000.0
	if reset:
		_samples.clear()
		global_position = state.position
		rotation.y = float(state.yaw)
		_shown = global_position
	_samples.append([_pose_time(now), state.position, state.yaw])
	if _samples.size() > 20:
		_samples.pop_front()


func _process(delta: float) -> void:
	if _samples.is_empty():
		return
	var at := Time.get_ticks_usec() / 1000000.0 - VIEW_DELAY
	var newest: Array = _samples[-1]
	if at >= float(newest[0]) or _samples.size() == 1:
		global_position = newest[1]
		rotation.y = float(newest[2])
	else:
		var placed := false
		for i in range(_samples.size() - 1, 0, -1):
			var a: Array = _samples[i - 1]
			var b: Array = _samples[i]
			if at >= float(a[0]):
				var t := clampf((at - float(a[0])) / maxf(float(b[0]) - float(a[0]), 0.0001), 0.0, 1.0)
				global_position = (a[1] as Vector3).lerp(b[1], t)
				rotation.y = lerp_angle(float(a[2]), float(b[2]), t)
				placed = true
				break
		if not placed:
			global_position = _samples[0][1]
	var speed := global_position.distance_to(_shown) / maxf(delta, 0.0001)
	_shown = global_position
	_moving = lerpf(_moving, 1.0 if speed > 0.35 else 0.0, clampf(delta * 8.0, 0.0, 1.0))
	if _anim != null:
		for clip in _anim.get_animation_list():
			if _moving > 0.5 and String(clip).to_lower().contains("run"):
				if _anim.current_animation != clip:
					_anim.play(clip)
				_anim.speed_scale = 1.0
				return
		for clip in _anim.get_animation_list():
			if _moving <= 0.5 and String(clip).to_lower().contains("idle"):
				if _anim.current_animation != clip:
					_anim.play(clip)
				_anim.speed_scale = 1.0
				return


## Places a pose on the local timeline by when the authority accepted it, so
## poses that arrive bunched together still play back evenly.
func _pose_time(now: float) -> float:
	var timing := group.get_timing()
	if timing == null or timing.state_authority_usec < 0:
		return now
	var accepted := float(timing.state_authority_usec) / 1000000.0
	_offsets.append(now - accepted)
	if _offsets.size() > 40:
		_offsets.pop_front()
	return minf(accepted + float(_offsets.min()), now)
