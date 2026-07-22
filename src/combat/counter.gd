extends Resource
class_name Counter

@export var counter_id: String
@export var name: String = ""
@export var description: String = ""
@export var trigger_chance: float = 0.0
@export var max_counters_per_turn: int = 1
@export var counter_type: String = "普通"  # 普通, 反击, 协同, 连击, 追击
@export var required_conditions: Array[Dictionary] = []
@export var counter_effects: Array[Dictionary] = []
@export var cooldown: int = 0
@export var current_cooldown: int = 0
@export var exclusive_characters: Array[String] = []
@export var exclusive_sects: Array[String] = []
@export var tags: Array[String] = []

func _init():
	if required_conditions.is_empty():
		required_conditions = []
	if counter_effects.is_empty():
		counter_effects = []
	if exclusive_characters.is_empty():
		exclusive_characters = []
	if exclusive_sects.is_empty():
		exclusive_sects = []
	if tags.is_empty():
		tags = []

func can_trigger(defender: BattleCharacter, attacker: BattleCharacter, damage: int, damage_type: String, is_crit: bool) -> bool:
	if current_cooldown > 0:
		return false
	
	if defender.counter_count >= max_counters_per_turn:
		return false
	
	if exclusive_characters.size() > 0 and defender.character_id not in exclusive_characters:
		return false
	
	if exclusive_sects.size() > 0 and defender.sect not in exclusive_sects:
		return false
	
	for cond in required_conditions:
		if not _check_condition(cond, defender, attacker, damage, damage_type, is_crit):
			return false
	
	if rng.randf_range(0.0, 1.0) > trigger_chance:
		return false
	
	return true

func _check_condition(cond: Dictionary, defender: BattleCharacter, attacker: BattleCharacter, damage: int, damage_type: String, is_crit: bool) -> bool:
	var cond_type = cond.get("type", "")
	match cond_type:
		"hp_above":
			return defender.current_hp / defender.max_hp > cond.get("value", 0.0)
		"hp_below":
			return defender.current_hp / defender.max_hp < cond.get("value", 0.0)
		"damage_above":
			return damage > cond.get("value", 0)
		"damage_type":
			return damage_type == cond.get("value", "")
		"is_crit":
			return is_crit == cond.get("value", false)
		"attacker_hp_below":
			return attacker.current_hp / attacker.max_hp < cond.get("value", 0.0)
		"has_status":
			return defender.has_status(cond.get("value", ""))
		"not_has_status":
			return not defender.has_status(cond.get("value", ""))
		"weapon_type":
			return defender.get_weapon_type() == cond.get("value", "")
		"sect":
			return defender.sect == cond.get("value", "")
		"formation":
			return defender.current_formation == cond.get("value", "")
		"rage_above":
			return defender.rage >= cond.get("value", 0)
		"qi_full":
			return defender.qi >= defender.max_qi
		"has_shield":
			return defender.shields.size() > 0
		"is_melee":
			return attacker.grid_pos.distance_to(defender.grid_pos) <= 1
		"is_ranged":
			return attacker.grid_pos.distance_to(defender.grid_pos) > 1
	return true

func execute(defender: BattleCharacter, attacker: BattleCharacter, damage: int, damage_type: String, is_crit: bool):
	if not can_trigger(defender, attacker, damage, damage_type, is_crit):
		return
	
	defender.counter_count += 1
	current_cooldown = cooldown
	
	log("%s 触发了 %s！" % [defender.character_name, name])
	
	for effect in counter_effects:
		_apply_counter_effect(effect, defender, attacker, damage)
	
	if on_counter_executed:
		on_counter_executed.call(defender, attacker, self)

func _apply_counter_effect(effect: Dictionary, defender: BattleCharacter, attacker: BattleCharacter, original_damage: int):
	var effect_type = effect.get("type", "")
	match effect_type:
		"反击伤害":
			var dmg = int(original_damage * effect.get("multiplier", 0.5))
			attacker.take_damage(dmg, effect.get("damage_type", "真实"), defender)
		"反击治疗":
			var heal = int(original_damage * effect.get("multiplier", 0.3))
			defender.heal(heal, defender)
		"反击加怒气":
			defender.add_rage(effect.get("value", 10))
		"反击减怒气":
			attacker.rage = max(attacker.rage - effect.get("value", 10), 0)
		"反击加护盾":
			defender.add_shield(effect.get("value", 100), "反击", effect.get("duration", 1))
		"反击加状态":
			var se = StatusEffect.new()
			se.effect_type = effect.get("status_type", "眩晕")
			se.params = effect.get("params", {})
			se.duration = effect.get("duration", 1)
			se.trigger = "常驻"
			attacker.apply_status_effect(se)
		"反击清除状态":
			attacker.clear_debuffs(effect.get("count", 1))
		"反击位移":
			var dir = (defender.grid_pos - attacker.grid_pos).sign()
			var distance = effect.get("distance", 1)
			var new_pos = attacker.grid_pos + dir * distance
			if battle_grid and battle_grid.is_valid_position(new_pos) and battle_grid.is_walkable(new_pos):
				battle_grid.move_character(attacker, new_pos)
		"反击追击":
			# 触发额外攻击
			if effect.get("use_basic_attack", true):
				execute_basic_attack(defender, attacker)
			else:
				var skill_id = effect.get("skill_id", "")
				if skill_id:
					var skill = WuxueDatabase.get_wuxue(skill_id)
					if skill:
						combat_manager.execute_skill(defender, attacker, skill)
		"反击协同":
			# 触发队友协同
			for ally in get_allies(defender.team):
				if ally != defender and ally.is_alive():
					var chance = effect.get("ally_chance", 0.5)
					if rng.randf_range(0.0, 1.0) < chance:
						if effect.get("ally_action", "attack") == "attack":
							execute_basic_attack(ally, attacker)
						else:
							var skill_id = effect.get("ally_skill", "")
							if skill_id:
								var skill = WuxueDatabase.get_wuxue(skill_id)
								if skill:
									combat_manager.execute_skill(ally, attacker, skill)
		"反击变身":
			defender.current_form = effect.get("form_id", "")
			defender.form_data = effect.get("form_data", {})
		"反击分身":
			combat_manager.summon_phantom(defender, effect.get("count", 1), effect.get("duration", 2))
		"反击召唤":
			combat_manager.summon_unit(defender.team, effect.get("summon_id", ""), defender.grid_pos, effect.get("duration", 3))

func reduce_cooldown():
	if current_cooldown > 0:
		current_cooldown -= 1

func reset():
	current_cooldown = 0

func to_dict() -> Dictionary:
	return {
		"id": counter_id,
		"name": name,
		"description": description,
		"trigger_chance": trigger_chance,
		"max_counters": max_counters_per_turn,
		"counter_type": counter_type,
		"conditions": required_conditions,
		"effects": counter_effects,
		"cooldown": cooldown,
		"current_cooldown": current_cooldown,
		"exclusive_chars": exclusive_characters,
		"exclusive_sects": exclusive_sects,
		"tags": tags
	}

func from_dict(data: Dictionary) -> Counter:
	counter_id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	trigger_chance = data.get("trigger_chance", 0.0)
	max_counters_per_turn = data.get("max_counters", 1)
	counter_type = data.get("counter_type", "普通")
	required_conditions = data.get("conditions", [])
	counter_effects = data.get("effects", [])
	cooldown = data.get("cooldown", 0)
	current_cooldown = data.get("current_cooldown", 0)
	exclusive_characters = data.get("exclusive_chars", [])
	exclusive_sects = data.get("exclusive_sects", [])
	tags = data.get("tags", [])
	return self