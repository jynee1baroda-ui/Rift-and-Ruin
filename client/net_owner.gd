extends Node3D
## Your own sorceress, seen through the network contract. The character you
## actually control is the game's Player node; this projection publishes her
## pose to the authority and snaps her back if the authority refuses one.

const SEND_INTERVAL := 1.0 / 20.0

var group: SummerNetworkStateGroup
var player: Node3D
var _pose := {}
var _sent := {}
var _submission: SummerNetworkStateSubmission
var _send_elapsed := 0.0


func bind(motion: SummerNetworkStateGroup) -> void:
	group = motion
	group.state_installed.connect(_on_installed)
	_on_installed(group.get_state(), group.get_revision(), true)


## Accepted receipts install the confirmed pose with reset = false. Only
## resets (spawn, teleport, a refused pose) move the character.
func _on_installed(state: Dictionary, _revision: int, reset: bool) -> void:
	if state.is_empty() or not reset:
		return
	_pose = state.duplicate()
	_sent = state.duplicate()
	_submission = null
	if player == null or not is_instance_valid(player):
		return
	player.global_position = state.position
	player.facing = float(state.yaw)
	player.velocity = Vector3.ZERO
	player.stop()


func _physics_process(delta: float) -> void:
	if group == null or not group.active:
		return
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			return
		if _pose.is_empty():
			_pose = group.get_state().duplicate()
	_send_elapsed += delta
	if _send_elapsed < SEND_INTERVAL:
		return
	_send_elapsed = 0.0
	_pose.position = player.global_position
	_pose.yaw = player.facing
	if _pose == _sent:
		if _submission == null or not _submission.is_completed():
			return
		if _submission.get_outcome() == SummerNetworkStateSubmission.OUTCOME_ACCEPTED:
			return
	_submission = group.submit(_pose)
	_sent = _pose.duplicate()
