extends Resource
class_name EquipmentEffect

@export var effect_type: String = ""
@export var trigger: String = "常驻"
@export var trigger_chance: float = 1.0
@export var params: Dictionary = {}
@export var duration: int = 0
@export var max_stacks: int = 1
@export var stack_type: String = "刷新"
@export var target: String = "自身"
@export var conditions: Array[Dictionary] = []
@export var description: String = ""

func _init():
	if params.is_empty():
		params = {}

func scale_with_level(level: int):
	var mult = 1.0 + (level - 1) * 0.05
	for key in params:
		if params[key] is int or params[key] is float:
			params[key] *= mult