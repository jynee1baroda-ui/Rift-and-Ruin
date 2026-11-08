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

## One grip profile per weapon type. `axis` is the world-space direction the
## weapon's own +Y should point while held, `roll` turns it about that axis,
## `offset` seats the handle in the palm and `curl` is how tightly the fingers
## close. Weapons are not interchangeable: a bow is carried upright in the left
## hand, a sword hangs blade-down in the right.
const WEAPON_PROFILES := {
	"staff": {"hand": "right", "axis": Vector3(0.16, -0.96, 0.20), "roll": 0.0, "offset": Vector3(0.0, 0.03, 0.01), "curl": 0.95},
	"hammer": {"hand": "right", "axis": Vector3(0.18, -0.95, 0.22), "roll": 0.0, "offset": Vector3(0.0, 0.02, 0.01), "curl": 1.0},
	"sword": {"hand": "right", "axis": Vector3(0.24, -0.90, 0.36), "roll": 8.0, "offset": Vector3(0.0, 0.02, 0.02), "curl": 1.0},
	"axe": {"hand": "right", "axis": Vector3(0.26, -0.90, 0.34), "roll": 0.0, "offset": Vector3(0.0, 0.02, 0.02), "curl": 1.0},
	"cleaver": {"hand": "right", "axis": Vector3(0.30, -0.86, 0.40), "roll": 0.0, "offset": Vector3(0.0, 0.03, 0.02), "curl": 1.0},
	"dagger": {"hand": "right", "axis": Vector3(0.20, -0.92, 0.34), "roll": 0.0, "offset": Vector3(0.0, 0.01, 0.01), "curl": 1.05},
	"spear": {"hand": "right", "axis": Vector3(0.20, -0.94, 0.28), "roll": 0.0, "offset": Vector3(0.0, 0.02, 0.01), "curl": 0.98},
	"trident": {"hand": "right", "axis": Vector3(0.20, -0.94, 0.28), "roll": 0.0, "offset": Vector3(0.0, 0.02, 0.01), "curl": 0.98},
	"bow": {"hand": "left", "axis": Vector3(0.05, 0.99, 0.10), "roll": 0.0, "offset": Vector3(0.0, 0.02, 0.02), "curl": 0.55},
}


static func profile(kind: String) -> Dictionary:
	return WEAPON_PROFILES.get(kind, WEAPON_PROFILES["sword"])



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
static func build_hand(skeleton: Skeleton3D, left: bool, scale_hint: float, skin: Color, curl := 1.0) -> Node3D:
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
	## Imported rigs often carry the whole skeleton at centimetre scale (0.01),
	## which shrinks anything parented to a hand a hundredfold - fingers and
	## weapon alike. Cancel the skeleton's own scale so props are built at true
	## model scale.
	var bone_scale := skeleton.scale
	if bone_scale.length_squared() < 0.0000001:
		bone_scale = Vector3.ONE
	palm.scale = Vector3(
		1.0 / maxf(0.0001, bone_scale.x),
		1.0 / maxf(0.0001, bone_scale.y),
		1.0 / maxf(0.0001, bone_scale.z))
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
		knuckle.rotation_degrees = Vector3(-72.0 * curl, 0.0, 8.0 * (float(finger) - 1.5))
		palm.add_child(knuckle)
		var parent := knuckle
		for segment in FINGER_SEGMENTS:
			var joint := Node3D.new()
			joint.position = Vector3(0.0, length * (1.0 if segment == 0 else 0.9), 0.0)
			joint.rotation_degrees = Vector3(-38.0 * curl, 0.0, 0.0)
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
			dark.albedo_color = Color(0.30, 0.19, 0.16)
			dark.roughness = 0.5
			dark.metallic = 0.25
			var shaft := CylinderMesh.new()
			shaft.top_radius = 0.012 * unit
			shaft.bottom_radius = 0.016 * unit
			shaft.height = 1.15 * unit
			var shaft_mesh := MeshInstance3D.new()
			shaft_mesh.mesh = shaft
			shaft_mesh.material_override = dark
			shaft_mesh.position = Vector3(0.0, 0.45 * unit, 0.0)
			root.add_child(shaft_mesh)
			## Runing bands so the haft reads against a dark robe at any zoom.
			var band_mat := StandardMaterial3D.new()
			band_mat.albedo_color = Color(1.0, 0.30, 0.22, 1.0)
			band_mat.emission_enabled = true
			band_mat.emission = Color(1.0, 0.16, 0.12)
			band_mat.emission_energy_multiplier = 2.4
			for band_y in [0.30, 0.74]:
				var band := MeshInstance3D.new()
				var band_mesh := CylinderMesh.new()
				band_mesh.top_radius = 0.020 * unit
				band_mesh.bottom_radius = 0.020 * unit
				band_mesh.height = 0.028 * unit
				band_mesh.radial_segments = 10
				band.mesh = band_mesh
				band.material_override = band_mat
				band.position = Vector3(0.0, float(band_y) * unit, 0.0)
				root.add_child(band)
			var orb_mat := StandardMaterial3D.new()
			orb_mat.albedo_color = Color(1.0, 0.16, 0.14, 0.95)
			orb_mat.emission_enabled = true
			orb_mat.emission = Color(1.0, 0.12, 0.1)
			orb_mat.emission_energy_multiplier = 3.0
			var orb := SphereMesh.new()
			orb.radius = 0.062 * unit
			orb.height = 0.124 * unit
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
		"sword", "dagger":
			var short := kind == "dagger"
			var steel := StandardMaterial3D.new()
			steel.albedo_color = Color(0.62, 0.64, 0.68)
			steel.metallic = 0.92
			steel.roughness = 0.26
			var grip_len := (0.09 if short else 0.17) * unit
			var blade_len := (0.34 if short else 0.92) * unit
			var leather := StandardMaterial3D.new()
			leather.albedo_color = Color(0.16, 0.10, 0.09)
			leather.roughness = 0.85
			var grip_mesh := MeshInstance3D.new()
			var grip_cyl := CylinderMesh.new()
			grip_cyl.top_radius = 0.016 * unit
			grip_cyl.bottom_radius = 0.018 * unit
			grip_cyl.height = grip_len
			grip_cyl.radial_segments = 8
			grip_mesh.mesh = grip_cyl
			grip_mesh.material_override = leather
			grip_mesh.position = Vector3(0.0, grip_len * 0.5 - 0.02 * unit, 0.0)
			root.add_child(grip_mesh)
			var guard := MeshInstance3D.new()
			var guard_mesh := BoxMesh.new()
			guard_mesh.size = Vector3((0.20 if short else 0.26) * unit, 0.022 * unit, 0.03 * unit)
			guard.mesh = guard_mesh
			guard.material_override = steel
			guard.position = Vector3(0.0, grip_len - 0.01 * unit, 0.0)
			root.add_child(guard)
			var blade := MeshInstance3D.new()
			var blade_mesh := BoxMesh.new()
			blade_mesh.size = Vector3((0.035 if short else 0.055) * unit, blade_len, 0.012 * unit)
			blade.mesh = blade_mesh
			blade.material_override = steel
			blade.position = Vector3(0.0, grip_len + blade_len * 0.5, 0.0)
			root.add_child(blade)
			var tip := MeshInstance3D.new()
			var tip_mesh := BoxMesh.new()
			tip_mesh.size = Vector3((0.018 if short else 0.03) * unit, blade_len * 0.14, 0.012 * unit)
			tip.mesh = tip_mesh
			tip.material_override = steel
			tip.position = Vector3(0.0, grip_len + blade_len + blade_len * 0.05, 0.0)
			root.add_child(tip)
			var pommel := MeshInstance3D.new()
			var pommel_mesh := SphereMesh.new()
			pommel_mesh.radius = 0.022 * unit
			pommel_mesh.height = 0.044 * unit
			pommel_mesh.radial_segments = 8
			pommel_mesh.rings = 4
			pommel.mesh = pommel_mesh
			pommel.material_override = steel
			pommel.position = Vector3(0.0, -0.03 * unit, 0.0)
			root.add_child(pommel)
		"axe", "cleaver":
			var heavy := kind == "cleaver"
			var iron := StandardMaterial3D.new()
			iron.albedo_color = Color(0.30, 0.27, 0.25)
			iron.metallic = 0.7
			iron.roughness = 0.5
			var wood := StandardMaterial3D.new()
			wood.albedo_color = Color(0.17, 0.11, 0.08)
			wood.roughness = 0.8
			var haft_len := (0.62 if heavy else 0.58) * unit
			var haft := MeshInstance3D.new()
			var haft_cyl := CylinderMesh.new()
			haft_cyl.top_radius = 0.016 * unit
			haft_cyl.bottom_radius = 0.020 * unit
			haft_cyl.height = haft_len
			haft_cyl.radial_segments = 8
			haft.mesh = haft_cyl
			haft.material_override = wood
			haft.position = Vector3(0.0, haft_len * 0.5 - 0.04 * unit, 0.0)
			root.add_child(haft)
			var head := MeshInstance3D.new()
			var head_mesh := BoxMesh.new()
			head_mesh.size = Vector3((0.30 if heavy else 0.24) * unit, (0.26 if heavy else 0.20) * unit, 0.035 * unit)
			head.mesh = head_mesh
			head.material_override = iron
			head.position = Vector3((0.09 if heavy else 0.08) * unit, haft_len - 0.06 * unit, 0.0)
			head.rotation_degrees = Vector3(0.0, 0.0, -6.0)
			root.add_child(head)
			var spike := MeshInstance3D.new()
			var spike_mesh := BoxMesh.new()
			spike_mesh.size = Vector3(0.05 * unit, 0.14 * unit, 0.03 * unit)
			spike.mesh = spike_mesh
			spike.material_override = iron
			spike.position = Vector3(0.0, haft_len + 0.02 * unit, 0.0)
			root.add_child(spike)
		"spear", "trident":
			var three := kind == "trident"
			var shaft_mat := StandardMaterial3D.new()
			shaft_mat.albedo_color = Color(0.19, 0.16, 0.14)
			shaft_mat.roughness = 0.7
			var head_mat := StandardMaterial3D.new()
			head_mat.albedo_color = Color(0.55, 0.58, 0.62)
			head_mat.metallic = 0.85
			head_mat.roughness = 0.3
			var span := (1.55 if three else 1.35) * unit
			var shaft := MeshInstance3D.new()
			var shaft_cyl := CylinderMesh.new()
			shaft_cyl.top_radius = 0.013 * unit
			shaft_cyl.bottom_radius = 0.017 * unit
			shaft_cyl.height = span
			shaft_cyl.radial_segments = 8
			shaft.mesh = shaft_cyl
			shaft.material_override = shaft_mat
			shaft.position = Vector3(0.0, span * 0.5 - 0.12 * unit, 0.0)
			root.add_child(shaft)
			var prongs := 3 if three else 1
			for p in prongs:
				var offset := 0.0 if prongs == 1 else (float(p) - 1.0) * 0.085 * unit
				var prong := MeshInstance3D.new()
				var prong_mesh := BoxMesh.new()
				prong_mesh.size = Vector3(0.028 * unit, (0.30 if three else 0.34) * unit, 0.020 * unit)
				prong.mesh = prong_mesh
				prong.material_override = head_mat
				prong.position = Vector3(offset, span - 0.02 * unit, 0.0)
				root.add_child(prong)
				if prongs > 1:
					var cap := MeshInstance3D.new()
					var cap_mesh := BoxMesh.new()
					cap_mesh.size = Vector3(0.20 * unit, 0.025 * unit, 0.025 * unit)
					cap.mesh = cap_mesh
					cap.material_override = head_mat
					cap.position = Vector3(0.0, span - 0.16 * unit, 0.0)
					root.add_child(cap)
					break
	return root


## Builds hands and the class weapon for one humanoid model.
static func dress(root: Node, class_id: String, scale_hint: float, skin: Color, weapon_override := "") -> void:
	var skeleton := find_skeleton(root)
	if skeleton == null:
		return
	var weapon := weapon_override
	if weapon.is_empty():
		match class_id:
			"iron_paladin":
				weapon = "hammer"
			"shadow_huntress":
				weapon = "bow"
			"blood_sorceress":
				weapon = "staff"
	var prof := profile(weapon) if not weapon.is_empty() else {}
	var hold_left := String(prof.get("hand", "right")) == "left"
	var curl := float(prof.get("curl", 1.0))
	var unit := maxf(0.6, scale_hint)
	## The holding hand closes on the grip; the free hand stays relaxed.
	var left_curl := curl if (not weapon.is_empty() and hold_left) else 0.6
	var right_curl := curl if (not weapon.is_empty() and not hold_left) else 0.6
	if weapon.is_empty():
		left_curl = 0.85
		right_curl = 0.85
	var left := build_hand(skeleton, true, scale_hint, skin, left_curl)
	var right := build_hand(skeleton, false, scale_hint, skin, right_curl)
	var hand: Node3D = left if hold_left else right
	if weapon.is_empty() or hand == null:
		return
	var prop := build_weapon(weapon, scale_hint)
	prop.position = Vector3(prof.get("offset", Vector3.ZERO)) * unit
	hand.add_child(prop)
	if weapon == "hammer" and class_id == "iron_paladin" and left != null:
		var shield := build_shield(scale_hint)
		left.add_child(shield)
		var shield_index := hand_bone(skeleton, true)
		if shield_index >= 0:
			var sb := skeleton.get_bone_global_pose(shield_index).basis.orthonormalized()
			shield.basis = sb.inverse() * Basis(Quaternion(sb.y.normalized(), Vector3(0.0, 0.25, -0.97).normalized())) * sb
			shield.position = Vector3(0.0, 0.10, 0.02)
	## A constant local rotation relative to the hand bone: it rides every
	## animation instead of being computed from a bind pose that the stance then
	## invalidates. `rot` is per weapon, in degrees, so a staff, a hammer and a
	## bow can each sit in the fist their own way.
	var rot: Vector3 = prof.get("rot", Vector3.ZERO)
	var grip_basis := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)))
	prop.basis = grip_basis


## Removes the built hands, weapon and shield so a class can be dressed again
## without stacking a second set of fingers inside the first.
static func undress(root: Node) -> void:
	if root == null:
		return
	for child in root.find_children("*", "BoneAttachment3D", true, false):
		var attach := child as BoneAttachment3D
		if attach != null and String(attach.name).begins_with("HandGrip"):
			attach.get_parent().remove_child(attach)
			attach.queue_free()
