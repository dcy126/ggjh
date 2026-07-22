extends Resource
class_name Shield

@export var shield_id: String
@export var amount: int = 0
@export var max_amount: int = 0
@export var shield_type: String = "通用"
@export var duration: int = 1
@export var remaining_turns: int = 1
var source: BattleCharacter = null
@export var can_crit: bool = false
@export var block_types: Array[String] = ["外功", "内功", "混合", "定伤"]
@export var on_break_effects: Array[Dictionary] = []
@export var on_absorb_effects: Array[Dictionary] = []
@export var tags: Array[String] = []

func _init():
	if block_types.is_empty():
		block_types = ["外功", "内功", "混合", "定伤"]
	if on_break_effects.is_empty():
		on_break_effects = []
	if on_absorb_effects.is_empty():
		on_absorb_effects = []
	if tags.is_empty():
		tags = []

func can_absorb(damage_type: String) -> bool:
	if "真实" in block_types:
		return true
	if damage_type in block_types:
		return true
	return false

func absorb(damage: int) -> int:
	var absorbed = min(amount, damage)
	amount -= absorbed
	if amount <= 0:
		trigger_on_break()
	return absorbed

func trigger_on_break():
	for effect in on_break_effects:
		execute_effect(effect, source)

func trigger_on_absorb(damage: int, damage_type: String):
	for effect in on_absorb_effects:
		execute_effect(effect, source, {"damage": damage, "type": damage_type})

func execute_effect(effect: Dictionary, source: BattleCharacter, context: Dictionary = {}):
	match effect.get("type", ""):
		"治疗":
			if source and source.is_alive():
				source.heal(effect.get("value", 0), source)
		"加怒气":
			if source:
				source.add_rage(effect.get("value", 0))
		"加护盾":
			if source and source.is_alive():
				source.add_shield(effect.get("value", 0), effect.get("shield_type", "通用"), effect.get("duration", 1))
		"添加状态":
			var se = StatusEffect.new()
			se.effect_type = effect.get("status_type", "")
			se.params = effect.get("params", {})
			se.duration = effect.get("duration", 1)
			if source:
				source.apply_status_effect(se)
		"伤害":
			var target = context.get("target")
			if target and target.is_alive():
				target.take_damage(effect.get("value", 0), effect.get("damage_type", "真实"), source)
		"反击":
			if source and source.is_alive():
				source.add_temp_stat("counter_chance", effect.get("value", 0.2))

func reduce_duration():
	remaining_turns -= 1
	duration = remaining_turns

func is_expired() -> bool:
	return remaining_turns <= 0

func get_remaining_percent() -> float:
	if max_amount <= 0:
		return 0.0
	return amount / max_amount

func to_dict() -> Dictionary:
	return {
		"id": shield_id,
		"amount": amount,
		"max_amount": max_amount,
		"type": shield_type,
		"duration": duration,
		"turns": remaining_turns
	}

func from_dict(data: Dictionary) -> Shield:
	shield_id = data.get("id", "")
	amount = data.get("amount", 0)
	max_amount = data.get("max_amount", 0)
	shield_type = data.get("type", "通用")
	duration = data.get("duration", 1)
	remaining_turns = data.get("turns", 1)
	return self
