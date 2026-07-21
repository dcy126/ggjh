extends RefCounted
class_name Summon

@export var summon_id: String
@export var owner: BattleCharacter = null
@export var name: String = ""
@export var max_hp: int = 1000
@export var current_hp: int = 1000
@export var atk: int = 100
@export var def: int = 100
@export var spd: int = 100
@export var team: int = 0
@export var grid_pos: Vector2i = Vector2i(-1, -1)
@export var duration: int = 3
@export var remaining_turns: int = 3
@export var ai_behavior: String = "attack_nearest"
@export var skills: Array[String] = []
@export var is_player_controlled: bool = false
@export var tags: Array[String] = []

func _init():
	if tags.is_empty():
		tags = []
	if skills.is_empty():
		skills = []

func take_damage(amount: int, damage_type: String, source: BattleCharacter) -> int:
	if current_hp <= 0:
		return 0
	
	var final_damage = amount
	var def_reduction = def / (def + 500.0)
	if damage_type != "真实":
		final_damage = int(final_damage * (1.0 - def_reduction * 0.5))
	
	final_damage = max(final_damage, 1)
	current_hp = max(current_hp - final_damage, 0)
	
	if current_hp <= 0:
		die()
	
	return final_damage

func heal(amount: int) -> int:
	var heal_amount = min(amount, max_hp - current_hp)
	current_hp += heal_amount
	return heal_amount

func die():
	current_hp = 0
	if owner:
		owner.summons.erase(self)

func on_turn_start():
	remaining_turns -= 1
	if remaining_turns <= 0:
		expire()

func expire():
	current_hp = 0
	die()

func act(battle: CombatManager):
	if not is_alive():
		return
	
	match ai_behavior:
		"attack_nearest":
			attack_nearest(battle)
		"support_owner":
			support_owner(battle)
		"guard_position":
			guard_position(battle)
		"random":
			random_action(battle)

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
		var skill_id = skills[0] if skills.size() > 0 else ""
		if skill_id:
			var skill = WuxueDatabase.get_wuxue(skill_id)
			if skill and skill.can_use(self, battle):
				battle.execute_skill(self, nearest, skill)
				return
		
		# 普通攻击
		battle.execute_basic_attack(self, nearest)

func support_owner(battle: CombatManager):
	if owner and owner.is_alive():
		if owner.current_hp < owner.max_hp * 0.5:
			var heal_skill = get_heal_skill()
			if heal_skill:
				battle.execute_skill(self, owner, heal_skill)
				return
		
		var buff_skill = get_buff_skill()
		if buff_skill:
			battle.execute_skill(self, owner, buff_skill)
			return
	
	attack_nearest(battle)

func guard_position(battle: CombatManager):
	# 待在原地，攻击进入范围的敌人
	pass

func random_action(battle: CombatManager):
	var actions = ["move", "attack", "skill", "wait"]
	var action = actions[randi() % actions.size()]
	# 实现随机行为
	pass

func get_heal_skill() -> String:
	for skill_id in skills:
		var skill = WuxueDatabase.get_wuxue(skill_id)
		if skill and skill.base_heal > 0:
			return skill_id
	return ""

func get_buff_skill() -> String:
	for skill_id in skills:
		var skill = WuxueDatabase.get_wuxue(skill_id)
		if skill and skill.effects.size() > 0:
			for eff in skill.effects:
				if eff.effect_type in ["护盾", "加属性", "增益"]:
					return skill_id
	return ""

func is_alive() -> bool:
	return current_hp > 0

func to_dict() -> Dictionary:
	return {
		"id": summon_id,
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
		"skills": skills,
		"tags": tags
	}

func from_dict(data: Dictionary) -> Summon:
	summon_id = data.get("id", "")
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
	tags = data.get("tags", tags)
	return self
