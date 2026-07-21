extends Resource
class_name XinfaEffect

@export var effect_type: String = ""
@export var trigger: String = "常驻"
@export var trigger_chance: float = 1.0
@export var params: Dictionary = {}
@export var duration: int = 0
@export var max_stacks: int = 1
@export var stack_type: String = "刷新"
@export var target: String = "自身"
@export var conditions: Array[Dictionary] = []
@export var description: String = ""

func _init():
	if params.is_empty():
		params = {}

func scale_with_level(level: int):
	var mult = 1.0 + (level - 1) * 0.05
	for key in params:
		if params[key] is int or params[key] is float:
			params[key] *= mult

func get_description() -> String:
	if description != "":
		return description
	
	var desc = ""
	match effect_type:
		"属性加成":
			var stat = params.get("stat", "")
			var value = params.get("value", 0)
			desc = "%s %+.0f" % [stat, value]
		"伤害加成":
			var dmg_type = params.get("damage_type", "所有")
			var value = params.get("value", 0.0)
			desc = "%s伤害加成 %+.0f%%" % [dmg_type, value * 100]
		"减伤":
			var value = params.get("value", 0.0)
			desc = "减伤 %+.0f%%" % [value * 100]
		"回血":
			var value = params.get("value", 0)
			var scaling = params.get("scaling", "atk")
			desc = "回血 %d(+%s)" % [value, scaling]
		"护盾":
			var value = params.get("value", 0)
			desc = "护盾 %d" % value
		"加怒气":
			var value = params.get("value", 0)
			desc = "怒气 +%d" % value
		"减怒气":
			var value = params.get("value", 0)
			desc = "怒气 -%d" % value
		"加集气":
			var value = params.get("value", 0.0)
			desc = "集气速度 %+.0f%%" % [value * 100]
		"减集气":
			var value = params.get("value", 0.0)
			desc = "集气速度 %-.0f%%" % [value * 100]
		"眩晕":
			var chance = params.get("chance", 0.0)
			desc = "眩晕 %.0f%%" % [chance * 100]
		"定身":
			var chance = params.get("chance", 0.0)
			desc = "定身 %.0f%%" % [chance * 100]
		"沉默":
			var chance = params.get("chance", 0.0)
			desc = "沉默 %.0f%%" % [chance * 100]
		"缴械":
			var chance = params.get("chance", 0.0)
			desc = "缴械 %.0f%%" % [chance * 100]
		"中毒":
			var dmg = params.get("damage", 0)
			var dur = params.get("duration", 0)
			desc = "中毒 %d/回合(%d回合)" % [dmg, dur]
		"燃烧":
			var dmg = params.get("damage", 0)
			var dur = params.get("duration", 0)
			desc = "燃烧 %d/回合(%d回合)" % [dmg, dur]
		"流血":
			var dmg = params.get("damage", 0)
			var dur = params.get("duration", 0)
			desc = "流血 %d/回合(%d回合)" % [dmg, dur]
		"反击":
			var chance = params.get("chance", 0.0)
			desc = "反击 %.0f%%" % [chance * 100]
		"反伤":
			var value = params.get("value", 0.0)
			desc = "反伤 %+.0f%%" % [value * 100]
		"吸血":
			var value = params.get("value", 0.0)
			desc = "吸血 %+.0f%%" % [value * 100]
		"格挡":
			var chance = params.get("chance", 0.0)
			var value = params.get("value", 0.0)
			desc = "格挡 %.0f%%(%+.0f%%)" % [chance * 100, value * 100]
		"无敌":
			var dur = params.get("duration", 0)
			desc = "无敌 %d回合" % dur
		"隐身":
			var dur = params.get("duration", 0)
			desc = "隐身 %d回合" % dur
		"分身":
			var count = params.get("count", 0)
			desc = "分身 %d个" % count
		"召唤":
			var id = params.get("summon_id", "")
			desc = "召唤 %s" % id
		"清除减益":
			var count = params.get("count", 0)
			desc = "清除%d个减益" % count
		"清除增益":
			var count = params.get("count", 0)
			desc = "清除%d个增益" % count
		"复活":
			var hp_pct = params.get("hp_percent", 0.0)
			desc = "复活(%.0f%%血量)" % [hp_pct * 100]
		"延迟生效":
			var timestamp = params.get("timestamp", 0)
			var effect_id = params.get("effect_id", "")
			desc = "%d时序触发%s" % [timestamp, effect_id]
		"按时序触发":
			var timestamps = params.get("timestamps", [])
			var effect_id = params.get("effect_id", "")
			desc = "时序%s触发%s" % [timestamps, effect_id]
		"连击":
			var count = params.get("count", 0)
			desc = "连击%d次" % count
		"追击":
			var chance = params.get("chance", 0.0)
			desc = "追击 %.0f%%" % [chance * 100]
		"协同":
			var ally = params.get("ally", "")
			desc = "与%s协同" % ally
		"合击":
			var allies = params.get("allies", [])
			desc = "与%s合击" % allies
		"变身":
			var form = params.get("form", "")
			desc = "变身:%s" % form
		"化蝶":
			desc = "化蝶"
		"魔刀":
			desc = "魔刀"
		"佛刀":
			desc = "佛刀"
		"阴阳":
			desc = "阴阳"
		"幻影":
			desc = "幻影"
		"机关":
			desc = "机关"
		"地雷":
			desc = "地雷"
		"龙拳":
			desc = "龙拳"
		"剑气":
			desc = "剑气"
		"内伤":
			desc = "内伤"
		"重剑":
			desc = "重剑"
		"慈悲相":
			desc = "慈悲相"
		"忿怒相":
			desc = "忿怒相"
		"援护":
			desc = "援护"
		"挡刀":
			desc = "挡刀"
		_:
			desc = effect_type
	
	if trigger != "常驻":
		desc = "[%s] %s" % [trigger, desc]
	if trigger_chance < 1.0:
		desc = "%.0f%% %s" % [trigger_chance * 100, desc]
	
	return desc

func check_conditions(caster: 'BattleCharacter', target: 'BattleCharacter', battle: 'CombatManager') -> bool:
	for cond in conditions:
		var cond_type = cond.get("type", "")
		var cond_value = cond.get("value", 0)
		match cond_type:
			"hp_above":
				if caster.current_hp / caster.max_hp <= cond_value:
					return false
			"hp_below":
				if caster.current_hp / caster.max_hp >= cond_value:
					return false
			"mp_above":
				if caster.current_mp / caster.max_mp <= cond_value:
					return false
			"rage_above":
				if caster.rage <= cond_value:
					return false
			"has_status":
				if not caster.has_status(cond_value):
					return false
			"not_has_status":
				if caster.has_status(cond_value):
					return false
			"has_buff":
				if not caster.has_buff(cond_value):
					return false
			"has_debuff":
				if not caster.has_debuff(cond_value):
					return false
			"team_hp_above":
				var avg = battle.get_team_avg_hp(caster.team)
				if avg <= cond_value:
					return false
			"enemy_count":
				if battle.get_enemy_count(caster.team) < cond_value:
					return false
			"ally_count":
				if battle.get_ally_count(caster.team) < cond_value:
					return false
			"timestamp":
				if battle.current_timestamp != cond_value:
					return false
			"turn":
				if battle.current_turn != cond_value:
					return false
			"wuxue_used":
				if not caster.last_used_wuxue.has(cond_value):
					return false
			"weapon_type":
				if caster.weapon_type != cond_value:
					return false
			"sect":
				if caster.sect != cond_value:
					return false
	return true

func apply(caster: 'BattleCharacter', target: 'BattleCharacter', battle: 'CombatManager'):
	if not check_conditions(caster, target, battle):
		return
	
	if randf() > trigger_chance:
		return
	
	match effect_type:
		"属性加成":
			var stat = params.get("stat", "")
			var value = params.get("value", 0)
			target.add_stat_bonus(stat, value, duration)
		"伤害加成":
			target.add_damage_bonus(params.get("damage_type", "所有"), params.get("value", 0.0), duration)
		"减伤":
			target.add_damage_reduction(params.get("value", 0.0), duration)
		"回血":
			var heal = params.get("value", 0)
			var scaling = params.get("scaling", "atk")
			var actual_heal = heal
			if scaling == "atk":
				actual_heal += int(caster.atk * params.get("scaling_mult", 0.5))
			elif scaling == "spd":
				actual_heal += int(caster.spd * params.get("scaling_mult", 0.5))
			target.heal(actual_heal, caster)
		"护盾":
			target.add_shield(params.get("value", 0), duration)
		"加怒气":
			target.gain_rage(params.get("value", 0))
		"减怒气":
			target.lose_rage(params.get("value", 0))
		"加集气":
			target.add_qi_speed_bonus(params.get("value", 0.0), duration)
		"减集气":
			target.add_qi_speed_bonus(-params.get("value", 0.0), duration)
		"眩晕":
			target.add_status("眩晕", duration)
		"定身":
			target.add_status("定身", duration)
		"沉默":
			target.add_status("沉默", duration)
		"缴械":
			target.add_status("缴械", duration)
		"中毒":
			target.add_status("中毒", duration, params.get("damage", 0))
		"燃烧":
			target.add_status("燃烧", duration, params.get("damage", 0))
		"流血":
			target.add_status("流血", duration, params.get("damage", 0))
		"反击":
			target.add_status("反击", duration, params.get("chance", 0.0))
		"反伤":
			target.add_status("反伤", duration, params.get("value", 0.0))
		"吸血":
			target.add_status("吸血", duration, params.get("value", 0.0))
		"格挡":
			target.add_status("格挡", duration, {"chance": params.get("chance", 0.0), "value": params.get("value", 0.0)})
		"无敌":
			target.add_status("无敌", duration)
		"隐身":
			target.add_status("隐身", duration)
		"分身":
			battle.summon_phantom(caster, params.get("count", 1), duration)
		"召唤":
			battle.summon_unit(caster.team, params.get("summon_id", ""), caster.grid_pos, duration)
		"清除减益":
			target.remove_debuffs(params.get("count", 999))
		"清除增益":
			target.remove_buffs(params.get("count", 999))
		"复活":
			if target.current_hp <= 0:
				target.revive(params.get("hp_percent", 0.5))
		"延迟生效":
			battle.schedule_effect(params.get("timestamp", 0), caster, target, params.get("effect_id", ""))
		"按时序触发":
			battle.schedule_timestamp_effects(params.get("timestamps", []), caster, target, params.get("effect_id", ""))
		"变身":
			target.transform(params.get("form", ""), duration)
		"化蝶":
			target.transform("化蝶", duration)
		"魔刀":
			target.transform("魔刀", duration)
		"佛刀":
			target.transform("佛刀", duration)
		"阴阳":
			target.add_status("阴阳", duration)
		"幻影":
			target.add_status("幻影", duration)
		"机关":
			battle.place_trap(caster.team, caster.grid_pos, params.get("trap_type", ""), duration)
		"地雷":
			battle.place_mine(caster.team, caster.grid_pos, params.get("damage", 0), duration)
		"龙拳":
			target.add_status("龙拳", duration)
		"剑气":
			target.add_status("剑气", duration)
		"内伤":
			target.add_status("内伤", duration)
		"重剑":
			target.add_status("重剑", duration)
		"慈悲相":
			target.transform("慈悲相", -1)
		"忿怒相":
			target.transform("忿怒相", -1)
		"援护":
			target.add_status("援护", duration)
		"挡刀":
			target.add_status("挡刀", duration)
		_:
			print("Unknown effect: ", effect_type)