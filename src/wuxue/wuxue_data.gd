extends Resource
class_name WuxueData

@export var id: String
@export var name: String
@export var description: String = ""
@export var type: String = "拳掌"
@export var quality: String = "白"
@export var damage_type: String = "外功"
@export var target_type: String = "单体"
@export var range_min: int = 1
@export var range_max: int = 1
@export var aoe_pattern: String = ""
@export var mp_cost: int = 0
@export var rage_cost: int = 0
@export var qi_cost: int = 0
@export var cooldown: int = 0
@export var max_cooldown: int = 0
@export var requires_weapon: String = ""
@export var requires_sect: String = ""
@export var is_ultimate: bool = false
@export var is_combo_starter: bool = false
@export var is_combo_finisher: bool = false
@export var combo_id: String = ""
@export var can_counter: bool = false
@export var counter_chance: float = 0.0
@export var can_chase: bool = false
@export var chase_chance: float = 0.0
@export var priority: int = 0
@export var cast_time: int = 0
@export var timestamp_offset: int = 0

## 伤害/治疗公式
@export var base_damage: int = 0
@export var damage_scaling: Dictionary = {}  # "atk" -> 1.0, "spd" -> 0.5, etc.
@export var base_heal: int = 0
@export var heal_scaling: Dictionary = {}
@export var shield_amount: int = 0
@export var shield_scaling: Dictionary = {}

## 效果列表
@export var effects: Array[WuxueEffect] = []

## 升级
@export var max_level: int = 10
@export var current_level: int = 1
@export var exp: int = 0
@export var exp_per_level: Array[int] = []
@export var upgrade_materials: Dictionary = {}

## 专属
@export var exclusive_character: String = ""
@export var exclusive_sect: String = ""
@export var is_sect_wuxue: bool = false
@export var sect_wuxue_rank: int = 0

## 真解/残页
@export var requires_zhenjie: bool = false
@export var zhenjie_level: int = 0
@export var max_zhenjie_level: int = 10
@export var zhenjie_effects: Array[WuxueEffect] = []

## 特殊机制
@export var special_mechanic: String = ""
@export var mechanic_data: Dictionary = {}

## 视觉/音效
@export var icon_path: String = ""
@export var animation_name: String = ""
@export var sound_effect: String = ""
@export var particle_effect: String = ""
@export var screen_shake: float = 0.0

## 标签
@export var tags: Array[String] = []

func _init():
	_init_defaults()

func _init_defaults():
	if damage_scaling.is_empty():
		damage_scaling = {"atk": 1.0}
	if heal_scaling.is_empty():
		heal_scaling = {"atk": 0.5}
	if shield_scaling.is_empty():
		shield_scaling = {"def": 1.0}
	if exp_per_level.is_empty():
		exp_per_level = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 5500]
	if upgrade_materials.is_empty():
		upgrade_materials = {"武学残页": 10, "铜钱": 1000}
	if mechanic_data.is_empty():
		mechanic_data = {}

func get_damage_at_level(level: int, caster_atk: int, caster_spd: int, caster_def: int, target_def: int) -> int:
	var dmg = base_damage
	for stat_name in damage_scaling:
		var scaling = damage_scaling[stat_name]
		var stat_value = 0
		match stat_name:
			"atk": stat_value = caster_atk
			"spd": stat_value = caster_spd
			"def": stat_value = caster_def
			"hp": stat_value = caster_atk * 10
			"mp": stat_value = caster_spd * 5
			_: stat_value = 0
		dmg += int(stat_value * scaling)
	
	var def_reduction = target_def / (target_def + 500.0)
	dmg = int(dmg * (1.0 - def_reduction * 0.5))
	
	if current_level > 1:
		var level_mult = 1.0 + (current_level - 1) * 0.1
		dmg = int(dmg * level_mult)
	
	if zhenjie_level > 0:
		dmg = int(dmg * (1.0 + zhenjie_level * 0.05))
	
	return max(dmg, 1)

func get_heal_at_level(level: int, caster_atk: int, caster_spd: int, caster_def: int) -> int:
	var heal = base_heal
	for stat_name in heal_scaling:
		var scaling = heal_scaling[stat_name]
		var stat_value = 0
		match stat_name:
			"atk": stat_value = caster_atk
			"spd": stat_value = caster_spd
			"def": stat_value = caster_def
			_: stat_value = 0
		heal += int(stat_value * scaling)
	
	if current_level > 1:
		var level_mult = 1.0 + (current_level - 1) * 0.1
		heal = int(heal * level_mult)
	
	return max(heal, 0)

func get_shield_at_level(level: int, caster_atk: int, caster_def: int) -> int:
	var shield = shield_amount
	for stat_name in shield_scaling:
		var scaling = shield_scaling[stat_name]
		var stat_value = 0
		match stat_name:
			"def": stat_value = caster_def
			"atk": stat_value = caster_atk
			"hp": stat_value = caster_atk * 10
			_: stat_value = 0
		shield += int(stat_value * scaling)
	
	if current_level > 1:
		var level_mult = 1.0 + (current_level - 1) * 0.1
		shield = int(shield * level_mult)
	
	return max(shield, 0)

func can_use(caster: BattleCharacter, battle: CombatManager) -> bool:
	if caster.current_mp < mp_cost:
		return false
	if caster.rage < rage_cost:
		return false
	if caster.qi < qi_cost:
		return false
	if cooldown > 0:
		return false
	if requires_weapon and not caster.has_weapon(requires_weapon):
		return false
	if requires_sect and caster.sect != requires_sect:
		return false
	return true

func apply_cooldown():
	cooldown = max_cooldown

func reduce_cooldown():
	if cooldown > 0:
		cooldown -= 1

func get_total_cost() -> Dictionary:
	return {
		"mp": mp_cost,
		"rage": rage_cost,
		"qi": qi_cost,
		"cooldown": cooldown
	}

func get_effect_descriptions() -> Array[String]:
	var descs = []
	for effect in effects:
		descs.append(effect.get_description())
	for effect in zhenjie_effects:
		descs.append("[真解] " + effect.get_description())
	return descs

func get_range_positions(center: Vector2i, direction: Vector2i, grid: BattleGrid, team: int = 0) -> Array[Vector2i]:
	var positions = []
	match target_type:
		"单体":
			var pos = center + direction * range_min
			if grid.is_valid_position(pos):
				positions.append(pos)
		"横排":
			for x in range(-range_max, range_max + 1):
				var pos = Vector2i(center.x + x, center.y)
				if grid.is_valid_position(pos):
					positions.append(pos)
		"竖排":
			for y in range(-range_max, range_max + 1):
				var pos = Vector2i(center.x, center.y + y)
				if grid.is_valid_position(pos):
					positions.append(pos)
		"十字":
			for i in range(-range_max, range_max + 1):
				var pos1 = Vector2i(center.x + i, center.y)
				var pos2 = Vector2i(center.x, center.y + i)
				if grid.is_valid_position(pos1):
					positions.append(pos1)
				if grid.is_valid_position(pos2):
					positions.append(pos2)
		"菱形":
			for x in range(-range_max, range_max + 1):
				for y in range(-range_max + abs(x), range_max - abs(x) + 1):
					var pos = Vector2i(center.x + x, center.y + y)
					if grid.is_valid_position(pos):
						positions.append(pos)
		"全体":
			for x in range(grid.width):
				for y in range(grid.height):
					positions.append(Vector2i(x, y))
		"随机":
			var valid = grid.get_valid_positions()
			if valid.size() > 0:
				positions.append(valid[randi() % valid.size()])
		"指定":
			positions.append(center + direction * range_min)
		"自身":
			positions.append(center)
		"友方单体":
			for pos in grid.get_friendly_positions(team):
				if center.distance_to(pos) <= range_max:
					positions.append(pos)
		"友方全体":
			positions = grid.get_friendly_positions(team)
		"敌方全体":
			positions = grid.get_enemy_positions(team)
		"血量最低":
			var lowest = grid.get_lowest_hp_target(team, false)
			if lowest:
				positions.append(lowest.grid_pos)
		"血量最高":
			var highest = grid.get_highest_hp_target(team, false)
			if highest:
				positions.append(highest.grid_pos)
	return positions

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"type": type,
		"quality": quality,
		"current_level": current_level,
		"exp": exp,
		"zhenjie_level": zhenjie_level,
		"cooldown": cooldown
	}

func from_dict(data: Dictionary):
	id = data.get("id", "")
	name = data.get("name", "")
	type = data.get("type", "拳掌")
	quality = data.get("quality", "白")
	current_level = data.get("current_level", 1)
	exp = data.get("exp", 0)
	zhenjie_level = data.get("zhenjie_level", 0)
	cooldown = data.get("cooldown", 0)
