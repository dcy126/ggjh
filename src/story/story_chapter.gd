extends RefCounted
class_name StoryChapter

@export var id: String
@export var name: String
@export var description: String
@export var unlock_level: int = 1
@export var map_areas: Array[String] = []
@export var main_quest: String = ""
@export var side_quests: Array[String] = []
@export var boss_battle: String = ""
@export var rewards: Dictionary = {}
@export var choices: Array[String] = []

func _init():
	if map_areas.is_empty():
		map_areas = []
	if side_quests.is_empty():
		side_quests = []
	if rewards.is_empty():
		rewards = {}
	if choices.is_empty():
		choices = []

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"unlock_level": unlock_level,
		"map_areas": map_areas,
		"main_quest": main_quest,
		"side_quests": side_quests,
		"boss_battle": boss_battle,
		"rewards": rewards,
		"choices": choices
	}

func from_dict(data: Dictionary) -> StoryChapter:
	id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	unlock_level = data.get("unlock_level", 1)
	map_areas = data.get("map_areas", [])
	main_quest = data.get("main_quest", "")
	side_quests = data.get("side_quests", [])
	boss_battle = data.get("boss_battle", "")
	rewards = data.get("rewards", {})
	choices = data.get("choices", [])
	return self