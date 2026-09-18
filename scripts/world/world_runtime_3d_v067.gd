extends "res://scripts/world/world_runtime_3d_v066.gd"

const PERFORMANCE_VERSION_067 := "0.6.7-alpha"
const ZombieV067Script = preload("res://scripts/entities/zombie_3d_v067.gd")
const AUTOSAVE_SECONDS_067 := 45.0

var perf_sample_timer_067 := 0.0
var fps_067 := 0
var fps_low_067 := 999
var fps_high_067 := 0
var zombie_full_067 := 0
var zombie_reduced_067 := 0
var zombie_sleep_067 := 0

func _ready() -> void:
	super._ready()
	add_to_group("performance_runtime_067")

func _setup_autosave() -> void:
	var timer := Timer.new()
	timer.name = "Autosave067"
	timer.wait_time = AUTOSAVE_SECONDS_067
	timer.autostart = true
	timer.timeout.connect(save_game)
	add_child(timer)

func _spawn_zombies(count: int) -> void:
	_ensure_horde_records_0537()
	var spawn_count := maxi(14, count)
	for i in range(spawn_count):
		var zombie_name := "Zombie_%02d" % i
		if dead_zombies_0520.has(zombie_name):
			continue
		var horde_id := i % HORDE_COUNT_0537
		var member_index := int(i / HORDE_COUNT_0537)
		var record: Dictionary = horde_records_0537.get(str(horde_id), {}) as Dictionary
		var center := _dict_to_vec_0537(record.get("spawn", {}) as Dictionary)
		var member_angle := float(member_index * 2 + horde_id) * 1.31
		var member_radius := 1.8 + float(member_index % 3) * 1.25
		var spawn_pos := center + Vector3(cos(member_angle) * member_radius, 0.20, sin(member_angle) * member_radius)
		spawn_pos.y = 0.20
		var zombie: CharacterBody3D = ZombieV067Script.new()
		zombie.name = zombie_name
		zombie.call("configure_horde_0537", horde_id, member_index, (i + horde_id * 2) % ZOMBIE_PROFILE_COUNT_05402)
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func _process(delta: float) -> void:
	super._process(delta)
	perf_sample_timer_067 += delta
	if perf_sample_timer_067 < 0.50:
		return
	perf_sample_timer_067 = 0.0
	fps_067 = roundi(Engine.get_frames_per_second())
	fps_low_067 = mini(fps_low_067, fps_067)
	fps_high_067 = maxi(fps_high_067, fps_067)
	zombie_full_067 = 0
	zombie_reduced_067 = 0
	zombie_sleep_067 = 0
	for raw in get_tree().get_nodes_in_group("zombie_performance_067"):
		if raw == null or not is_instance_valid(raw):
			continue
		var tier := str(raw.call("get_performance_tier_067")) if raw.has_method("get_performance_tier_067") else ""
		match tier:
			"full":
				zombie_full_067 += 1
			"reduced", "far_alert":
				zombie_reduced_067 += 1
			_:
				zombie_sleep_067 += 1

func get_performance_debug_067() -> Dictionary:
	var stream_debug: Dictionary = {}
	var streamer := get_node_or_null("ChunkStreamer")
	if streamer != null and streamer.has_method("get_streaming_performance_debug_067"):
		stream_debug = streamer.call("get_streaming_performance_debug_067") as Dictionary
	return {
		"version": PERFORMANCE_VERSION_067,
		"fps": fps_067,
		"fps_low": 0 if fps_low_067 == 999 else fps_low_067,
		"fps_high": fps_high_067,
		"zombie_full": zombie_full_067,
		"zombie_reduced": zombie_reduced_067,
		"zombie_sleep": zombie_sleep_067,
		"zombie_total": get_tree().get_nodes_in_group("zombie_performance_067").size(),
		"autosave_seconds": AUTOSAVE_SECONDS_067,
		"streaming": stream_debug
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var perf := get_performance_debug_067()
	result["performance_067"] = perf
	result["fps_067"] = int(perf.get("fps", 0))
	result["zombie_full_067"] = int(perf.get("zombie_full", 0))
	result["zombie_sleep_067"] = int(perf.get("zombie_sleep", 0))
	var stream := perf.get("streaming", {}) as Dictionary
	result["chunks_067"] = int(stream.get("loaded_chunks", 0))
	return result
