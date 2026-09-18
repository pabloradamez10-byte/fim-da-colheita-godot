extends "res://scripts/world/city_chunk_streamer_3d_v066.gd"

const PERFORMANCE_VERSION_067 := "0.6.7-alpha"
const PERF_LOAD_RADIUS_067 := 1
const PERF_UNLOAD_RADIUS_067 := 2
const CHUNK_BUILD_INTERVAL_MS_067 := 90

var last_chunk_build_msec_067 := -100000
var chunk_builds_067 := 0
var chunk_build_deferred_067 := 0

func _ready() -> void:
	super._ready()
	add_to_group("streaming_performance_067")

func _queue_missing_chunks_0601(center: Vector2i) -> void:
	pending_chunks_0601.clear()
	pending_lookup_0601.clear()
	for radius in range(PERF_LOAD_RADIUS_067 + 1):
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
	if pending_chunks_0601.is_empty():
		return
	var now := Time.get_ticks_msec()
	if now - last_chunk_build_msec_067 < CHUNK_BUILD_INTERVAL_MS_067:
		chunk_build_deferred_067 += 1
		return
	var coord := pending_chunks_0601.pop_front() as Vector2i
	pending_lookup_0601.erase(coord)
	if loaded_chunks.has(coord):
		return
	last_chunk_build_msec_067 = now
	_generate_chunk(coord)
	generated_last_frame_0601 = 1
	chunk_builds_067 += 1

func _unload_far_chunks_0601(center: Vector2i) -> void:
	var to_remove: Array[Vector2i] = []
	for raw_key in loaded_chunks.keys():
		var coord := raw_key as Vector2i
		if abs(coord.x - center.x) > PERF_UNLOAD_RADIUS_067 or abs(coord.y - center.y) > PERF_UNLOAD_RADIUS_067:
			to_remove.append(coord)
	for coord in to_remove:
		var node := loaded_chunks.get(coord) as Node3D
		if node != null and is_instance_valid(node):
			node.queue_free()
		loaded_chunks.erase(coord)

func _create_terrain_multimesh(parent: Node3D, id: String, transforms: Array) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(CELL_SIZE + 0.03, 0.24, CELL_SIZE + 0.03)
	mesh.material = _material_for(id)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in range(transforms.size()):
		multi.set_instance_transform(i, transforms[i] as Transform3D)
	var node := MultiMeshInstance3D.new()
	node.multimesh = multi
	# O chão recebe sombras dos objetos; ele próprio não precisa projetar sombra.
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.add_to_group("terrain_no_shadow_067")
	parent.add_child(node)

func get_streaming_performance_debug_067() -> Dictionary:
	return {
		"version": PERFORMANCE_VERSION_067,
		"load_radius": PERF_LOAD_RADIUS_067,
		"unload_radius": PERF_UNLOAD_RADIUS_067,
		"max_primary_chunks": (PERF_LOAD_RADIUS_067 * 2 + 1) * (PERF_LOAD_RADIUS_067 * 2 + 1),
		"loaded_chunks": loaded_chunks.size(),
		"pending_chunks": pending_chunks_0601.size(),
		"chunk_interval_ms": CHUNK_BUILD_INTERVAL_MS_067,
		"chunk_builds": chunk_builds_067,
		"chunk_build_deferred": chunk_build_deferred_067,
		"terrain_shadows": false
	}
