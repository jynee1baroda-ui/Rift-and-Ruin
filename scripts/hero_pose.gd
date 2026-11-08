extends RefCounted
class_name HeroPose
## Signature idle stances for a bind pose. Works from bone directions instead of
## guessed Euler angles, so it lands the same on Mixamo ("LeftArm") and Meshy
## ("upperarm.l") rigs, and never leaves a character in a T or A pose.

static func bone_index(skeleton: Skeleton3D, patterns: Array) -> int:
	return HandGrip.bone_index(skeleton, patterns)


## Rotates a bone so the direction from it to `child` points along `want`
## (skeleton space). The bone axis comes from the rest skeleton itself, so it
## does not depend on which way a given rig happens to orient its bones.
static func aim(skeleton: Skeleton3D, index: int, want: Vector3, child: int = -1) -> void:
	if skeleton == null or index < 0 or want.length_squared() < 0.0001:
		return
	var posed := skeleton.get_bone_global_pose(index)
	var current := posed.basis.y.normalized()
	if child >= 0:
		var child_posed := skeleton.get_bone_global_pose(child)
		if child_posed.origin.distance_to(posed.origin) > 0.0005:
			current = (child_posed.origin - posed.origin).normalized()
	var target := want.normalized()
	var delta := Quaternion(current, target)
	var wanted_basis := Basis(delta) * posed.basis
	var parent := skeleton.get_bone_parent(index)
	var local_rest := skeleton.get_bone_rest(index)
	var parent_global := skeleton.get_bone_global_pose(parent) if parent >= 0 else Transform3D.IDENTITY
	var desired := parent_global.affine_inverse() * Transform3D(wanted_basis, posed.origin)
	var pose_q := (local_rest.basis.inverse() * desired.basis).get_rotation_quaternion()
	skeleton.set_bone_pose_rotation(index, pose_q)
	skeleton.force_update_all_bone_transforms()


## Applies the class stance to a skeleton that is showing its bind pose.
static func stance(skeleton: Skeleton3D, class_id: String) -> void:
	if skeleton == null:
		return
	var l_arm := bone_index(skeleton, ["leftarm", "upperarm.l", "leftupperarm"])
	var r_arm := bone_index(skeleton, ["rightarm", "upperarm.r", "rightupperarm"])
	var l_fore := bone_index(skeleton, ["leftforearm", "lowerarm.l", "leftlowerarm"])
	var r_fore := bone_index(skeleton, ["rightforearm", "lowerarm.r", "rightlowerarm"])
	var l_hand := HandGrip.hand_bone(skeleton, true)
	var r_hand := HandGrip.hand_bone(skeleton, false)
	var spine := bone_index(skeleton, ["spine01", "spine1", "chest"])
	match class_id:
		"iron_paladin":
			aim(skeleton, l_arm, Vector3(-0.46, -0.90, -0.08), l_fore)
			aim(skeleton, r_arm, Vector3(0.34, -0.94, -0.02), r_fore)
			aim(skeleton, l_fore, Vector3(-0.10, -1.0, -0.10), l_hand)
			aim(skeleton, r_fore, Vector3(0.08, -1.0, -0.12), r_hand)
		"shadow_huntress":
			aim(skeleton, l_arm, Vector3(-0.30, -0.62, -0.72), l_fore)
			aim(skeleton, r_arm, Vector3(0.34, -0.92, -0.18), r_fore)
			aim(skeleton, l_fore, Vector3(-0.10, -0.34, -0.94), l_hand)
			aim(skeleton, r_fore, Vector3(0.10, -1.0, -0.14), r_hand)
		_:
			aim(skeleton, r_arm, Vector3(0.44, -0.78, -0.44), r_fore)
			aim(skeleton, l_arm, Vector3(-0.40, -0.90, -0.16), l_fore)
			aim(skeleton, r_fore, Vector3(0.14, -1.0, -0.16), r_hand)
			aim(skeleton, l_fore, Vector3(-0.12, -1.0, -0.10), l_hand)
	if spine >= 0:
		skeleton.set_bone_pose_rotation(spine, Quaternion(Vector3.RIGHT, deg_to_rad(-3.0)))
		skeleton.force_update_all_bone_transforms()
