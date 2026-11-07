extends RefCounted
## Shared by every client and by the headless authority: ids, streams and the
## rules both sides have to agree on. Never load an authority/ file from here.

const GAME_ID := "game_rift_and_ruin"
const QUEUE := &"rift"
const CMD := &"rift.cmd"
const MOTION := &"rift.motion"
const WORLD := &"rift.world"
const MAX_PLAYERS := 4
const COMPOSITION := preload("res://network/composition.tres")

## Sanity bound the authority puts on movement, in metres per second. Above
## the fastest legitimate speed, dash included.
const MAX_SPEED := 22.0
## The arena is 17 cells of 4 m; a player can never be outside this.
const ARENA_RADIUS := 40.0


## Builds the World, the entity root and the Spawner the same way on both
## sides. Each side passes its own player archetype.
static func build_network(parent: Node, player: SummerEntityArchetype) -> SummerNetworkSpawner:
	var world := SummerNetworkWorld.new()
	world.name = "World"
	parent.add_child(world)
	var entities := Node3D.new()
	entities.name = "Entities"
	parent.add_child(entities)
	var spawner := SummerNetworkSpawner.new()
	spawner.name = "Spawner"
	spawner.network_world_path = NodePath("../World")
	spawner.entities_root_path = NodePath("../Entities")
	spawner.archetypes = [player]
	spawner.player_archetype = &"player"
	spawner.network_composition = COMPOSITION
	parent.add_child(spawner)
	return spawner


## Pose groups are keyed by seat, so a stream needs at most MAX_PLAYERS keys.
static func motion_key(seat: int) -> StringName:
	return StringName("p%d" % seat)


## Seats spawn inside the opening cell of the dungeon, one step apart, so no
## player starts in lava and two bodies never overlap.
static func spawn_pose(seat: int, entity_id: int) -> Dictionary:
	var offset := Vector3.ZERO
	match seat:
		1:
			offset = Vector3(1.9, 0.0, 0.0)
		2:
			offset = Vector3(-1.9, 0.0, 0.0)
		3:
			offset = Vector3(0.0, 0.0, 1.9)
	return {"entity": entity_id, "position": offset + Vector3(0.0, 0.15, 0.0), "yaw": 0.0}


static func in_bounds(position: Vector3) -> bool:
	return position.is_finite() \
		and Vector2(position.x, position.z).length() <= ARENA_RADIUS \
		and position.y > -6.0 and position.y < 24.0


## Commands and results travel as JSON bytes, at most 256 UTF-8 bytes each.
static func pack(document: Dictionary) -> Dictionary:
	return {"b": JSON.stringify(document).to_utf8_buffer()}


static func unpack(fields: Dictionary) -> Dictionary:
	var parsed: Variant = JSON.parse_string((fields.get("b", PackedByteArray()) as PackedByteArray).get_string_from_utf8())
	return parsed if parsed is Dictionary else {}
