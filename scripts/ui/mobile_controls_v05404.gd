extends "res://scripts/ui/mobile_controls_v05401.gd"

func _ready() -> void:
	super._ready()
	add_to_group("mobile_feedback_05404")
	attack_button.pressed.connect(_emit_mobile_feedback_05404.bind("attack", ""))
	interact_button.pressed.connect(_emit_mobile_feedback_05404.bind("action", "AÇÃO"))
	weapon_button.pressed.connect(_emit_mobile_feedback_05404.bind("weapon", "ARMA"))
	sprint_button.toggled.connect(_on_sprint_toggled_05404)

func _emit_mobile_feedback_05404(kind: String, text: String) -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("emit_feedback_05404"):
		scene.call("emit_feedback_05404", kind, text, 0.72)

func _on_sprint_toggled_05404(enabled: bool) -> void:
	if enabled:
		_emit_mobile_feedback_05404("sprint", "CORRER")

func set_vehicle_mode_0530(enabled: bool) -> void:
	super.set_vehicle_mode_0530(enabled)
	if enabled:
		_emit_mobile_feedback_05404("action", "VEÍCULO")

func get_mobile_feedback_debug_05404() -> Dictionary:
	return {
		"version": "0.5.40.4",
		"feedback_connected": true,
		"attack_visible": attack_button.visible,
		"vehicle_mode": vehicle_mode_0530,
		"interact_text": interact_button.text
	}
