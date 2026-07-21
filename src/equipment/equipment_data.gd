extends Resource
class_name EquipmentData

@export var id: String
@export var name: String
@export var description: String = ""
@export var slot: String = "武器"
@export var type: String = "剑"
@export var quality: String = "白"
@export var level_requirement: int = 1
@export var sect_requirement: String = ""

## 基础属性
@export var base_stats: Dictionary = {}

## 强化
@export var max_enhance_level: int = 20
@export var current_enhance_level: int = 0
@export var enhance_stats_per_level: Dictionary = {}
@export var enhance_materials: Dictionary = {}
@export var enhance_success_rate: Array[float] = []
@export var enhance_failure_break: bool = false

## 精炼
@export var max_refine_level: int = 10
@export var current_refine_level: int = 0
@export var refine_stats: Dictionary = {}
@export var refine_materials: Dictionary = {}

## 万炼
@export var max_wanlian_level: int = 100
@export var current_wanlian_level: int = 0
@export var wanlian_stats: Dictionary = {}
@export var wanlian_materials: Dictionary = {}
@export var wanlian_special_effect: String = ""

## 套装
@export var set_id: String = ""
@export var set_piece_index: int = 0

## 特殊效果
@export var special_effects: Array[EquipmentEffect] = []

## 宝石槽
@export var gem_slots: int = 0
@export var max_gem_slots: int = 4
@export var equipped_gems: Array[String] = []

## 外观
@export var icon_path: String = ""
@export var model_path: String = ""
@export var dyeable: bool = false
@export var current_dye: String = ""

## 标签
@export var tags: Array[String] = []

func _init():
	_init_defaults()

func _init_defaults():
	if base_stats.is_empty():
		base_stats = {
			"hp": 0,
			"mp": 0,
			"atk": 0,
			"def": 0,
			"spd": 0,
			"hit": 0,
			"dodge": 0,
			"crit": 0,
			"crit_dmg": 0.0,
			"fortune": 0,
			"move_range": 0,
			"qi_speed": 0.0
		}
	if enhance_stats_per_level.is_empty():
		enhance_stats_per_level = {
			"hp": 10,
			"atk": 2,
			"def": 2,
			"spd": 1
		}
	if enhance_materials.is_empty():
		enhance_materials = {"强化石": 1, "铜钱": 1000}
	if refine_materials.is_empty():
		refine_materials = {"精炼石": 1, "铜钱": 5000}
	if wanlian_materials.is_empty():
		wanlian_materials = {"万炼石": 1, "元宝": 100}
	if enhance_success_rate.is_empty():
		enhance_success_rate = [1.0, 1.0, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.25, 0.2, 0.15, 0.1, 0.08, 0.06, 0.04, 0.03, 0.02, 0.01, 0.005]
	if equipped_gems.is_empty():
		equipped_gems = []

func get_total_stats() -> Dictionary:
	var result = base_stats.duplicate()
	
	# 强化加成
	for stat in enhance_stats_per_level:
		result[stat] = result.get(stat, 0) + enhance_stats_per_level[stat] * current_enhance_level
	
	# 精炼加成
	for stat in refine_stats:
		result[stat] = result.get(stat, 0) + refine_stats[stat] * current_refine_level
	
	# 万炼加成
	for stat in wanlian_stats:
		result[stat] = result.get(stat, 0) + wanlian_stats[stat] * current_wanlian_level
	
	# 宝石加成
	for gem_id in equipped_gems:
		var gem = EquipmentDatabase.get_gem(gem_id)
		if gem:
			for stat in gem.stats:
				result[stat] = result.get(stat, 0) + gem.stats[stat]
	
	return result

func get_special_effects() -> Array[EquipmentEffect]:
	var effects = special_effects.duplicate()
	
	# 万炼特效
	if current_wanlian_level > 0 and wanlian_special_effect != "":
		var effect = EquipmentEffect.new()
		effect.effect_type = wanlian_special_effect
		effect.params = {"level": current_wanlian_level}
		effects.append(effect)
	
	return effects

func can_enhance() -> bool:
	return current_enhance_level < max_enhance_level

func get_enhance_success_rate() -> float:
	if current_enhance_level < enhance_success_rate.size():
		return enhance_success_rate[current_enhance_level]
	return 0.0

func try_enhance() -> bool:
	if not can_enhance():
		return false
	
	var success = randf() < get_enhance_success_rate()
	if success:
		current_enhance_level += 1
		return true
	else:
		if enhance_failure_break and current_enhance_level > 10:
			current_enhance_level = max(current_enhance_level - 1, 0)
		return false

func can_refine() -> bool:
	return current_refine_level < max_refine_level

func try_refine() -> bool:
	if not can_refine():
		return false
	current_refine_level += 1
	return true

func can_wanlian() -> bool:
	return current_wanlian_level < max_wanlian_level

func try_wanlian() -> bool:
	if not can_wanlian():
		return false
	current_wanlian_level += 1
	
	# 检查是否解锁特效
	if current_wanlian_level in [20, 40, 60, 80, 100] and wanlian_special_effect != "":
		pass # 特效已在get_special_effects中处理
	
	return true

func add_gem(gem_id: String) -> bool:
	if equipped_gems.size() >= gem_slots:
		return false
	equipped_gems.append(gem_id)
	return true

func remove_gem(index: int) -> String:
	if index >= 0 and index < equipped_gems.size():
		return equipped_gems.remove_at(index)
	return ""

func set_dye(dye_id: String):
	if dyeable:
		current_dye = dye_id

func get_set_effect(piece_count: int) -> Dictionary:
	if set_id == "":
		return {}
	var set_data = EquipmentSetDatabase.get_set(set_id)
	if set_data:
		return set_data.get_effect(piece_count)
	return {}

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"slot": slot,
		"quality": quality,
		"enhance_level": current_enhance_level,
		"refine_level": current_refine_level,
		"wanlian_level": current_wanlian_level,
		"gems": equipped_gems,
		"dye": current_dye
	}

func from_dict(data: Dictionary):
	id = data.get("id", "")
	name = data.get("name", "")
	slot = data.get("slot", "武器")
	quality = data.get("quality", "白")
	current_enhance_level = data.get("enhance_level", 0)
	current_refine_level = data.get("refine_level", 0)
	current_wanlian_level = data.get("wanlian_level", 0)
	equipped_gems = data.get("gems", [])
	current_dye = data.get("dye", "")