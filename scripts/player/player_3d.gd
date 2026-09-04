class_name Player3D
extends CharacterBody3D

var world: Node = null
var mobile_controls: Node = null
var health := 100.0
var stamina := 100.0
var hunger := 100.0
var thirst := 100.0
var inventory: Dictionary = {
	"wood": 0,
	"stone": 0,
	"fiber": 0,
	"food": 1,
	"water": 1,
	"bandage": 1,
	"ammo_9mm": 0,
	"shells": 0
}
var owned_weapons: Array[String] = ["machete"]
var equipped_index := 0
var attack_cooldown := 0.0
var visual_root: Node3D
var weapon_anchor: Node3D
var bob_time := 0.0

const WALK_SPEED := 5.0
const RUN_SPEED := 7.4

func _ready() -> void:
	add_to_group("player")
	_build_collision()
	_build_visual()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	_update_needs(delta)
	if mobile_controls == null or not is_instance_valid(mobile_controls):
		mobile_controls = get_tree().get_first_node_in_group("mobile_controls")

	var input_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): input_vec.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): input_vec.y += 1.0
	if mobile_controls != null and mobile_controls.has_method("get_move_vector"):
		var mv: Variant = mobile_controls.call("get_move_vector")
		if mv is Vector2 and (mv as Vector2).length() > 0.05:
			input_vec = mv as Vector2

	var sprint := Input.is_key_pressed(KEY_SHIFT)
	if mobile_controls != null and mobile_controls.has_method("is_sprinting"):
		sprint = sprint or bool(mobile_controls.call("is_sprinting"))
	var running := sprint and input_vec.length() > 0.05 and stamina > 2.0
	if running:
		stamina = maxf(0.0, stamina - 18.0 * delta)
	else:
		stamina = minf(100.0, stamina + 12.0 * delta)

	var dir := Vector3(input_vec.x + input_vec.y, 0.0, -input_vec.x + input_vec.y)
	if dir.length() > 0.05:
		dir = dir.normalized()
		# O modelo visual tem a frente apontando para -Z (mochila em +Z).
		# Somar PI faz o personagem olhar para a direção real do deslocamento.
		var target_yaw := atan2(dir.x, dir.z) + PI
		rotation.y = lerp_angle(rotation.y, target_yaw, minf(1.0, delta * 12.0))
	velocity.x = dir.x * (RUN_SPEED if running else WALK_SPEED)
	velocity.z = dir.z * (RUN_SPEED if running else WALK_SPEED)
	velocity.y = 0.0
	move_and_slide()

	if visual_root != null:
		if dir.length() > 0.05:
			bob_time += delta * (13.0 if running else 9.0)
			visual_root.position.y = sin(bob_time) * 0.045
		else:
			visual_root.position.y = lerpf(visual_root.position.y, 0.0, delta * 8.0)

	var attack := Input.is_key_pressed(KEY_SPACE)
	if mobile_controls != null and mobile_controls.has_method("consume_attack"):
		attack = attack or bool(mobile_controls.call("consume_attack"))
	if attack:
		_attack()

	var interact := Input.is_key_pressed(KEY_E)
	if mobile_controls != null and mobile_controls.has_method("consume_interact"):
		interact = interact or bool(mobile_controls.call("consume_interact"))
	if interact and world != null and world.has_method("try_interact_near"):
		world.call("try_interact_near", global_position, self)

	var cycle := Input.is_key_pressed(KEY_Q)
	if mobile_controls != null and mobile_controls.has_method("consume_cycle_weapon"):
		cycle = cycle or bool(mobile_controls.call("consume_cycle_weapon"))
	if cycle:
		cycle_weapon()

func _update_needs(delta: float) -> void:
	hunger = maxf(0.0, hunger - 0.012 * delta)
	thirst = maxf(0.0, thirst - 0.022 * delta)
	if hunger <= 0.0 or thirst <= 0.0:
		health = maxf(0.0, health - 2.5 * delta)
	if health <= 0.0:
		_respawn()

func _attack() -> void:
	if attack_cooldown > 0.0:
		return
	var weapon := get_equipped_weapon()
	if weapon == "machete":
		if stamina < 7.0: return
		stamina -= 7.0
		attack_cooldown = 0.48
		_damage_nearest(2.5, 38.0)
		_animate_weapon_swing()
	elif weapon == "pistol":
		if int(inventory.get("ammo_9mm", 0)) <= 0: return
		inventory["ammo_9mm"] = int(inventory.get("ammo_9mm", 0)) - 1
		attack_cooldown = 0.32
		_damage_nearest(21.0, 42.0)
	elif weapon == "shotgun":
		if int(inventory.get("shells", 0)) <= 0: return
		inventory["shells"] = int(inventory.get("shells", 0)) - 1
		attack_cooldown = 0.85
		_damage_nearest(13.0, 78.0)

func _damage_nearest(max_range: float, damage: float) -> void:
	if world == null or not world.has_method("get_zombies"): return
	var nearest: Node3D = null
	var best := max_range
	for candidate in world.call("get_zombies"):
		var zombie := candidate as Node3D
		if zombie == null: continue
		var d := global_position.distance_to(zombie.global_position)
		if d < best:
			best = d
			nearest = zombie
	if nearest != null and nearest.has_method("take_damage"):
		nearest.call("take_damage", damage)

func _animate_weapon_swing() -> void:
	if weapon_anchor == null: return
	var start_rot := weapon_anchor.rotation_degrees
	var tween := create_tween()
	tween.tween_property(weapon_anchor, "rotation_degrees:z", start_rot.z - 72.0, 0.09)
	tween.tween_property(weapon_anchor, "rotation_degrees:z", start_rot.z, 0.16)

func cycle_weapon() -> void:
	if owned_weapons.size() <= 1: return
	equipped_index = (equipped_index + 1) % owned_weapons.size()
	_refresh_weapon_visual()

func unlock_weapon(id: String) -> void:
	if not owned_weapons.has(id):
		owned_weapons.append(id)
	equip_weapon(id)

func equip_weapon(id: String) -> bool:
	if not owned_weapons.has(id): return false
	equipped_index = owned_weapons.find(id)
	_refresh_weapon_visual()
	return true

func get_equipped_weapon() -> String:
	if owned_weapons.is_empty(): return "machete"
	return owned_weapons[clampi(equipped_index, 0, owned_weapons.size() - 1)]

func get_owned_weapons() -> Array[String]:
	return owned_weapons.duplicate()

func get_inventory_snapshot() -> Dictionary:
	return inventory.duplicate(true)

func add_item(id: String, amount: int = 1) -> void:
	inventory[id] = int(inventory.get(id, 0)) + amount

func use_inventory_item(id: String) -> bool:
	var count := int(inventory.get(id, 0))
	if count <= 0: return false
	match id:
		"food":
			hunger = minf(100.0, hunger + 28.0)
		"water":
			thirst = minf(100.0, thirst + 35.0)
		"bandage":
			health = minf(100.0, health + 30.0)
		_:
			return false
	inventory[id] = count - 1
	return true

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	if health <= 0.0: _respawn()

func _respawn() -> void:
	health = 100.0
	stamina = 100.0
	hunger = 72.0
	thirst = 72.0
	global_position = Vector3(0, 0.75, 3.5)

func reset_for_new_world() -> void:
	health = 100.0
	stamina = 100.0
	hunger = 100.0
	thirst = 100.0
	inventory = {"wood":0,"stone":0,"fiber":0,"food":1,"water":1,"bandage":1,"ammo_9mm":0,"shells":0}
	owned_weapons = ["machete"]
	equipped_index = 0
	_refresh_weapon_visual()

func get_vitals() -> Dictionary:
	return {"health":health,"stamina":stamina,"hunger":hunger,"thirst":thirst}

func get_inventory_summary() -> String:
	return "Madeira %d  Pedra %d  Fibra %d  Comida %d  Água %d" % [int(inventory.get("wood",0)), int(inventory.get("stone",0)), int(inventory.get("fiber",0)), int(inventory.get("food",0)), int(inventory.get("water",0))]

func get_weapon_summary() -> String:
	var weapon := get_equipped_weapon()
	if weapon == "pistol": return "PISTOLA 9mm — %d munições" % int(inventory.get("ammo_9mm",0))
	if weapon == "shotgun": return "ESPINGARDA — %d cartuchos" % int(inventory.get("shells",0))
	return "FACÃO — corpo a corpo"

func export_save_state() -> Dictionary:
	return {
		"position":{"x":global_position.x,"y":global_position.y,"z":global_position.z},
		"health":health,"stamina":stamina,"hunger":hunger,"thirst":thirst,
		"inventory":inventory.duplicate(true),"weapons":owned_weapons.duplicate(),"equipped":equipped_index
	}

func import_save_state(state: Dictionary) -> void:
	var p: Dictionary = state.get("position", {}) as Dictionary
	global_position = Vector3(float(p.get("x",0)), float(p.get("y",0.75)), float(p.get("z",3.5)))
	health = float(state.get("health",100.0))
	stamina = float(state.get("stamina",100.0))
	hunger = float(state.get("hunger",100.0))
	thirst = float(state.get("thirst",100.0))
	var inv: Dictionary = state.get("inventory", {}) as Dictionary
	for key in inv: inventory[str(key)] = int(inv[key])
	owned_weapons.clear()
	for item in state.get("weapons", ["machete"]): owned_weapons.append(str(item))
	if owned_weapons.is_empty(): owned_weapons.append("machete")
	equipped_index = clampi(int(state.get("equipped",0)), 0, owned_weapons.size()-1)
	_refresh_weapon_visual()

func _build_collision() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.75
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.85
	add_child(collision)

func _build_visual() -> void:
	visual_root = Node3D.new()
	visual_root.name = "CharacterVisual"
	add_child(visual_root)
	_box(Vector3(0.7, 0.85, 0.38), Vector3(0, 1.35, 0), _material("35473b"))
	_box(Vector3(0.28, 0.82, 0.28), Vector3(-0.2, 0.55, 0), _material("26302b"))
	_box(Vector3(0.28, 0.82, 0.28), Vector3(0.2, 0.55, 0), _material("26302b"))
	_box(Vector3(0.22, 0.78, 0.22), Vector3(-0.48, 1.35, -0.06), _material("35473b"))
	_box(Vector3(0.22, 0.78, 0.22), Vector3(0.48, 1.35, -0.08), _material("35473b"))
	_sphere(0.34, Vector3(0, 2.05, 0), _material("b98c68"), Vector3(0.9,1.0,0.9))
	# Mochila atrás: +Z. Isso define claramente a frente visual como -Z.
	_box(Vector3(0.64, 0.82, 0.25), Vector3(0, 1.38, 0.32), _material("5a4935"))
	_box(Vector3(0.68, 0.10, 0.68), Vector3(0, 2.34, 0), _material("2a241f"))
	weapon_anchor = Node3D.new()
	weapon_anchor.name = "RightHandWeaponAnchor"
	weapon_anchor.position = Vector3(0.48, 1.38, -0.30)
	visual_root.add_child(weapon_anchor)
	_refresh_weapon_visual()

func _refresh_weapon_visual() -> void:
	if weapon_anchor == null: return
	for child in weapon_anchor.get_children(): child.free()
	weapon_anchor.rotation_degrees = Vector3.ZERO
	var weapon := get_equipped_weapon()
	if weapon == "machete":
		weapon_anchor.rotation_degrees = Vector3(-18.0, -8.0, -12.0)
		_box_to(weapon_anchor, Vector3(0.11, 0.11, 0.34), Vector3(0,0,0.05), _material("4a2c1d"))
		var blade := _box_to(weapon_anchor, Vector3(0.13, 0.055, 0.82), Vector3(0.02,0,-0.53), _material("a7aaa4"))
		blade.rotation_degrees.y = -4.0
	elif weapon == "pistol":
		weapon_anchor.rotation_degrees = Vector3(-5.0, 0.0, -7.0)
		_box_to(weapon_anchor, Vector3(0.15, 0.16, 0.48), Vector3(0,0,-0.20), _material("343938"))
		var grip := _box_to(weapon_anchor, Vector3(0.15, 0.34, 0.16), Vector3(0,-0.18,-0.02), _material("2d302f"))
		grip.rotation_degrees.x = -15.0
	elif weapon == "shotgun":
		weapon_anchor.rotation_degrees = Vector3(0.0, 0.0, -5.0)
		_box_to(weapon_anchor, Vector3(0.12, 0.12, 1.45), Vector3(0,0,-0.65), _material("444846"))
		_box_to(weapon_anchor, Vector3(0.18, 0.20, 0.72), Vector3(0,0,0.38), _material("6b452d"))
		_box_to(weapon_anchor, Vector3(0.18, 0.18, 0.48), Vector3(0,-0.03,-0.15), _material("6b452d"))

func _material(hex: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(hex)
	mat.roughness = 0.95
	return mat

func _box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	return _box_to(visual_root, size, pos, mat)

func _box_to(parent: Node3D, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func _sphere(radius: float, pos: Vector3, mat: Material, scale_value: Vector3) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.scale = scale_value
	visual_root.add_child(node)
	return node
