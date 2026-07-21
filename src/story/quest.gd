extends RefCounted
class_name Quest

@export var id: String
@export var name: String
@export var description: String
@export var chapter: int
@export var type: String = "主线"
@export var objectives: Array[Dictionary] = []
@export var rewards: Dictionary = {}
@export var choices: Array[String] = []
@export var unlock_chapter: int = 0
@export var repeatable: bool = false
@export var reset_type: String = ""
@export var hidden: bool = false
@export var trigger_probability: float = 1.0
@export var trigger_map: String = ""
@export var trigger_time: String = ""
@export var prerequisites: Array[String] = []
@export var is_completed: bool = false
@export var current_objective: int = 0
@export var progress: Dictionary = {}

func _init():
	if objectives.is_empty():
		objectives = []
	if rewards.is_empty():
		rewards = {}
	if choices.is_empty():
		choices = []
	if prerequisites.is_empty():
		prerequisites = []
	if progress.is_empty():
		progress = {}

func get_current_objective() -> Dictionary:
	if current_objective < objectives.size():
		return objectives[current_objective]
	return {}

func advance_objective():
	current_objective += 1
	if current_objective >= objectives.size():
		is_completed = true

func check_prerequisites(player_data: PlayerData) -> bool:
	for prereq in prerequisites:
		if not player_data.completed_quests.has(prereq):
			return false
	return true

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"chapter": chapter,
		"type": type,
		"objectives": objectives,
		"rewards": rewards,
		"choices": choices,
		"unlock_chapter": unlock_chapter,
		"repeatable": repeatable,
		"reset_type": reset_type,
		"hidden": hidden,
		"trigger_probability": trigger_probability,
		"trigger_map": trigger_map,
		"trigger_time": trigger_time,
		"prerequisites": prerequisites,
		"is_completed": is_completed,
		"current_objective": current_objective,
		"progress": progress
	}

func from_dict(data: Dictionary) -> Quest:
	id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	chapter = data.get("chapter", 1)
	type = data.get("type", "主线")
	objectives = data.get("objectives", [])
	rewards = data.get("rewards", {})
	choices = data.get("choices", [])
	unlock_chapter = data.get("unlock_chapter", 0)
	repeatable = data.get("repeatable", false)
	reset_type = data.get("reset_type", "")
	hidden = data.get("hidden", false)
	trigger_probability = data.get("trigger_probability", 1.0)
	trigger_map = data.get("trigger_map", "")
	trigger_time = data.get("trigger_time", "")
	prerequisites = data.get("prerequisites", [])
	is_completed = data.get("is_completed", false)
	current_objective = data.get("current_objective", 0)
	progress = data.get("progress", {})
	return self