extends RefCounted
class_name Combo

@export var combo_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var trigger_conditions: Array[Dictionary] = []
@export var steps: Array[Dictionary] = []
@export var max_steps: int = 5
@export var required_characters: Array[String] = []
@export var required_wuxue: Array[String] = []
@export var required_formation: String = ""
@export var cooldown: int = 3
@export var current_cooldown: int = 0
@export var can_trigger_once_per_battle: bool = false
@export var has_triggered: bool = false
@export var bonus_effects: Array[Dictionary] = []

func _init():
	if trigger_conditions.is_empty():
		trigger_conditions = []
	if steps.is_empty():
		steps = []
	if required_characters.is_empty():
		required_characters = []
	if required_wuxue.is_empty():
		required_wuxue = []
	if bonus_effects.is_empty():
		bonus_effects = []

func check_trigger(caster: BattleCharacter, target: BattleCharacter, skill: WuxueData, combat: CombatManager) -> bool:
	if current_cooldown > 0:
		return false
	if can_trigger_once_per_battle and has_triggered:
		return false
	if required_formation != "" and combat.formation_system.current_formation != required_formation:
		return false
	
	# 检查角色要求
	for char_id in required_characters:
		var found = false
		for char in combat.all_characters:
			if char.character_id == char_id and char.team == caster.team and char.is_alive():
				found = true
				break
		if not found:
			return false
	
	# 检查武学要求
	for wuxue_id in required_wuxue:
		if not caster.known_wuxue.has(wuxue_id):
			return false
	
	# 检查触发条件
	for condition in trigger_conditions:
		if not _check_condition(caster, target, skill, condition, combat):
			return false
	
	return true

func _check_condition(caster: BattleCharacter, target: BattleCharacter, skill: WuxueData, condition: Dictionary, combat: CombatManager) -> bool:
	var cond_type = condition.get("type", "")
	var cond_value = condition.get("value", 0)
	
	match cond_type:
		"skill_type":
			return skill.type == cond_value
		"damage_type":
			return skill.damage_type == cond_value
		"target_hp_below":
			return target.current_hp / target.max_hp < cond_value
		"target_hp_above":
			return target.current_hp / target.max_hp > cond_value
		"caster_hp_below":
			return caster.current_hp / caster.max_hp < cond_value
		"caster_rage_above":
			return caster.rage >= cond_value
		"combo_count":
			return caster.combo_count >= cond_value
		"timestamp":
			return combat.current_timestamp == cond_value
		"turn":
			return combat.current_turn == cond_value
		"status_on_target":
			return target.has_status(cond_value)
		"status_on_caster":
			return caster.has_status(cond_value)
		"formation":
			return combat.formation_system.current_formation == cond_value
		"ally_count":
			return combat.get_ally_count(caster.team) >= cond_value
		"enemy_count":
			return combat.get_enemy_count(caster.team) >= cond_value
		"random":
			return randf() < cond_value
	
	return true

func start_combo(caster: BattleCharacter, combat: CombatManager):
	has_triggered = true
	current_cooldown = cooldown
	caster.combo_count = 0
	
	for i in range(steps.size()):
		var step = steps[i]
		var step_actor_id = step.get("actor", "caster")
		var step_target_id = step.get("target", "target")
		var step_skill_id = step.get("skill", "")
		var step_delay = step.get("delay", 0)
		
		var step_actor = caster
		if step_actor_id != "caster":
			for char in combat.all_characters:
				if char.character_id == step_actor_id and char.team == caster.team and char.is_alive():
					step_actor = char
					break
		
		var step_target = target
		if step_target_id != "target":
			if step_target_id == "nearest_enemy":
				step_target = combat.get_nearest_enemy(step_actor)
			elif step_target_id == "lowest_hp_ally":
				step_target = combat.get_lowest_hp_ally(step_actor.team)
			elif step_target_id == "highest_hp_enemy":
				step_target = combat.get_highest_hp_enemy(step_actor.team)
		
		if step_actor and step_actor.is_alive() and step_target and step_target.is_alive():
			if step_skill_id:
				var skill = WuxueDatabase.get_wuxue(step_skill_id)
				if skill:
					var action = BattleAction.new().set_combo_action(step_actor, self, i)
					combat.action_queue.append(action)
			else:
				var action = BattleAction.new().set_chase_action(step_actor, step_target)
				combat.action_queue.append(action)
			
			caster.combo_count += 1

func execute_combo_step(actor: BattleCharacter, combo_data: Dictionary, step: int, combat: CombatManager):
	if step >= combo_data.get("steps", []).size():
		return
	
	var step_info = combo_data["steps"][step]
	var step_skill_id = step_info.get("skill", "")
	
	if step_skill_id:
		var skill = WuxueDatabase.get_wuxue(step_skill_id)
		if skill:
			var step_target = combat.get_enemies(actor.team)[0]
			if step_target:
				combat.execute_skill(actor, step_target, skill)
	
	# 检查是否有下一步
	if step + 1 < combo_data["steps"].size():
		# 下一步会通过combo系统自动处理
		pass

func apply_bonus_effects(caster: BattleCharacter, combat: CombatManager):
	for effect in bonus_effects:
		var eff_type = effect.get("type", "")
		var eff_value = effect.get("value", 0)
		var eff_target = effect.get("target", "caster")
		var eff_duration = effect.get("duration", 1)
		
		var target_char = caster if eff_target == "caster" else combat.get_nearest_enemy(caster)
		
		if target_char:
			match eff_type:
				"heal":
					target_char.heal(eff_value, caster)
				"shield":
					target_char.add_shield(eff_value, "连击", eff_duration, caster)
				"rage":
					target_char.add_rage(eff_value)
				"qi":
					target_char.add_qi(eff_value)
				"buff":
					var se = StatusEffect.new()
					se.effect_type = effect.get("buff_type", "属性加成")
					se.params = effect.get("params", {})
					se.duration = eff_duration
					target_char.apply_status_effect(se)
				"debuff_enemy":
					var se = StatusEffect.new()
					se.effect_type = effect.get("debuff_type", "减攻")
					se.params = effect.get("params", {})
					se.duration = eff_duration
					target_char.apply_status_effect(se)

func reduce_cooldown():
	if current_cooldown > 0:
		current_cooldown -= 1

func to_dict() -> Dictionary:
	return {
		"id": combo_id,
		"name": name,
		"description": description,
		"trigger_conditions": trigger_conditions,
		"steps": steps,
		"max_steps": max_steps,
		"required_characters": required_characters,
		"required_wuxue": required_wuxue,
		"required_formation": required_formation,
		"cooldown": cooldown,
		"current_cooldown": current_cooldown,
		"once_per_battle": can_trigger_once_per_battle,
		"has_triggered": has_triggered,
		"bonus_effects": bonus_effects
	}

func from_dict(data: Dictionary) -> Combo:
	combo_id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	trigger_conditions = data.get("trigger_conditions", [])
	steps = data.get("steps", [])
	max_steps = data.get("max_steps", 5)
	required_characters = data.get("required_characters", [])
	required_wuxue = data.get("required_wuxue", [])
	required_formation = data.get("required_formation", "")
	cooldown = data.get("cooldown", 3)
	current_cooldown = data.get("current_cooldown", 0)
	can_trigger_once_per_battle = data.get("once_per_battle", false)
	has_triggered = data.get("has_triggered", false)
	bonus_effects = data.get("bonus_effects", [])
	return self
