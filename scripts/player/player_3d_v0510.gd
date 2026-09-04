extends "res://scripts/player/player_3d_v059.gd"

const SPRITE_PIXEL_SIZE_0510 := 0.050
const SPRITE_CENTER_Y_0510 := 0.90

func _build_visual() -> void:
	super._build_visual()
	if survivor_sprite != null:
		survivor_sprite.pixel_size = SPRITE_PIXEL_SIZE_0510
		survivor_sprite.position.y = SPRITE_CENTER_Y_0510
		_apply_side_facing()

func _update_character_animation(delta: float, running: bool) -> void:
	super._update_character_animation(delta, running)
	_apply_side_facing()

func _start_sprite_attack() -> void:
	super._start_sprite_attack()
	_apply_side_facing()

func _apply_side_facing() -> void:
	if survivor_sprite == null:
		return
	# O atlas 0.5.9 trouxe as duas linhas laterais apontando visualmente para a esquerda.
	# Mantemos as animações existentes e espelhamos apenas quando o movimento é para a direita.
	survivor_sprite.flip_h = sprite_direction == "right"

func get_motion_debug() -> Dictionary:
	var result: Dictionary = super.get_motion_debug()
	result["sprite_pixel_size"] = survivor_sprite.pixel_size if survivor_sprite != null else 0.0
	result["sprite_flip_h"] = survivor_sprite.flip_h if survivor_sprite != null else false
	result["sprite_center_y"] = survivor_sprite.position.y if survivor_sprite != null else 0.0
	return result
