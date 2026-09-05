extends "res://scripts/world/city_chunk_streamer_3d_v0516.gd"

const VEHICLE_ATLAS_0517: Texture2D = preload("res://assets/vehicles/fdc_vehicle_atlas_0517.webp")
const VEHICLE_TILE_0517 := Vector2i(160, 120)
const CITY_VEHICLE_VARIANTS_0517 := [0, 1, 2, 3, 4, 5, 6, 8]

func _build_vehicle(parent: Node3D, pos: Vector3, yaw: float, _variant: int, key: String) -> void:
	var marker := int(abs(hash("vehicle0517:%s:%d" % [key, world_seed])))
	var atlas_index: int = CITY_VEHICLE_VARIANTS_0517[marker % CITY_VEHICLE_VARIANTS_0517.size()]
	_build_vehicle_sprite_0517(parent, pos, yaw, atlas_index, key)

func _build_vehicle_sprite_0517(parent: Node3D, pos: Vector3, yaw: float, atlas_index: int, key: String) -> void:
	var root := Node3D.new()
	root.name = "AbandonedVehicle0517"
	root.position = pos
	root.add_to_group("vehicle")
	root.add_to_group("vehicle_sprite_root_0517")
	parent.add_child(root)

	var sprite := Sprite3D.new()
	sprite.name = "VehicleSprite0517"
	sprite.texture = VEHICLE_ATLAS_0517
	sprite.region_enabled = true
	var col := atlas_index % 3
	var row := atlas_index / 3
	sprite.region_rect = Rect2(float(col * VEHICLE_TILE_0517.x), float(row * VEHICLE_TILE_0517.y), float(VEHICLE_TILE_0517.x), float(VEHICLE_TILE_0517.y))
	sprite.pixel_size = 0.028
	sprite.position = Vector3(0.0, 1.42, 0.0)
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.shaded = false
	sprite.transparent = true
	sprite.double_sided = true
	# As vias X/Z aparecem em diagonais opostas na câmera isométrica; o flip troca a leitura da direção sem girar o sprite no plano da tela.
	sprite.flip_h = absf(sin(yaw)) > 0.55
	sprite.add_to_group("vehicle_sprite_0517")
	root.add_child(sprite)

	var collider := StaticBody3D.new()
	collider.name = "VehicleCollider0517"
	collider.rotation.y = yaw
	collider.add_to_group("vehicle_collider_0517")
	root.add_child(collider)
	var collision_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var collision_size := _vehicle_collision_size_0517(atlas_index)
	box.size = collision_size
	collision_shape.shape = box
	collision_shape.position = Vector3(0.0, collision_size.y * 0.5, 0.0)
	collider.add_child(collision_shape)

	if world != null and world.has_method("register_streamed_loot"):
		world.call("register_streamed_loot", root.global_position, "city_garage", key, null)

func _vehicle_collision_size_0517(atlas_index: int) -> Vector3:
	match atlas_index:
		3: # pickup
			return Vector3(2.0, 1.45, 4.35)
		4: # van
			return Vector3(2.05, 1.72, 4.35)
		5: # caminhão baú
			return Vector3(2.35, 2.25, 5.15)
		6: # utilitário/SUV
			return Vector3(2.0, 1.62, 4.15)
		8: # carcaça queimada
			return Vector3(2.0, 1.30, 4.05)
		_:
			return Vector3(1.90, 1.48, 3.95)

func _build_rural_garage(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_garage(parent, pos, coord)
	# A Art Bible prevê máquinas rurais contextualizadas; o trator fica restrito a garagens rurais.
	var marker := int(abs(hash("tractor0517:%d:%d:%d" % [world_seed, coord.x, coord.y])))
	if marker % 2 == 0:
		_build_vehicle_sprite_0517(parent, pos + Vector3(5.2, 0.28, 1.2), 0.0, 7, "tractor0517:%d:%d" % [coord.x, coord.y])

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["vehicle_sprites_0517"] = get_tree().get_nodes_in_group("vehicle_sprite_0517").size()
	result["vehicle_colliders_0517"] = get_tree().get_nodes_in_group("vehicle_collider_0517").size()
	return result
