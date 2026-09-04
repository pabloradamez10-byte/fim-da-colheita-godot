class_name ZombieAI
extends CharacterBody2D

@export var max_health: float = 65.0
@export var move_speed: float = 72.0
@export var detection_radius: float = 360.0
@export var attack_range: float = 43.0
@export var attack_damage: float = 9.0
@export var attack_interval: float = 1.15

var health: float
var attack_cooldown := 0.0
var player: Node2D = null

func _ready() -> void:
	health = max_health
	add_to_group("zombies")
	queue_redraw()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		velocity = Vector2.ZERO
		return

	var distance := global_position.distance_to(player.global_position)
	if distance > detection_radius:
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(player.global_position)
	if distance > attack_range:
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if attack_cooldown <= 0.0 and player.has_method("take_damage"):
			player.call("take_damage", attack_damage)
			attack_cooldown = attack_interval

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var damage_ratio := clampf(health / max_health, 0.0, 1.0)
	draw_circle(Vector2(0, -8), 12.0, Color("8da07d"))
	draw_rect(Rect2(-10, 4, 20, 27), Color("4f6250"), true)
	draw_line(Vector2(-8, 30), Vector2(-10, 42), Color("343a35"), 5.0)
	draw_line(Vector2(8, 30), Vector2(10, 42), Color("343a35"), 5.0)
	draw_rect(Rect2(-15, -28, 30, 4), Color(0.12, 0.12, 0.12, 0.8), true)
	draw_rect(Rect2(-15, -28, 30 * damage_ratio, 4), Color(0.55, 0.13, 0.12, 0.9), true)
