extends Node
## The client half of Rift & Ruin's multiplayer. It joins a Summer World when
## a dedicated authority is available, then hands the world seed and this
## player's seat to the running game. With no World available the game boots
## its normal solo mode, so single player never depends on the network.

const Game = preload("res://network/game.gd")
const PlayerArchetype = preload("res://client/player_archetype.tres")

var game: Node
var spawner: SummerNetworkSpawner
var world: SummerNetworkWorld
var online := false
var seat := -1
var world_seed := 0
var waiting: Dictionary = {}      # entity id -> pose group that arrived first
var seen := {}                    # entity ids currently on this client
var _world_group: SummerNetworkStateGroup
var _seed_ready := false


func start(host: Node) -> void:
	game = host
	add_to_group("rift_net")
	_boot()


func _boot() -> void:
	spawner = Game.build_network(self, PlayerArchetype)
	spawner.state_group_created.connect(_on_group_created)
	spawner.entity_spawned.connect(_on_entity_spawned)
	if spawner.has_signal("entity_despawned"):
		spawner.entity_despawned.connect(_on_entity_despawned)
	var initialized: SummerResult = await Summer.initialize(Game.GAME_ID).get_result_or_completed_signal()
	if not initialized.ok:
		print("RIFT_NET_SOLO init=%s" % initialized.message)
		game.boot_solo()
		return
	var join := Summer.client.join(SummerJoinTarget.queue(Game.QUEUE))
	join.acceptance_required.connect(func(proposal: SummerMatchmakingProposal) -> void: proposal.accept())
	var joined: SummerResult = await join.get_result_or_completed_signal()
	if not joined.ok:
		print("RIFT_NET_SOLO join=%s %s" % [joined.code, joined.message])
		game.boot_solo()
		return
	if not spawner.is_network_ready():
		await spawner.network_ready
	online = true
	var entered: Dictionary = await command({"c": "join"})
	if bool(entered.get("ok", false)):
		var result: Dictionary = entered.get("result", {})
		seat = int(result.get("seat", -1))
		if not _seed_ready:
			world_seed = int(result.get("seed", 0))
	var waited := 0
	while not _seed_ready and waited < 50:
		await get_tree().create_timer(0.1).timeout
		waited += 1
	game.boot_online(world_seed, seat)
	print("RIFT_CLIENT_JOINED seat=%d online=%s" % [seat, str(_seed_ready)])


## Sends one Command and waits for the authority's answer.
func command(payload: Dictionary) -> Dictionary:
	var admission := spawner.enqueue_command(Game.CMD, Game.pack(payload))
	if not admission.is_enqueued():
		return {"ok": false, "error": String(admission.get_code())}
	var handle := admission.get_handle()
	if not handle.is_terminal():
		await handle.completed
	if handle.get_outcome() == SummerNetworkCommandHandle.OUTCOME_ACCEPTED:
		return {"ok": true, "error": "", "result": Game.unpack(handle.get_result())}
	return {"ok": false, "error": String(handle.get_reason())}


func _on_group_created(group: SummerNetworkStateGroup) -> void:
	if group.get_stream_id() == Game.WORLD:
		_world_group = group
		group.state_installed.connect(_on_world_state)
		_on_world_state(group.get_state(), group.get_revision(), true)
	elif group.get_stream_id() == Game.MOTION:
		_attach_pose(group, int(group.get_state().get("entity", -1)))


func _on_world_state(state: Dictionary, _revision: int, _reset: bool) -> void:
	if state.is_empty():
		return
	world_seed = int(state.get("seed", world_seed))
	_seed_ready = true


## The pose group and the player's entity can arrive in either order.
func _attach_pose(group: SummerNetworkStateGroup, entity_id: int) -> void:
	var entity := spawner.get_entity(entity_id)
	if entity == null or entity.root == null:
		waiting[entity_id] = group
		return
	if entity.root.has_method("bind"):
		entity.root.bind(group)


func _on_entity_spawned(entity: SummerNetworkEntity) -> void:
	seen[entity.entity_id] = true
	if waiting.has(entity.entity_id):
		_attach_pose(waiting[entity.entity_id], entity.entity_id)
		waiting.erase(entity.entity_id)
	if online and game != null:
		game.set_online_peers(seen.size())


## A player left the World for good: their projection is gone and the party
## chip drops a member.
func _on_entity_despawned(entity: SummerNetworkEntity) -> void:
	seen.erase(entity.entity_id)
	waiting.erase(entity.entity_id)
	if online and game != null:
		game.set_online_peers(maxi(1, seen.size()))
