extends "res://scripts/player/player_3d_v0510.gd"

const WALK_NOISE_RADIUS_0519 := 4.0
const RUN_NOISE_RADIUS_0519 := 9.0
const HURT_NOISE_RADIUS_0519 := 7.5

var footstep_noise_timer_0519 := 0.0
var bleeding_0519 := 0.0
var pain_0519 := 0.0
var last_noise_kind_0519 := ""

func _physics_process(delta: float) -> void:
	footstep_noise_timer_0519 = maxf(0.0, footstep_noise_timer_0519 - delta)
	super._physics_process(delta)
	_update_condition_0519(delta)
	_emit_movement_noise_0519()

func _emit_movement_noise_0519() -> void:
	if footstep_noise_timer_0519 > 0.0:
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed < 1.0:
		return
	var running := speed > 6.15
	if running:
		_emit_noise_0519(RUN_NOISE_RADIUS_0519, "run")
		footstep_noise_timer_0519 = 0.34
	else:
		_emit_noise_0519(WALK_NOISE_RADIUS_0519, "walk")
		footstep_noise_timer_0519 = 0.78

func _attack() -> void:
	var cooldown_before := attack_cooldown
	var weapon := get_equipped_weapon()
	super._attack()
	if attack_cooldown <= cooldown_before:
		return
	match weapon:
		"pistol":
			_emit_noise_0519(30.0, "pistol")
		"shotgun":
			_emit_noise_0519(46.0, "shotgun")
		"axe":
			_emit_noise_0519(7.5, "axe")
		"spear":
			_emit_noise_0519(4.5, "spear")
		_:
			_emit_noise_0519(5.5, "machete")

func take_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	super.take_damage(amount)
	if health <= 0.0:
		return
	pain_0519 = minf(100.0, pain_0519 + amount * 1.45)
	bleeding_0519 = minf(8.0, bleeding_0519 + maxf(0.0, amount - 4.0) * 0.085)
	stamina = maxf(0.0, stamina - amount * 0.65)
	_emit_noise_0519(HURT_NOISE_RADIUS_0519, "hurt")

func _update_condition_0519(delta: float) -> void:
	pain_0519 = maxf(0.0, pain_0519 - 0.70 * delta)
	bleeding_0519 = maxf(0.0, bleeding_0519 - 0.018 * delta)
	if bleeding_0519 > 0.01:
		health = maxf(0.0, health - bleeding_0519 * 0.045 * delta)
	if pain_0519 >= 68.0:
		stamina = maxf(0.0, stamina - 1.6 * delta)
	if health <= 0.0:
		_respawn()

func use_inventory_item(id: String) -> bool:
	var used := super.use_inventory_item(id)
	if used and id == "bandage":
		bleeding_0519 = maxf(0.0, bleeding_0519 - 4.5)
		pain_0519 = maxf(0.0, pain_0519 - 22.0)
	return used

func _emit_noise_0519(radius: float, kind: String) -> void:
	last_noise_kind_0519 = kind
	if world != null and world.has_method("emit_noise_0519"):
		world.call("emit_noise_0519", global_position, radius, kind, self)

func get_vitals() -> Dictionary:
	var result := super.get_vitals()
	result["pain"] = pain_0519
	result["bleeding"] = bleeding_0519
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["pain_0519"] = pain_0519
	state["bleeding_0519"] = bleeding_0519
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	pain_0519 = float(state.get("pain_0519", 0.0))
	bleeding_0519 = float(state.get("bleeding_0519", 0.0))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	pain_0519 = 0.0
	bleeding_0519 = 0.0
	last_noise_kind_0519 = ""

func _respawn() -> void:
	super._respawn()
	pain_0519 = 0.0
	bleeding_0519 = 0.0

func get_survival_debug_0519() -> Dictionary:
	return {
		"pain": pain_0519,
		"bleeding": bleeding_0519,
		"last_noise": last_noise_kind_0519,
		"stamina": stamina
	}
