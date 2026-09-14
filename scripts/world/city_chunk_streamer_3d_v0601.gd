extends "res://scripts/world/city_chunk_streamer_3d_v05403.gd"

const FLUIDITY_VERSION_0601 := "0.6.1-alpha"
const CENTER_REFRESH_SECONDS_0601 := 0.12
const CHUNKS_PER_FRAME_0601 := 1

var pending_chunks_0601: Array[Vector2i] = []
var pending_lookup_0601: Dictionary = {}
var generated_last_frame_0601 := 0

func _ready() -> void:
	super._ready()
	add_to_group("chunk_fluidity_0601")

func _process(delta: float) -> void:
	generated_last_frame_0601 = 0
	_load_pending_chunks_0601()

	refresh_timer += delta
	if refresh_timer < CENTER_REFRESH_SECONDS_0601:
		return
	refresh_timer = 0.0
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return

	var previous_seed := world_seed
	_sync_seed(false)
	if previous_seed != world_seed:
		pending_chunks_0601.clear()
		pending_lookup_0601.clear()

	var center := _world_to_chunk(player.global_position)
	if center != last_center:
		last_center = center
		_queue_missing_chunks_0601(center)
		_unload_far_chunks_0601(center)

func _queue_missing_chunks_0601(center: Vector2i) -> void:
	pending_chunks_0601.clear()
	pending_lookup_0601.clear()
	for radius in range(LOAD_RADIUS + 1):
		for cz in range(center.y - radius, center.y + radius + 1):
			for cx in range(center.x - radius, center.x + radius + 1):
				var coord := Vector2i(cx, cz)
				if maxi(abs(coord.x - center.x), abs(coord.y - center.y)) != radius:
					continue
				if loaded_chunks.has(coord) or pending_lookup_0601.has(coord):
					continue
				pending_chunks_0601.append(coord)
				pending_lookup_0601[coord] = true

func _load_pending_chunks_0601() -> void:
	var budget := CHUNKS_PER_FRAME_0601
	while budget > 0 and not pending_chunks_0601.is_empty():
		var coord := pending_chunks_0601.pop_front() as Vector2i
		pending_lookup_0601.erase(coord)
		if not loaded_chunks.has(coord):
			_generate_chunk(coord)
			generated_last_frame_0601 += 1
			budget -= 1

func _unload_far_chunks_0601(center: Vector2i) -> void:
	var to_remove: Array[Vector2i] = []
	for raw_key in loaded_chunks.keys():
		var coord := raw_key as Vector2i
		if abs(coord.x - center.x) > UNLOAD_RADIUS or abs(coord.y - center.y) > UNLOAD_RADIUS:
			to_remove.append(coord)
	for coord in to_remove:
		var node := loaded_chunks.get(coord) as Node3D
		if node != null and is_instance_valid(node):
			node.queue_free()
		loaded_chunks.erase(coord)

func get_streaming_fluidity_debug_0601() -> Dictionary:
	return {
		"version": FLUIDITY_VERSION_0601,
		"chunks_per_frame": CHUNKS_PER_FRAME_0601,
		"pending_chunks": pending_chunks_0601.size(),
		"loaded_chunks": loaded_chunks.size(),
		"generated_last_frame": generated_last_frame_0601,
		"refresh_seconds": CENTER_REFRESH_SECONDS_0601
	}
