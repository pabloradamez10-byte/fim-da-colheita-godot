class_name BuildingVisual063
extends RefCounted

const VERSION := "0.6.3-alpha"
const PIXEL_SIZE := 0.014
const CANVAS_HALF_HEIGHT := 512.0
const ROLE_PIXEL_SIZES := {
	"house": 0.014,
	"hospital": 0.019,
	"market": 0.019,
	"bar": 0.014,
	"dairy": 0.021,
	"pharmacy": 0.013,
	"workshop": 0.019,
	"gas_station": 0.024
}
const HOUSE_VARIANT_NAMES := ["urban", "rural", "fortified"]
const HOUSE_TEXTURES := [
	preload("res://assets/buildings/full/fdc_building_house_urban_two_story_063.png"),
	preload("res://assets/buildings/full/fdc_building_house_rural_two_story_063.png"),
	preload("res://assets/buildings/full/fdc_building_house_fortified_two_story_063.png")
]
const TEXTURES := {
	"hospital": preload("res://assets/buildings/full/fdc_building_hospital_063.png"),
	"market": preload("res://assets/buildings/full/fdc_building_market_063.png"),
	"bar": preload("res://assets/buildings/full/fdc_building_bar_063.png"),
	"dairy": preload("res://assets/buildings/full/fdc_building_dairy_063.png"),
	"pharmacy": preload("res://assets/buildings/full/fdc_building_pharmacy_063.png"),
	"workshop": preload("res://assets/buildings/full/fdc_building_workshop_063.png"),
	"gas_station": preload("res://assets/buildings/full/fdc_building_gas_station_063.png")
}

static func apply(root: Node3D, role: String, variant: int = 0) -> Sprite3D:
	if root == null or not has_role(role):
		return null
	_hide_previous_asset(root)
	var visual_parent := root.get_node_or_null("Roof") as Node3D
	if visual_parent == null:
		visual_parent = root
	var texture: Texture2D
	var variant_name := role
	if role == "house":
		var variant_index := posmod(variant, HOUSE_TEXTURES.size())
		texture = HOUSE_TEXTURES[variant_index] as Texture2D
		variant_name = str(HOUSE_VARIANT_NAMES[variant_index])
	else:
		texture = TEXTURES[role] as Texture2D
	var sprite := Sprite3D.new()
	sprite.name = "FullBuildingAsset063_%s_%s" % [role, variant_name]
	sprite.texture = texture
	var pixel_size := float(ROLE_PIXEL_SIZES.get(role, PIXEL_SIZE))
	sprite.pixel_size = pixel_size
	var target_global := root.to_global(Vector3(0.0, CANVAS_HALF_HEIGHT * pixel_size, 0.0))
	sprite.position = visual_parent.to_local(target_global)
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.shaded = false
	sprite.transparent = true
	sprite.double_sided = true
	sprite.add_to_group("building_asset_063")
	sprite.add_to_group("full_building_asset_063")
	sprite.add_to_group("building_asset_%s_063" % role)
	visual_parent.add_child(sprite)
	root.set_meta("building_asset_version", VERSION)
	root.set_meta("building_asset_role", role)
	root.set_meta("building_asset_kind", "full_exterior")
	root.set_meta("building_asset_variant", variant_name)
	return sprite

static func has_role(role: String) -> bool:
	return role == "house" or TEXTURES.has(role)

static func _hide_previous_asset(node: Node) -> void:
	for child in node.get_children():
		if child is Sprite3D and child.is_in_group("building_asset_063"):
			(child as Sprite3D).visible = false
		_hide_previous_asset(child)
