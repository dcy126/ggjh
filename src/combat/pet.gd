extends BattleCharacter
class_name Pet

@export var pet_id: String
@export var loyalty: int = 100
@export var exp: int = 0
@export var skills: Array[String] = []
@export var ai_behavior: String = "follow_owner"
@export var formation_offset: Vector2i = Vector2i(1, 0)
@export var tags: Array[String] = []
var master: BattleCharacter = null
@export var prioritize_ultimate: bool = true

func _init():
	if tags.is_empty():
		tags = []
	if skills.is_empty():
		skills = []

func initialize(pet_data: Dictionary, owner_char: BattleCharacter):
	master = owner_char
	pet_id = pet_data.get("id", "")
	name = pet_data.get("name", "")
	max_hp = pet_data.get("hp", 1000)
	current_hp = max_hp
	atk = pet_data.get("atk", 50)
	def = pet_data.get("def", 20)
	spd = pet_data.get("spd", 50)
	hit = pet_data.get("hit", 50)
	dodge = pet_data.get("dodge", 20)
	crit = pet_data.get("crit", 20)
	crit_dmg = pet_data.get("crit_dmg", 1.5)
	team = master.team
	skills = pet_data.get("skills", [])
	ai_behavior = pet_data.get("ai", "follow_owner")
	formation_offset = Vector2i(pet_data.get("offset_x", 1), pet_data.get("offset_y", 0))
	loyalty = 100
	level = 1
	exp = 0

func take_damage(amount: int, damage_type: String, source: BattleCharacter, is_crit: bool = false) -> int:
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

func heal(amount: int, source: BattleCharacter = null) -> int:
	var heal_amount = min(amount, max_hp - current_hp)
	current_hp += heal_amount
	return heal_amount

func die():
	current_hp = 0
	if master and master.pet == self:
		master.pet = null

func gain_exp(amount: int):
	exp += amount
	while exp >= get_exp_for_next_level():
		level_up()

func get_exp_for_next_level() -> int:
	return level * level * 100

func level_up():
	level += 1
	max_hp += int(max_hp * 0.05)
	atk += int(atk * 0.05)
	def += int(def * 0.05)
	spd += int(spd * 0.02)
	hit += int(hit * 0.02)
	dodge += int(dodge * 0.02)
	crit += int(crit * 0.02)
	current_hp = max_hp

func act(battle: CombatManager):
	if not is_alive():
		return
	
	match ai_behavior:
		"follow_owner":
			follow_owner(battle)
		"attack_nearest":
			attack_nearest(battle)
		"support_owner":
			support_owner(battle)
		"guard":
			guard_owner(battle)
		"passive":
			pass

func follow_owner(battle: CombatManager):
	if not master or not master.is_alive():
		attack_nearest(battle)
		return
	
	var target_pos = master.grid_pos + formation_offset
	var grid = battle.battle_grid
	if grid and grid.is_valid_position(target_pos) and grid.is_walkable(target_pos):
		if grid_pos != target_pos:
			grid.move_character(self, target_pos)
	
	# 检查周围敌人
	for enemy in battle.get_enemies(team):
		if enemy.is_alive() and grid_pos.distance_to(enemy.grid_pos) <= 3:
			attack_enemy(enemy, battle)
			return

func guard_owner(battle: CombatManager):
	if not master or not master.is_alive():
		return
	
	# 站在主人前面
	var grid = battle.battle_grid
	var guard_pos = master.grid_pos + Vector2i(-1, 0) if master.team == 0 else master.grid_pos + Vector2i(1, 0)
	if grid and grid.is_valid_position(guard_pos) and grid.is_walkable(guard_pos):
		if grid_pos != guard_pos:
			grid.move_character(self, guard_pos)
	
	# 拦截攻击
	for enemy in battle.get_enemies(team):
		if enemy.is_alive() and grid_pos.distance_to(enemy.grid_pos) <= 2:
			attack_enemy(enemy, battle)
			return

func support_owner(battle: CombatManager):
	if not master or not master.is_alive():
		return
	
	# 治疗主人
	if master.current_hp < master.max_hp * 0.6:
		var heal_skill = get_heal_skill()
		if heal_skill:
			var skill = WuxueDatabase.instance.get_wuxue(heal_skill)
			if skill and skill.can_use(self, battle):
				battle.execute_skill(self, master, skill)
				return
	
	# 给主人加buff
	var buff_skill = get_buff_skill()
	if buff_skill:
		var skill = WuxueDatabase.instance.get_wuxue(buff_skill)
		if skill and skill.can_use(self, battle):
			battle.execute_skill(self, master, skill)
			return
	
	# 没有支援技能，跟随
	follow_owner(battle)

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
		attack_enemy(nearest, battle)

func attack_enemy(target: BattleCharacter, battle: CombatManager):
	var skill_id = get_usable_skill(battle)
	if skill_id:
		var skill = WuxueDatabase.instance.get_wuxue(skill_id)
		if skill and skill.can_use(self, battle):
			battle.execute_skill(self, target, skill)
			return
	
	battle.execute_basic_attack(self, target)

func get_usable_skill(battle: CombatManager) -> String:
	var usable = []
	for skill_id in skills:
		var skill = WuxueDatabase.instance.get_wuxue(skill_id)
		if skill and skill.can_use(self, battle):
			if prioritize_ultimate and skill.is_ultimate:
				return skill_id
			usable.append(skill_id)
	
	if usable.is_empty():
		return ""
	
	if prioritize_ultimate:
		for skill_id in usable:
			var skill = WuxueDatabase.instance.get_wuxue(skill_id)
			if skill and skill.is_ultimate:
				return skill_id
	
	return usable[randi() % usable.size()]

func get_heal_skill() -> String:
	for skill_id in skills:
		var skill = WuxueDatabase.instance.get_wuxue(skill_id)
		if skill and skill.base_heal > 0:
			return skill_id
	return ""

func get_buff_skill() -> String:
	for skill_id in skills:
		var skill = WuxueDatabase.instance.get_wuxue(skill_id)
		if skill:
			for eff in skill.effects:
				if eff.effect_type in ["护盾", "属性加成", "增益", "加状态"]:
					return skill_id
	return ""

func is_alive() -> bool:
	return current_hp > 0

func to_dict() -> Dictionary:
	return {
		"id": pet_id,
		"name": name,
		"hp": current_hp,
		"max_hp": max_hp,
		"atk": atk,
		"def": def,
		"spd": spd,
		"hit": hit,
		"dodge": dodge,
		"crit": crit,
		"crit_dmg": crit_dmg,
		"team": team,
		"pos": grid_pos,
		"loyalty": loyalty,
		"level": level,
		"exp": exp,
		"skills": skills,
		"ai": ai_behavior,
		"offset_x": formation_offset.x,
		"offset_y": formation_offset.y,
		"tags": tags
	}

func from_dict(data: Dictionary) -> Pet:
	pet_id = data.get("id", "")
	name = data.get("name", "")
	current_hp = data.get("hp", max_hp)
	max_hp = data.get("max_hp", max_hp)
	atk = data.get("atk", atk)
	def = data.get("def", def)
	spd = data.get("spd", spd)
	hit = data.get("hit", hit)
	dodge = data.get("dodge", dodge)
	crit = data.get("crit", crit)
	crit_dmg = data.get("crit_dmg", crit_dmg)
	team = data.get("team", team)
	grid_pos = data.get("pos", Vector2i(-1, -1))
	loyalty = data.get("loyalty", loyalty)
	level = data.get("level", level)
	exp = data.get("exp", exp)
	skills = data.get("skills", skills)
	ai_behavior = data.get("ai", ai_behavior)
	formation_offset = Vector2i(data.get("offset_x", 1), data.get("offset_y", 0))
	tags = data.get("tags", tags)
	return self
