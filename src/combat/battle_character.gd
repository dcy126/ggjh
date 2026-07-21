extends RefCounted
class_name BattleCharacter

@export var character_id: String
@export var character_name: String
@export var level: int = 1
@export var breakthrough: int = 0

## 基础属性
@export var max_hp: int = 1000
@export var current_hp: int = 1000
@export var max_mp: int = 100
@export var current_mp: int = 100
@export var atk: int = 100
@export var def: int = 100
@export var spd: int = 100
@export var hit: int = 100
@export var dodge: int = 50
@export var crit: int = 50
@export var crit_dmg: float = 1.5
@export var fortune: int = 50

## 战斗属性
@export var move_range: int = 2
@export var qi_speed: float = 1.0
@export var qi: int = 0
@export var max_qi: int = 100
@export var rage: int = 0
@export var max_rage: int = 100
@export var team: int = 0
@export var is_player_controlled: bool = true

## 位置
@export var grid_pos: Vector2i = Vector2i(0, 0)
@export var formation_position: int = 0

## 武学/心法/装备/天赋
@export var known_wuxue: Array[String] = []
@export var equipped_wuxue: Array[String] = []
@export var equipped_xinfa: Dictionary = {}
@export var equipped_items: Dictionary = {}
@export var talents: Array[CharacterTalent] = []
@export var exclusive_talent: CharacterTalent = null

## 状态
@export var status_effects: Array[StatusEffect] = []
@export var shields: Array[Shield] = []
@export var buffs: Dictionary = {}
@export var debuffs: Dictionary = {}

## 战斗状态标记
@export var is_dead: bool = false
@export var is_stunned: bool = false
@export var is_silenced: bool = false
@export var is_disarmed: bool = false
@export var is_frozen: bool = false
@export var is_rooted: bool = false
@export var is_blind: bool = false
@export var is_confused: bool = false
@export var is_feared: bool = false
@export var is_taunted: bool = false
@export var is_stealthed: bool = false
@export var is_invulnerable: bool = false
@export var is_untargetable: bool = false
@export var cannot_move: bool = false
@export var cannot_act: bool = false
@export var skip_turn: bool = false
@export var extra_turn: bool = false
@export var has_acted: bool = false
@export var has_moved: bool = false
@export var qi_gained_this_turn: int = 0

## 计数器
@export var combo_count: int = 0
@export var counter_count: int = 0
@export var chase_count: int = 0
@export var damage_taken_this_turn: int = 0
@export var damage_dealt_this_turn: int = 0
@export var heal_done_this_turn: int = 0
@export var shield_gained_this_turn: int = 0

## 召唤物/幻影/宠物
@export var summons: Array[Summon] = []
@export var phantoms: Array[Phantom] = []
@export var pet: Pet = null

## 变身/特殊形态
@export var current_form: String = ""
@export var form_data: Dictionary = {}

func _init():
	_init_defaults()

func _init_defaults():
	if equipped_xinfa.is_empty():
		equipped_xinfa = {
			"攻击": "",
			"防御": "",
			"辅助": "",
			"特殊": "",
			"通用": "",
			"通用2": "",
			"通用3": ""
		}
	if equipped_items.is_empty():
		equipped_items = {
			"武器": "", "头盔": "", "衣服": "", "护腕": "", "鞋子": "",
			"项链": "", "戒指": "", "腰带": "", "护符": "", "暗器": ""
		}
	if buffs.is_empty():
		buffs = {}
	if debuffs.is_empty():
		debuffs = {}

func is_alive() -> bool:
	return current_hp > 0 and not is_dead

func can_act() -> bool:
	return is_alive() and not cannot_act and not is_stunned and not is_frozen and not skip_turn

func can_move() -> bool:
	return is_alive() and not cannot_move and not is_rooted and not is_frozen

func take_damage(amount: int, damage_type: String, source: BattleCharacter, is_crit: bool = false) -> int:
	if is_invulnerable:
		return 0
	
	var final_damage = amount
	
	# 护盾吸收
	for shield in shields:
		if shield.can_absorb(damage_type):
			var absorbed = shield.absorb(final_damage)
			final_damage -= absorbed
			if final_damage <= 0:
				return 0
	
	# 伤害减免
	var dmg_reduction = get_total_damage_reduction()
	final_damage = int(final_damage * (1.0 - dmg_reduction))
	
	# 真实伤害无视防御
	if damage_type != "真实":
		var def_reduction = def / (def + 500.0)
		final_damage = int(final_damage * (1.0 - def_reduction * 0.5))
	
	final_damage = max(final_damage, 1)
	
	current_hp = max(current_hp - final_damage, 0)
	damage_taken_this_turn += final_damage
	
	if current_hp <= 0:
		die()
	
	# 触发受击效果
	trigger_on_hit_effects(source, final_damage, damage_type, is_crit)
	
	return final_damage

func heal(amount: int, source: BattleCharacter = null) -> int:
	if not is_alive():
		return 0
	
	var heal_amount = min(amount, max_hp - current_hp)
	current_hp += heal_amount
	heal_done_this_turn += heal_amount
	
	trigger_on_heal_effects(source, heal_amount)
	
	return heal_amount

func add_shield(amount: int, shield_type: String = "通用", duration: int = 1, source: BattleCharacter = null) -> Shield:
	var shield = Shield.new()
	shield.amount = amount
	shield.max_amount = amount
	shield.shield_type = shield_type
	shield.duration = duration
	shield.source = source
	shields.append(shield)
	shield_gained_this_turn += amount
	return shield

func add_rage(amount: int):
	rage = min(rage + amount, max_rage)
	check_rage_trigger()

func add_qi(amount: int):
	qi = min(qi + amount, max_qi)
	qi_gained_this_turn += amount

func gain_qi_speed_bonus(bonus: float):
	qi_speed = clamp(qi_speed + bonus, GameData.MIN_QI_SPEED, GameData.MAX_QI_SPEED)

func apply_status_effect(effect: StatusEffect):
	# 检查免疫
	if has_immunity_to(effect.effect_type):
		return
	
	# 检查已有同类效果
	var existing = find_status_effect(effect.effect_type)
	if existing:
		existing.refresh(effect)
	else:
		status_effects.append(effect)
		effect.on_apply(self)

func remove_status_effect(effect_type: String):
	for i in range(status_effects.size()):
		if status_effects[i].effect_type == effect_type:
			status_effects[i].on_remove(self)
			status_effects.remove_at(i)
			break

func find_status_effect(effect_type: String) -> StatusEffect:
	for effect in status_effects:
		if effect.effect_type == effect_type:
			return effect
	return null

func has_immunity_to(effect_type: String) -> bool:
	for effect in status_effects:
		if effect.effect_type == "免疫" and effect.params.has("immune_to"):
			if effect_type in effect.params["immune_to"]:
				return true
	return false

func get_total_damage_reduction() -> float:
	var reduction = 0.0
	for effect in status_effects:
		if effect.effect_type == "减伤":
			reduction += effect.params.get("value", 0.0)
	for buff in buffs.values():
		if buff.has("damage_reduction"):
			reduction += buff["damage_reduction"]
	return clamp(reduction, 0.0, 0.9)

func get_total_damage_bonus() -> float:
	var bonus = 0.0
	for effect in status_effects:
		if effect.effect_type == "增伤":
			bonus += effect.params.get("value", 0.0)
	return bonus

func get_total_crit_chance() -> float:
	var chance = crit / 10000.0
	for effect in status_effects:
		if effect.effect_type == "暴击率":
			chance += effect.params.get("value", 0.0)
	return clamp(chance, 0.0, 1.0)

func get_total_crit_damage() -> float:
	var dmg = crit_dmg
	for effect in status_effects:
		if effect.effect_type == "暴击伤害":
			dmg += effect.params.get("value", 0.0)
	return dmg

func get_total_hit_chance(target: BattleCharacter) -> float:
	var base_hit = hit / 10000.0
	var target_dodge = target.dodge / 10000.0
	var chance = base_hit - target_dodge + 0.5
	
	for effect in status_effects:
		if effect.effect_type == "命中":
			chance += effect.params.get("value", 0.0)
	
	return clamp(chance, 0.05, 0.95)

func get_total_dodge_chance(attacker: BattleCharacter) -> float:
	var base_dodge = dodge / 10000.0
	var attacker_hit = attacker.hit / 10000.0
	var chance = base_dodge - attacker_hit + 0.5
	
	for effect in status_effects:
		if effect.effect_type == "闪避":
			chance += effect.params.get("value", 0.0)
	
	return clamp(chance, 0.05, 0.95)

func check_rage_trigger():
	if rage >= 100 and has_ultimate_ready():
		# 可以释放大招
		pass

func has_ultimate_ready() -> bool:
	for wuxue_id in equipped_wuxue:
		var wuxue = WuxueDatabase.get_wuxue(wuxue_id)
		if wuxue and wuxue.is_ultimate and wuxue.cooldown == 0:
			if current_mp >= wuxue.mp_cost and rage >= wuxue.rage_cost:
				return true
	return false

func trigger_on_hit_effects(source: BattleCharacter, damage: int, damage_type: String, is_crit: bool):
	for talent in talents:
		if talent.trigger_type == "受击" and randf() < talent.trigger_chance:
			apply_talent_effect(talent, source)
	
	for effect in status_effects:
		if effect.trigger == "受击":
			effect.trigger_effect(self, source)

func trigger_on_heal_effects(source: BattleCharacter, amount: int):
	for talent in talents:
		if talent.trigger_type == "治疗" and randf() < talent.trigger_chance:
			apply_talent_effect(talent, source)

func apply_talent_effect(talent: CharacterTalent, target: BattleCharacter):
	var params = talent.get_effect_params()
	for effect_type in params:
		match effect_type:
			"属性加成":
				for stat in params[effect_type]:
					add_temp_stat(stat, params[effect_type][stat])
			"添加状态":
				for status_type in params[effect_type]:
					var se = StatusEffect.new()
					se.effect_type = status_type
					se.params = params[effect_type][status_type]
					apply_status_effect(se)

func add_temp_stat(stat: String, value: float):
	var current = buffs.get(stat, 0.0)
	buffs[stat] = current + value

func get_effective_stat(stat: String) -> float:
	var base = 0
	match stat:
		"atk": base = atk
		"def": base = def
		"spd": base = spd
		"hit": base = hit
		"dodge": base = dodge
		"crit": base = crit
		"fortune": base = fortune
		"move_range": base = move_range
		"qi_speed": base = qi_speed
		_: return 0
	
	var bonus = buffs.get(stat, 0.0) - debuffs.get(stat, 0.0)
	for effect in status_effects:
		if effect.effect_type == stat:
			bonus += effect.params.get("value", 0.0)
	
	return base + bonus

func die():
	is_dead = true
	current_hp = 0
	# 触发死亡效果
	for talent in talents:
		if talent.trigger_type == "死亡":
			apply_talent_effect(talent, null)
	for effect in status_effects:
		if effect.trigger == "死亡":
			effect.trigger_effect(self, null)

func revive(hp_percent: float = 1.0):
	is_dead = false
	current_hp = int(max_hp * hp_percent)
	# 清除负面状态
	clear_debuffs()

func clear_debuffs():
	var to_remove = []
	for effect in status_effects:
		if effect.category == "减益":
			to_remove.append(effect)
	for effect in to_remove:
		remove_status_effect(effect.effect_type)

func clear_buffs():
	var to_remove = []
	for effect in status_effects:
		if effect.category == "增益":
			to_remove.append(effect)
	for effect in to_remove:
		remove_status_effect(effect.effect_type)

func clear_all_status():
	status_effects.clear()

func has_weapon(weapon_type: String) -> bool:
	var weapon_id = equipped_items.get("武器", "")
	if weapon_id:
		var weapon = EquipmentDatabase.get_equipment(weapon_id)
		if weapon and weapon.weapon_type == weapon_type:
			return true
	return false

func get_equipped_wuxue_data() -> Array[WuxueData]:
	var result = []
	for wuxue_id in equipped_wuxue:
		var wuxue = WuxueDatabase.get_wuxue(wuxue_id)
		if wuxue:
			result.append(wuxue)
	return result

func get_available_wuxue() -> Array[WuxueData]:
	var result = []
	for wuxue_id in known_wuxue:
		var wuxue = WuxueDatabase.get_wuxue(wuxue_id)
		if wuxue and wuxue.can_use(self, CombatManager.get_instance()):
			result.append(wuxue)
	return result

func to_dict() -> Dictionary:
	return {
		"id": character_id,
		"name": character_name,
		"level": level,
		"breakthrough": breakthrough,
		"hp": current_hp,
		"mp": current_mp,
		"qi": qi,
		"rage": rage,
		"pos": grid_pos,
		"team": team,
		"status": [s.to_dict() for s in status_effects],
		"shields": [s.to_dict() for s in shields]
	}

func from_dict(data: Dictionary):
	character_id = data.get("id", "")
	character_name = data.get("name", "")
	level = data.get("level", 1)
	breakthrough = data.get("breakthrough", 0)
	current_hp = data.get("hp", max_hp)
	current_mp = data.get("mp", max_mp)
	qi = data.get("qi", 0)
	rage = data.get("rage", 0)
	grid_pos = data.get("pos", Vector2i(0, 0))
	team = data.get("team", 0)
	
	for s_data in data.get("status", []):
		var se = StatusEffect.new().from_dict(s_data)
		status_effects.append(se)
	
	for s_data in data.get("shields", []):
		var sh = Shield.new().from_dict(s_data)
		shields.append(sh)
