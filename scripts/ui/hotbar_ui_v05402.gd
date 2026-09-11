extends "res://scripts/ui/hotbar_ui_v05401.gd"

const ITEM_ATLAS_05402: Texture2D = preload("res://assets/visual_rework/fdc_item_atlas_05402.svg")
const ITEM_TILE_05402 := Vector2i(64, 64)
const ITEM_INDEX_05402 := {
	"machete": 0,
	"axe": 1,
	"spear": 2,
	"pistol": 3,
	"shotgun": 4,
	"bandage": 5,
	"water": 6,
	"food": 7,
	"antiseptic": 8,
	"raw_game_meat": 9,
	"cooked_game_meat": 10,
	"animal_hide": 11,
	"feathers": 12,
	"wood": 13,
	"stone": 14,
	"fiber": 15
}

var item_icons_05402: Array[TextureRect] = []

func _ready() -> void:
	super._ready()
	add_to_group("hotbar_asset_rework_05402")
	_build_item_icons_05402()
	_refresh_slots_0523()

func _build_item_icons_05402() -> void:
	item_icons_05402.clear()
	for button in buttons:
		var icon := TextureRect.new()
		icon.name = "ItemIcon05402"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(maxf(4.0, button.size.x - 34.0), 5.0)
		icon.size = Vector2(29.0, 29.0)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.visible = false
		button.add_child(icon)
		item_icons_05402.append(icon)

func _refresh_slots_0523() -> void:
	super._refresh_slots_0523()
	if item_icons_05402.is_empty():
		return
	for i in range(item_icons_05402.size()):
		var icon := item_icons_05402[i]
		if i >= slots_0523.size():
			icon.visible = false
			continue
		var item_id := str(slots_0523[i].get("id", ""))
		if not ITEM_INDEX_05402.has(item_id):
			icon.visible = false
			continue
		var index := int(ITEM_INDEX_05402[item_id])
		var atlas := AtlasTexture.new()
		atlas.atlas = ITEM_ATLAS_05402
		atlas.region = Rect2(
			float((index % 4) * ITEM_TILE_05402.x),
			float(int(index / 4) * ITEM_TILE_05402.y),
			float(ITEM_TILE_05402.x),
			float(ITEM_TILE_05402.y)
		)
		icon.texture = atlas
		icon.visible = true
		icon.modulate = Color.WHITE if not buttons[i].disabled else Color(0.65, 0.65, 0.62, 0.55)

func _refresh_layout_0523() -> void:
	super._refresh_layout_0523()
	for i in range(mini(buttons.size(), item_icons_05402.size())):
		var button := buttons[i]
		var icon := item_icons_05402[i]
		icon.position = Vector2(maxf(4.0, button.size.x - 34.0), 5.0)

func get_item_asset_debug_05402() -> Dictionary:
	var visible_count := 0
	for icon in item_icons_05402:
		if icon.visible:
			visible_count += 1
	return {
		"version": "0.5.40.2",
		"atlas": "fdc_item_atlas_05402.svg",
		"registered_items": ITEM_INDEX_05402.size(),
		"slots": item_icons_05402.size(),
		"visible_icons": visible_count,
		"tile": "64x64"
	}
