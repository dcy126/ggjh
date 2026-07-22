extends Resource
class_name FormData

@export var form_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var stat_modifiers: Dictionary = {}
@export var skills: Array[String] = []
@export var ai_behavior: String = "balanced"
@export var max_duration: int = -1  # -1为永久
@export var visual_effect: String = ""
@export var particle_effect: String = ""

func _init():
	if stat_modifiers.is_empty():
		stat_modifiers = {}
	if skills.is_empty():
		skills = []

func get_data() -> Dictionary:
	return {
		"form_id": form_id,
		"name": name,
		"description": description,
		"stat_modifiers": stat_modifiers,
		"skills": skills,
		"ai_behavior": ai_behavior,
		"max_duration": max_duration,
		"visual_effect": visual_effect,
		"particle_effect": particle_effect
	}