extends Resource
class_name CharacterPotential

@export var character_id: String
@export var potential_type: String = "根骨"
@export var base_value: float = 1.0
@export var current_value: float = 1.0
@export var max_value: float = 3.0
@export var breakthrough_bonus: Array[float] = [0.1, 0.15, 0.2, 0.25]
@export var level: int = 0
@export var exp: int = 0
@export var max_level: int = 100

@export var exp_curve: Array[int] = []

func _init():
	_init_exp_curve()

func _init_exp_curve():
	exp_curve.resize(max_level + 1)
	var total_exp = 0
	for i in range(1, max_level + 1):
		total_exp += i * 10
		exp_curve[i] = total_exp

func add_exp(amount: int):
	exp += amount
	while level < max_level and exp >= exp_curve[level + 1]:
		level += 1
		current_value = min(current_value + 0.01, max_value)

func get_effective_value() -> float:
	var value = current_value
	if level > 0:
		value += breakthrough_bonus[min(level // 25, breakthrough_bonus.size() - 1)]
	return min(value, max_value)

func get_breakthrough_level() -> int:
	return level // 25

func can_breakthrough() -> bool:
	return get_breakthrough_level() < 4 and level >= (get_breakthrough_level() + 1) * 25

func do_breakthrough():
	var bt = get_breakthrough_level()
	if bt < breakthrough_bonus.size():
		current_value += breakthrough_bonus[bt]
		current_value = min(current_value, max_value)

func to_dict() -> Dictionary:
	return {
		"type": potential_type,
		"level": level,
		"exp": exp,
		"current_value": current_value
	}

func from_dict(data: Dictionary):
	potential_type = data.get("type", "根骨")
	level = data.get("level", 0)
	exp = data.get("exp", 0)
	current_value = data.get("current_value", 1.0)