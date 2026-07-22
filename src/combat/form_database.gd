extends Resource
class_name FormDatabase

var forms: Dictionary = {}

func _init():
	# 慈悲相
	var form = FormData.new()
	form.form_id = "cibeixiang"
	form.name = "慈悲相"
	form.description = "花镜棠慈悲相，治疗辅助形态"
	form.stat_modifiers = {"heal_bonus": 0.5, "shield_bonus": 0.3, "atk": -0.3}
	form.skills = ["cibeixiang_heal", "cibeixiang_shield", "cibeixiang_cleanse"]
	form.ai_behavior = "support_owner"
	forms[form.form_id] = form
	
	# 忿怒相
	form = FormData.new()
	form.form_id = "fennuxiang"
	form.name = "忿怒相"
	form.description = "花镜棠忿怒相，高爆发输出形态"
	form.stat_modifiers = {"atk": 0.8, "crit": 0.5, "crit_dmg": 0.4, "def": -0.3}
	form.skills = ["fennuxiang_strike", "fennuxiang_aoe", "fennuxiang_execute"]
	form.ai_behavior = "aggressive"
	forms[form.form_id] = form
	
	# 魔刀
	form = FormData.new()
	form.form_id = "modao"
	form.name = "魔刀"
	form.description = "刀魔传人魔刀形态，吸血狂暴"
	form.stat_modifiers = {"atk": 0.5, "lifesteal": 0.3, "rage_gain": 2.0, "def": -0.2}
	form.skills = ["modao_blood", "modao_frenzy", "modao_devour"]
	form.ai_behavior = "aggressive"
	forms[form.form_id] = form
	
	# 佛刀
	form = FormData.new()
	form.form_id = "fodao"
	form.name = "佛刀"
	form.description = "刀魔传人佛刀形态，守护援护"
	form.stat_modifiers = {"def": 0.5, "block_chance": 0.3, "team_shield": 0.2, "heal_received": 0.3}
	form.skills = ["fodao_guard", "fodao_aid", "fodao_salvation"]
	form.ai_behavior = "protect_owner"
	forms[form.form_id] = form
	
	# 阴阳
	form = FormData.new()
	form.form_id = "yinyang"
	form.name = "阴阳"
	form.description = "华山派阴阳内气形态"
	form.stat_modifiers = {"yin_dmg": 0.4, "yang_heal": 0.4, "switch_cd": -1}
	form.skills = ["yinyang_switch", "yinyang_seal", "yinyang_balance"]
	form.ai_behavior = "balanced"
	forms[form.form_id] = form
	
	# 幻影
	form = FormData.new()
	form.form_id = "huanying"
	form.name = "幻影"
	form.description = "八大门幻影迷踪形态"
	form.stat_modifiers = {"dodge": 0.5, "phantom_chance": 0.3, "counter_dmg": 0.5}
	form.skills = ["huanying_dodge", "huanying_counter", "huanying_phantom"]
	form.ai_behavior = "evasive"
	forms[form.form_id] = form
	
	# 机关
	form = FormData.new()
	form.form_id = "jiguan"
	form.name = "机关"
	form.description = "不器门机关术形态"
	form.stat_modifiers = {"trap_dmg": 0.5, "trap_cd": -0.3, "trap_range": 1}
	form.skills = ["jiguan_trap", "jiguan_mine", "jiguan_mechanism"]
	form.ai_behavior = "tactical"
	forms[form.form_id] = form
	
	# 地雷
	form = FormData.new()
	form.form_id = "dilei"
	form.name = "地雷"
	form.description = "不器门地雷阵形态"
	form.stat_modifiers = {"mine_dmg": 0.5, "mine_cd": -0.3, "mine_stealth": true}
	form.skills = ["dilei_plant", "dilei_chain", "dilei_explode"]
	form.ai_behavior = "tactical"
	forms[form.form_id] = form
	
	# 龙拳
	form = FormData.new()
	form.form_id = "longquan"
	form.name = "龙拳"
	form.description = "南山派龙拳绝杀形态"
	form.stat_modifiers = {"atk": 0.8, "crit": 0.6, "crit_dmg": 0.5, "qi_speed": 0.5}
	form.skills = ["longquan_strike", "longquan_aoe", "longquan_execute"]
	form.ai_behavior = "aggressive"
	forms[form.form_id] = form
	
	# 剑气
	form = FormData.new()
	form.form_id = "jianqi"
	form.name = "剑气"
	form.description = "铁石岛剑气内伤形态"
	form.stat_modifiers = {"penetration": 0.5, "internal_dmg": 0.3, "qi_speed": 0.3}
	form.skills = ["jianqi_pierce", "jianqi_internal", "jianqi_burst"]
	form.ai_behavior = "aggressive"
	forms[form.form_id] = form
	
	# 内伤特效
	form = FormData.new()
	form.form_id = "neishang"
	form.name = "内伤"
	form.description = "持续内伤状态"
	form.stat_modifiers = {"mp_regen": -0.5, "heal_received": -0.5}
	form.skills = []
	form.ai_behavior = "passive"
	forms[form.form_id] = form
	
	# 重剑
	form = FormData.new()
	form.form_id = "zhongjian"
	form.name = "重剑"
	form.description = "铁石岛重剑无锋形态"
	form.stat_modifiers = {"atk": 0.6, "knockback": 1, "def": 0.2}
	form.skills = ["zhongjian_strike", "zhongjian_push", "zhongjian_break"]
	form.ai_behavior = "aggressive"
	forms[form.form_id] = form

static var _instance: FormDatabase = null

static func get_form(form_id: String) -> FormData:
	if _instance == null:
		_instance = FormDatabase.new()
	return _instance.forms.get(form_id)

static func get_all_forms() -> Array[FormData]:
	if _instance == null:
		_instance = FormDatabase.new()
	return _instance.forms.values()