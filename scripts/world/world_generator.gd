class_name WorldGenerator
extends Node2D

const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")

@export var world_seed: int = 104729
@export var map_width: int = 46
@export var map_height: int = 46
@export var tile_width: float = 96.0
@export var tile_height: float = 48.0
@export var zombie_count: int = 14
@export var autosave_interval: float = 20.0

var awe_data: Dictionary = {}
var terrain_cells: Array[Dictionary] = []
var world_objects: Array[Dictionary] = []
var landmarks: Array[Dictionary] = []
var decorations: Array[Dictionary] = []
var harvested_keys: Array[String] = []
var noise := FastNoiseLite.new()
var rng := RandomNumberGenerator.new()

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
	return {"seed": world_seed, "harvested": harvested_keys.duplicate()}

func _save_game() -> void:
	var player := get_tree().get_first_node_in_group("player")
	SaveSystem.save_game(self, player)

func _generate_world(reset_player: bool = false) -> void:
	terrain_cells.clear()
	world_objects.clear()
	landmarks.clear()
	decorations.clear()
	noise.seed = world_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.050
	rng.seed = world_seed
	var half_width := int(floor(map_width / 2.0))
	var half_height := int(floor(map_height / 2.0))
	for y in range(-half_height, half_height):
		for x in range(-half_width, half_width):
			var grid := Vector2i(x, y)
			var value := noise.get_noise_2d(float(x), float(y))
			var terrain_id := _terrain_for_cell(grid, value)
			terrain_cells.append({"grid": grid, "screen": _grid_to_iso(grid), "terrain": terrain_id})
			_try_spawn_object(grid, terrain_id, value)
	_spawn_landmarks()
	queue_redraw()
	_spawn_zombies()
	if reset_player:
		move_player_to_spawn()
	_update_status()

func _terrain_for_cell(grid: Vector2i, value: float) -> String:
	if abs(grid.x + grid.y) <= 1 and abs(grid.x) < 19:
		return "dry_soil"
	if grid.x >= -10 and grid.x <= 8 and grid.y >= -10 and grid.y <= 5 and (grid.x + grid.y) % 3 != 0:
		if value > -0.35:
			return "fertile_soil"
	if value < -0.48: return "deep_water"
	if value < -0.32: return "shallow_water"
	if value < -0.17: return "wetland"
	if value < 0.20: return "grass"
	if value < 0.43: return "fertile_soil"
	if value < 0.62: return "dry_soil"
	return "rock"

func _try_spawn_object(grid: Vector2i, terrain_id: String, noise_value: float) -> void:
	var roll := rng.randf()
	var object_id := ""
	if terrain_id == "grass" and roll < 0.095: object_id = "native_tree"
	elif terrain_id == "fertile_soil" and roll < 0.040: object_id = "bush"
	elif terrain_id == "dry_soil" and roll < 0.028: object_id = "rock"
	elif terrain_id == "rock" and roll < 0.070: object_id = "rock"
	elif terrain_id == "wetland" and roll < 0.022 and noise_value > -0.28: object_id = "bush"
	if object_id.is_empty(): return
	var object_key := "%d:%d:%s" % [grid.x, grid.y, object_id]
	if harvested_keys.has(object_key): return
	world_objects.append({"id": object_id, "key": object_key, "grid": grid, "screen": _grid_to_iso(grid)})

func _spawn_landmarks() -> void:
	landmarks = [
		{"id": "house", "screen": _grid_to_iso(Vector2i(-6, -5)) + Vector2(0, -38)},
		{"id": "barn", "screen": _grid_to_iso(Vector2i(6, -5)) + Vector2(0, -34)}
	]
	for x in range(-10, 11, 2): decorations.append({"id": "fence", "screen": _grid_to_iso(Vector2i(x, -10))})
	for y in range(-8, 5, 2): decorations.append({"id": "fence", "screen": _grid_to_iso(Vector2i(-11, y))})
	_add_fixed_loot("crate", Vector2i(-4, -2), "farm_crate_a")
	_add_fixed_loot("crate", Vector2i(4, -2), "farm_crate_b")
	_add_fixed_loot("crate", Vector2i(8, -7), "barn_crate")

func _add_fixed_loot(object_id: String, grid: Vector2i, key_suffix: String) -> void:
	var object_key := "fixed:%s" % key_suffix
	if harvested_keys.has(object_key): return
	world_objects.append({"id": object_id, "key": object_key, "grid": grid, "screen": _grid_to_iso(grid)})

func try_interact_near(player_position: Vector2, player: Node) -> bool:
	var nearest_index := -1
	var nearest_distance := 92.0
	for index in range(world_objects.size()):
		var object_position: Vector2 = world_objects[index]["screen"]
		var distance := player_position.distance_to(object_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_index = index
	if nearest_index < 0: return false
	var object_data: Dictionary = world_objects[nearest_index]
	var object_id := str(object_data.get("id", ""))
	if player != null and player.has_method("add_item"):
		match object_id:
			"native_tree": player.call("add_item", "wood", 4)
			"rock": player.call("add_item", "stone", 3)
			"bush": player.call("add_item", "fiber", 2)
			"crate":
				player.call("add_item", "ammo_pistol", 8)
				player.call("add_item", "ammo_shotgun", 3)
				player.call("add_item", "water", 1)
				player.call("add_item", "food", 1)
			_: player.call("add_item", "fiber", 1)
	harvested_keys.append(str(object_data.get("key", "")))
	world_objects.remove_at(nearest_index)
	queue_redraw()
	_save_game()
	return true

func move_player_to_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		player.global_position = _grid_to_iso(Vector2i(0, 2)) + Vector2(0, -30)

func _spawn_zombies() -> void:
	var container := get_node_or_null("Zombies") as Node2D
	if container == null: return
	for child in container.get_children(): child.queue_free()
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var spawned := 0
	var attempts := 0
	while spawned < zombie_count and attempts < zombie_count * 50:
		attempts += 1
		if terrain_cells.is_empty(): break
		var cell: Dictionary = terrain_cells[rng.randi_range(0, terrain_cells.size() - 1)]
		var terrain_id := str(cell.get("terrain", ""))
		if terrain_id in ["deep_water", "shallow_water", "wetland"]: continue
		var spawn_position: Vector2 = cell["screen"]
		if player != null and spawn_position.distance_to(player.global_position) < 320.0: continue
		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		if zombie == null: continue
		zombie.position = spawn_position
		container.add_child(zombie)
		spawned += 1

func _grid_to_iso(grid: Vector2i) -> Vector2:
	return Vector2((float(grid.x - grid.y) * tile_width) / 2.0, (float(grid.x + grid.y) * tile_height) / 2.0)

func _draw() -> void:
	for cell in terrain_cells: _draw_iso_tile(cell["screen"], str(cell["terrain"]))
	for decoration in decorations: _draw_world_object(str(decoration["id"]), decoration["screen"])
	for landmark in landmarks: _draw_landmark(str(landmark["id"]), landmark["screen"])
	for object_data in world_objects: _draw_world_object(str(object_data["id"]), object_data["screen"])

func _draw_iso_tile(center: Vector2, terrain_id: String) -> void:
	var texture_id := "grass"
	match terrain_id:
		"deep_water", "shallow_water": texture_id = "water"
		"wetland": texture_id = "mud"
		"fertile_soil": texture_id = "soil"
		"dry_soil", "rock": texture_id = "dirt"
	var tex := VisualAssets.texture(texture_id)
	if tex != null:
		draw_texture_rect(tex, Rect2(center - Vector2(48, 24), Vector2(96, 48)), false)

func _draw_world_object(object_id: String, position_2d: Vector2) -> void:
	var tex: Texture2D = null
	var destination := Rect2()
	match object_id:
		"native_tree":
			tex = VisualAssets.texture("tree")
			destination = Rect2(position_2d - Vector2(52, 132), Vector2(104, 144))
		"rock":
			tex = VisualAssets.texture("rock")
			destination = Rect2(position_2d - Vector2(42, 34), Vector2(84, 68))
		"bush":
			tex = VisualAssets.texture("bush")
			destination = Rect2(position_2d - Vector2(42, 30), Vector2(84, 60))
		"fence":
			tex = VisualAssets.texture("fence")
			destination = Rect2(position_2d - Vector2(84, 36), Vector2(168, 72))
		"crate":
			tex = VisualAssets.texture("crate")
			destination = Rect2(position_2d - Vector2(42, 34), Vector2(84, 70))
	if tex != null: draw_texture_rect(tex, destination, false)

func _draw_landmark(landmark_id: String, position_2d: Vector2) -> void:
	var tex := VisualAssets.texture(landmark_id)
	if tex == null: return
	match landmark_id:
		"house": draw_texture_rect(tex, Rect2(position_2d - Vector2(205, 210), Vector2(410, 255)), false)
		"barn": draw_texture_rect(tex, Rect2(position_2d - Vector2(215, 210), Vector2(430, 255)), false)

func _update_status() -> void:
	var status := get_node_or_null("HUD/TopPanel/WorldStatus") as Label
	if status != null:
		status.text = "ALPHA 0.4.0 — Fazenda por Seed %d | Recursos %d | Estruturas 2" % [world_seed, world_objects.size()]
