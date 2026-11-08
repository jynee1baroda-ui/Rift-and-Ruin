extends RefCounted
class_name HandGrip
## Finger joints and weapon sockets for every humanoid in the game.
##
## Imported rigs (Meshy and Mixamo style) stop at the wrist: they carry a single
## mitten hand and no finger bones at all. This builds real finger chains on a
## BoneAttachment3D per hand, so a held weapon has something to sit in and every
## humanoid reads as gripping instead of waving a floating prop.

const FINGER_SEGMENTS := 3
const FINGER_SIDES := 4


## Semantic bone lookup that understands both rig naming schemes in the game:
## Mixamo ("LeftHand") and Meshy ("hand.l").
static func bone_index(skeleton: Skeleton3D, patterns: Array) -> int:
	if skeleton == null:
		return -1
	for i in skeleton.get_bone_count():
		var name := skeleton.get_bone_name(i).to_lower().replace("_", "").replace(" ", "").replace(".", "")
		for pattern in patterns:
			if name == String(pattern).to_lower().replace("_", "").replace(".", ""):
				return i
	return -1


static func hand_bone(skeleton: Skeleton3D, left: bool) -> int:
	if left:
		return bone_index(skeleton, ["lefthand", "handl", "handleft", "lhand"])
	return bone_index(skeleton, ["righthand", "handr", "handright", "rhand"])


static func find_skeleton(root: Node) -> Skeleton3D:
	if root == null:
		return null
	if root is Skeleton3D:
		return root as Skeleton3D
	for child in root.find_children("*", "Skeleton3D", true, false):
		var skeleton := child as Skeleton3D
		if skeleton != null:
			return skeleton
	return null


## Builds a hand attachment with five curling fingers and a weapon socket.
## `scale_hint` is the model scale, so the joints stay proportional.
static func build_hand(skeleton: Skeleton3D, left: bool, scale_hint: float, skin: Color) -> Node3D:
	var index := hand_bone(skeleton, left)
	if index < 0:
		return null
	var attach := BoneAttachment3D.new()
	attach.name = "HandGrip%s" % ("L" if left else "R")
	skeleton.add_child(attach)
	attach.bone_name = skeleton.get_bone_name(index)
	attach.bone_idx = index
	var palm := Node3D.new()
	palm.name = "Grip"
	attach.add_child(palm)
	var unit := maxf(0.6, scale_hint)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = skin
	mat.roughness = 0.85
	var side := -1.0 if left else 1.0
	for finger in FINGER_SIDES:
		var spread := (float(finger) - 1.5) * 0.022 * unit
		var length := (0.030 - absf(float(finger) - 1.2) * 0.003) * unit
		var knuckle := Node3D.new()
		knuckle.position = Vector3(spread, 0.05 * unit, side * 0.012 * unit)
		knuckle.rotation_degrees = Vector3(-72.0, 0.0, 8.0 * (float(finger) - 1.5))
		palm.add_child(knuckle)
		var parent := knuckle
		for segment in FINGER_SEGMENTS:
			var joint := Node3D.new()
			joint.position = Vector3(0.0, length * (1.0 if segment == 0 else 0.9), 0.0)
			joint.rotation_degrees = Vector3(-38.0, 0.0, 0.0)
			parent.add_child(joint)
			var capsule := CapsuleMesh.new()
			capsule.radius = 0.0085 * unit
			capsule.height = length * 1.35
			capsule.radial_segments = 6
			capsule.rings = 2
			var mesh := MeshInstance3D.new()
			mesh.mesh = capsule
			mesh.material_override = mat
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			mesh.position = Vector3(0.0, length * 0.5, 0.0)
			joint.add_child(mesh)
			parent = joint
	var thumb := Node3D.new()
	thumb.position = Vector3(-0.03 * unit * (1.0 if left else -1.0), 0.03 * unit, side * 0.028 * unit)
	thumb.rotation_degrees = Vector3(-30.0, 0.0, 55.0 * side)
	palm.add_child(thumb)
	var thumb_len := 0.026 * unit
	var thumb_joint := Node3D.new()
	thumb_joint.position = Vector3(0.0, thumb_len, 0.0)
	thumb_joint.rotation_degrees = Vector3(-40.0, 0.0, 0.0)
	thumb.add_child(thumb_joint)
	for node in [thumb, thumb_joint]:
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.0095 * unit
		capsule.height = thumb_len * 1.4
		capsule.radial_segments = 6
		capsule.rings = 2
		var mesh := MeshInstance3D.new()
		mesh.mesh = capsule
		mesh.material_override = mat
		mesh.position = Vector3(0.0, thumb_len * 0.5, 0.0)
		node.add_child(mesh)
	return palm


## A held weapon, built from primitives in the grip's local space. The hammer
## and staff sit along the bone, the bow across it.
static func build_shield(scale_hint: float) -> Node3D:
	var unit := maxf(0.6, scale_hint)
	var root := Node3D.new()
	root.name = "Shield"
	var plate := StandardMaterial3D.new()
	plate.albedo_color = Color(0.34, 0.31, 0.29)
	plate.metallic = 0.8
	plate.roughness = 0.36
	var face := CylinderMesh.new()
	face.top_radius = 0.30 * unit
	face.bottom_radius = 0.32 * unit
	face.height = 0.05 * unit
	face.radial_segments = 20
	var mesh := MeshInstance3D.new()
	mesh.mesh = face
	mesh.material_override = plate
	root.add_child(mesh)
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.74, 0.30)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.66, 0.22)
	rim_mat.emission_energy_multiplier = 1.4
	var rim := TorusMesh.new()
	rim.inner_radius = 0.29 * unit
	rim.outer_radius = 0.325 * unit
	rim.rings = 28
	rim.ring_segments = 4
	var rim_mesh := MeshInstance3D.new()
	rim_mesh.mesh = rim
	rim_mesh.material_override = rim_mat
	rim_mesh.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	root.add_child(rim_mesh)
	return root


static func build_weapon(kind: String, scale_hint: float) -> Node3D:
	var unit := maxf(0.6, scale_hint)
	var root := Node3D.new()
	root.name = "Weapon"
	match kind:
		"hammer":
			var steel := StandardMaterial3D.new()
			steel.albedo_color = Color(0.42, 0.40, 0.38)
			steel.metallic = 0.75
			steel.roughness = 0.42
			var haft := CylinderMesh.new()
			haft.top_radius = 0.016 * unit
			haft.bottom_radius = 0.019 * unit
			haft.height = 0.72 * unit
			var haft_mesh := MeshInstance3D.new()
			haft_mesh.mesh = haft
			haft_mesh.material_override = steel
			haft_mesh.position = Vector3(0.0, 0.40 * unit, 0.0)
			root.add_child(haft_mesh)
			var head := BoxMesh.new()
			head.size = Vector3(0.20, 0.13, 0.13) * unit
			var head_mesh := MeshInstance3D.new()
			head_mesh.mesh = head
			head_mesh.material_override = steel
			head_mesh.position = Vector3(0.0, 0.80 * unit, 0.0)
			head_mesh.rotation_degrees = Vector3(0.0, 0.0, 12.0)
			root.add_child(head_mesh)
			var glow := StandardMaterial3D.new()
			glow.albedo_color = Color(1.0, 0.72, 0.28, 0.9)
			glow.emission_enabled = true
			glow.emission = Color(1.0, 0.66, 0.2)
			glow.emission_energy_multiplier = 2.2
			var band := CylinderMesh.new()
			band.top_radius = 0.021 * unit
			band.bottom_radius = 0.021 * unit
			band.height = 0.03 * unit
			var band_mesh := MeshInstance3D.new()
			band_mesh.mesh = band
			band_mesh.material_override = glow
			band_mesh.position = Vector3(0.0, 0.62 * unit, 0.0)
			root.add_child(band_mesh)
		"staff":
			var dark := StandardMaterial3D.new()
			dark.albedo_color = Color(0.13, 0.09, 0.11)
			dark.roughness = 0.55
			dark.metallic = 0.2
			var shaft := CylinderMesh.new()
			shaft.top_radius = 0.012 * unit
			shaft.bottom_radius = 0.016 * unit
			shaft.height = 1.15 * unit
			var shaft_mesh := MeshInstance3D.new()
			shaft_mesh.mesh = shaft
			shaft_mesh.material_override = dark
			shaft_mesh.position = Vector3(0.0, 0.45 * unit, 0.0)
			root.add_child(shaft_mesh)
			var orb_mat := StandardMaterial3D.new()
			orb_mat.albedo_color = Color(1.0, 0.16, 0.14, 0.95)
			orb_mat.emission_enabled = true
			orb_mat.emission = Color(1.0, 0.12, 0.1)
			orb_mat.emission_energy_multiplier = 3.0
			var orb := SphereMesh.new()
			orb.radius = 0.045 * unit
			orb.height = 0.09 * unit
			orb.radial_segments = 12
			orb.rings = 6
			var orb_mesh := MeshInstance3D.new()
			orb_mesh.mesh = orb
			orb_mesh.material_override = orb_mat
			orb_mesh.position = Vector3(0.0, 1.06 * unit, 0.0)
			root.add_child(orb_mesh)
		"bow":
			var wood := StandardMaterial3D.new()
			wood.albedo_color = Color(0.17, 0.11, 0.09)
			wood.roughness = 0.7
			var limbs := CylinderMesh.new()
			limbs.top_radius = 0.009 * unit
			limbs.bottom_radius = 0.011 * unit
			limbs.height = 0.62 * unit
			for i in 2:
				var limb := MeshInstance3D.new()
				limb.mesh = limbs
				limb.material_override = wood
				limb.position = Vector3(0.0, (0.29 if i == 0 else -0.29) * unit, 0.03 * unit)
				limb.rotation_degrees = Vector3(14.0 if i == 0 else -14.0, 0.0, 0.0)
				root.add_child(limb)
			var string_mat := StandardMaterial3D.new()
			string_mat.albedo_color = Color(0.85, 0.82, 0.76)
			string_mat.emission_enabled = true
			string_mat.emission = Color(0.6, 0.8, 0.75)
			string_mat.emission_energy_multiplier = 0.6
			var string_mesh := MeshInstance3D.new()
			var line := BoxMesh.new()
			line.size = Vector3(0.004, 0.60 * unit, 0.004)
			string_mesh.mesh = line
			string_mesh.material_override = string_mat
			string_mesh.position = Vector3(0.0, 0.0, 0.02 * unit)
			root.add_child(string_mesh)
	return root


## Builds hands and the class weapon for one humanoid model.
static func dress(root: Node, class_id: String, scale_hint: float, skin: Color, weapon_override := "") -> void:
	var skeleton := find_skeleton(root)
	if skeleton == null:
		return
	var left := build_hand(skeleton, true, scale_hint, skin)
	var right := build_hand(skeleton, false, scale_hint, skin)
	var weapon := weapon_override
	var hand: Node3D = right
	if weapon.is_empty():
		match class_id:
			"iron_paladin":
				weapon = "hammer"
			"shadow_huntress":
				weapon = "bow"
			"blood_sorceress":
				weapon = "staff"
	if weapon.is_empty() or hand == null:
		return
	if weapon == "bow":
		hand = left
	var prop := build_weapon(weapon, scale_hint)
	hand.add_child(prop)
	if class_id == "iron_paladin" and left != null:
		var shield := build_shield(scale_hint)
		left.add_child(shield)
		var shield_index := hand_bone(skeleton, true)
		if shield_index >= 0:
			var sb := skeleton.get_bone_global_pose(shield_index).basis.orthonormalized()
			shield.basis = sb.inverse() * Basis(Quaternion(sb.y.normalized(), Vector3(0.0, 0.25, -0.97).normalized())) * sb
			shield.position = Vector3(0.0, 0.10, 0.02)
	## Align the shaft with a deliberate world direction instead of guessing the
	## hand bone's local axes: the prop is rotated so its own +Y points along
	## `want` while the hand keeps its pose.
	var hand_index := hand_bone(skeleton, weapon == "bow")
	var want := Vector3(0.05, 0.99, 0.10) if weapon == "bow" else Vector3(0.18, -0.95, 0.22)
	if hand_index >= 0:
		var hand_basis := skeleton.get_bone_global_pose(hand_index).basis.orthonormalized()
		var current := hand_basis.y.normalized()
		var delta := Basis(Quaternion(current, want.normalized()))
		prop.basis = hand_basis.inverse() * delta * hand_basis
