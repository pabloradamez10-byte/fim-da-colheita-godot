class_name WorldGenerator
extends Node2D

const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")

@export var world_seed: int = 104729
@export var map_width: int = 42
@export var map_height: int = 42
@export var tile_width: float = 64.0
@export var tile_height: float = 32.0
@export var zombie_count: int = 12
@export var autosave_interval: float = 20.0

var awe_data: Dictionary = {}
var terrain_cells: Array[Dictionary] = []
var world_objects: Array[Dictionary] = []
var harvested_keys: Array[String] = []
var noise := FastNoiseLite.new()
var rng := RandomNumberGenerator.new()

const TERRAIN_COLORS := {
	"deep_water": Color("173d5a"),
	"shallow_water": Color("2d6f82"),
	"wetland": Color("55765c"),
	"grass": Color("66894f"),
	"fertile_soil": Color("7c6947"),
	"dry_soil": Color("8a7656"),
	"rock": Color("777a72")
}

func _ready() -> void:
	awe_data = AWEDataLoader.load_core_data()
	_load_world_state()
	_generate_world(not _has_saved_player())
	_setup_autosave()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			world_seed += 1
			harvested_keys.clear()
			_generate_world(true)
			_save_game()
		elif event.keycode == KEY_F5:
			_save_game()

func _notification(what: int) -> void:
	if not is_inside_tree():
		return
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()

func _setup_autosave() -> void:
	var timer := Timer.new()
	timer.name = "AutosaveTimer"
	timer.wait_time = autosave_interval
	timer.autostart = true
	timer.timeout.connect(_save_game)
	add_child(timer)

func _load_world_state() -> void:
	var save_data := SaveSystem.load_save()
	var state: Dictionary = save_data.get("world", {}) as Dictionary
	if state.is_empty():
		return
	world_seed = int(state.get("seed", world_seed))
	harvested_keys.clear()
	for value in state.get("harvested", []):
		harvested_keys.append(str(value))

func _has_saved_player() -> bool:
	var save_data := SaveSystem.load_save()
	var player_state: Dictionary = save_data.get("player", {}) as Dictionary
	return not player_state.is_empty()

func export_save_state() -> Dictionary:
	return {
		"seed": world_seed,
		"harvested": harvested_keys.duplicate()
	}

func _save_game() -> void:
	var player := get_tree().get_first_node_in_group("player")
	SaveSystem.save_game(self, player)

func _generate_world(reset_player: bool = false) -> void:
	terrain_cells.clear()
	world_objects.clear()

	noise.seed = world_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.055
	rng.seed = world_seed

	var half_width := int(floor(map_width / 2.0))
	var half_height := int(floor(map_height / 2.0))

	for y in range(-half_height, half_height):
		for x in range(-half_width, half_width):
			var value := noise.get_noise_2d(float(x), float(y))
			var terrain_id := _terrain_for_value(value)
			terrain_cells.append({
				"grid": Vector2i(x, y),
				"screen": _grid_to_iso(Vector2i(x, y)),
				"terrain": terrain_id
			})
			_try_spawn_object(Vector2i(x, y), terrain_id, value)

	queue_redraw()
	_spawn_zombies()
	if reset_player:
		move_player_to_spawn()
	_update_status()

func _terrain_for_value(value: float) -> String:
	if value < -0.48:
		return "deep_water"
	if value < -0.32:
		return "shallow_water"
	if value < -0.17:
		return "wetland"
	if value < 0.20:
		return "grass"
	if value < 0.43:
		return "fertile_soil"
	if value < 0.62:
		return "dry_soil"
	return "rock"

func _try_spawn_object(grid: Vector2i, terrain_id: String, noise_value: float) -> void:
	var roll := rng.randf()
	var object_id := ""

	if terrain_id == "grass" and roll < 0.075:
		object_id = "native_tree"
	elif terrain_id == "fertile_soil" and roll < 0.035:
		object_id = "bush"
	elif terrain_id == "dry_soil" and roll < 0.022:
		object_id = "rock"
	elif terrain_id == "rock" and roll < 0.055:
		object_id = "rock"
	elif terrain_id == "wetland" and roll < 0.025 and noise_value > -0.28:
		object_id = "fallen_log"

	if object_id.is_empty():
		return

	var object_key := "%d:%d:%s" % [grid.x, grid.y, object_id]
	if harvested_keys.has(object_key):
		return

	world_objects.append({
		"id": object_id,
		"key": object_key,
		"grid": grid,
		"screen": _grid_to_iso(grid)
	})

func try_interact_near(player_position: Vector2, player: Node) -> bool:
	var nearest_index := -1
	var nearest_distance := 72.0
	for index in range(world_objects.size()):
		var object_position: Vector2 = world_objects[index]["screen"]
		var distance := player_position.distance_to(object_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_index = index

	if nearest_index < 0:
		return false

	var object_data: Dictionary = world_objects[nearest_index]
	var object_id := str(object_data.get("id", ""))
	var reward_id := "fiber"
	var reward_amount := 1
	match object_id:
		"native_tree":
			reward_id = "wood"
			reward_amount = 3
		"fallen_log":
			reward_id = "wood"
			reward_amount = 2
		"rock":
			reward_id = "stone"
			reward_amount = 2
		"bush":
			reward_id = "fiber"
			reward_amount = 2

	if player != null and player.has_method("add_item"):
		player.call("add_item", reward_id, reward_amount)
	harvested_keys.append(str(object_data.get("key", "")))
	world_objects.remove_at(nearest_index)
	queue_redraw()
	_save_game()
	return true

func move_player_to_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	player.global_position = _find_spawn_position()

func _find_spawn_position() -> Vector2:
	var best_position := Vector2.ZERO
	var best_distance := INF
	for cell in terrain_cells:
		var terrain_id := str(cell.get("terrain", ""))
		if terrain_id in ["deep_water", "shallow_water", "wetland"]:
			continue
		var screen_position: Vector2 = cell["screen"]
		var distance := screen_position.length()
		if distance < best_distance:
			best_distance = distance
			best_position = screen_position + Vector2(0, -24)
	return best_position

func _spawn_zombies() -> void:
	var container := get_node_or_null("Zombies") as Node2D
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()

	var player := get_tree().get_first_node_in_group("player") as Node2D
	var spawned := 0
	var attempts := 0
	while spawned < zombie_count and attempts < zombie_count * 40:
		attempts += 1
		if terrain_cells.is_empty():
			break
		var cell: Dictionary = terrain_cells[rng.randi_range(0, terrain_cells.size() - 1)]
		var terrain_id := str(cell.get("terrain", ""))
		if terrain_id in ["deep_water", "shallow_water", "wetland"]:
			continue
		var spawn_position: Vector2 = cell["screen"]
		if player != null and spawn_position.distance_to(player.global_position) < 250.0:
			continue
		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		if zombie == null:
			continue
		zombie.position = spawn_position
		container.add_child(zombie)
		spawned += 1

func _grid_to_iso(grid: Vector2i) -> Vector2:
	return Vector2(
		(float(grid.x - grid.y) * tile_width) / 2.0,
		(float(grid.x + grid.y) * tile_height) / 2.0
	)

func _draw() -> void:
	for cell in terrain_cells:
		var terrain_color: Color = TERRAIN_COLORS.get(cell["terrain"], Color.MAGENTA)
		_draw_iso_tile(cell["screen"], terrain_color)

	for object_data in world_objects:
		_draw_world_object(object_data["id"], object_data["screen"])

func _draw_iso_tile(center: Vector2, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -tile_height / 2.0),
		center + Vector2(tile_width / 2.0, 0.0),
		center + Vector2(0.0, tile_height / 2.0),
		center + Vector2(-tile_width / 2.0, 0.0)
	])
	draw_colored_polygon(points, color)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), color.darkened(0.16), 1.0)

func _draw_world_object(object_id: String, position_2d: Vector2) -> void:
	match object_id:
		"native_tree":
			draw_rect(Rect2(position_2d + Vector2(-3, -25), Vector2(6, 25)), Color("5f422d"), true)
			draw_circle(position_2d + Vector2(0, -31), 14.0, Color("294d32"))
			draw_circle(position_2d + Vector2(-8, -25), 10.0, Color("355f3b"))
		"bush":
			draw_circle(position_2d + Vector2(-5, -7), 7.0, Color("3f6d3c"))
			draw_circle(position_2d + Vector2(5, -7), 7.0, Color("4f7d45"))
		"rock":
			var rock_points := PackedVector2Array([
				position_2d + Vector2(-10, 0),
				position_2d + Vector2(-6, -10),
				position_2d + Vector2(5, -13),
				position_2d + Vector2(12, -3),
				position_2d + Vector2(7, 3)
			])
			draw_colored_polygon(rock_points, Color("686b65"))
		"fallen_log":
			draw_line(position_2d + Vector2(-14, -5), position_2d + Vector2(14, -12), Color("59412f"), 8.0)

func _update_status() -> void:
	var status := get_node_or_null("HUD/TopPanel/WorldStatus") as Label
	if status == null:
		return
	status.text = "ALPHA 0.3.0 — Seed %d | Terrenos %d | Recursos %d" % [world_seed, terrain_cells.size(), world_objects.size()]
