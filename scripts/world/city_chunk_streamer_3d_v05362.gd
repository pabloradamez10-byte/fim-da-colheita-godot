extends "res://scripts/world/city_chunk_streamer_3d_v0534.gd"

const VehicleV05362Script = preload("res://scripts/entities/vehicle_3d_v05362.gd")

const CITY_VEHICLE_VARIANTS_05362 := [
	0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 22, 23, 24, 25, 26,
	27, 28, 29, 30, 31, 32, 33, 34, 35
]
const RURAL_VEHICLE_VARIANTS_05362 := [
	3, 7, 14, 15, 16, 17, 18, 19, 22, 23, 24, 31, 32, 36, 37, 38, 39
]
const SERVICE_VARIANTS_05362 := {
	"hospital": 13,
	"police": 12,
	"farm": 37,
	"workshop": 31,
	"market": 33
}

func _build_vehicle(parent: Node3D, pos: Vector3, yaw: float, _variant: int, key: String) -> void:
	var marker := int(abs(hash("vehicle05362:%s:%d" % [key, world_seed])))
	var atlas_index: int = CITY_VEHICLE_VARIANTS_05362[marker % CITY_VEHICLE_VARIANTS_05362.size()]
	_build_vehicle_sprite_0517(parent, pos, yaw, atlas_index, key)

func _build_vehicle_sprite_0517(parent: Node3D, pos: Vector3, yaw: float, atlas_index: int, key: String) -> void:
	if world != null and world.has_method("should_spawn_streamed_vehicle_0530"):
		if not bool(world.call("should_spawn_streamed_vehicle_0530", key)):
			return
	var vehicle: CharacterBody3D = VehicleV05362Script.new()
	vehicle.call("configure_parked_0530", world, key, atlas_index, yaw, world_seed)
	vehicle.position = pos
	vehicle.add_to_group("vehicle_streamed_0530")
	vehicle.add_to_group("vehicle_streamed_05362")
	parent.add_child(vehicle)
	if world != null and world.has_method("register_streamed_loot"):
		world.call("register_streamed_loot", vehicle.global_position, "city_garage", key, null)

func _build_rural_garage(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_garage(parent, pos, coord)
	var marker := int(abs(hash("rural_vehicle05362:%d:%d:%d" % [world_seed, coord.x, coord.y])))
	if marker % 3 != 0:
		return
	var variant := int(RURAL_VEHICLE_VARIANTS_05362[int(marker / 3) % RURAL_VEHICLE_VARIANTS_05362.size()])
	_build_vehicle_sprite_0517(
		parent,
		pos + Vector3(-5.4, 0.28, 1.4),
		PI * 0.5,
		variant,
		"rural05362:%d:%d" % [coord.x, coord.y]
	)

func _decorate_location_0534(root: Node3D, role: String, key_base: String) -> void:
	super._decorate_location_0534(root, role, key_base)
	if root == null or role not in SERVICE_VARIANTS_05362:
		return
	var marker := int(abs(hash("service_vehicle05362:%s:%d" % [key_base, world_seed])))
	if marker % 2 != 0:
		return
	var variant := int(SERVICE_VARIANTS_05362[role])
	var offset := Vector3(7.3, 0.28, 4.8)
	if role == "farm":
		offset = Vector3(6.4, 0.28, -5.0)
	elif role == "workshop":
		offset = Vector3(-7.2, 0.28, 4.6)
	elif role == "market":
		offset = Vector3(7.0, 0.28, -4.3)
	_build_vehicle_sprite_0517(root, offset, PI * 0.5, variant, "%s:service_vehicle05362" % key_base)

func get_vehicle_catalog_05362() -> Dictionary:
	return {
		"variant_count": 40,
		"directions": 8,
		"city_variants": CITY_VEHICLE_VARIANTS_05362.duplicate(),
		"rural_variants": RURAL_VEHICLE_VARIANTS_05362.duplicate(),
		"service_variants": SERVICE_VARIANTS_05362.duplicate(true)
	}

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["vehicle_art_05362"] = get_tree().get_nodes_in_group("vehicle_art_05362").size()
	result["vehicle_sprite_8dir_05362"] = get_tree().get_nodes_in_group("vehicle_sprite_8dir_05362").size()
	result["vehicle_variant_count_05362"] = 40
	result["vehicle_direction_count_05362"] = 8
	return result
