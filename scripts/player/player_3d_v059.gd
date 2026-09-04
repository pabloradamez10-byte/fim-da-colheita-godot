extends "res://scripts/player/player_3d_v058.gd"

const SpriteAtlasData = preload("res://scripts/assets/survivor_sprite_atlas_v059.gd")
const GROUND_Y_059 := 0.20

var survivor_sprite: AnimatedSprite3D
var sprite_direction := "down"
var sprite_attack_timer := 0.0
var sprite_ready := false

func _build_visual() -> void:
	visual_root = Node3D.new()
	visual_root.name = "CharacterVisual2D"
	add_child(visual_root)

	var atlas: Texture2D = SpriteAtlasData.build_texture()
	survivor_sprite = AnimatedSprite3D.new()
	survivor_sprite.name = "SurvivorPixelSprite"
	survivor_sprite.sprite_frames = _build_sprite_frames(atlas)
	survivor_sprite.position = Vector3(0.0, 1.03, 0.0)
	survivor_sprite.pixel_size = 0.034
	survivor_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	survivor_sprite.shaded = false
	survivor_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	visual_root.add_child(survivor_sprite)
	survivor_sprite.play("idle_down")
	sprite_ready = atlas != null

	# Compatibilidade com o restante do inventário/equipamento: o visual da arma agora
	# já está incorporado ao sprite sheet, então o anchor 3D existe mas fica vazio.
	weapon_anchor = Node3D.new()
	weapon_anchor.name = "SpriteWeaponCompatibilityAnchor"
	visual_root.add_child(weapon_anchor)
	weapon_anchor.visible = false

func _build_sprite_frames(atlas: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	if atlas == null:
		return frames
	var directions := ["up", "right", "down", "left"]
	for row in range(4):
		var dir_name: String = directions[row]
		var idle_name := "idle_%s" % dir_name
		frames.add_animation(idle_name)
		frames.set_animation_loop(idle_name, true)
		frames.set_animation_speed(idle_name, 1.0)
		frames.add_frame(idle_name, SpriteAtlasData.frame(atlas, 0, row))

		var walk_name := "walk_%s" % dir_name
		frames.add_animation(walk_name)
		frames.set_animation_loop(walk_name, true)
		frames.set_animation_speed(walk_name, 8.2)
		for col in range(1, 5):
			frames.add_frame(walk_name, SpriteAtlasData.frame(atlas, col, row))

		var run_name := "run_%s" % dir_name
		frames.add_animation(run_name)
		frames.set_animation_loop(run_name, true)
		frames.set_animation_speed(run_name, 12.5)
		for col in range(1, 5):
			frames.add_frame(run_name, SpriteAtlasData.frame(atlas, col, row))

		var attack_name := "attack_%s" % dir_name
		frames.add_animation(attack_name)
		frames.set_animation_loop(attack_name, false)
		frames.set_animation_speed(attack_name, 12.0)
		for col in range(5, 8):
			frames.add_frame(attack_name, SpriteAtlasData.frame(atlas, col, row))
	return frames

func _physics_process(delta: float) -> void:
	sprite_attack_timer = maxf(0.0, sprite_attack_timer - delta)
	super._physics_process(delta)
	# A cena 3D antiga nascia em Y=0.75 sem gravidade, fazendo o personagem flutuar.
	# O capsule collider tem a base junto da origem, então mantemos a raiz na superfície.
	global_position.y = GROUND_Y_059
	if visual_root != null:
		visual_root.position.y = 0.0

func _update_character_animation(_delta: float, running: bool) -> void:
	if survivor_sprite == null or not sprite_ready:
		return
	if movement_amount > 0.025:
		sprite_direction = _sprite_direction_from_world(last_move_dir)
	if sprite_attack_timer > 0.0:
		return
	var anim := "idle_%s" % sprite_direction
	if movement_amount > 0.055:
		anim = ("run_%s" if running else "walk_%s") % sprite_direction
	if survivor_sprite.animation != anim or not survivor_sprite.is_playing():
		survivor_sprite.play(anim)

func _sprite_direction_from_world(dir: Vector3) -> String:
	# Inverte a projeção isométrica usada para converter o analógico em vetor 3D.
	var screen_x: float = (dir.x - dir.z) * 0.5
	var screen_y: float = (dir.x + dir.z) * 0.5
	if absf(screen_x) > absf(screen_y):
		return "right" if screen_x > 0.0 else "left"
	return "down" if screen_y > 0.0 else "up"

func _animate_weapon_swing() -> void:
	_start_sprite_attack()

func _start_sprite_attack() -> void:
	if survivor_sprite == null or not sprite_ready:
		return
	sprite_direction = _sprite_direction_from_world(last_move_dir)
	sprite_attack_timer = 0.30
	survivor_sprite.play("attack_%s" % sprite_direction)

func _attack() -> void:
	if attack_cooldown > 0.0:
		return
	_face_soft_target()
	var before: float = attack_cooldown
	super._attack()
	# Armas de fogo não chamam o swing do melee, mas ainda precisam de feedback visual.
	if attack_cooldown > before and sprite_attack_timer <= 0.0:
		_start_sprite_attack()

func _face_soft_target() -> void:
	super._face_soft_target()
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() > 0.01:
		last_move_dir = forward.normalized()

func _refresh_weapon_visual() -> void:
	# As poses/armas do survivor estão no sprite sheet; evita reconstruir cubos 3D na mão.
	pass

func get_motion_debug() -> Dictionary:
	return {
		"speed": Vector2(velocity.x, velocity.z).length(),
		"movement_amount": movement_amount,
		"sprite_character": survivor_sprite != null,
		"sprite_ready": sprite_ready,
		"sprite_direction": sprite_direction,
		"ground_y": global_position.y,
		"weapon_anchor_parent": weapon_anchor.get_parent().name if weapon_anchor != null else ""
	}
