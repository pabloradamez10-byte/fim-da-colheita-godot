extends "res://scripts/entities/zombie_3d_v067.gd"

const INFECTED_ATLAS_068: Texture2D = preload("res://assets/zombies/fdc_infected_atlas_068.png")
var travel_phase_068 := 0.0

func _ready() -> void:
	super._ready()
	set_meta("zombie_visual_version", "0.6.8")
	set_meta("zombie_visual_source", "fdc_infected_atlas_068.png")
	add_to_group("infected_visual_068")

func _build_sprite_0537() -> void:
	if sprite_0537 != null and is_instance_valid(sprite_0537):
		sprite_0537.queue_free()
	sprite_0537 = Sprite3D.new()
	sprite_0537.name = "InfectedSprite068"
	sprite_0537.texture = INFECTED_ATLAS_068
	sprite_0537.region_enabled = true
	sprite_0537.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0537.shaded = false
	sprite_0537.transparent = true
	sprite_0537.double_sided = true
	sprite_0537.pixel_size = 2.25 / (float(INFECTED_ATLAS_068.get_height()) / 5.0)
	sprite_0537.position = Vector3(0.0, 1.125, 0.0)
	sprite_0537.add_to_group("zombie_sprite_0537")
	add_child(sprite_0537)
	_refresh_sprite_frame_0537()

func _refresh_sprite_frame_0537() -> void:
	if sprite_0537 == null or not is_instance_valid(sprite_0537):
		return
	var cell := Vector2(float(INFECTED_ATLAS_068.get_width()) / 8.0, float(INFECTED_ATLAS_068.get_height()) / 5.0)
	sprite_0537.region_rect = Rect2(Vector2(float(animation_frame_0537) * cell.x, float(clampi(profile_0537, 0, 4)) * cell.y), cell)
	# Initial art pack has one three-quarter view, mirrored for leftward travel.
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		var lateral_speed := velocity.dot(camera.global_basis.x)
		if absf(lateral_speed) > 0.08:
			sprite_0537.flip_h = lateral_speed < 0.0

func _update_sprite_animation_0537(delta: float) -> void:
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed <= 0.08:
		animation_frame_0537 = 0
	else:
		travel_phase_068 = fposmod(travel_phase_068 + speed * maxf(delta, 0.0) / 2.2, 1.0)
		animation_frame_0537 = mini(7, int(travel_phase_068 * 8.0))
	_refresh_sprite_frame_0537()
