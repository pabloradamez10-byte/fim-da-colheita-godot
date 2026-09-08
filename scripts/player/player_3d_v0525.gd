extends "res://scripts/player/player_3d_v0524.gd"

const MAX_PRODUCTION_QUEUE_0525 := 4
const RECIPE_TIMES_0525 := {
	"bandage": 3.0,
	"axe": 8.0,
	"spear": 6.0,
	"cordage": 4.0,
	"plank_bundle": 8.0,
	"stone_blade": 6.0,
	"repair_kit": 12.0
}
const RECIPE_TOOL_REQUIREMENTS_0525 := {
	"spear": "machete",
	"cordage": "machete",
	"plank_bundle": "axe",
	"stone_blade": "machete",
	"repair_kit": "axe"
}
const TOOL_CRAFT_WEAR_0525 := 0.80
const WORKBENCH_REPAIR_TIME_0525 := 10.0

var production_queue_0525: Array[Dictionary] = []
var production_serial_0525 := 0
var completed_jobs_0525 := 0
var last_completed_job_0525 := ""
var last_production_state_0525 := "idle"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_production_queue_0525(delta)

func get_craft_recipes() -> Array[Dictionary]:
	var result: Array[Dictionary] = super.get_craft_recipes()
	for i in range(result.size()):
		var recipe := result[i]
		var recipe_id := str(recipe.get("id", ""))
		recipe["duration_0525"] = get_recipe_duration_0525(recipe_id)
		recipe["tool_required_0525"] = get_recipe_tool_requirement_0525(recipe_id)
		recipe["tool_ok_0525"] = _has_required_tool_0525(recipe_id)
		recipe["queue_ok_0525"] = can_queue_craft_0525(recipe_id)
		result[i] = recipe
	return result

func get_recipe_duration_0525(recipe_id: String) -> float:
	return float(RECIPE_TIMES_0525.get(recipe_id, 5.0))

func get_recipe_tool_requirement_0525(recipe_id: String) -> String:
	return str(RECIPE_TOOL_REQUIREMENTS_0525.get(recipe_id, ""))

func _has_required_tool_0525(recipe_id: String) -> bool:
	var tool := get_recipe_tool_requirement_0525(recipe_id)
	if tool == "":
		return true
	if not owned_weapons.has(tool):
		return false
	if has_method("is_weapon_broken_0523") and is_weapon_broken_0523(tool):
		return false
	return true

func can_craft(recipe_id: String) -> bool:
	return can_queue_craft_0525(recipe_id)

func can_queue_craft_0525(recipe_id: String) -> bool:
	if production_queue_0525.size() >= MAX_PRODUCTION_QUEUE_0525:
		return false
	var recipe := _get_recipe_definition_0525(recipe_id)
	if recipe.is_empty():
		return false
	var station := str(recipe.get("station", "field"))
	if station == "workbench" and not is_at_workbench_0524():
		return false
	if not _has_required_tool_0525(recipe_id):
		return false
	return _has_available_requirements_after_reservations_0525(recipe)

func craft_recipe(recipe_id: String) -> bool:
	return queue_craft_0525(recipe_id)

func queue_craft_0525(recipe_id: String) -> bool:
	if not can_queue_craft_0525(recipe_id):
		return false
	var recipe := _get_recipe_definition_0525(recipe_id)
	production_serial_0525 += 1
	var duration := get_recipe_duration_0525(recipe_id)
	var job := {
		"uid": "craft0525:%d" % production_serial_0525,
		"kind": "craft",
		"recipe_id": recipe_id,
		"name": str(recipe.get("name", recipe_id)),
		"station": str(recipe.get("station", "field")),
		"requirements": (recipe.get("requirements", {}) as Dictionary).duplicate(true),
		"result_type": str(recipe.get("result_type", "item")),
		"result_id": str(recipe.get("result_id", "")),
		"amount": int(recipe.get("amount", 1)),
		"tool_required": get_recipe_tool_requirement_0525(recipe_id),
		"duration": duration,
		"remaining": duration,
		"started": false,
		"state": "queued"
	}
	production_queue_0525.append(job)
	last_production_state_0525 = "queued"
	last_hotbar_action_0523 = "queue:%s" % recipe_id
	_request_save_0524()
	return true

func can_workbench_repair_0524(id: String) -> bool:
	return can_queue_workbench_repair_0525(id)

func workbench_repair_weapon_0524(id: String) -> bool:
	return queue_workbench_repair_0525(id)

func can_queue_workbench_repair_0525(id: String) -> bool:
	if production_queue_0525.size() >= MAX_PRODUCTION_QUEUE_0525:
		return false
	if not owned_weapons.has(id):
		return false
	if not is_at_workbench_0524():
		return false
	if get_weapon_durability_0523(id) >= get_weapon_max_durability_0523(id) - 0.01:
		return false
	return _available_item_after_reservations_0525("repair_kit") >= 1

func queue_workbench_repair_0525(id: String) -> bool:
	if not can_queue_workbench_repair_0525(id):
		return false
	production_serial_0525 += 1
	var job := {
		"uid": "repair0525:%d" % production_serial_0525,
		"kind": "repair",
		"recipe_id": "repair:%s" % id,
		"name": "Revisão de %s" % id,
		"station": "workbench",
		"requirements": {"repair_kit": 1},
		"result_type": "repair",
		"result_id": id,
		"amount": 1,
		"tool_required": "",
		"duration": WORKBENCH_REPAIR_TIME_0525,
		"remaining": WORKBENCH_REPAIR_TIME_0525,
		"started": false,
		"state": "queued"
	}
	production_queue_0525.append(job)
	last_production_state_0525 = "queued"
	last_hotbar_action_0523 = "queue_repair:%s" % id
	_request_save_0524()
	return true

func _get_recipe_definition_0525(recipe_id: String) -> Dictionary:
	var recipes: Array[Dictionary] = super.get_craft_recipes()
	for recipe in recipes:
		if str(recipe.get("id", "")) == recipe_id:
			return recipe.duplicate(true)
	return {}

func _has_available_requirements_after_reservations_0525(recipe: Dictionary) -> bool:
	var requirements := recipe.get("requirements", {}) as Dictionary
	for raw_id in requirements.keys():
		var item_id := str(raw_id)
		if _available_item_after_reservations_0525(item_id) < int(requirements[raw_id]):
			return false
	return true

func _available_item_after_reservations_0525(item_id: String) -> int:
	var available := int(inventory.get(item_id, 0))
	for raw_job in production_queue_0525:
		var job := raw_job as Dictionary
		if bool(job.get("started", false)):
			continue
		var requirements := job.get("requirements", {}) as Dictionary
		available -= int(requirements.get(item_id, 0))
	return available

func _update_production_queue_0525(delta: float) -> void:
	if production_queue_0525.is_empty() or delta <= 0.0:
		if production_queue_0525.is_empty():
			last_production_state_0525 = "idle"
		return

	var job := production_queue_0525[0]
	var station := str(job.get("station", "field"))
	var tool_required := str(job.get("tool_required", ""))

	if station == "workbench" and not is_at_workbench_0524():
		job["state"] = "waiting_station" if not bool(job.get("started", false)) else "paused_station"
		production_queue_0525[0] = job
		last_production_state_0525 = str(job["state"])
		return

	if tool_required != "" and (not owned_weapons.has(tool_required) or is_weapon_broken_0523(tool_required)):
		job["state"] = "waiting_tool" if not bool(job.get("started", false)) else "paused_tool"
		production_queue_0525[0] = job
		last_production_state_0525 = str(job["state"])
		return

	if not bool(job.get("started", false)):
		var requirements := job.get("requirements", {}) as Dictionary
		if not _has_raw_requirements_0525(requirements):
			job["state"] = "waiting_resources"
			production_queue_0525[0] = job
			last_production_state_0525 = "waiting_resources"
			return
		_consume_requirements_0525(requirements)
		job["started"] = true
		job["state"] = "running"
		production_queue_0525[0] = job
		last_production_state_0525 = "running"
		_request_save_0524()

	job = production_queue_0525[0]
	job["state"] = "running"
	job["remaining"] = maxf(0.0, float(job.get("remaining", 0.0)) - delta)
	production_queue_0525[0] = job
	last_production_state_0525 = "running"
	if float(job.get("remaining", 0.0)) <= 0.001:
		_finish_production_job_0525(job)
		production_queue_0525.pop_front()
		_request_save_0524()

func _has_raw_requirements_0525(requirements: Dictionary) -> bool:
	for raw_id in requirements.keys():
		var item_id := str(raw_id)
		if int(inventory.get(item_id, 0)) < int(requirements[raw_id]):
			return false
	return true

func _consume_requirements_0525(requirements: Dictionary) -> void:
	for raw_id in requirements.keys():
		var item_id := str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(requirements[raw_id])

func _finish_production_job_0525(job: Dictionary) -> void:
	var kind := str(job.get("kind", "craft"))
	var result_id := str(job.get("result_id", ""))
	if kind == "repair":
		weapon_durability_0523[result_id] = get_weapon_max_durability_0523(result_id)
		if last_broken_weapon_0523 == result_id:
			last_broken_weapon_0523 = ""
		workbench_repair_count_0524 += 1
		last_completed_job_0525 = "repair:%s" % result_id
	else:
		var result_type := str(job.get("result_type", "item"))
		if result_type == "weapon":
			unlock_weapon(result_id)
		else:
			add_item(result_id, int(job.get("amount", 1)))
		var tool := str(job.get("tool_required", ""))
		if tool != "" and owned_weapons.has(tool):
			var current := get_weapon_durability_0523(tool)
			weapon_durability_0523[tool] = maxf(0.0, current - TOOL_CRAFT_WEAR_0525)
		last_craft_0524 = str(job.get("recipe_id", ""))
		craft_count_0524 += 1
		last_completed_job_0525 = last_craft_0524
	completed_jobs_0525 += 1
	last_production_state_0525 = "completed"
	last_hotbar_action_0523 = "completed:%s" % last_completed_job_0525

func get_production_queue_0525() -> Array[Dictionary]:
	return production_queue_0525.duplicate(true)

func get_production_status_0525() -> Dictionary:
	var current: Dictionary = {}
	if not production_queue_0525.is_empty():
		current = production_queue_0525[0].duplicate(true)
		var duration := maxf(0.001, float(current.get("duration", 1.0)))
		current["progress"] = clampf(1.0 - float(current.get("remaining", duration)) / duration, 0.0, 1.0)
	return {
		"queue_size": production_queue_0525.size(),
		"capacity": MAX_PRODUCTION_QUEUE_0525,
		"state": last_production_state_0525,
		"current": current,
		"completed": completed_jobs_0525,
		"last_completed": last_completed_job_0525
	}

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["production_queue_0525"] = production_queue_0525.duplicate(true)
	state["production_serial_0525"] = production_serial_0525
	state["completed_jobs_0525"] = completed_jobs_0525
	state["last_completed_job_0525"] = last_completed_job_0525
	state["last_production_state_0525"] = last_production_state_0525
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	production_queue_0525.clear()
	var raw_queue: Variant = state.get("production_queue_0525", [])
	if raw_queue is Array:
		for raw_job in raw_queue as Array:
			if raw_job is Dictionary:
				production_queue_0525.append((raw_job as Dictionary).duplicate(true))
	production_serial_0525 = int(state.get("production_serial_0525", production_queue_0525.size()))
	completed_jobs_0525 = int(state.get("completed_jobs_0525", 0))
	last_completed_job_0525 = str(state.get("last_completed_job_0525", ""))
	last_production_state_0525 = str(state.get("last_production_state_0525", "idle"))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	production_queue_0525.clear()
	production_serial_0525 = 0
	completed_jobs_0525 = 0
	last_completed_job_0525 = ""
	last_production_state_0525 = "idle"

func get_production_debug_0525() -> Dictionary:
	var result := get_production_status_0525()
	result["reserved_wood"] = int(inventory.get("wood", 0)) - _available_item_after_reservations_0525("wood")
	result["reserved_fiber"] = int(inventory.get("fiber", 0)) - _available_item_after_reservations_0525("fiber")
	result["reserved_stone"] = int(inventory.get("stone", 0)) - _available_item_after_reservations_0525("stone")
	return result
