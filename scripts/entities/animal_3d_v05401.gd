extends "res://scripts/entities/animal_3d_v0538.gd"

const ANIMAL_ATLAS_05401: Texture2D = preload("res://assets/visual_rework/fdc_animal_atlas_05401.svg")
const ANIMAL_TILE_05401 := Vector2i(96, 96)
const ANIMAL_DIRECTION_COUNT_05401 := 8
const ANIMAL_ROWS_05401 := {"rabbit":0,"deer":1,"boar":2,"chicken":3}
var animal_sprite_05401: Sprite3D = null

func _build_visual_0538() -> void:
	animal_sprite_05401 = Sprite3D.new()
	animal_sprite_05401.name = "AnimalSprite05401"
	animal_sprite_05401.texture = ANIMAL_ATLAS_05401
	animal_sprite_05401.region_enabled = true
	animal_sprite_05401.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	animal_sprite_05401.shaded = false
	animal_sprite_05401.transparent = true
	animal_sprite_05401.double_sided = true
	animal_sprite_05401.pixel_size = _animal_pixel_size_05401()
	animal_sprite_05401.position = Vector3(0.0, _animal_sprite_height_05401(), 0.0)
	animal_sprite_05401.add_to_group("animal_sprite_05401")
	animal_sprite_05401.add_to_group("animal_high_detail_05401")
	add_child(animal_sprite_05401)
	_refresh_animal_sprite_05401()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_refresh_animal_sprite_05401()

func _direction_index_05401(yaw: float) -> int:
	return posmod(int(round(fposmod(yaw, TAU) / (PI * 0.25))), ANIMAL_DIRECTION_COUNT_05401)

func _refresh_animal_sprite_05401() -> void:
	if animal_sprite_05401 == null: return
	var row := int(ANIMAL_ROWS_05401.get(species_id_0538,0))
	var direction := _direction_index_05401(rotation.y)
	animal_sprite_05401.region_rect = Rect2(float(direction*ANIMAL_TILE_05401.x),float(row*ANIMAL_TILE_05401.y),float(ANIMAL_TILE_05401.x),float(ANIMAL_TILE_05401.y))
	set_meta("animal_visual_version","0.5.40.1")
	set_meta("animal_direction_05401",direction)
	set_meta("animal_art_row_05401",row)

func _animal_pixel_size_05401() -> float:
	match species_id_0538:
		"rabbit": return 0.0094
		"deer": return 0.0176
		"boar": return 0.0139
		"chicken": return 0.0088
		_: return 0.0107

func _animal_sprite_height_05401() -> float:
	match species_id_0538:
		"rabbit": return 0.58
		"deer": return 1.02
		"boar": return 0.76
		"chicken": return 0.54
		_: return 0.65

func _apply_dead_pose_0538() -> void:
	global_position.y=0.27
	if collision_0538!=null: collision_0538.set_deferred("disabled",true)
	if animal_sprite_05401!=null:
		animal_sprite_05401.rotation.z=deg_to_rad(78.0)
		animal_sprite_05401.modulate=Color(0.72,0.72,0.72,1.0)
		animal_sprite_05401.position.y=0.35

func get_visual_rework_debug_05401() -> Dictionary:
	return {"atlas":"fdc_animal_atlas_05401.svg","species":ANIMAL_ROWS_05401.size(),"directions":ANIMAL_DIRECTION_COUNT_05401,"tile_width":ANIMAL_TILE_05401.x,"tile_height":ANIMAL_TILE_05401.y,"high_detail":true}
