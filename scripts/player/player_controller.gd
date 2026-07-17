class_name PlayerController
extends CharacterBody2D

@export var speed: float = 220.0

func _ready() -> void:
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

func _draw() -> void:
	# Marcador provisório do personagem para o primeiro teste técnico.
	draw_circle(Vector2.ZERO, 13.0, Color("e7c79b"))
	draw_rect(Rect2(-9.0, 7.0, 18.0, 22.0), Color("365f42"), true)
	draw_line(Vector2(-8.0, 29.0), Vector2(-9.0, 40.0), Color("30352f"), 5.0)
	draw_line(Vector2(8.0, 29.0), Vector2(9.0, 40.0), Color("30352f"), 5.0)
