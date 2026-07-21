extends Resource
class_name EquipmentSetData

@export var id: String
@export var name: String
@export var description: String = ""
@export var piece_ids: Array[String] = []
@export var effects: Dictionary = {}  # piece_count -> effect_dict

@export var max_pieces: int = 6
@export var quality: String = "紫"

func _init():
	if effects.is_empty():
		effects = {
			"2": {"type": "属性加成", "params": {"atk%": 0.1, "def%": 0.1}},
			"4": {"type": "特殊效果", "params": {}},
			"6": {"type": "终极效果", "params": {}}
		}

func get_effect(piece_count: int) -> Dictionary:
	var key = str(piece_count)
	return effects.get(key, {})

func get_all_effects(current_pieces: int) -> Array[Dictionary]:
	var result = []
	for count_str in effects:
		var count = int(count_str)
		if count <= current_pieces:
			var effect = effects[count_str].duplicate()
			effect["piece_count"] = count
			effect["active"] = true
			result.append(effect)
		else:
			var effect = effects[count_str].duplicate()
			effect["piece_count"] = count
			effect["active"] = false
			result.append(effect)
	return result

func get_equipped_count(equipped_items: Array[String]) -> int:
	var count = 0
	for item_id in equipped_items:
		if item_id in piece_ids:
			count += 1
	return count