extends Node3D

var half_size := Vector2(7.4, 6.3)
var roof_node: Node3D
var upper_floor_node: Node3D
var roof_hidden := false
var upper_hidden := false

func _physics_process(_delta: float) -> void:
	refresh_cutaway_063()

func refresh_cutaway_063(player_override: Node3D = null) -> void:
	if roof_node == null or not is_instance_valid(roof_node):
		roof_node = get_node_or_null("Roof") as Node3D
	if upper_floor_node == null or not is_instance_valid(upper_floor_node):
		upper_floor_node = get_node_or_null("UpperFloor063") as Node3D
	if roof_node == null:
		return
	var player := player_override
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null or not is_instance_valid(player):
		return
	var local_player := to_local(player.global_position)
	var inside := absf(local_player.x) <= half_size.x and absf(local_player.z) <= half_size.y and local_player.y < 7.2
	roof_hidden = inside
	roof_node.visible = not inside
	var hide_upper := inside and local_player.y < 2.75
	upper_hidden = hide_upper
	if upper_floor_node != null:
		upper_floor_node.visible = not hide_upper
