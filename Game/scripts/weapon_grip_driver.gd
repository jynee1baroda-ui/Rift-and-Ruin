extends Node

var skeleton: Skeleton3D
var weapon: Node3D
var hand_left := false
var grip_mode := "shaft"
var grip_offset := Vector3.ZERO
var upper_index := -1
var forearm_index := -1
var hand_index := -1


func configure(rig: Skeleton3D, held_weapon: Node3D, secondary_left: bool, mode: String, offset: Vector3) -> void:
	skeleton = rig
	weapon = held_weapon
	hand_left = secondary_left
	grip_mode = mode
	grip_offset = offset
	var upper_patterns := ["leftarm", "upperarm.l", "leftupperarm"] if hand_left else ["rightarm", "upperarm.r", "rightupperarm"]
	var forearm_patterns := ["leftforearm", "lowerarm.l", "leftlowerarm"] if hand_left else ["rightforearm", "lowerarm.r", "rightlowerarm"]
	upper_index = HandGrip.bone_index(skeleton, upper_patterns)
	forearm_index = HandGrip.bone_index(skeleton, forearm_patterns)
	hand_index = HandGrip.hand_bone(skeleton, hand_left)
	process_priority = 100


func _process(_delta: float) -> void:
	if skeleton == null or weapon == null or not is_instance_valid(skeleton) or not is_instance_valid(weapon):
		return
	if upper_index < 0 or forearm_index < 0 or hand_index < 0:
		return
	var goal := skeleton.global_transform.affine_inverse() * weapon.to_global(grip_offset)
	_aim_hand_to(goal)


func _aim_hand_to(goal: Vector3) -> void:
	var shoulder := skeleton.get_bone_global_pose(upper_index).origin
	var elbow := skeleton.get_bone_global_pose(forearm_index).origin
	var wrist := skeleton.get_bone_global_pose(hand_index).origin
	var upper_length := shoulder.distance_to(elbow)
	var lower_length := elbow.distance_to(wrist)
	if upper_length < 0.001 or lower_length < 0.001:
		return
	var toward_goal := goal - shoulder
	if toward_goal.length_squared() < 0.0001:
		return
	var direction := toward_goal.normalized()
	var reach := clampf(toward_goal.length(), absf(upper_length - lower_length) + 0.001, upper_length + lower_length - 0.001)
	var target := shoulder + direction * reach
	var pole := elbow - shoulder
	pole -= direction * pole.dot(direction)
	if grip_mode == "draw":
		pole += (Vector3.RIGHT if hand_left else Vector3.LEFT) * 0.12
		pole -= direction * pole.dot(direction)
	if pole.length_squared() < 0.0001:
		pole = Vector3.FORWARD - direction * Vector3.FORWARD.dot(direction)
	if pole.length_squared() < 0.0001:
		pole = Vector3.RIGHT - direction * Vector3.RIGHT.dot(direction)
	pole = pole.normalized()
	var along := (upper_length * upper_length - lower_length * lower_length + reach * reach) / (2.0 * reach)
	var height := sqrt(maxf(0.0, upper_length * upper_length - along * along))
	var elbow_target := shoulder + direction * along + pole * height
	HeroPose.aim(skeleton, upper_index, elbow_target - shoulder, forearm_index)
	skeleton.force_update_all_bone_transforms()
	var posed_elbow := skeleton.get_bone_global_pose(forearm_index).origin
	HeroPose.aim(skeleton, forearm_index, target - posed_elbow, hand_index)
	skeleton.force_update_all_bone_transforms()
