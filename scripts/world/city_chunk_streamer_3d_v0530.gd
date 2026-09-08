extends "res://scripts/world/city_chunk_streamer_3d_v0521.gd"

const VehicleV0530Script = preload("res://scripts/entities/vehicle_3d_v0530.gd")

func _build_vehicle_sprite_0517(parent: Node3D, pos: Vector3, yaw: float, atlas_index: int, key: String) -> void:
	if world != null and world.has_method("should_spawn_streamed_vehicle_0530"):
		if not bool(world.call("should_spawn_streamed_vehicle_0530", key)):
			return
	var vehicle: CharacterBody3D = VehicleV0530Script.new()
	vehicle.call("configure_parked_0530", world, key, atlas_index, yaw, world_seed)
	vehicle.position = pos
	vehicle.add_to_group("vehicle_streamed_0530")
	parent.add_child(vehicle)
	if world != null and world.has_method("register_streamed_loot"):
		world.call("register_streamed_loot", vehicle.global_position, "city_garage", key, null)

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["vehicles_drivable_0530"] = get_tree().get_nodes_in_group("vehicle_0530").size()
	result["vehicles_streamed_0530"] = get_tree().get_nodes_in_group("vehicle_streamed_0530").size()
	return result
