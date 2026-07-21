extends RefCounted
class_name CombatManager

var battle_grid: BattleGrid = null
var player_team: Array[BattleCharacter] = []
var enemy_team: Array[BattleCharacter] = []
var all_characters: Array[BattleCharacter] = []
var turn_order: Array[BattleCharacter] = []

var current_turn: int = 0
var current_timestamp: int = 0
var max_timestamp: int = GameData.MAX_TIMESTAMP
var battle_state: String = "准备"
var battle_result: String = ""

var action_queue: Array[BattleAction] = []
var pending_effects: Array[Dictionary] = []
var timestamp_callbacks: Dictionary = {}

var combo_system: Combo = null
var counter_system: Counter = null
var formation_system: Formation = null

var rng: RandomNumberGenerator = null
var battle_log: Array[String] = []
var event_history: Array[Dictionary] = []

var is_auto_battle: bool = false
var battle_speed: float = 1.0
var skip_animations: bool = false

var on_battle_start: Callable 
var on_battle_end: Callable 
var on_turn_start: Callable 
var on_turn_end: Callable 
var on_character_act: Callable 
var on_damage_dealt: Callable 
var on_heal_done: Callable 
var on_status_applied: Callable 
var on_character_death: Callable 

static var instance: CombatManager = null

func _init():
	instance = self
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	battle_grid = BattleGrid.new(9, 6)
	combo_system = Combo.new()
	counter_system = Counter.new()
	formation_system = Formation.new()
	
	_init_timestamp_callbacks()

func _init_timestamp_callbacks():
	for i in range(0, GameData.MAX_TIMESTAMP + 1, 50):
		timestamp_callbacks[i] = []

func setup_battle(player_chars: Array[BattleCharacter], enemy_chars: Array[BattleCharacter], formation: String = "方阵"):
	player_team = player_chars.duplicate()
	enemy_team = enemy_chars.duplicate()
	all_characters = player_team + enemy_team
	
	for char in all_characters:
		char.team = 0 if char in player_team else 1
		char.qi = 0
		char.rage = 0
		char.status_effects.clear()
		char.shields.clear()
		char.buffs.clear()
		char.debuffs.clear()
		char.is_dead = false
		char.is_stunned = false
		char.is_silenced = false
		char.is_disarmed = false
		char.is_frozen = false
		char.is_rooted = false
		char.is_blind = false
		char.is_confused = false
		char.is_feared = false
		char.is_taunted = false
		char.is_stealthed = false
		char.is_invulnerable = false
		char.is_untargetable = false
		char.cannot_move = false
		char.cannot_act = false
		char.skip_turn = false
		char.extra_turn = false
		char.has_acted = false
		char.has_moved = false
		char.qi_gained_this_turn = 0
		char.combo_count = 0
		char.counter_count = 0
		char.chase_count = 0
		char.damage_taken_this_turn = 0
		char.damage_dealt_this_turn = 0
		char.heal_done_this_turn = 0
		char.shield_gained_this_turn = 0
		char.last_attack_target = null
		char.last_used_wuxue = []
	
	battle_grid.clear()
	
	var player_positions = battle_grid.get_team_start_positions(0, player_team.size())
	var enemy_positions = battle_grid.get_team_start_positions(1, enemy_team.size())
	
	for i in range(player_team.size()):
		if i < player_positions.size():
			battle_grid.add_character(player_team[i], player_positions[i])
	
	for i in range(enemy_team.size()):
		if i < enemy_positions.size():
			battle_grid.add_character(enemy_team[i], enemy_positions[i])
	
	_init_turn_order()
	
	current_turn = 0
	current_timestamp = 0
	battle_state = "进行中"
	battle_result = ""
	battle_log.clear()
	event_history.clear()
	
	apply_formation_bonuses(formation)
	
	if on_battle_start:
		on_battle_start.call()

func _init_turn_order():
	turn_order = all_characters.duplicate()
	turn_order.sort_custom(_compare_qi_speed)

func _compare_qi_speed(a: BattleCharacter, b: BattleCharacter) -> int:
	if a.qi_speed != b.qi_speed:
		return -1 if a.qi_speed > b.qi_speed else 1
	return -1 if a.spd > b.spd else 1

func start_battle():
	battle_state = "进行中"
	_process_turn()

func _process_turn():
	while battle_state == "进行中":
		_current_turn_logic()
		if battle_state != "进行中":
			break
		current_turn += 1
		_increment_timestamp(50)
		_update_turn_order()
		_check_battle_end()
		if battle_state != "进行中":
			break

func _current_turn_logic():
	for char in turn_order:
		if not char.is_alive() or battle_state != "进行中":
			continue
		
		char.has_acted = false
		char.has_moved = false
		char.qi_gained_this_turn = 0
		
		_process_character_qi_gain(char)
		
		if on_turn_start:
			on_turn_start.call(char)
		
		if char.can_act() and char.qi >= char.max_qi:
			_process_character_action(char)
		else:
			_process_character_wait(char)
		
		if on_turn_end:
			on_turn_end.call(char)
		
		_check_battle_end()
		if battle_state != "进行中":
			break

func _process_character_qi_gain(char: BattleCharacter):
	var qi_gain = int(char.qi_speed * 10)
	
	# 福缘加成
	var fortune_bonus = char.fortune / 100.0
	qi_gain = int(qi_gain * (1.0 + fortune_bonus))
	
	# 状态效果加成
	for effect in char.status_effects:
		if effect.effect_type == "加集气":
			qi_gain = int(qi_gain * (1.0 + effect.params.get("value", 0.0)))
		elif effect.effect_type == "减集气":
			qi_gain = int(qi_gain * (1.0 - effect.params.get("value", 0.0)))
	
	qi_gain = clamp(qi_gain, 1, 50)
	char.add_qi(qi_gain)
	char.qi_gained_this_turn += qi_gain
	
	print("%s 获得 %d 集气" % [char.character_name, qi_gain])

func _process_character_action(char: BattleCharacter):
	char.has_acted = true
	
	if on_character_act:
		on_character_act.call(char)
	
	if is_auto_battle or not char.is_player_controlled:
		_ai_act(char)
	else:
		_wait_for_player_input(char)

func _process_character_wait(char: BattleCharacter):
	# 等待时恢复少量内力
	var mp_regen = max(1, int(char.max_mp * 0.05))
	char.current_mp = min(char.current_mp + mp_regen, char.max_mp)

func _ai_act(char: BattleCharacter):
	var action = _select_ai_action(char)
	if action:
		_execute_action(char, action)

func _select_ai_action(char: BattleCharacter) -> Dictionary:
	var available_skills = []
	for skill_id in char.equipped_wuxue:
		var skill = WuxueDatabase.get_wuxue(skill_id)
		if skill and skill.can_use(char, self):
			available_skills.append(skill_id)
	
	if available_skills.is_empty():
		return {"type": "basic_attack", "target": _find_basic_attack_target(char)}
	
	# 评分选择最佳技能
	var best_skill = ""
	var best_score = -1
	var best_target = null
	
	for skill_id in available_skills:
		var skill = WuxueDatabase.get_wuxue(skill_id)
		var targets = _get_skill_targets(char, skill)
		
		for target in targets:
			var score = _evaluate_skill(char, skill, target)
			if score > best_score:
				best_score = score
				best_skill = skill_id
				best_target = target
	
	if best_skill:
		return {"type": "skill", "skill": best_skill, "target": best_target}
	
	return {"type": "basic_attack", "target": _find_basic_attack_target(char)}

func _evaluate_skill(caster: BattleCharacter, skill: WuxueData, target: BattleCharacter) -> float:
	var score = 0.0
	
	if skill.base_damage > 0:
		var dmg = skill.get_damage_at_level(skill.current_level, caster.atk, caster.spd, caster.def, target.def)
		var hp_pct = target.current_hp / target.max_hp
		score += dmg * (2.0 - hp_pct) * 0.1
		
		if skill.is_ultimate:
			score *= 1.5
	
	if skill.base_heal > 0:
		var heal = skill.get_heal_at_level(skill.current_level, caster.atk, caster.spd)
		var missing_hp = target.max_hp - target.current_hp
		score += heal * (missing_hp / target.max_hp) * 0.2
	
	if skill.shield_amount > 0:
		var shield = skill.get_shield_at_level(skill.current_level, caster.def)
		score += shield * 0.1
	
	for effect in skill.effects:
		if effect.effect_type in ["眩晕", "定身", "沉默", "缴械", "封印"]:
			score += 50 * effect.trigger_chance
		elif effect.effect_type in ["中毒", "燃烧", "流血"]:
			score += 30 * effect.trigger_chance
		elif effect.effect_type in ["护盾", "治疗", "增益"]:
			score += 20 * effect.trigger_chance
	
	# 怒气消耗惩罚
	if skill.rage_cost > 0:
		score *= 0.8
	
	# 冷却惩罚
	if skill.cooldown > 0:
		score *= 0.9
	
	return score

func _get_skill_targets(caster: BattleCharacter, skill: WuxueData) -> Array[BattleCharacter]:
	var targets = []
	var grid = battle_grid
	
	if not grid:
		return targets
	
	match skill.target_type:
		"单体":
			var enemies = get_enemies(caster.team)
			for enemy in enemies:
				if enemy.is_alive() and caster.grid_pos.distance_to(enemy.grid_pos) <= skill.range_max:
					targets.append(enemy)
		"横排":
			for enemy in get_enemies(caster.team):
				if enemy.is_alive() and enemy.grid_pos.y == caster.grid_pos.y:
					targets.append(enemy)
		"竖排":
			for enemy in get_enemies(caster.team):
				if enemy.is_alive() and enemy.grid_pos.x == caster.grid_pos.x:
					targets.append(enemy)
		"十字":
			for enemy in get_enemies(caster.team):
				if enemy.is_alive():
					if enemy.grid_pos.x == caster.grid_pos.x or enemy.grid_pos.y == caster.grid_pos.y:
						targets.append(enemy)
		"菱形":
			for enemy in get_enemies(caster.team):
				if enemy.is_alive():
					var dist = abs(enemy.grid_pos.x - caster.grid_pos.x) + abs(enemy.grid_pos.y - caster.grid_pos.y)
					if dist <= skill.range_max:
						targets.append(enemy)
		"全体":
			for enemy in get_enemies(caster.team):
				if enemy.is_alive():
					targets.append(enemy)
		"友方单体":
			for ally in get_allies(caster.team):
				if ally.is_alive() and caster.grid_pos.distance_to(ally.grid_pos) <= skill.range_max:
					targets.append(ally)
		"友方全体":
			for ally in get_allies(caster.team):
				if ally.is_alive():
					targets.append(ally)
		"自身":
			targets.append(caster)
		"血量最低":
			var target = grid.get_lowest_hp_target(caster.team, false)
			if target:
				targets.append(target)
		"血量最高":
			var target = grid.get_highest_hp_target(caster.team, false)
			if target:
				targets.append(target)
	
	return targets

func _find_basic_attack_target(char: BattleCharacter) -> BattleCharacter:
	var enemies = get_enemies(char.team)
	var nearest = null
	var min_dist = 999
	
	for enemy in enemies:
		if enemy.is_alive():
			var dist = char.grid_pos.distance_to(enemy.grid_pos)
			if dist <= char.move_range + 1 and dist < min_dist:
				min_dist = dist
				nearest = enemy
	
	if not nearest and enemies.size() > 0:
		for enemy in enemies:
			if enemy.is_alive():
				nearest = enemy
				break
	
	return nearest

func execute_skill(caster: BattleCharacter, target: BattleCharacter, skill: WuxueData):
	if not caster.is_alive() or not target.is_alive():
		return
	
	print("%s 对 %s 使用了 %s" % [caster.character_name, target.character_name, skill.name])
	
	caster.last_used_wuxue.append(skill.id)
	caster.current_mp = max(caster.current_mp - skill.mp_cost, 0)
	caster.rage = max(caster.rage - skill.rage_cost, 0)
	caster.qi = max(caster.qi - skill.qi_cost, 0)
	skill.apply_cooldown()
	
	# 检查连击
	if skill.is_combo_starter:
		combo_system.start_combo(caster, skill)
	
	var targets = _get_aoe_targets(caster, target, skill)
	
	for t in targets:
		_apply_skill_effect(caster, t, skill)
	
	# 触发连击/追击
	_process_combo_and_chase(caster, skill)

func _get_aoe_targets(caster: BattleCharacter, primary_target: BattleCharacter, skill: WuxueData) -> Array[BattleCharacter]:
	var targets = [primary_target]
	
	if skill.target_type in ["横排", "竖排", "十字", "菱形", "全体"]:
		var grid = battle_grid
		if grid:
			targets = grid.get_characters_in_aoe(primary_target.grid_pos, skill.target_type, skill.range_max, primary_target.team)
	
	return targets

func _apply_skill_effect(caster: BattleCharacter, target: BattleCharacter, skill: WuxueData):
	var is_crit = false
	var hit_chance = caster.get_total_hit_chance(target)
	var dodge_chance = target.get_total_dodge_chance(caster)
	var final_hit = hit_chance - dodge_chance + 0.5
	
	if rng.randf_range(0.0, 1.0) > final_hit:
		print("%s 闪避了 %s 的攻击" % [target.character_name, caster.character_name])
		trigger_counter(target, caster)
		return
	
	var crit_chance = caster.get_total_crit_chance()
	if rng.randf_range(0.0, 1.0) < crit_chance:
		is_crit = true
	
	var damage = 0
	var heal = 0
	var shield = 0
	
	if skill.base_damage > 0:
		damage = skill.get_damage_at_level(skill.current_level, caster.atk, caster.spd, caster.def, target.def)
		damage = int(damage * (1.0 + caster.get_total_damage_bonus()))
		
		if is_crit:
			damage = int(damage * caster.get_total_crit_damage())
			print("暴击！")
		
		var actual_damage = target.take_damage(damage, skill.damage_type, caster, is_crit)
		caster.damage_dealt_this_turn += actual_damage
		target.damage_taken_this_turn += actual_damage
		
		print("%s 造成了 %d 点 %s 伤害" % [caster.character_name, actual_damage, skill.damage_type])
		
		if on_damage_dealt:
			on_damage_dealt.call(caster, target, actual_damage, skill.damage_type, is_crit)
	
	if skill.base_heal > 0:
		heal = skill.get_heal_at_level(skill.current_level, caster.atk, caster.spd)
		var actual_heal = target.heal(heal, caster)
		caster.heal_done_this_turn += actual_heal
		
		print("%s 治疗了 %s %d 点血量" % [caster.character_name, target.character_name, actual_heal])
		
		if on_heal_done:
			on_heal_done.call(caster, target, actual_heal)
	
	if skill.shield_amount > 0:
		shield = skill.get_shield_at_level(skill.current_level, caster.def)
		var sh = target.add_shield(shield, "技能", 2, caster)
		caster.shield_gained_this_turn += shield
		
		print("%s 为 %s 提供了 %d 点护盾" % [caster.character_name, target.character_name, shield])
	
	for effect in skill.effects:
		var se = effect.duplicate()
		se.caster = caster
		se.source = caster
		target.apply_status_effect(se)
	
	# 真解效果
	if skill.zhenjie_level > 0:
		for effect in skill.zhenjie_effects:
			var se = effect.duplicate()
			se.caster = caster
			se.source = caster
			target.apply_status_effect(se)

func execute_basic_attack(caster: BattleCharacter, target: BattleCharacter):
	if not caster.is_alive() or not target.is_alive():
		return
	
	var is_crit = false
	var hit_chance = caster.get_total_hit_chance(target)
	var dodge_chance = target.get_total_dodge_chance(caster)
	var final_hit = hit_chance - dodge_chance + 0.5
	
	if rng.randf_range(0.0, 1.0) > final_hit:
		print("%s 闪避了 %s 的普通攻击" % [target.character_name, caster.character_name])
		trigger_counter(target, caster)
		return
	
	var crit_chance = caster.get_total_crit_chance()
	if rng.randf_range(0.0, 1.0) < crit_chance:
		is_crit = true
	
	var base_damage = caster.atk
	var damage_type = caster.get_weapon_damage_type()
	var damage = int(base_damage * (1.0 + caster.get_total_damage_bonus()))
	
	if is_crit:
		damage = int(damage * caster.get_total_crit_damage())
	
	var actual_damage = target.take_damage(damage, damage_type, caster, is_crit)
	
	print("%s 对 %s 进行了普通攻击，造成 %d 点 %s 伤害" % [caster.character_name, target.character_name, actual_damage, damage_type])

func trigger_counter(defender: BattleCharacter, attacker: BattleCharacter):
	if not defender.is_alive() or not attacker.is_alive():
		return
	
	var counter_chance = defender.get_total_stat("counter_chance")
	if rng.randf_range(0.0, 1.0) < counter_chance:
		print("%s 触发了反击！" % defender.character_name)
		execute_basic_attack(defender, attacker)

func _process_combo_and_chase(caster: BattleCharacter, skill: WuxueData):
	# 连击系统
	if skill.is_combo_finisher and combo_system.is_in_combo(caster):
		combo_system.finish_combo(caster, skill)
	
	# 追击系统
	var chase_chance = caster.get_total_stat("chase_chance")
	if rng.randf_range(0.0, 1.0) < chase_chance:
		var target = _find_chase_target(caster)
		if target:
			execute_basic_attack(caster, target)
			print("%s 触发了追击！" % caster.character_name)

func _find_chase_target(caster: BattleCharacter) -> BattleCharacter:
	var enemies = get_enemies(caster.team)
	for enemy in enemies:
		if enemy.is_alive() and caster.grid_pos.distance_to(enemy.grid_pos) <= caster.move_range + 1:
			return enemy
	return null

func move_character(char: BattleCharacter, target_pos: Vector2i) -> bool:
	if not char.can_move():
		return false
	
	var path = battle_grid.find_path(char.grid_pos, target_pos, char.move_range)
	if path.is_empty() or path.size() > char.move_range + 1:
		return false
	
	# 移动消耗集气
	var cost = (path.size() - 1) * 5
	char.add_qi(-cost)
	
	var success = battle_grid.move_character(char, target_pos)
	if success:
		char.has_moved = true
		print("%s 移动到 (%d, %d)" % [char.character_name, target_pos.x, target_pos.y])
		
		# 触发踩陷阱等
		battle_grid.check_hazards(target_pos, char)
	
	return success

func get_allies(team: int) -> Array[BattleCharacter]:
	var allies = []
	for char in all_characters:
		if char.team == team and char.is_alive():
			allies.append(char)
	return allies

func get_enemies(team: int) -> Array[BattleCharacter]:
	var enemies = []
	for char in all_characters:
		if char.team != team and char.is_alive():
			enemies.append(char)
	return enemies

func get_enemy_count(team: int) -> int:
	return get_enemies(team).size()

func get_ally_count(team: int) -> int:
	return get_allies(team).size()

func get_team_avg_hp(team: int) -> float:
	var allies = get_allies(team)
	if allies.is_empty():
		return 1.0
	var total = 0.0
	for ally in allies:
		total += ally.current_hp / ally.max_hp
	return total / allies.size()

func _update_turn_order():
	_init_turn_order()

func _increment_timestamp(amount: int):
	current_timestamp += amount
	if current_timestamp >= max_timestamp:
		_time_up()
	
	# 处理时序回调
	if timestamp_callbacks.has(current_timestamp):
		for callback in timestamp_callbacks[current_timestamp]:
			callback.call()
	
	# 怒气回复
	if current_timestamp % GameData.RAGE_GAIN_INTERVAL == 0:
		for char in all_characters:
			if char.is_alive():
				char.add_rage(1)

func _time_up():
	print("时序耗尽，战斗失败")
	battle_state = "失败"
	battle_result = "time_up"
	_end_battle()

func _check_battle_end():
	var player_alive = false
	var enemy_alive = false
	
	for char in all_characters:
		if char.is_alive():
			if char.team == 0:
				player_alive = true
			else:
				enemy_alive = true
	
	if not enemy_alive:
		battle_state = "胜利"
		battle_result = "victory"
		_end_battle()
	elif not player_alive:
		battle_state = "失败"
		battle_result = "defeat"
		_end_battle()

func _end_battle():
	if on_battle_end:
		on_battle_end.call(battle_result)

func apply_formation_bonuses(formation_name: String):
	var formation = FormationDatabase.get_formation(formation_name)
	if formation:
		formation_system.apply(formation, player_team)
		formation_system.apply(formation, enemy_team)

func print(message: String):
	var log_entry = "[T%d][%d] %s" % [current_turn, current_timestamp, message]
	battle_log.append(log_entry)
	print(log_entry)

func add_timestamp_callback(timestamp: int, callback: Callable):
	if not timestamp_callbacks.has(timestamp):
		timestamp_callbacks[timestamp] = []
	timestamp_callbacks[timestamp].append(callback)

func schedule_effect(timestamp: int, caster: BattleCharacter, target: BattleCharacter, effect_id: String):
	add_timestamp_callback(timestamp, Callable(self, "_trigger_delayed_effect").bind(caster, target, effect_id))

func _trigger_delayed_effect(caster: BattleCharacter, target: BattleCharacter, effect_id: String):
	var effect = EffectDatabase.get_effect(effect_id)
	if effect:
		var se = StatusEffect.new()
		se.effect_type = effect.type
		se.params = effect.params
		se.duration = effect.duration
		se.trigger = "常驻"
		se.caster = caster
		se.source = caster
		target.apply_status_effect(se)

func schedule_timestamp_effects(timestamps: Array[int], caster: BattleCharacter, target: BattleCharacter, effect_id: String):
	for ts in timestamps:
		schedule_effect(ts, caster, target, effect_id)

func summon_unit(team: int, summon_id: String, pos: Vector2i, duration: int):
	var summon_data = SummonDatabase.get_summon(summon_id)
	if not summon_data:
		return
	
	var summon = Summon.new()
	summon.summon_id = summon_id
	summon.name = summon_data.name
	summon.max_hp = summon_data.base_hp
	summon.current_hp = summon.max_hp
	summon.atk = summon_data.base_atk
	summon.def = summon_data.base_def
	summon.spd = summon_data.base_spd
	summon.team = team
	summon.duration = duration
	summon.remaining_turns = duration
	summon.skills = summon_data.skills
	summon.ai_behavior = summon_data.ai
	
	battle_grid.add_character(summon, pos)
	all_characters.append(summon)
	if team == 0:
		player_team.append(summon)
	else:
		enemy_team.append(summon)
	
	print("召唤了 %s" % summon.name)

func summon_phantom(caster: BattleCharacter, count: int, duration: int):
	for i in range(count):
		var phantom = Phantom.new()
		phantom.initialize(caster, 0.3)
		phantom.duration = duration
		phantom.remaining_turns = duration
		
		var grid = battle_grid
		var pos = grid.find_empty_adjacent(caster.grid_pos)
		if pos != Vector2i(-1, -1):
			grid.add_character(phantom, pos)
			all_characters.append(phantom)
			if caster.team == 0:
				player_team.append(phantom)
			else:
				enemy_team.append(phantom)
			caster.phantoms.append(phantom)
			print("%s 召唤了幻影分身" % caster.character_name)

func place_trap(team: int, pos: Vector2i, trap_type: String, duration: int):
	battle_grid.add_trap(pos, trap_type)
	print("%d 方在 (%d, %d) 放置了机关" % [team, pos.x, pos.y])

func place_mine(team: int, pos: Vector2i, damage: int, duration: int):
	battle_grid.add_mine(pos, damage)
	print("%d 方在 (%d, %d) 埋设了地雷" % [team, pos.x, pos.y])

static func get_instance() -> CombatManager:
	return instance

func get_battle_state() -> Dictionary:
	var player_team_arr = []
	for s in player_team_arr:
		player_team_arr.append(s.to_dict())
		
	var enemy_team_arr = []
	for s in enemy_team:
		enemy_team_arr.append(s.to_dict())
	return {
		"turn": current_turn,
		"timestamp": current_timestamp,
		"state": battle_state,
		"result": battle_result,
		"player_team": player_team_arr,
		"enemy_team": enemy_team_arr,
		"log": battle_log
	}
