extends "res://scripts/ui/inventory_ui_v0536.gd"

const ICON_ATLAS_068: Texture2D = preload("res://assets/items/fdc_item_atlas_068.png")
const ICON_IDS_068 := ["wood", "stone", "fiber", "food", "water", "bandage", "antiseptic", "ammo_9mm", "shells", "plank", "cordage", "stone_blade", "repair_kit", "gasoline", "axe", "machete"]

func _add_item_row(id: String, amount: int) -> void:
	super._add_item_row(id, amount)
	if items_box.get_child_count() == 0 or not ICON_IDS_068.has(id):
		return
	var row := items_box.get_child(items_box.get_child_count() - 1) as HBoxContainer
	_prepend_icon_068(row, id)

func _add_weapon_row(id: String, equipped: bool) -> void:
	super._add_weapon_row(id, equipped)
	if not ICON_IDS_068.has(id) or weapons_box.get_child_count() == 0:
		return
	var container := weapons_box.get_child(weapons_box.get_child_count() - 1)
	if container.get_child_count() > 0:
		_prepend_icon_068(container.get_child(0) as HBoxContainer, id)

func _prepend_icon_068(row: HBoxContainer, id: String) -> void:
	if row == null:
		return
	var index := ICON_IDS_068.find(id)
	var cell := Vector2(float(ICON_ATLAS_068.get_width()) / 4.0, float(ICON_ATLAS_068.get_height()) / 4.0)
	var atlas := AtlasTexture.new()
	atlas.atlas = ICON_ATLAS_068
	atlas.region = Rect2(Vector2(float(index % 4) * cell.x, float(index / 4) * cell.y), cell)
	var icon := TextureRect.new()
	icon.name = "ItemIcon068"
	icon.texture = atlas
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	row.move_child(icon, 0)
	# Preserve room for the existing use/equip button and readable item label.
	for child in row.get_children():
		if child is Label:
			(child as Label).custom_minimum_size.x = 118.0
			(child as Label).size_flags_horizontal = Control.SIZE_EXPAND_FILL
