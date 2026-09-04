class_name PlayerController
extends CharacterBody2D

@export var walk_speed: float = 205.0
@export var sprint_speed: float = 310.0
@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var max_hunger: float = 100.0
@export var max_thirst: float = 100.0

var health := 100.0
var stamina := 100.0
var hunger := 100.0
var thirst := 100.0
var inventory: Dictionary = {"wood": 0, "stone": 0, "fiber": 0, "water": 1, "food": 1, "bandage": 1, "ammo_pistol": 15, "ammo_shotgun": 6}
var equipped_weapon := "machete"
var owned_weapons: Dictionary = {"machete": true, "axe": true, "pistol": true, "shotgun": true}
var attack_cooldown := 0.0
var mobile_controls: Node = null

func _ready() -> void:
	add_to_group("player")
	_load_saved_state()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if mobile_controls == null or not is_instance_valid(mobile_controls):
		mobile_controls = get_tree().get_first_node_in_group("mobile_controls")
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	_update_survival(delta)
	var direction := _get_keyboard_direction()
	if mobile_controls != null and mobile_controls.has_method("get_move_vector"):
		var mobile_direction: Variant = mobile_controls.call("get_move_vector")
		if mobile_direction is Vector2 and (mobile_direction as Vector2).length() > 0.05:
			direction = mobile_direction as Vector2
	var wants_sprint := Input.is_key_pressed(KEY_SHIFT)
	if mobile_controls != null and mobile_controls.has_method("is_sprinting"):
		wants_sprint = wants_sprint or bool(mobile_controls.call("is_sprinting"))
	var can_sprint := wants_sprint and direction.length() > 0.05 and stamina > 1.0
	if can_sprint: stamina = maxf(0.0, stamina - 18.0 * delta)
	else: stamina = minf(max_stamina, stamina + 12.0 * delta)
	velocity = direction.normalized() * (sprint_speed if can_sprint else walk_speed)
	move_and_slide()
	var attack_pressed := Input.is_key_pressed(KEY_SPACE)
	if mobile_controls != null and mobile_controls.has_method("consume_attack"):
		attack_pressed = attack_pressed or bool(mobile_controls.call("consume_attack"))
	if attack_pressed: _try_attack()
	var interact_pressed := Input.is_key_pressed(KEY_E)
	if mobile_controls != null and mobile_controls.has_method("consume_interact"):
		interact_pressed = interact_pressed or bool(mobile_controls.call("consume_interact"))
	if interact_pressed: _try_interact()

func _get_keyboard_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1.0
	return direction.normalized()

func _update_survival(delta: float) -> void:
	hunger = maxf(0.0, hunger - 0.018 * delta)
	thirst = maxf(0.0, thirst - 0.034 * delta)
	if hunger <= 0.0 or thirst <= 0.0: health = maxf(0.0, health - 3.0 * delta)
	if health <= 0.0: _respawn_after_death()

func set_equipped_weapon(weapon_id: String) -> void:
	if not bool(owned_weapons.get(weapon_id, false)): return
	equipped_weapon = weapon_id
	queue_redraw()

func get_equipped_weapon() -> String:
	return equipped_weapon

func _try_attack() -> void:
	if attack_cooldown > 0.0: return
	match equipped_weapon:
		"machete": _melee_attack(42.0, 92.0, 0.34, 5.0)
		"axe": _melee_attack(58.0, 84.0, 0.52, 8.0)
		"pistol": _fire_weapon("ammo_pistol", 56.0, 560.0, 0.32)
		"shotgun": _fire_weapon("ammo_shotgun", 105.0, 390.0, 0.75)

func _melee_attack(damage: float, attack_range: float, cooldown: float, stamina_cost: float) -> void:
	if stamina < stamina_cost: return
	attack_cooldown = cooldown
	stamina = maxf(0.0, stamina - stamina_cost)
	var nearest := _nearest_zombie(attack_range)
	if nearest != null and nearest.has_method("take_damage"): nearest.call("take_damage", damage)

func _fire_weapon(ammo_id: String, damage: float, attack_range: float, cooldown: float) -> void:
	var ammo := int(inventory.get(ammo_id, 0))
	if ammo <= 0: return
	inventory[ammo_id] = ammo - 1
	attack_cooldown = cooldown
	var nearest := _nearest_zombie(attack_range)
	if nearest != null and nearest.has_method("take_damage"):
		nearest.call("take_damage", damage)
		if equipped_weapon == "shotgun":
			for candidate in get_tree().get_nodes_in_group("zombies"):
				var zombie := candidate as Node2D
				if zombie != null and zombie != nearest and zombie.global_position.distance_to(nearest.global_position) <= 90.0 and zombie.has_method("take_damage"):
					zombie.call("take_damage", damage * 0.45)
	queue_redraw()

func _nearest_zombie(max_range: float) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := max_range
	for candidate in get_tree().get_nodes_in_group("zombies"):
		var zombie := candidate as Node2D
		if zombie == null: continue
		var distance := global_position.distance_to(zombie.global_position)
		if distance <= nearest_distance:
			nearest = zombie
			nearest_distance = distance
	return nearest

func _try_interact() -> void:
	var world := get_parent()
	if world != null and world.has_method("try_interact_near"): world.call("try_interact_near", global_position, self)

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	queue_redraw()
	if health <= 0.0: _respawn_after_death()

func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount

func get_vitals() -> Dictionary:
	return {"health": health, "stamina": stamina, "hunger": hunger, "thirst": thirst}

func get_inventory_summary() -> String:
	return "Madeira %d | Pedra %d | Fibra %d | 9mm %d | Cart. %d" % [int(inventory.get("wood", 0)), int(inventory.get("stone", 0)), int(inventory.get("fiber", 0)), int(inventory.get("ammo_pistol", 0)), int(inventory.get("ammo_shotgun", 0))]

func export_save_state() -> Dictionary:
	return {"position": {"x": global_position.x, "y": global_position.y}, "health": health, "stamina": stamina, "hunger": hunger, "thirst": thirst, "inventory": inventory.duplicate(true), "equipped_weapon": equipped_weapon}

func _load_saved_state() -> void:
	var save_data := SaveSystem.load_save()
	var state: Dictionary = save_data.get("player", {}) as Dictionary
	if state.is_empty(): return
	var position_data: Dictionary = state.get("position", {}) as Dictionary
	global_position = Vector2(float(position_data.get("x", global_position.x)), float(position_data.get("y", global_position.y)))
	health = clampf(float(state.get("health", health)), 1.0, max_health)
	stamina = clampf(float(state.get("stamina", stamina)), 0.0, max_stamina)
	hunger = clampf(float(state.get("hunger", hunger)), 0.0, max_hunger)
	thirst = clampf(float(state.get("thirst", thirst)), 0.0, max_thirst)
	var saved_inventory: Dictionary = state.get("inventory", {}) as Dictionary
	for key in saved_inventory: inventory[str(key)] = int(saved_inventory[key])
	equipped_weapon = str(state.get("equipped_weapon", equipped_weapon))

func _respawn_after_death() -> void:
	health = max_health
	stamina = max_stamina
	hunger = 70.0
	thirst = 70.0
	inventory["wood"] = 0
	inventory["stone"] = 0
	inventory["fiber"] = 0
	var world := get_parent()
	if world != null and world.has_method("move_player_to_spawn"): world.call("move_player_to_spawn")
	else: global_position = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	var character := VisualAssets.texture("player")
	if character != null: draw_texture_rect(character, Rect2(-30, -72, 60, 90), false)
	var weapon_icon := VisualAssets.texture(equipped_weapon)
	if weapon_icon != null: draw_texture_rect(weapon_icon, Rect2(15, -28, 32, 32), false)
