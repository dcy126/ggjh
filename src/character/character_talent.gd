extends Resource
class_name CharacterTalent

@export var id: String
@export var name: String
@export var description: String = ""
@export var icon: String = ""
@export var talent_type: String = "被动"
@export var trigger_type: String = "常驻"
@export var trigger_chance: float = 1.0
@export var max_level: int = 1
@export var current_level: int = 0
@export var unlock_level: int = 0
@export var unlock_breakthrough: int = 0
@export var exclusive_character: String = ""
@export var exclusive_sect: String = ""
@export var is_ultimate: bool = false

## 效果参数
@export var effects: Array[Dictionary] = []

## 前置天赋
@export var prerequisites: Array[String] = []

## 互斥天赋
@export var conflicts: Array[String] = []

## 标签
@export var tags: Array[String] = []

func _init():
	if effects.is_empty():
		effects = [{"type": "属性加成", "params": {}, "level_scaling": 0.1}]

func can_unlock(character: CharacterData) -> bool:
	if character.potential_level < unlock_level:
		return false
	if character.potential_breakthrough < unlock_breakthrough:
		return false
	if exclusive_character and character.id != exclusive_character:
		return false
	if exclusive_sect and character.current_sect != exclusive_sect:
		return false
	for pre_id in prerequisites:
		if not character.has_talent(pre_id):
			return false
	for con_id in conflicts:
		if character.has_talent(con_id):
			return false
	return true

func unlock(character: CharacterData):
	if can_unlock(character):
		current_level = 1
		character.talents.append(self)

func upgrade(character: CharacterData) -> bool:
	if current_level >= max_level:
		return false
	if not can_unlock(character):
		return false
	current_level += 1
	return true

func get_effect_params(level: int = -1) -> Dictionary:
	var lvl = level if level > 0 else current_level
	var result = {}
	for effect in effects:
		var params = effect.params.duplicate()
		var scaling = effect.get("level_scaling", 0.1)
		for key in params:
			if params[key] is float or params[key] is int:
				params[key] = params[key] * (1.0 + (lvl - 1) * scaling)
		result[effect.type] = params
	return result

func get_description(level: int = -1) -> String:
	var lvl = level if level > 0 else current_level
	var desc = description
	var params = get_effect_params(lvl)
	for effect_type in params:
		for param_key in params[effect_type]:
			var val = params[effect_type][param_key]
			var placeholder = "{" + param_key + "}"
			if desc.find(placeholder) >= 0:
				desc = desc.replace(placeholder, str(val))
	return "[Lv.%d] %s" % [lvl, desc]

func to_dict() -> Dictionary:
	return {
		"id": id,
		"level": current_level
	}

func from_dict(data: Dictionary):
	id = data.get("id", "")
	current_level = data.get("level", 0)
