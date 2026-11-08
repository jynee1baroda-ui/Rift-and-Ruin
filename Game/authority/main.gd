extends Node
## The Rift & Ruin match server. It runs headless, owns each player's seat and
## checks every pose a client publishes. Monster, loot and rift simulation
## move here in the next phase; the pose, seat and world contracts already
## exist so that work does not change the client.

const Game = preload("res://network/game.gd")
const PlayerArchetype = preload("res://authority/player_archetype.tres")

## How far a player may move in one burst after a network stall, in metres.
const BURST := Game.MAX_SPEED * 0.5

var spawner: SummerNetworkSpawner
var world: SummerNetworkWorld
var seat_of := {}          # session_id -> seat, held until the Session leaves
var allowance := {}        # seat -> metres the player may still move
var refilled_at := {}      # seat -> msec of the last allowance refill
var world_group: SummerNetworkStateGroup
var world_seed := 0


func _ready() -> void:
	world_seed = int(Time.get_ticks_usec() & 0x7fffffff) ^ randi()
	if world_seed < 0:
		world_seed = -world_seed
	spawner = Game.build_network(self, PlayerArchetype)
	world = $World
	spawner.entity_spawned.connect(_on_player_spawned)
	spawner.command_received.connect(_on_command)
	world.session_left.connect(_on_session_left)
	world.session_disconnected.connect(_on_session_disconnected)
	var initialized: SummerResult = await Summer.initialize(Game.GAME_ID).get_result_or_completed_signal()
	if not initialized.ok:
		push_error("RIFT_AUTHORITY_FAILED %s" % initialized.message)
		return
	if not world.is_ready():
		await world.binding_ready
	if not spawner.is_network_ready():
		await spawner.network_ready
	world_group = spawner.create_state_group(Game.WORLD, &"world", {"seed": world_seed})
	print("RIFT_AUTHORITY_READY seed=%d" % world_seed)


## A seat is a player's place in this World for their whole stay, across
## reconnects. Returns -1 when the World is full.
func _seat(session: SummerSession) -> int:
	if seat_of.has(session.session_id):
		return seat_of[session.session_id]
	var taken := seat_of.values()
	for seat in Game.MAX_PLAYERS:
		if seat not in taken:
			seat_of[session.session_id] = seat
			return seat
	return -1


## The Spawner spawns one player entity per joined player, once that player's
## network is ready (and again after a reconnect). Its owner becomes the only
## writer of the pose; the group ends with the entity.
func _on_player_spawned(entity: SummerNetworkEntity) -> void:
	var seat := _seat(entity.session)
	if seat < 0:
		push_warning("RIFT_AUTHORITY_FULL")
		return
	allowance[seat] = BURST
	refilled_at[seat] = Time.get_ticks_msec()
	var group := spawner.create_state_group(Game.MOTION, Game.motion_key(seat), Game.spawn_pose(seat, entity.entity_id), entity.session, entity)
	group.set_acceptance_policy(_accept_motion.bind(seat))
	print("RIFT_PLAYER_SPAWNED seat=%d entity=%d" % [seat, entity.entity_id])


## Runs before an owner pose is accepted. True accepts it unchanged; false
## refuses it and the owner snaps back to the last accepted pose.
func _accept_motion(candidate: Dictionary, current: Dictionary, seat: int) -> bool:
	if candidate.entity != current.entity:
		return false   # a player can move, never become someone else
	var position: Vector3 = candidate.position
	if not Game.in_bounds(position) or not is_finite(float(candidate.yaw)):
		return false
	var now := Time.get_ticks_msec()
	var budget := minf(float(allowance.get(seat, BURST)) + Game.MAX_SPEED * float(now - int(refilled_at.get(seat, now))) / 1000.0, BURST)
	refilled_at[seat] = now
	var distance := position.distance_to(current.position)
	if distance > budget:
		allowance[seat] = budget
		return false
	allowance[seat] = budget - distance
	return true


## Moves a player on purpose (respawn, portal). The owner snaps to it.
func teleport(seat: int, position: Vector3) -> void:
	var group := spawner.get_state_group(Game.MOTION, Game.motion_key(seat))
	if group != null and group.active:
		var pose := group.get_state()
		pose.position = position
		allowance[seat] = BURST
		group.reset(pose)


func _on_command(request: SummerNetworkCommandRequest) -> void:
	var command := Game.unpack(request.payload)
	match str(command.get("c", "")):
		"join":
			_join(request)
		"ping":
			request.accept({}, Game.pack({"t": Time.get_ticks_msec()}))
		"pose_probe":
			_probe_pose(request)
		_:
			request.refuse(&"unknown_command")


## A client sends "join" once its network is ready.
func _join(request: SummerNetworkCommandRequest) -> void:
	var seat := _seat(request.get_session())
	if seat < 0:
		request.refuse(&"match_full")
		return
	request.accept({}, Game.pack({"seat": seat, "seed": world_seed}))
	print("RIFT_PLAYER_JOINED seat=%d" % seat)


## Diagnostic used by the automated two-client test: reports whether a
## deliberately impossible pose would be refused.
func _probe_pose(request: SummerNetworkCommandRequest) -> void:
	var seat := _seat(request.get_session())
	var group := spawner.get_state_group(Game.MOTION, Game.motion_key(seat))
	if group == null or not group.active:
		request.refuse(&"no_pose")
		return
	var current := group.get_state()
	var jump: Vector3 = current.position + Vector3(60.0, 0.0, 0.0)
	var accepted := _accept_motion({"entity": current.entity, "position": jump, "yaw": 0.0}, current, seat)
	request.accept({}, Game.pack({"accepted": accepted}))


func _on_session_disconnected(session: SummerSession, reason: String) -> void:
	var seat: int = seat_of.get(session.session_id, -1)
	print("RIFT_PLAYER_DISCONNECTED seat=%d reason=%s" % [seat, reason])


## The Session ended for good: free the seat. (Its pose group already ended
## with the player's entity.)
func _on_session_left(session: SummerSession, reason: String) -> void:
	var seat: int = seat_of.get(session.session_id, -1)
	seat_of.erase(session.session_id)
	allowance.erase(seat)
	refilled_at.erase(seat)
	print("RIFT_PLAYER_LEFT seat=%d reason=%s" % [seat, reason])
