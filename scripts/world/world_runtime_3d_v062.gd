extends "res://scripts/world/world_runtime_3d_v0601.gd"

const NATURE_VERSION_062 := "0.6.2-alpha"
const NatureVisual := preload("res://scripts/visual/nature_visual_062.gd")

func _create_tree(pos: Vector3, scale_value: float, pinus: bool) -> Node3D:
	var root := super._create_tree(pos, scale_value, pinus)
	NatureVisual.apply(root, "tree")
	return root

func _create_bush(pos: Vector3, scale_value: float) -> Node3D:
	var root := super._create_bush(pos, scale_value)
	NatureVisual.apply(root, "bush")
	return root

func _create_rock(pos: Vector3, scale_value: float) -> Node3D:
	var root := super._create_rock(pos, scale_value)
	NatureVisual.apply(root, "rock")
	return root

func get_nature_asset_debug_062() -> Dictionary:
	return {
		"version": NATURE_VERSION_062,
		"tree_sprites": get_tree().get_nodes_in_group("nature_tree_062").size(),
		"bush_sprites": get_tree().get_nodes_in_group("nature_bush_062").size(),
		"rock_sprites": get_tree().get_nodes_in_group("nature_rock_062").size(),
		"save_schema_compatible": SAVE_SCHEMA_0600,
		"fluidity_version": FLUIDITY_VERSION_0601
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["nature_assets_062"] = get_nature_asset_debug_062()
	return result
