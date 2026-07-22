extends BattleCharacter
class_name Phantom

@export var phantom_id: String
var phantom_owner: BattleCharacter = null
@export var duration: int = 2
@export var remaining_turns: int = 2
@export var inherit_stats_pct: float = 0.3
@export var ai_behavior: String = "attack_owner_target"
@export var skills: Array[String] = []
@export var tags: Array[String] = []

func _init():
	if tags.is_empty():
		tags = []
	if skills.is_empty():
		skills = []

func initialize(owner_char: BattleCharacter, inherit_pct: float = 0.3):
	phantom_owner = owner_char
	character_id = phantom_owner.character_id + "_phantom"
	character_name = phantom_owner.character_name + "·幻影"
	inherit_stats_pct = inherit_pct
	max_hp = int(phantom_owner.max_hp * inherit_pct)
	current_hp = max_hp
	atk = int(phantom_owner.atk * inherit_pct * 0.8)
	def = int(phantom_owner.def * inherit_pct * 0.5)
	spd = phantom_owner.spd
	team = phantom_owner.team
	duration = 2
	remaining_turns = 2
	skills = phantom_owner.equipped_wuxue.duplicate()
	inherit_owner_buffs()

func inherit_owner_buffs():
	if not phantom_owner:
		return
	for effect in phantom_owner.status_effects:
		if effect.effect_type in ["增益", "无敌", "隐身", "分身", "护盾"]:
			var new_effect = effect.duplicate()
			new_effect.duration = remaining_turns
			new_effect.remaining_turns = remaining_turns
			apply_status_effect(new_effect)

func take_damage(amount: int, damage_type: String, source: BattleCharacter, is_crit: bool = false) -> int:
	if current_hp <= 0:
		return 0
	
	var final_damage = amount
	# 幻影承受真实伤害
	if damage_type != "真实":
		final_damage = int(final_damage * 1.5)
	
	current_hp = max(current_hp - final_damage, 0)
	
	if current_hp <= 0:
		die()
	
	return final_damage

func heal(amount: int, source: BattleCharacter = null) -> int:
	var heal_amount = min(amount, max_hp - current_hp)
	current_hp += heal_amount
	return heal_amount

func die():
	current_hp = 0
	if phantom_owner and phantom_owner.phantoms.has(self):
		phantom_owner.phantoms.erase(self)

func on_turn_start():
	remaining_turns -= 1
	if remaining_turns <= 0:
		expire()

func expire():
	die()

func act(battle: CombatManager):
	if not is_alive():
		return
	
	match ai_behavior:
		"attack_owner_target":
			attack_owner_target(battle)
		"attack_nearest":
			attack_nearest(battle)
		"protect_owner":
			protect_owner(battle)

func attack_owner_target(battle: CombatManager):
	if not phantom_owner or not phantom_owner.is_alive():
		attack_nearest(battle)
		return
	
	# 攻击主人的目标
	var target = phantom_owner.last_attack_target
	if target and target.is_alive() and can_reach_target(target):
		var skill_id = get_usable_skill(battle)
		if skill_id:
			var skill = WuxueDatabase.instance.get_wuxue(skill_id)
			if skill and skill.can_use(self, battle):
				battle.execute_skill(self, target, skill)
				return
		
		battle.execute_basic_attack(self, target)
	else:
		attack_nearest(battle)

func protect_owner(battle: CombatManager):
	if not phantom_owner or not phantom_owner.is_alive():
		return
	
	# 检查是否有敌人接近主人
	for enemy in battle.get_enemies(team):
		if enemy.is_alive() and phantom_owner.grid_pos.distance_to(enemy.grid_pos) <= 2:
			var skill_id = get_usable_skill(battle)
			if skill_id:
				var skill = WuxueDatabase.instance.get_wuxue(skill_id)
				if skill and skill.can_use(self, battle):
					battle.execute_skill(self, enemy, skill)
					return
			
			battle.execute_basic_attack(self, enemy)
			return
	
	# 没有威胁，靠近主人
	var grid = battle.battle_grid
	if grid:
		var target_pos = phantom_owner.grid_pos + Vector2i(1, 0)
		if grid.is_valid_position(target_pos) and grid.is_walkable(target_pos):
			grid.move_character(self, target_pos)

func attack_nearest(battle: CombatManager):
	var nearest = null
	var min_dist = 999
	for enemy in battle.get_enemies(team):
		if enemy.is_alive():
			var dist = grid_pos.distance_to(enemy.grid_pos)
			if dist < min_dist:
				min_dist = dist
				nearest = enemy
	
	if nearest:
		var skill_id = get_usable_skill(battle)
		if skill_id:
			var skill = WuxueDatabase.instance.get_wuxue(skill_id)
			if skill and skill.can_use(self, battle):
				battle.execute_skill(self, nearest, skill)
				return
		
		battle.execute_basic_attack(self, nearest)

func can_reach_target(target: BattleCharacter) -> bool:
	var range = 1
	for skill_id in skills:
		var skill = WuxueDatabase.instance.get_wuxue(skill_id)
		if skill:
			range = max(range, skill.range_max)
	return grid_pos.distance_to(target.grid_pos) <= range

func get_usable_skill(battle: CombatManager) -> String:
	var usable = []
	for skill_id in skills:
		var skill = WuxueDatabase.instance.get_wuxue(skill_id)
		if skill and skill.can_use(self, battle):
			usable.append(skill_id)
	
	if usable.is_empty():
		return ""
	
	return usable[randi() % usable.size()]

func is_alive() -> bool:
	return current_hp > 0

func to_dict() -> Dictionary:
	return {
		"id": phantom_id,
		"owner_id": phantom_owner.character_id if phantom_owner else "",
		"name": name,
		"hp": current_hp,
		"max_hp": max_hp,
		"atk": atk,
		"def": def,
		"spd": spd,
		"team": team,
		"pos": grid_pos,
		"duration": duration,
		"turns": remaining_turns,
		"skills": skills
	}

func from_dict(data: Dictionary) -> Phantom:
	phantom_id = data.get("id", "")
	name = data.get("name", "")
	current_hp = data.get("hp", max_hp)
	max_hp = data.get("max_hp", max_hp)
	atk = data.get("atk", atk)
	def = data.get("def", def)
	spd = data.get("spd", spd)
	team = data.get("team", team)
	grid_pos = data.get("pos", Vector2i(-1, -1))
	duration = data.get("duration", duration)
	remaining_turns = data.get("turns", remaining_turns)
	skills = data.get("skills", skills)
	return self
