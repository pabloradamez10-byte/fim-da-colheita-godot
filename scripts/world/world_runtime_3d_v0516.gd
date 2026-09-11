extends "res://scripts/world/world_runtime_3d_v0515.gd"

const INTERACT_DOOR_RANGE_0516 := 3.05
const INTERACT_LOOT_RANGE_0516 := 1.95
const INTERACT_WINDOW_RANGE_0516 := 1.15

func _pick_special_interactable_0513(pos: Vector3, target_player: Node) -> int:
	# 0.5.16: a porta externa deve responder mesmo quando varanda/degrau ou câmera
	# deixam o player ligeiramente fora do ponto ideal. Porta continua tendo prioridade
	# absoluta; janelas só respondem quando o jogador está realmente junto delas.
	var facing := Vector3.ZERO
	var raw_facing: Variant = target_player.get("last_move_dir") if target_player != null else null
	if raw_facing is Vector3:
		facing = raw_facing as Vector3
		facing.y = 0.0
		if facing.length() > 0.01:
			facing = facing.normalized()

	for category in ["door", "loot", "window"]:
		var best_index := -1
		var best_distance := INF
		var max_range: float = INTERACT_DOOR_RANGE_0516 if category == "door" else (INTERACT_LOOT_RANGE_0516 if category == "loot" else INTERACT_WINDOW_RANGE_0516)
		for i in range(interactables.size()):
			var data := interactables[i] as Dictionary
			var kind := str(data.get("type", ""))
			if category == "door" and kind != "door":
				continue
			if category == "window" and kind != "window":
				continue
			if category == "loot" and not kind.begins_with("loot_"):
				continue
			var node_value: Variant = data.get("node")
			# Interactables são persistidos em uma lista compartilhada por muitas versões.
			# Alguns nós podem ter sido queue_free entre um painel/POI e a próxima interação.
			# Testar `is Node3D` diretamente em uma referência já liberada gera erro no Godot.
			if node_value != null and typeof(node_value) == TYPE_OBJECT and not is_instance_valid(node_value):
				continue
			var target_pos := data.get("position", Vector3.ZERO) as Vector3
			var delta := target_pos - pos
			delta.y = 0.0
			var distance := delta.length()
			if distance > max_range:
				continue
			# Portas não exigem orientação: no touchscreen, proximidade é suficiente.
			# Loot/janela continuam exigindo estar aproximadamente à frente.
			if category != "door" and facing.length() > 0.01 and distance > 0.72 and delta.length() > 0.01:
				if facing.dot(delta.normalized()) < -0.05:
					continue
			if distance < best_distance:
				best_distance = distance
				best_index = i
		if best_index >= 0:
			return best_index
	return -1

func get_debug_0516() -> Dictionary:
	var doors := 0
	for raw in interactables:
		var data := raw as Dictionary
		if str(data.get("type", "")) == "door":
			doors += 1
	return {
		"door_range": INTERACT_DOOR_RANGE_0516,
		"registered_doors": doors,
		"walkable_thresholds": get_tree().get_nodes_in_group("walkable_threshold_0516").size()
	}
