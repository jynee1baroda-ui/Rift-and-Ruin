extends Node3D

const CELL := 4.0
const GRID := 17
const CAMERA_OFFSET := Vector3(0.0, 16.2, 10.8)
const HERO_DIR := "res://art/generated/blood_sorceress"
const ROCK_PATH := "res://art/generated/basalt_rocks/3d_61c4c6fd5084468abe17b1bb_1794029018098.glb"
const GATE_PATH := "res://art/generated/rift_gate/3d_de536d2e46e04f69aab95a43_1794029026993.glb"
const BASALT_TEX := "res://art/generated/basalt_texture/img-f4afbd64-b344-4c4f-a17c-5b062341cf23-1794028912343-0_1794028912343_c4ay4u2t.png"
const DUNGEON_DIR := "res://assets/library/dungeon/"

const KINDS := {
	"wolf": {"key": "wolf", "name": "Gloam Wolf", "file": "gloam-wolf.glb", "health": 40.0, "damage": 8.0, "speed": 5.0, "range": 2.0, "interval": 1.5, "windup": 0.45, "scale": 1.0},
	"crawler": {"key": "crawler", "name": "Cave Crawler", "file": "cave-crawler.glb", "health": 26.0, "damage": 6.0, "speed": 5.6, "range": 1.5, "interval": 1.1, "windup": 0.3, "scale": 1.7},
	"acolyte": {"key": "acolyte", "name": "Hushed Acolyte", "file": "hushed-acolyte.glb", "health": 56.0, "damage": 10.0, "speed": 4.0, "range": 2.1, "interval": 1.8, "windup": 0.55, "scale": 1.0},
	"slinger": {"key": "slinger", "name": "Hushed Slinger", "file": "hushed-slinger.glb", "health": 46.0, "damage": 7.0, "speed": 3.8, "range": 9.0, "interval": 2.4, "windup": 0.65, "scale": 1.0, "ranged": true},
	"brute": {"key": "brute", "name": "Hushed Brute", "file": "hushed-brute.glb", "health": 150.0, "damage": 19.0, "speed": 3.4, "range": 2.7, "interval": 2.4, "windup": 0.85, "scale": 1.0, "elite": true},
	"prophet": {"key": "prophet", "name": "Hushed Prophet", "file": "hushed-prophet.glb", "health": 240.0, "damage": 22.0, "speed": 3.1, "range": 3.2, "interval": 2.6, "windup": 0.9, "scale": 1.0, "boss": true},
}

@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $Sun

var hud: GameHUD
var player: Player
var world_root: Node3D
var floor_root: Node3D
var entity_root: Node3D
var fx_root: Node3D

var grid := AStarGrid2D.new()
var walkable: Dictionary = {}
var bridge_cells: Dictionary = {}
var distance: Dictionary = {}
var start_cell := Vector2i(8, 14)
var enemies: Array[Enemy] = []
var portal: Node3D
var portal_area: Area3D
var portal_disc: MeshInstance3D
var portal_active := false

var layer := 1
var kills := 0
var total_enemies := 0
var run_active := false
var started := false
var hazard_timer := 7.0
var lava_timer := 0.0
var lava_warn_timer := 0.0
var camera_shake := 0.0
var rng := RandomNumberGenerator.new()
var model_cache: Dictionary = {}
var sfx: Dictionary = {}
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_index := 0
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var ember_emitter: GPUParticles3D


func _ready() -> void:
	rng.randomize()
	world_root = Node3D.new()
	world_root.name = "World"
	add_child(world_root)
	floor_root = Node3D.new()
	floor_root.name = "Floor"
	world_root.add_child(floor_root)
	entity_root = Node3D.new()
	entity_root.name = "Entities"
	world_root.add_child(entity_root)
	fx_root = Node3D.new()
	fx_root.name = "FX"
	world_root.add_child(fx_root)
	hud = GameHUD.new()
	add_child(hud)
	hud.equip_requested.connect(_on_equip_requested)
	_setup_audio()
	_create_player()
	_generate_floor()
	camera.global_position = player.global_position + CAMERA_OFFSET
	camera.look_at(player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	hud.set_layer_info(layer, enemies.size(), total_enemies)
	hud.set_relic({})


func _create_player() -> void:
	player = Player.new()
	player.name = "BloodSorceress"
	world_root.add_child(player)
	player.setup(_find_hero_scene())
	player.died.connect(_on_player_died)
	player.damaged.connect(_on_player_damaged)
	player.healed.connect(_on_player_healed)
	player.health_changed.connect(_on_health_changed)
	player.ability_used.connect(_on_ability_used)
	player.life_spent.connect(_on_life_spent)


func _find_hero_scene() -> PackedScene:
	var dir := DirAccess.open(HERO_DIR)
	if dir == null:
		return null
	var files := dir.get_files()
	for extension in ["tscn", "glb"]:
		for file in files:
			if String(file).get_extension().to_lower() == extension:
				var res := load(HERO_DIR.path_join(file))
				if res is PackedScene:
					return res
	return null


func _setup_audio() -> void:
	_load_sfx("cast", "res://audio/cast_blood.wav")
	_load_sfx("hit", "res://audio/hit_impact.wav")
	_load_sfx("portal", "res://audio/rift_portal.wav")
	_load_sfx("lava", "res://audio/lava_burst.wav")
	_load_sfx("death", "res://audio/enemy_death.wav")
	_load_sfx("pickup", "res://audio/loot_pickup.wav")
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_pool.append(p)
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -11.0
	add_child(music_player)
	music_player.finished.connect(_restart_music)
	var music_path := _find_audio("res://audio/music")
	if music_path != "":
		music_player.stream = load(music_path)
		music_player.play()
	ambient_player = AudioStreamPlayer.new()
	ambient_player.volume_db = -16.0
	add_child(ambient_player)
	ambient_player.finished.connect(_restart_ambient)
	var ambient_path := _find_audio("res://audio/ambience")
	if ambient_path != "":
		ambient_player.stream = load(ambient_path)
		ambient_player.play()


func _find_audio(dir_path: String) -> String:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ""
	for file in dir.get_files():
		var ext := String(file).get_extension().to_lower()
		if ext == "mp3" or ext == "wav" or ext == "ogg":
			return dir_path.path_join(file)
	return ""


func _restart_music() -> void:
	if music_player.stream != null:
		music_player.play()


func _restart_ambient() -> void:
	if ambient_player.stream != null:
		ambient_player.play()


func _load_sfx(key: String, path: String) -> void:
	if ResourceLoader.exists(path):
		sfx[key] = load(path)


func play_sfx(key: String, volume_db := 0.0, pitch_variation := 0.08) -> void:
	if not sfx.has(key):
		return
	var p := sfx_pool[sfx_index % sfx_pool.size()]
	sfx_index += 1
	p.stream = sfx[key]
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + rng.randf_range(-pitch_variation, pitch_variation)
	p.play()


func _generate_floor() -> void:
	_clear_floor()
	portal = null
	portal_area = null
	portal_disc = null
	portal_active = false
	enemies.clear()
	kills = 0
	hazard_timer = 7.5
	_make_layout()
	_build_ground()
	_build_decor()
	player.global_position = _cell_to_world(start_cell) + Vector3(0.0, 0.15, 0.0)
	player.velocity = Vector3.ZERO
	player.stop()
	_spawn_packs()
	_spawn_embers()
	hud.set_layer_info(layer, enemies.size(), total_enemies)
	hud.set_status("PACKS AWAKE")
	hud.set_health(player.health, player.max_health)
	hud.set_relic(player.relic)


func _clear_floor() -> void:
	for root in [floor_root, entity_root, fx_root]:
		for child in root.get_children():
			child.queue_free()
	ember_emitter = null


func _make_layout() -> void:
	walkable.clear()
	bridge_cells.clear()
	for x in GRID:
		for y in GRID:
			walkable[Vector2i(x, y)] = false
	start_cell = Vector2i(GRID / 2, GRID / 2)
	walkable[start_cell] = true
	var target_density := maxf(0.40, 0.54 - 0.04 * float(layer - 1))
	var target := int(float(GRID * GRID) * target_density)
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var pos := start_cell
	var carved := 1
	var guard := 0
	while carved < target and guard < 9000:
		guard += 1
		var dir: Vector2i = directions[rng.randi_range(0, 3)]
		if rng.randf() < 0.2:
			dir = directions[rng.randi_range(0, 3)]
		var next := pos + dir
		if next.x < 1 or next.y < 1 or next.x > GRID - 2 or next.y > GRID - 2:
			pos = start_cell
			continue
		pos = next
		if not walkable[pos]:
			walkable[pos] = true
			carved += 1
		if rng.randf() < 0.16:
			var side := pos + Vector2i(dir.y, dir.x)
			if side.x > 0 and side.y > 0 and side.x < GRID - 1 and side.y < GRID - 1:
				if not walkable[side]:
					walkable[side] = true
					carved += 1
	var chambers := 2 + mini(2, layer)
	for i in chambers:
		var centers: Array = []
		for cell in walkable.keys():
			if walkable[cell]:
				centers.append(cell)
		if centers.is_empty():
			break
		var center: Vector2i = centers[rng.randi() % centers.size()]
		for x in range(center.x - 1, center.x + 2):
			for y in range(center.y - 1, center.y + 2):
				if x > 0 and y > 0 and x < GRID - 1 and y < GRID - 1:
					if rng.randf() < 0.85:
						walkable[Vector2i(x, y)] = true
	walkable[start_cell] = true
	var rivers := 2 + mini(2, layer)
	for i in rivers:
		if i == 0:
			_carve_river(false, 1, clampi(start_cell.x + 3, 3, GRID - 4))
		else:
			_carve_river(i % 2 == 0, 1 if rng.randf() < 0.7 else 2)
	var pools := 2 + mini(2, layer)
	for i in pools:
		_carve_pool()
	_clear_start_pad()
	_carve_gate_river()
	_ensure_connected()
	_rebuild_grid()
	_compute_distances()



func _walkable_count() -> int:
	var count := 0
	for cell in walkable.keys():
		if walkable[cell]:
			count += 1
	return count


func _carve_river(horizontal: bool, width: int, start_offset := -1) -> void:
	var offset := start_offset if start_offset >= 0 else rng.randi_range(4, GRID - 5)
	for i in range(1, GRID - 1):
		offset = clampi(offset + rng.randi_range(-1, 1), 2, GRID - 3)
		for w in width:
			var cell := Vector2i(i, offset + w) if horizontal else Vector2i(offset + w, i)
			if cell.x > 0 and cell.y > 0 and cell.x < GRID - 1 and cell.y < GRID - 1:
				walkable[cell] = false


func _carve_pool() -> void:
	var origin := Vector2i(rng.randi_range(2, GRID - 4), rng.randi_range(2, GRID - 4))
	if origin.distance_to(start_cell) < 3.0:
		return
	var w := rng.randi_range(2, 3)
	var h := rng.randi_range(2, 2)
	for x in range(origin.x, origin.x + w):
		for y in range(origin.y, origin.y + h):
			if x < 1 or y < 1 or x > GRID - 2 or y > GRID - 2:
				continue
			if rng.randf() < 0.82:
				walkable[Vector2i(x, y)] = false


func _clear_start_pad() -> void:
	for x in range(start_cell.x - 1, start_cell.x + 2):
		for y in range(start_cell.y - 1, start_cell.y + 2):
			if x > 0 and y > 0 and x < GRID - 1 and y < GRID - 1:
				walkable[Vector2i(x, y)] = true
	walkable[start_cell] = true


func _carve_gate_river() -> void:
	var row := start_cell.y - 3
	for x in range(2, GRID - 2):
		walkable[Vector2i(x, row)] = false
		if rng.randf() < 0.28:
			walkable[Vector2i(x, row - 1)] = false


func _portal_cell() -> Vector2i:
	var best := start_cell
	var best_dist := -1
	for cell in distance.keys():
		if cell.x < 2 or cell.y < 2 or cell.x > GRID - 3 or cell.y > GRID - 3:
			continue
		var d := int(distance[cell])
		if d > best_dist:
			best_dist = d
			best = cell
	return best

func _ensure_connected() -> void:
	var guard := 0
	while guard < 24:
		guard += 1
		var reached := _flood(start_cell)
		var missing: Array = []
		for cell in walkable.keys():
			if walkable[cell] and not reached.has(cell):
				missing.append(cell)
		if missing.is_empty():
			return
		var target: Vector2i = missing[rng.randi() % missing.size()]
		var anchor := _nearest_cell(reached, target)
		_carve_bridge(anchor, target)
	var final_reached := _flood(start_cell)
	for cell in walkable.keys():
		if walkable[cell] and not final_reached.has(cell):
			walkable[cell] = false


func _flood(origin: Vector2i) -> Dictionary:
	var seen := {origin: true}
	var queue: Array[Vector2i] = [origin]
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while queue.size() > 0:
		var cell: Vector2i = queue.pop_back()
		for dir in directions:
			var next: Vector2i = cell + dir
			if next.x < 0 or next.y < 0 or next.x >= GRID or next.y >= GRID:
				continue
			if seen.has(next) or not walkable.get(next, false):
				continue
			seen[next] = true
			queue.append(next)
	return seen


func _nearest_cell(from_set: Dictionary, target: Vector2i) -> Vector2i:
	var best := target
	var best_dist := 1e9
	for cell in from_set.keys():
		var d := absi(cell.x - target.x) + absi(cell.y - target.y)
		if d < best_dist:
			best_dist = d
			best = cell
	return best


func _carve_bridge(from_cell: Vector2i, to_cell: Vector2i) -> void:
	var cell := from_cell
	var guard := 0
	var carved: Array[Vector2i] = []
	while cell != to_cell and guard < 80:
		guard += 1
		if not walkable.get(cell, false):
			carved.append(cell)
		walkable[cell] = true
		if cell.x != to_cell.x:
			cell += Vector2i(signi(to_cell.x - cell.x), 0)
		elif cell.y != to_cell.y:
			cell += Vector2i(0, signi(to_cell.y - cell.y))
	walkable[to_cell] = true
	for bridge in carved:
		bridge_cells[bridge] = true


func _compute_distances() -> void:
	distance.clear()
	distance[start_cell] = 0
	var queue: Array[Vector2i] = [start_cell]
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while queue.size() > 0:
		var cell: Vector2i = queue.pop_front()
		for dir in directions:
			var next: Vector2i = cell + dir
			if not walkable.get(next, false) or distance.has(next):
				continue
			distance[next] = int(distance[cell]) + 1
			queue.append(next)


func _rebuild_grid() -> void:
	grid = AStarGrid2D.new()
	grid.region = Rect2i(0, 0, GRID, GRID)
	grid.cell_size = Vector2(1, 1)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			grid.set_point_solid(cell, not bool(walkable.get(cell, false)))


func _cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3((float(cell.x) - float(GRID - 1) * 0.5) * CELL, 0.0, (float(cell.y) - float(GRID - 1) * 0.5) * CELL)


func _world_to_cell(point: Vector3) -> Vector2i:
	return Vector2i(roundi(point.x / CELL + float(GRID - 1) * 0.5), roundi(point.z / CELL + float(GRID - 1) * 0.5))


func _is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID and cell.y < GRID


func _nearest_walkable(cell: Vector2i) -> Vector2i:
	if walkable.get(cell, false):
		return cell
	var best := start_cell
	var best_dist := 1e9
	for c in walkable.keys():
		if not walkable[c]:
			continue
		var d := Vector2(c - cell).length_squared()
		if d < best_dist:
			best_dist = d
			best = c
	return best


func find_path(from_point: Vector3, to_point: Vector3) -> PackedVector3Array:
	var from_cell := _world_to_cell(from_point)
	var to_cell := _world_to_cell(to_point)
	if not _is_inside(from_cell):
		from_cell = _nearest_walkable(from_cell)
	if not _is_inside(to_cell):
		to_cell = _nearest_walkable(to_cell)
	from_cell = _nearest_walkable(from_cell)
	to_cell = _nearest_walkable(to_cell)
	var out := PackedVector3Array()
	if from_cell == to_cell:
		out.append(_cell_to_world(to_cell))
		return out
	var id_path := grid.get_id_path(from_cell, to_cell)
	for p in id_path:
		var cell := Vector2i(int(p.x), int(p.y))
		out.append(_cell_to_world(cell))
	if out.size() > 0:
		out.remove_at(0)
	return out


func _corner_jitter(lx: int, lz: int) -> Vector2:
	var h := (lx * 73856093) ^ (lz * 19349663) ^ 0x9E3779B9
	var a := float((h >> 3) & 255) / 255.0 - 0.5
	var b := float((h >> 11) & 255) / 255.0 - 0.5
	return Vector2(a, b) * 0.85


func _build_ground() -> void:
	var stone := SurfaceTool.new()
	stone.begin(Mesh.PRIMITIVE_TRIANGLES)
	var lava := SurfaceTool.new()
	lava.begin(Mesh.PRIMITIVE_TRIANGLES)
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = rng.randi()
	var half := CELL * 0.5
	var lava_y := -1.15
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			var center := _cell_to_world(cell)
			if not walkable.get(cell, false):
				var la := Vector3(center.x - half, lava_y, center.z - half)
				var lb := Vector3(center.x + half, lava_y, center.z - half)
				var lc := Vector3(center.x + half, lava_y, center.z + half)
				var ld := Vector3(center.x - half, lava_y, center.z + half)
				_add_quad(lava, la, lb, lc, ld, Vector3.UP, Color.WHITE, 0.12)
				continue
			var j00 := _corner_jitter(2 * x - 1, 2 * y - 1)
			var j10 := _corner_jitter(2 * x + 1, 2 * y - 1)
			var j11 := _corner_jitter(2 * x + 1, 2 * y + 1)
			var j01 := _corner_jitter(2 * x - 1, 2 * y + 1)
			var c0 := Vector3(center.x - half + j00.x, 0.0, center.z - half + j00.y)
			var c1 := Vector3(center.x + half + j10.x, 0.0, center.z - half + j10.y)
			var c2 := Vector3(center.x + half + j11.x, 0.0, center.z + half + j11.y)
			var c3 := Vector3(center.x - half + j01.x, 0.0, center.z + half + j01.y)
			var is_bridge := bridge_cells.has(cell)
			var shade := 0.85 + local_rng.randf() * 0.4
			var tint := Color(shade, shade * 0.95, shade * 0.93)
			if is_bridge:
				tint = Color(shade * 1.25, shade * 1.12, shade * 1.0)
			var dark_tint := Color(tint.r * 0.45, tint.g * 0.4, tint.b * 0.4)
			_add_quad(stone, c0, c1, c2, c3, Vector3.UP, tint, 0.11)
			var lip := 0.16
			var corners := [c0, c1, c2, c3]
			var normals := [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)]
			var neighbors := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
			for e in 4:
				var a: Vector3 = corners[e]
				var b: Vector3 = corners[(e + 1) % 4]
				var next_cell: Vector2i = cell + neighbors[e]
				var depth := 1.2 if not walkable.get(next_cell, false) else lip
				var ab := Vector3(a.x, -depth, a.z)
				var bb := Vector3(b.x, -depth, b.z)
				_add_quad(stone, a, b, bb, ab, normals[e], dark_tint, 0.11)
				if is_bridge and not walkable.get(next_cell, false):
					var rail := 0.24
					var ra := Vector3(a.x, 0.0, a.z)
					var rb := Vector3(b.x, 0.0, b.z)
					var rt := Vector3(a.x, rail, a.z)
					var ru := Vector3(b.x, rail, b.z)
					_add_quad(stone, ra, rb, ru, rt, normals[e], Color(0.55, 0.4, 0.28), 0.2)
	var stone_mesh := stone.commit()
	var ground := MeshInstance3D.new()
	ground.name = "Stone"
	ground.mesh = stone_mesh
	ground.material_override = _stone_material()
	floor_root.add_child(ground)
	var lava_mesh := lava.commit()
	var lava_inst := MeshInstance3D.new()
	lava_inst.name = "Lava"
	lava_inst.mesh = lava_mesh
	lava_inst.material_override = _lava_material(0.34, 0.62)
	lava_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_root.add_child(lava_inst)
	var sea := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(420, 420)
	sea.mesh = plane
	sea.position.y = -2.6
	sea.material_override = _lava_material(0.3, 0.4)
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_root.add_child(sea)
	var body := StaticBody3D.new()
	body.name = "FloorBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(GRID * CELL, 1.0, GRID * CELL)
	shape.shape = box
	shape.position.y = -0.5
	body.add_child(shape)
	var wall_height := 3.0
	var half_arena := GRID * CELL * 0.5
	var walls := [
		[Vector3(half_arena * 2.0, wall_height, 0.5), Vector3(0.0, wall_height * 0.5, half_arena)],
		[Vector3(half_arena * 2.0, wall_height, 0.5), Vector3(0.0, wall_height * 0.5, -half_arena)],
		[Vector3(0.5, wall_height, half_arena * 2.0), Vector3(half_arena, wall_height * 0.5, 0.0)],
		[Vector3(0.5, wall_height, half_arena * 2.0), Vector3(-half_arena, wall_height * 0.5, 0.0)],
	]
	for wall in walls:
		var wall_shape := CollisionShape3D.new()
		var wall_box := BoxShape3D.new()
		wall_box.size = wall[0]
		wall_shape.shape = wall_box
		wall_shape.position = wall[1]
		body.add_child(wall_shape)
	floor_root.add_child(body)
func _add_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3, color: Color, uv_scale: float) -> void:
	for vertex in [a, b, c, a, c, d]:
		st.set_normal(normal)
		st.set_color(color)
		st.set_uv(Vector2(vertex.x, vertex.z) * uv_scale)
		st.add_vertex(vertex)


func _stone_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/basalt.gdshader")
	mat.set_shader_parameter("seed", rng.randf() * 40.0)
	mat.set_shader_parameter("plate_scale", 0.13)
	mat.set_shader_parameter("glow_strength", 1.4)
	return mat


func _lava_material(scale_value: float, glow: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/lava.gdshader")
	mat.set_shader_parameter("pattern_scale", scale_value)
	mat.set_shader_parameter("glow_strength", glow)
	mat.set_shader_parameter("flow_speed", 0.08)
	return mat


func _build_decor() -> void:
	var rock_scene := _get_model(ROCK_PATH)
	var pillar_scene := _get_model(DUNGEON_DIR + "pillar-01.glb")
	var pot_scene := _get_model(DUNGEON_DIR + "pot.glb")
	var gate_cell := _portal_cell()
	for x in GRID:
		for y in GRID:
			var cell := Vector2i(x, y)
			if walkable.get(cell, false):
				continue
			if (cell - gate_cell).length() < 2.4:
				continue
			var center := _cell_to_world(cell)
			var rim := _touches_walkable(cell)
			var roll := rng.randf()
			if rock_scene != null and roll < (0.2 if rim else 0.1):
				var size := rng.randf_range(1.8, 3.6) if rim else rng.randf_range(1.4, 3.4)
				var rock := _spawn_model(rock_scene, size, floor_root, center + Vector3(rng.randf_range(-1, 1), -1.0, rng.randf_range(-1, 1)), rng.randf_range(0, 360))
				if rock != null:
					_apply_rock_material(rock, 1.4)
			elif pillar_scene != null and roll < (0.26 if rim else 0.16):
				var pillar := _spawn_model(pillar_scene, rng.randf_range(2.8, 5.5), floor_root, center + Vector3(0, -1.0, 0), rng.randf_range(0, 60))
				if pillar != null:
					pillar.rotate_x(deg_to_rad(rng.randf_range(-6, 6)))
					_apply_rock_material(pillar, 1.8)
			elif pot_scene != null and roll < 0.245:
				var pot := _spawn_model(pot_scene, 0.9, floor_root, center + Vector3(rng.randf_range(-0.8, 0.8), -0.3, rng.randf_range(-0.8, 0.8)), rng.randf_range(0, 360))
				if pot != null:
					_apply_rock_material(pot, 2.2)
	_build_outer_cliffs()
	var placed := 0
	var guard := 0
	while placed < 7 and guard < 120:
		guard += 1
		var cell := Vector2i(rng.randi_range(1, GRID - 2), rng.randi_range(1, GRID - 2))
		if not walkable.get(cell, false):
			continue
		if int(distance.get(cell, 99)) < 2:
			continue
		var center := _cell_to_world(cell) + Vector3(rng.randf_range(-1.2, 1.2), 0.0, rng.randf_range(-1.2, 1.2))
		_build_brazier(center)
		placed += 1
	for offset in [Vector2i(0, -3), Vector2i(3, -2), Vector2i(-3, -1)]:
		var near_cell := _nearest_walkable(start_cell + offset)
		if near_cell == start_cell:
			continue
		var near := _cell_to_world(near_cell)
		_build_brazier(near)
	_scatter_stone_props(rock_scene, pillar_scene, pot_scene)


func _build_brazier(at: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = at
	floor_root.add_child(holder)
	var iron := StandardMaterial3D.new()
	iron.albedo_color = Color(0.09, 0.075, 0.08)
	iron.metallic = 0.75
	iron.roughness = 0.45
	var stand := MeshInstance3D.new()
	var stand_mesh := CylinderMesh.new()
	stand_mesh.top_radius = 0.16
	stand_mesh.bottom_radius = 0.34
	stand_mesh.height = 0.95
	stand_mesh.radial_segments = 10
	stand.mesh = stand_mesh
	stand.material_override = iron
	stand.position.y = 0.47
	holder.add_child(stand)
	var bowl := MeshInstance3D.new()
	var bowl_mesh := CylinderMesh.new()
	bowl_mesh.top_radius = 0.52
	bowl_mesh.bottom_radius = 0.26
	bowl_mesh.height = 0.34
	bowl_mesh.radial_segments = 14
	bowl.mesh = bowl_mesh
	bowl.material_override = iron
	bowl.position.y = 1.05
	holder.add_child(bowl)
	var coals := MeshInstance3D.new()
	var coal_mesh := CylinderMesh.new()
	coal_mesh.top_radius = 0.44
	coal_mesh.bottom_radius = 0.44
	coal_mesh.height = 0.06
	coal_mesh.radial_segments = 12
	coals.mesh = coal_mesh
	coals.material_override = FX.glow_material(Color(1.0, 0.32, 0.05, 0.95))
	coals.position.y = 1.22
	holder.add_child(coals)
	_add_fire(at + Vector3(0.0, 1.24, 0.0))


func _touches_walkable(cell: Vector2i) -> bool:
	for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if walkable.get(cell + dir, false):
			return true
	return false


func _build_outer_cliffs() -> void:
	var rock_scene := _get_model(ROCK_PATH)
	if rock_scene == null:
		return
	var radius := float(GRID) * CELL * 0.5
	for i in 54:
		var angle := TAU * float(i) / 54.0 + rng.randf_range(-0.05, 0.05)
		var dist := radius + rng.randf_range(3.0, 16.0)
		var pos := Vector3(cos(angle) * dist, -1.2, sin(angle) * dist)
		var height := rng.randf_range(7.0, 17.0) if i % 3 != 0 else rng.randf_range(3.0, 6.0)
		var rock := _spawn_model(rock_scene, height, floor_root, pos, rng.randf_range(0, 360))
		if rock != null:
			_apply_rock_material(rock, 1.2)


func _scatter_stone_props(rock_scene: PackedScene, pillar_scene: PackedScene, pot_scene: PackedScene) -> void:
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		var center := _cell_to_world(cell)
		if center.distance_to(_cell_to_world(start_cell)) < 6.0:
			continue
		var roll := rng.randf()
		var angle := rng.randf() * TAU
		var offset := Vector3(cos(angle), 0.0, sin(angle)) * rng.randf_range(1.1, 1.5)
		if rock_scene != null and roll < 0.1:
			var rock := _spawn_model(rock_scene, rng.randf_range(0.8, 2.2), floor_root, center + offset + Vector3(0.0, -0.12, 0.0), rng.randf_range(0, 360))
			if rock != null:
				_apply_rock_material(rock, 1.9)
		elif pillar_scene != null and roll < 0.13:
			var ruined := _spawn_model(pillar_scene, rng.randf_range(1.2, 3.4), floor_root, center + offset, rng.randf_range(0, 360))
			if ruined != null:
				ruined.rotate_x(deg_to_rad(rng.randf_range(-10, 10)))
				_apply_rock_material(ruined, 2.0)
		elif pot_scene != null and roll < 0.16:
			var pot := _spawn_model(pot_scene, 0.85, floor_root, center + offset, rng.randf_range(0, 360))
			if pot != null:
				_apply_rock_material(pot, 2.2)


func _add_fire(at: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.amount = 26
	particles.lifetime = 0.8
	particles.preprocess = 0.6
	particles.position = at
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	proc.emission_sphere_radius = 0.12
	proc.direction = Vector3.UP
	proc.spread = 12.0
	proc.initial_velocity_min = 0.7
	proc.initial_velocity_max = 1.6
	proc.gravity = Vector3(0.0, 1.2, 0.0)
	proc.scale_min = 0.25
	proc.scale_max = 0.55
	proc.color = Color(1.0, 0.55, 0.15, 0.9)
	particles.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	quad.material = FX.spark_material(Color(1, 1, 1, 1))
	particles.draw_pass_1 = quad
	floor_root.add_child(particles)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.5, 0.18)
	light.light_energy = 2.6
	light.omni_range = 9.0
	light.shadow_enabled = false
	light.position = at + Vector3(0.0, 0.3, 0.0)
	floor_root.add_child(light)


func _spawn_embers() -> void:
	ember_emitter = GPUParticles3D.new()
	ember_emitter.amount = 120
	ember_emitter.lifetime = 7.0
	ember_emitter.preprocess = 4.0
	ember_emitter.visibility_aabb = AABB(Vector3(-60, -6, -60), Vector3(120, 40, 120))
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	proc.emission_box_extents = Vector3(GRID * CELL * 0.5, 0.5, GRID * CELL * 0.5)
	proc.direction = Vector3.UP
	proc.spread = 25.0
	proc.initial_velocity_min = 0.6
	proc.initial_velocity_max = 1.9
	proc.gravity = Vector3(0.6, 0.7, 0.2)
	proc.scale_min = 0.012
	proc.scale_max = 0.035
	proc.color = Color(1.0, 0.45, 0.12, 0.28)
	ember_emitter.process_material = proc
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	quad.material = FX.spark_material(Color(1, 1, 1, 1))
	ember_emitter.draw_pass_1 = quad
	ember_emitter.position.y = 0.5
	fx_root.add_child(ember_emitter)


func _get_model(path: String) -> PackedScene:
	if model_cache.has(path):
		return model_cache[path]
	if not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is PackedScene:
		model_cache[path] = res
		return res
	return null


func _measure(node: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var stack: Array = [node]
	while stack.size() > 0:
		var current: Node = stack.pop_back()
		if current is MeshInstance3D:
			var mesh_inst := current as MeshInstance3D
			var box := mesh_inst.get_aabb()
			var xform := Transform3D.IDENTITY
			var walker: Node = mesh_inst
			while walker != null and walker != node:
				if walker is Node3D:
					xform = (walker as Node3D).transform * xform
				walker = walker.get_parent()
			box = xform * box
			if first:
				result = box
				first = false
			else:
				result = result.merge(box)
		for child in current.get_children():
			stack.append(child)
	return result


func _spawn_model(scene: PackedScene, target_height: float, parent: Node3D, position: Vector3, yaw_deg: float) -> Node3D:
	if scene == null:
		return null
	var holder := Node3D.new()
	var inst := scene.instantiate()
	holder.add_child(inst)
	var box := _measure(inst)

	var scale_factor := 1.0
	if box.size.y > 0.001:
		scale_factor = target_height / box.size.y
	inst.scale = Vector3.ONE * scale_factor
	inst.position.y = -box.position.y * scale_factor
	holder.position = position
	holder.rotation_degrees.y = yaw_deg
	parent.add_child(holder)
	return holder


func _apply_rock_material(root: Node3D, scale_value: float) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_inst := node as MeshInstance3D
		if mesh_inst.mesh == null:
			continue
		var original: Material = null
		for surface in mesh_inst.mesh.get_surface_count():
			var candidate := mesh_inst.mesh.surface_get_material(surface)
			if candidate != null:
				original = candidate
				break
		var tinted: StandardMaterial3D
		if original is StandardMaterial3D:
			tinted = (original as StandardMaterial3D).duplicate()
		else:
			tinted = StandardMaterial3D.new()
		tinted.albedo_color = Color(0.42, 0.36, 0.34)
		tinted.roughness = 0.92
		tinted.metallic = 0.08
		mesh_inst.material_override = tinted


func _spawn_packs() -> void:
	total_enemies = 0
	var candidates: Array = []
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		if int(distance.get(cell, 0)) >= 5:
			candidates.append(cell)
	if candidates.is_empty():
		candidates.append(start_cell)
	var pack_count := 3 + mini(3, layer - 1)
	for p in pack_count:
		var center: Vector2i = candidates[rng.randi() % candidates.size()]
		if p == 0:
			var near: Array = []
			for cell in candidates:
				var d := int(distance.get(cell, 0))
				if d >= 3 and cell.y <= start_cell.y - 4 and absi(cell.x - start_cell.x) <= 4:
					near.append(cell)
			if near.is_empty():
				for cell in candidates:
					var d := int(distance.get(cell, 0))
					if d >= 3 and d <= 7:
						near.append(cell)
			if not near.is_empty():
				center = near[rng.randi() % near.size()]
		var size := rng.randi_range(3, 5)
		for i in size:
			var cell := _nearby_walkable(center)
			_spawn_enemy(_pick_kind(p == pack_count - 1), cell)
	if layer >= 2:
		var boss_cell := _nearby_walkable(candidates[rng.randi() % candidates.size()])
		_spawn_enemy("prophet", boss_cell)
	total_enemies = enemies.size()


func _nearby_walkable(center: Vector2i) -> Vector2i:
	for attempt in 14:
		var cell := center + Vector2i(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
		if walkable.get(cell, false) and cell != start_cell:
			return cell
	return center


func _pick_kind(last_pack: bool) -> String:
	var roll := rng.randf()
	if layer == 1:
		if roll < 0.5:
			return "wolf"
		if roll < 0.85:
			return "acolyte"
		return "crawler"
	if last_pack and roll < 0.35:
		return "brute"
	if roll < 0.3:
		return "wolf"
	if roll < 0.55:
		return "acolyte"
	if roll < 0.72:
		return "slinger"
	if roll < 0.9:
		return "crawler"
	return "brute"


func _spawn_enemy(kind_key: String, cell: Vector2i) -> void:
	var base: Dictionary = KINDS.get(kind_key, KINDS["wolf"]).duplicate()
	var health_scale := 1.0 + 0.45 * float(layer - 1)
	var damage_scale := 1.0 + 0.25 * float(layer - 1)
	base.health = float(base.health) * health_scale
	base.damage = float(base.damage) * damage_scale
	var enemy := Enemy.new()
	entity_root.add_child(enemy)
	var model := _get_model(DUNGEON_DIR + String(base.file))
	enemy.setup(base, model, player, find_path, _enemy_bolt)
	enemy.global_position = _cell_to_world(cell) + Vector3(0.0, 0.2, 0.0)
	enemy.frozen = not run_active
	enemy.died.connect(_on_enemy_died)
	enemies.append(enemy)
	FX.burst(fx_root, enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.65, 0.2, 1.0, 0.95), 22, 5.0, 0.4, 0.6)
	FX.ring(fx_root, enemy.global_position, Color(0.7, 0.25, 1.0, 0.7), 1.8, 0.5, 0.05)


func _enemy_bolt(from: Vector3, to: Vector3, damage: float) -> void:
	var dir := (to - from)
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	var bolt := BloodBolt.new()
	bolt.hostile = true
	bolt.color = Color(0.7, 0.25, 1.0)
	bolt.direction = dir
	bolt.speed = 17.0
	bolt.damage = damage
	fx_root.add_child(bolt)
	bolt.global_position = from + dir * 0.6


func _on_enemy_died(enemy: Enemy) -> void:
	kills += 1
	enemies.erase(enemy)
	play_sfx("death", -4.0)
	FX.burst(fx_root, enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.55, 0.12, 0.9, 0.9), 30, 6.0, 0.5, 0.8)
	_drop_loot(enemy)
	hud.set_layer_info(layer, enemies.size(), total_enemies)
	if enemies.is_empty():
		_on_floor_cleared()


func _drop_loot(enemy: Enemy) -> void:
	var chance := 0.18 + 0.02 * float(layer)
	if enemy.boss:
		chance = 1.0
	elif enemy.elite:
		chance = 0.65
	if rng.randf() < chance:
		_spawn_item(enemy.global_position)
	if rng.randf() < 0.32:
		_spawn_life(enemy.global_position)


func _spawn_item(at: Vector3, force_rarity := "") -> void:
	var item := ItemDB.make_item(layer, rng, force_rarity)
	var drop := LootDrop.new()
	drop.item = item
	entity_root.add_child(drop)
	drop.global_position = at + Vector3(rng.randf_range(-0.7, 0.7), 0.2, rng.randf_range(-0.7, 0.7))
	drop.picked.connect(_on_loot_picked)
	if item.rarity == "legendary":
		FX.burst(fx_root, at + Vector3(0.0, 0.8, 0.0), Color(1.0, 0.45, 0.1, 1.0), 40, 8.0, 0.6, 1.2, -3.0)


func _spawn_life(at: Vector3) -> void:
	var drop := LootDrop.new()
	drop.is_life = true
	drop.life_amount = 26.0
	entity_root.add_child(drop)
	drop.global_position = at + Vector3(rng.randf_range(-0.6, 0.6), 0.2, rng.randf_range(-0.6, 0.6))
	drop.picked.connect(_on_loot_picked)


func _on_loot_picked(drop: LootDrop) -> void:

	if drop.is_life:
		player.heal(drop.life_amount)
		FX.burst(fx_root, drop.global_position, Color(1.0, 0.2, 0.25, 1.0), 16, 3.5, 0.3, 0.5)
		play_sfx("pickup", -6.0)
		return
	play_sfx("pickup", -2.0)
	hud.show_compare(drop.item, player.relic)
	hud.toast("%s RELIC" % String(drop.item.get("rarity_name", "")).to_upper(), drop.item.get("color", Color.WHITE), 2.0)


func _on_equip_requested(item: Dictionary) -> void:

	player.equip(item)
	hud.set_relic(item)
	hud.toast("RELIC BOUND", Color(1.0, 0.55, 0.2), 2.0)
	play_sfx("cast", -4.0, 0.12)
	FX.ring(fx_root, player.global_position, Color(1.0, 0.6, 0.2, 0.9), 3.0, 0.6, 0.06)


func _on_floor_cleared() -> void:
	hud.set_status("THE RIFT IS OPEN")
	hud.toast("PACKS CLEARED", Color(1.0, 0.8, 0.35), 3.0)
	_open_portal()
	if layer >= 2:
		_spawn_item(player.global_position + Vector3(0.0, 0.0, 1.4), "legendary")
		_spawn_item(player.global_position + Vector3(1.6, 0.0, 1.0), "rare")
	else:
		_spawn_item(player.global_position + Vector3(0.0, 0.0, 1.4), "rare")


func _farthest_cell() -> Vector2i:
	return _portal_cell()


func _open_portal() -> void:
	var cell := _farthest_cell()
	var pos := _cell_to_world(cell)
	portal = Node3D.new()
	portal.name = "RiftPortal"
	entity_root.add_child(portal)
	portal.global_position = pos
	var to_center := Vector3.ZERO - pos
	var yaw := rad_to_deg(atan2(to_center.x, to_center.z))
	_spawn_model(_get_model(GATE_PATH), 7.2, portal, Vector3.ZERO, yaw)
	var disc := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(3.8, 5.0)
	disc.mesh = quad
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/portal.gdshader")
	mat.set_shader_parameter("intensity", 1.9)
	disc.material_override = mat
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.position = Vector3(0.0, 2.6, 0.0)
	disc.rotation.y = deg_to_rad(yaw)
	portal.add_child(disc)
	var back := MeshInstance3D.new()
	var back_quad := QuadMesh.new()
	back_quad.size = Vector2(4.5, 5.7)
	back.mesh = back_quad
	var back_mat := StandardMaterial3D.new()
	back_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	back_mat.albedo_color = Color(0.03, 0.0, 0.06)
	back.material_override = back_mat
	back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	back.position = Vector3(0.0, 0.0, 0.08)
	disc.add_child(back)
	var frame := MeshInstance3D.new()
	var frame_torus := TorusMesh.new()
	frame_torus.inner_radius = 2.28
	frame_torus.outer_radius = 2.46
	frame_torus.rings = 64
	frame_torus.ring_segments = 8
	frame.mesh = frame_torus
	frame.material_override = FX.glow_material(Color(1.0, 0.24, 0.04, 0.85), false)
	frame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	frame.position = Vector3(0.0, 0.0, -0.04)
	disc.add_child(frame)
	portal_disc = disc
	var pool := MeshInstance3D.new()
	var pool_mesh := CylinderMesh.new()
	pool_mesh.top_radius = 3.0
	pool_mesh.bottom_radius = 3.0
	pool_mesh.height = 0.06
	pool_mesh.radial_segments = 40
	pool.mesh = pool_mesh
	pool.material_override = FX.glow_material(Color(1.0, 0.36, 0.1, 0.2))
	pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pool.position.y = 0.12
	portal.add_child(pool)
	var halo := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 2.32
	torus.outer_radius = 2.4
	torus.rings = 48
	torus.ring_segments = 6
	halo.mesh = torus
	halo.material_override = FX.glow_material(Color(1.0, 0.26, 0.05, 0.6))
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halo.position.y = 0.14
	portal.add_child(halo)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.45, 0.2)
	light.light_energy = 7.5
	light.omni_range = 16.0
	light.shadow_enabled = false
	light.position.y = 2.5
	portal.add_child(light)
	var swirl := GPUParticles3D.new()
	swirl.amount = 60
	swirl.lifetime = 2.0
	swirl.preprocess = 1.0
	swirl.position.y = 2.6
	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	proc.emission_ring_radius = 1.6
	proc.emission_ring_inner_radius = 1.2
	proc.emission_ring_height = 0.4
	proc.emission_ring_axis = Vector3(0, 0, 1)
	proc.direction = Vector3.UP
	proc.spread = 40.0
	proc.initial_velocity_min = 0.8
	proc.initial_velocity_max = 2.4
	proc.gravity = Vector3(0, 1.2, 0)
	proc.scale_min = 0.1
	proc.scale_max = 0.3
	proc.color = Color(1.0, 0.55, 0.25, 0.9)
	swirl.process_material = proc
	var spark := QuadMesh.new()
	spark.size = Vector2(1, 1)
	spark.material = FX.spark_material(Color(1, 1, 1, 1))
	swirl.draw_pass_1 = spark
	portal.add_child(swirl)
	var label := Label3D.new()
	label.text = "ENTER THE RIFT"
	label.font_size = 56
	label.pixel_size = 0.0035
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.75, 0.35)
	label.outline_size = 12
	label.outline_modulate = Color(0.05, 0.0, 0.0, 0.9)
	label.position = Vector3(0.0, 5.9, 0.0)
	portal.add_child(label)
	portal_area = Area3D.new()
	portal_area.collision_layer = 0
	portal_area.collision_mask = 2
	portal_area.monitoring = true
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 2.6
	cylinder.height = 4.0
	shape.shape = cylinder
	shape.position.y = 2.0
	portal_area.add_child(shape)
	portal_area.body_entered.connect(_on_portal_entered)
	portal.add_child(portal_area)
	portal_active = true
	play_sfx("portal", 0.0, 0.03)
	FX.ring(fx_root, pos, Color(1.0, 0.55, 0.2, 0.9), 9.0, 1.2, 0.08)
	FX.burst(fx_root, pos + Vector3(0.0, 1.5, 0.0), Color(1.0, 0.5, 0.2, 1.0), 60, 10.0, 0.7, 1.4, -2.0)


func _on_portal_entered(body: Node) -> void:
	if body is Player and portal_active:
		_next_layer()


func _next_layer() -> void:
	portal_active = false
	layer += 1
	play_sfx("portal", -2.0, 0.02)
	player.heal(player.max_health * 0.3)
	FX.nova(fx_root, player.global_position, Color(0.75, 0.3, 1.0, 1.0), 6.0)
	_generate_floor()
	hud.toast("RIFT LAYER %d" % layer, Color(1.0, 0.72, 0.3), 2.6)


func begin_run() -> void:
	if started:
		return
	started = true
	run_active = true
	hud.hide_title()
	for enemy in enemies:
		enemy.frozen = false
	hud.toast("RIFT LAYER 1", Color(1.0, 0.72, 0.3), 2.4)


func _restart_run() -> void:
	layer = 1
	kills = 0
	run_active = true
	started = true
	hud.hide_death()
	hud.hide_compare()
	player.revive()
	_generate_floor()
	for enemy in enemies:
		enemy.frozen = false
	hud.toast("THE RIFT REMEMBERS", Color(1.0, 0.72, 0.3), 2.6)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if not started:
			begin_run()
		var key_event := event as InputEventKey
		var key: int = key_event.keycode

		if key == KEY_1:
			_cast_ability(0)
		elif key == KEY_2:
			_cast_ability(1)
		elif key == KEY_3:
			_cast_ability(2)
		elif key == KEY_SPACE:
			_cast_dash()
		elif key == KEY_ENTER or key == KEY_KP_ENTER:
			hud._equip_pending()
		elif key == KEY_ESCAPE:
			hud.hide_compare()
		elif key == KEY_R and not player.alive:
			_restart_run()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not started:
			begin_run()
			get_viewport().set_input_as_handled()
			return
		if not run_active or not player.alive:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			_left_click(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			player.set_aim(_aim_point(event.position))
			_cast_ability(1)


func _left_click(screen_pos: Vector2) -> void:
	var enemy := _enemy_under(screen_pos)
	if enemy != null:
		player.set_aim(enemy.global_position)
		_cast_ability(1)
		return
	var point := _aim_point(screen_pos)
	var cell := _world_to_cell(point)
	if _is_inside(cell) and not walkable.get(cell, false):
		point = _cell_to_world(_nearest_walkable(cell))
	player.move_along(find_path(player.global_position, point))
	FX.ring(fx_root, point, Color(1.0, 0.55, 0.2, 0.5), 0.9, 0.35, 0.05)


func _aim_point(screen_pos: Vector2) -> Vector3:
	var from := camera.project_ray_origin(screen_pos)
	var normal := camera.project_ray_normal(screen_pos)
	var plane := Plane(Vector3.UP, 0.0)
	var hit = plane.intersects_ray(from, normal)
	if hit == null:
		return player.global_position + Vector3(0, 0, -3)
	return hit


func _enemy_under(screen_pos: Vector2) -> Enemy:
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 200.0)
	query.collision_mask = 4
	query.collide_with_areas = false
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider = result.get("collider")
	if collider is Enemy:
		return collider
	return null


func _cast_ability(index: int) -> void:
	if not run_active or not player.alive:
		return
	player.try_ability(index)


func _cast_dash() -> void:
	if not run_active or not player.alive:
		return
	if player.try_dash():
		FX.burst(fx_root, player.global_position + Vector3(0.0, 0.6, 0.0), Color(1.0, 0.2, 0.15, 0.9), 20, 4.0, 0.35, 0.5)
		play_sfx("cast", -6.0, 0.2)
		if String(player.relic.get("unique", "")) == "dash_burn":
			_dash_burn()


func _dash_burn() -> void:
	await get_tree().create_timer(0.2).timeout
	if not is_instance_valid(player) or not player.alive:
		return
	var center := player.global_position
	FX.nova(fx_root, center, Color(1.0, 0.35, 0.08, 1.0), 4.2)
	play_sfx("lava", -2.0, 0.1)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		if enemy.global_position.distance_to(center) <= 4.2:
			var roll := player.roll_damage(30.0)
			enemy.take_damage(roll[0], roll[1])


func _on_ability_used(index: int, aim: Vector3) -> void:
	match index:
		0:
			_blood_nova()
		1:
			_crimson_lance(aim)
		2:
			_siphon()
	play_sfx("cast", -1.0, 0.1)


func _blood_nova() -> void:
	var radius := 4.6
	if String(player.relic.get("unique", "")) == "nova_free":
		radius *= 1.55
	var center := player.global_position
	FX.nova(fx_root, center, Color(1.0, 0.13, 0.1, 1.0), radius)
	_shake(0.45)
	play_sfx("hit", -1.0, 0.14)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		if enemy.global_position.distance_to(center) <= radius + 0.7:
			var roll := player.roll_damage(34.0)
			enemy.take_damage(roll[0], roll[1])
			if is_instance_valid(enemy) and not enemy.dead:
				var push: Vector3 = enemy.global_position - center
				push.y = 0.0
				enemy.global_position += push.normalized() * 0.4


func _crimson_lance(aim: Vector3) -> void:
	var dir := aim - player.global_position
	dir.y = 0.0
	if dir.length() < 0.2:
		dir = Vector3(sin(player.facing), 0.0, cos(player.facing))
	dir = dir.normalized()
	var triple := String(player.relic.get("unique", "")) == "lance_triple"
	var count := 3 if triple else 1
	for i in count:
		var angle := 0.0
		if triple:
			angle = deg_to_rad(-9.0 + 9.0 * float(i))
		var shot_dir := dir.rotated(Vector3.UP, angle)
		var roll := player.roll_damage(26.0)
		var bolt := BloodBolt.new()
		bolt.direction = shot_dir
		bolt.speed = 36.0
		bolt.damage = roll[0]
		bolt.crit = roll[1]
		bolt.pierce = 2 if triple else 0
		bolt.color = Color(1.0, 0.12, 0.1)
		fx_root.add_child(bolt)
		bolt.global_position = player.global_position + Vector3(0.0, 1.05, 0.0) + shot_dir * 0.9


func _siphon() -> void:
	var greater := String(player.relic.get("unique", "")) == "siphon_greater"
	var damage_per_tick := 9.0 if greater else 7.0
	var heal_factor := 0.34 if greater else 0.2
	var radius := 7.5
	for tick in 8:
		if not is_instance_valid(player) or not player.alive or not run_active:
			return
		var drained := 0.0
		for enemy in enemies.duplicate():
			if not is_instance_valid(enemy) or enemy.dead:
				continue
			var offset: Vector3 = enemy.global_position - player.global_position
			offset.y = 0.0
			if offset.length() <= radius:
				var roll := player.roll_damage(damage_per_tick)
				enemy.take_damage(roll[0], roll[1])
				drained += roll[0]
				FX.beam(fx_root, player.global_position + Vector3(0.0, 1.1, 0.0), enemy.global_position + Vector3(0.0, 1.0, 0.0), Color(0.95, 0.12, 0.15, 0.85), 0.06, 0.28)
		if drained > 0.0:
			player.heal(drained * heal_factor)
		FX.ring(fx_root, player.global_position, Color(0.85, 0.1, 0.12, 0.5), radius * 0.6, 0.3, 0.04)
		await get_tree().create_timer(0.24).timeout


func _on_player_damaged(amount: float) -> void:
	hud.flash_damage(clampf(amount / 30.0, 0.25, 1.4))
	_shake(clampf(amount / 26.0, 0.1, 0.6))
	play_sfx("hit", -6.0, 0.15)


func _on_player_healed(amount: float) -> void:
	if amount > 3.0:
		FX.sparkle(fx_root, player.global_position + Vector3(0.0, 1.3, 0.0), Color(1.0, 0.25, 0.25, 0.9))


func _on_life_spent(amount: float) -> void:
	FX.burst(fx_root, player.global_position + Vector3(0.0, 1.0, 0.0), Color(0.8, 0.05, 0.1, 0.85), 8, 3.0, 0.3, 0.4)


func _on_health_changed(current: float, maximum: float) -> void:
	hud.set_health(current, maximum)


func _on_player_died() -> void:
	run_active = false
	hud.hide_compare()
	play_sfx("death", 0.0, 0.05)
	FX.burst(fx_root, player.global_position + Vector3(0.0, 1.0, 0.0), Color(0.9, 0.1, 0.12, 1.0), 60, 8.0, 0.6, 1.2)
	FX.nova(fx_root, player.global_position, Color(0.9, 0.12, 0.1, 1.0), 5.0)
	var relic_name := "None"
	if not player.relic.is_empty():
		relic_name = String(player.relic.get("name", "None"))
	hud.show_death(layer, kills, relic_name)


func _shake(amount: float) -> void:
	camera_shake = maxf(camera_shake, amount)


func _process(delta: float) -> void:
	if player == null:
		return
	var mouse := get_viewport().get_mouse_position()
	player.set_aim(_aim_point(mouse))
	hud.set_cooldowns(player.cooldowns, player.dash_cooldown)
	if portal_disc != null and is_instance_valid(portal_disc):
		var flat_cam := Vector3(camera.global_position.x, portal_disc.global_position.y, camera.global_position.z)
		if flat_cam.distance_to(portal_disc.global_position) > 0.2:
			portal_disc.look_at(flat_cam, Vector3.UP)
	_update_camera(delta)
	if not run_active or not player.alive:
		return
	hazard_timer -= delta
	if hazard_timer <= 0.0:
		hazard_timer = maxf(2.4, 7.0 - 0.5 * float(layer - 1)) * rng.randf_range(0.8, 1.3)
		_spawn_hazard()
	lava_timer -= delta
	if lava_timer <= 0.0:
		lava_timer = 0.5
		var cell := _world_to_cell(player.global_position)
		player.in_lava = _is_inside(cell) and not walkable.get(cell, false)
		if player.in_lava:
			player.take_damage(4.0 + 1.2 * float(layer))
			FX.burst(fx_root, player.global_position + Vector3(0.0, 0.3, 0.0), Color(1.0, 0.5, 0.15, 0.9), 12, 3.0, 0.4, 0.5)
			if lava_warn_timer <= 0.0:
				lava_warn_timer = 2.4
				hud.toast("MOLTEN GROUND  ·  MOVE", Color(1.0, 0.45, 0.2), 1.2)
	lava_warn_timer = maxf(0.0, lava_warn_timer - 0.5)


func _update_camera(delta: float) -> void:
	var desired := player.global_position + CAMERA_OFFSET
	var limit := float(GRID) * CELL * 0.5 - 7.0
	desired.x = clampf(desired.x, -limit, limit)
	desired.z = clampf(desired.z, -limit, limit)
	camera.global_position = camera.global_position.lerp(desired, clampf(delta * 6.5, 0.0, 1.0))
	camera_shake = maxf(0.0, camera_shake - delta * 1.8)
	var jitter := Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), 0.0) * camera_shake * 0.6
	camera.look_at(player.global_position + Vector3(0.0, 1.0, 0.0) + jitter, Vector3.UP)


func _spawn_hazard() -> void:
	var options: Array = []
	for cell in walkable.keys():
		if not walkable[cell]:
			continue
		var pos := _cell_to_world(cell)
		var dist := pos.distance_to(player.global_position)
		if dist > 5.0 and dist < 22.0:
			options.append(cell)
	if options.is_empty():
		return
	var cell: Vector2i = options[rng.randi() % options.size()]
	var hazard := LavaEruption.new()
	fx_root.add_child(hazard)
	hazard.global_position = _cell_to_world(cell)
	hazard.radius = rng.randf_range(2.2, 3.2)
	hazard.damage = 16.0 + 4.0 * float(layer)
	hazard.set_player(player)
	hazard.exploded.connect(_on_hazard_exploded)


func _on_hazard_exploded(at: Vector3) -> void:
	play_sfx("lava", -3.0, 0.12)
	_shake(0.25)
