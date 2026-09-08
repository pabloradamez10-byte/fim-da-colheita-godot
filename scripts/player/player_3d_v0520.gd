extends "res://scripts/player/player_3d_v0519.gd"

const INFECTION_WARN_0520 := 25.0
const INFECTION_SICK_0520 := 55.0
const INFECTION_CRITICAL_0520 := 82.0
const DEATH_DROP_RATIO_0520 := 0.35

var infection_0520 := 0.0
var last_death_bag_0520 := ""

func _ready() -> void:
	super._ready()
	if not inventory.has("antiseptic"):
		inventory["antiseptic"] = 0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_infection_0520(delta)

func take_zombie_damage_0520(amount: float, zombie_variant: int = 0) -> void:
	if amount <= 0.0:
		return
	var lethal := health - amount <= 0.0
	take_damage(amount)
	if lethal:
		return
	var exposure := amount * (0.30 + float(clampi(zombie_variant, 0, 3)) * 0.035)
	exposure += bleeding_0519 * 0.16
	infection_0520 = minf(100.0, infection_0520 + exposure)

func _update_infection_0520(delta: float) -> void:
	# Ferimento leve e já controlado pode limpar lentamente; infecção estabelecida
	# exige cuidado e passa a interferir no corpo inteiro.
	if infection_0520 > 0.0 and infection_0520 < INFECTION_WARN_0520 and bleeding_0519 < 0.25:
		infection_0520 = maxf(0.0, infection_0520 - 0.035 * delta)
	if infection_0520 >= INFECTION_WARN_0520:
		pain_0519 = minf(100.0, pain_0519 + 0.12 * delta)
	if infection_0520 >= INFECTION_SICK_0520:
		stamina = maxf(0.0, stamina - 0.75 * delta)
	if infection_0520 >= INFECTION_CRITICAL_0520:
		health = maxf(0.0, health - 0.32 * delta)
		thirst = maxf(0.0, thirst - 0.18 * delta)
	if health <= 0.0:
		_respawn()

func use_inventory_item(id: String) -> bool:
	if id == "antiseptic":
		var count := int(inventory.get("antiseptic", 0))
		if count <= 0:
			return false
		inventory["antiseptic"] = count - 1
		infection_0520 = maxf(0.0, infection_0520 - 38.0)
		bleeding_0519 = maxf(0.0, bleeding_0519 - 1.15)
		pain_0519 = maxf(0.0, pain_0519 - 8.0)
		return true
	return super.use_inventory_item(id)

func _respawn() -> void:
	var death_position := global_position
	var dropped := _extract_death_drop_0520()
	last_death_bag_0520 = ""
	if world != null and world.has_method("register_player_death_0520"):
		last_death_bag_0520 = str(world.call("register_player_death_0520", death_position, dropped))
	super._respawn()
	infection_0520 = 0.0
	health = 82.0
	stamina = 58.0
	hunger = minf(hunger, 68.0)
	thirst = minf(thirst, 68.0)
	if world != null and world.has_method("get_respawn_position_0520"):
		var respawn: Variant = world.call("get_respawn_position_0520")
		if respawn is Vector3:
			global_position = respawn as Vector3
	if world != null and world.has_method("save_game"):
		world.call_deferred("save_game")

func _extract_death_drop_0520() -> Dictionary:
	var dropped: Dictionary = {}
	for id in ["wood", "stone", "fiber", "food", "water", "bandage", "ammo_9mm", "shells", "antiseptic"]:
		var amount := int(inventory.get(id, 0))
		if amount < 2:
			continue
		var loss := int(floor(float(amount) * DEATH_DROP_RATIO_0520))
		loss = maxi(1, loss)
		loss = mini(loss, amount)
		if loss <= 0:
			continue
		inventory[id] = amount - loss
		dropped[id] = loss
	return dropped

func get_vitals() -> Dictionary:
	var result := super.get_vitals()
	result["infection"] = infection_0520
	return result

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var antiseptic := int(inventory.get("antiseptic", 0))
	if antiseptic > 0:
		result += " | Antissép. %d" % antiseptic
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["infection_0520"] = infection_0520
	state["last_death_bag_0520"] = last_death_bag_0520
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	infection_0520 = float(state.get("infection_0520", 0.0))
	last_death_bag_0520 = str(state.get("last_death_bag_0520", ""))
	if not inventory.has("antiseptic"):
		inventory["antiseptic"] = 0

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	infection_0520 = 0.0
	last_death_bag_0520 = ""
	inventory["antiseptic"] = 0

func get_survival_debug_0520() -> Dictionary:
	return {
		"infection": infection_0520,
		"pain": pain_0519,
		"bleeding": bleeding_0519,
		"stamina": stamina,
		"last_death_bag": last_death_bag_0520,
		"antiseptic": int(inventory.get("antiseptic", 0))
	}
