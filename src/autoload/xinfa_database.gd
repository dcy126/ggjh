extends RefCounted
class_name XinfaDatabase

var xinfa_list: Dictionary = {}
var xinfa_by_slot: Dictionary = {}
var xinfa_by_color: Dictionary = {}
var xinfa_by_quality: Dictionary = {}
var xinfa_sets: Dictionary = {}

static var instance: XinfaDatabase = null

func _init():
	instance = self
	_load_all_xinfa()

func _load_all_xinfa():
	# 攻击类心诀
	_create_attack_xinfa()
	
	# 防御类心诀
	_create_defense_xinfa()
	
	# 辅助类心诀
	_create_support_xinfa()
	
	# 特殊类心诀
	_create_special_xinfa()
	
	# 通用/万能类心诀
	_create_universal_xinfa()
	
	# 套装心诀
	_create_xinfa_sets()
	
	# 构建索引
	_build_indices()

func _create_attack_xinfa():
	# 奋战 - 红色攻击
	var x = _create_base_xinfa("fen_zhan", "奋战", "攻击", "红", 0)
	x.stat_bonuses = {"atk%": 0.3, "crit%": 0.15, "crit_dmg%": 0.2}
	x.combat_effects.append(_create_xinfa_effect("伤害加成", "常驻", 1.0, {"damage_type": "所有", "value": 0.3}))
	x.combat_effects.append(_create_xinfa_effect("暴击增伤", "暴击", 1.0, {"extra_crit_dmg": 0.2}))
	x.tags = ["输出", "暴击"]
	
	# 追命 - 金色攻击
	x = _create_base_xinfa("zhui_ming", "追命", "攻击", "金", 5)
	x.stat_bonuses = {"atk%": 0.25, "hit%": 0.2, "penetration%": 0.15}
	x.combat_effects.append(_create_xinfa_effect("穿透", "常驻", 1.0, {"ignore_def": 0.15}))
	x.combat_effects.append(_create_xinfa_effect("必中", "攻击", 0.1, {"ignore_dodge": true}))
	x.tags = ["穿透", "必中"]
	
	# 迅闪 - 紫色攻击
	x = _create_base_xinfa("xun_shan", "迅闪", "攻击", "紫", 8)
	x.stat_bonuses = {"spd%": 0.3, "qi_speed%": 0.25, "dodge%": 0.15}
	x.combat_effects.append(_create_xinfa_effect("先手", "回合开始", 1.0, {"qi_bonus": 30}))
	x.combat_effects.append(_create_xinfa_effect("闪避反击", "闪避", 0.3, {"counter": true}))
	x.tags = ["速度", "先手", "闪避"]
	
	# 洪流 - 蓝色攻击
	x = _create_base_xinfa("hong_liu", "洪流", "攻击", "蓝", 3)
	x.stat_bonuses = {"atk%": 0.15, "combo_dmg%": 0.2}
	x.combat_effects.append(_create_xinfa_effect("连击伤害", "连击", 1.0, {"bonus_per_hit": 0.1}))
	x.combat_effects.append(_create_xinfa_effect("追击", "击杀", 0.5, {"chance": 0.5}))
	x.tags = ["连击", "追击"]
	
	# 强臂 - 白色万能
	x = _create_base_xinfa("qiang_bi", "强臂", "万能", "白", 1)
	x.stat_bonuses = {"atk": 50}
	x.combat_effects.append(_create_xinfa_effect("基础攻击", "常驻", 1.0, {"flat_atk": 50}))
	x.tags = ["基础", "攻击"]

func _create_defense_xinfa():
	# 化劲 - 红色防御
	var x = _create_base_xinfa("hua_jin", "化劲", "防御", "红", 0)
	x.stat_bonuses = {"def%": 0.3, "dmg_reduction%": 0.2, "hp%": 0.15}
	x.combat_effects.append(_create_xinfa_effect("化劲", "受击", 1.0, {"damage_to_shield": 0.5}))
	x.combat_effects.append(_create_xinfa_effect("反震", "受击", 0.3, {"reflect_damage": 0.3}))
	x.tags = ["化劲", "反震", "护盾"]
	
	# 争锋 - 金色防御
	x = _create_base_xinfa("zheng_feng", "争锋", "防御", "金", 5)
	x.stat_bonuses = {"def%": 0.25, "block%": 0.2, "counter%": 0.15}
	x.combat_effects.append(_create_xinfa_effect("格挡", "受击", 0.4, {"reduction": 0.6}))
	x.combat_effects.append(_create_xinfa_effect("反击", "格挡", 1.0, {"damage_multiplier": 1.0}))
	x.tags = ["格挡", "反击", "主角专属"]
	
	# 卸力 - 紫色防御
	x = _create_base_xinfa("xie_li", "卸力", "防御", "紫", 8)
	x.stat_bonuses = {"def%": 0.2, "dmg_reduction%": 0.15, "move_range": 1}
	x.combat_effects.append(_create_xinfa_effect("卸力", "受击", 0.5, {"redirect_damage": 0.3}))
	x.combat_effects.append(_create_xinfa_effect("位移", "受击", 0.3, {"distance": 1}))
	x.tags = ["卸力", "位移"]
	
	# 援护 - 蓝色防御
	x = _create_base_xinfa("yuan_hu", "援护", "防御", "蓝", 3)
	x.stat_bonuses = {"def%": 0.15, "aid_chance%": 0.25}
	x.combat_effects.append(_create_xinfa_effect("援护", "友方受击", 0.3, {"range": 2, "block_chance": 0.5}))
	x.combat_effects.append(_create_xinfa_effect("分担伤害", "援护", 1.0, {"share_ratio": 0.3}))
	x.tags = ["援护", "分担", "队友"]
	
	# 壮骨 - 白色万能
	x = _create_base_xinfa("zhuang_gu", "壮骨", "万能", "白", 1)
	x.stat_bonuses = {"hp": 200, "def": 20}
	x.combat_effects.append(_create_xinfa_effect("基础血防", "常驻", 1.0, {"flat_hp": 200, "flat_def": 20}))
	x.tags = ["基础", "血量", "防御"]

func _create_support_xinfa():
	# 苍冥 - 红色辅助
	var x = _create_base_xinfa("cang_ming", "苍冥", "辅助", "红", 0)
	x.stat_bonuses = {"heal%": 0.4, "mp_regen%": 0.3, "shield%": 0.25}
	x.combat_effects.append(_create_xinfa_effect("治疗增强", "治疗", 1.0, {"heal_bonus": 0.4}))
	x.combat_effects.append(_create_xinfa_effect("群体护盾", "治疗", 0.3, {"team_shield": 200, "duration": 2}))
	x.combat_effects.append(_create_xinfa_effect("回蓝", "回合开始", 1.0, {"team_mp": 20}))
	x.tags = ["治疗", "护盾", "回蓝"]
	
	# 酣畅 - 金色辅助
	x = _create_base_xinfa("han_chang", "酣畅", "辅助", "金", 5)
	x.stat_bonuses = {"qi_speed%": 0.3, "rage_gain%": 0.4, "cd_reduction%": 0.15}
	x.combat_effects.append(_create_xinfa_effect("加速集气", "常驻", 1.0, {"qi_speed": 0.3}))
	x.combat_effects.append(_create_xinfa_effect("怒气加速", "常驻", 1.0, {"rage_per_action": 0.4}))
	x.combat_effects.append(_create_xinfa_effect("缩减CD", "技能结束", 1.0, {"cd_reduce": 1}))
	x.tags = ["集气", "怒气", "缩减CD"]
	
	# 清心 - 紫色辅助
	x = _create_base_xinfa("qing_xin", "清心", "辅助", "紫", 8)
	x.stat_bonuses = {"heal%": 0.2, "debuff_resist%": 0.3, "fortune%": 0.2}
	x.combat_effects.append(_create_xinfa_effect("净化", "回合开始", 1.0, {"remove_debuffs": 1}))
	x.combat_effects.append(_create_xinfa_effect("免疫控制", "受击", 0.2, {"immune_control": true, "duration": 1}))
	x.tags = ["净化", "免疫控制", "福缘"]
	
	# 麒麟 - 蓝色辅助
	x = _create_base_xinfa("qi_lin", "麒麟", "辅助", "蓝", 3)
	x.stat_bonuses = {"hp%": 0.15, "shield%": 0.2, "aid_chance%": 0.2}
	x.combat_effects.append(_create_xinfa_effect("护盾", "回合开始", 1.0, {"team_shield": 100, "duration": 1}))
	x.combat_effects.append(_create_xinfa_effect("援护", "友方受击", 0.25, {"damage_share": 0.2}))
	x.tags = ["护盾", "援护", "团队"]
	
	# 龟寿 - 白色万能
	x = _create_base_xinfa("gui_shou", "龟寿", "万能", "白", 1)
	x.stat_bonuses = {"hp%": 0.1, "mp%": 0.1}
	x.combat_effects.append(_create_xinfa_effect("基础血蓝", "常驻", 1.0, {"hp%": 0.1, "mp%": 0.1}))
	x.tags = ["基础", "血量", "内力"]

func _create_special_xinfa():
	# 电掣 - 红色特殊
	var x = _create_base_xinfa("dian_che", "电掣", "特殊", "红", 0)
	x.stat_bonuses = {"qi_speed%": 0.5, "combo%": 0.3, "chase%": 0.2}
	x.combat_effects.append(_create_xinfa_effect("疾风", "回合开始", 1.0, {"qi": 50}))
	x.combat_effects.append(_create_xinfa_effect("连环", "攻击", 0.4, {"extra_hits": 2, "dmg_multiplier": 0.5}))
	x.combat_effects.append(_create_xinfa_effect("追击", "击杀", 1.0, {"chance": 1.0}))
	x.tags = ["集气", "连击", "追击", "集气流"]
	
	# 修罗 - 金色特殊
	x = _create_base_xinfa("xiu_luo", "修罗", "特殊", "金", 5)
	x.stat_bonuses = {"atk%": 0.2, "crit%": 0.25, "crit_dmg%": 0.3, "hp_cost%": 0.1}
	x.combat_effects.append(_create_xinfa_effect("修罗", "hp低于50%", 1.0, {"atk_bonus": 0.5, "crit_bonus": 0.3}))
	x.combat_effects.append(_create_xinfa_effect("嗜血", "击杀", 1.0, {"heal%": 0.2, "rage": 20}))
	x.tags = ["低血高伤", "嗜血", "修罗"]
	
	# 惊蛰 - 紫色特殊
	x = _create_base_xinfa("jing_zhe", "惊蛰", "特殊", "紫", 8)
	x.stat_bonuses = {"spd%": 0.25, "counter%": 0.2, "first_strike%": 0.3}
	x.combat_effects.append(_create_xinfa_effect("先手", "战斗开始", 1.0, {"qi": 100}))
	x.combat_effects.append(_create_xinfa_effect("反击", "受击", 0.3, {"chance": 1.0, "dmg": 1.5}))
	x.tags = ["先手", "反击", "反手"]
	
	# 归元 - 蓝色特殊
	x = _create_base_xinfa("gui_yuan", "归元", "特殊", "蓝", 3)
	x.stat_bonuses = {"mp_regen%": 0.5, "heal_received%": 0.3, "revive%": 0.1}
	x.combat_effects.append(_create_xinfa_effect("回蓝", "回合开始", 1.0, {"self_mp": 30}))
	x.combat_effects.append(_create_xinfa_effect("自愈", "回合结束", 1.0, {"heal%": 0.1}))
	x.combat_effects.append(_create_xinfa_effect("归元", "死亡", 0.1, {"revive_hp%": 0.5}))
	x.tags = ["回蓝", "自愈", "复活"]
	
	# 迷离 - 白色万能特殊
	x = _create_base_xinfa("mi_li", "迷离", "万能", "白", 1)
	x.stat_bonuses = {"dodge%": 0.1, "confuse_resist%": 0.2}
	x.combat_effects.append(_create_xinfa_effect("迷离", "受击", 0.1, {"confuse_attacker": true, "duration": 1}))
	x.tags = ["迷离", "混乱", "闪避"]

func _create_universal_xinfa():
	# 万能心诀 - 可以装备在任何槽位
	var x = _create_base_xinfa("wan_neng", "万能心诀", "万能", "万能", 0)
	x.stat_bonuses = {"all_stats%": 0.05}
	x.combat_effects.append(_create_xinfa_effect("全属性", "常驻", 1.0, {"all_stats%": 0.05}))
	x.tags = ["万能", "全属性"]
	
	# 激潜 - 增加器值上限
	x = _create_base_xinfa("ji_qian", "激潜", "万能", "绿", -3)
	x.stat_bonuses = {"qi_value_max": 3}
	x.combat_effects.append(_create_xinfa_effect("激发潜能", "常驻", 1.0, {"extra_qi_value": 3}))
	x.tags = ["器值", "潜能"]

func _create_xinfa_sets():
	# 奋战套装
	var set = XinfaSetData.new()
	set.set_id = "fenzhan_set"
	set.name = "奋战套装"
	set.piece_ids = ["fen_zhan", "qiang_bi", "zhuang_gu", "wan_neng"]
	set.effects = {
		"2": {"type": "属性加成", "params": {"atk%": 0.15, "crit%": 0.1}},
		"4": {"type": "特殊效果", "params": {"effect_id": "fenzhan_4pc", "desc": "暴击时额外造成15%伤害"}}
	}
	xinfa_sets[set.set_id] = set
	
	# 化劲套装
	set = XinfaSetData.new()
	set.set_id = "huajin_set"
	set.name = "化劲套装"
	set.piece_ids = ["hua_jin", "zheng_feng", "gui_shou", "wan_neng"]
	set.effects = {
		"2": {"type": "属性加成", "params": {"def%": 0.15, "dmg_reduction%": 0.1}},
		"4": {"type": "特殊效果", "params": {"effect_id": "huajin_4pc", "desc": "受击时有30%几率化解伤害并反震"}}
	}
	xinfa_sets[set.set_id] = set

func _create_base_xinfa(id: String, name: String, slot_type: String, color: String, qi_cost: int) -> XinfaData:
	var x = XinfaData.new()
	x.id = id
	x.name = name
	x.slot_type = slot_type
	x.color = color
	x.quality = color
	x.base_qi_cost = qi_cost
	xinfa_list[id] = x
	return x

func _create_xinfa_effect(effect_type: String, trigger: String, chance: float, params: Dictionary) -> XinfaEffect:
	var e = XinfaEffect.new()
	e.effect_type = effect_type
	e.trigger = trigger
	e.trigger_chance = chance
	e.params = params
	return e

func _build_indices():
	xinfa_by_slot.clear()
	xinfa_by_color.clear()
	xinfa_by_quality.clear()
	
	for x in xinfa_list.values():
		if not xinfa_by_slot.has(x.slot_type):
			xinfa_by_slot[x.slot_type] = []
		xinfa_by_slot[x.slot_type].append(x)
		
		if not xinfa_by_color.has(x.color):
			xinfa_by_color[x.color] = []
		xinfa_by_color[x.color].append(x)
		
		if not xinfa_by_quality.has(x.quality):
			xinfa_by_quality[x.quality] = []
		xinfa_by_quality[x.quality].append(x)

func get_xinfa(id: String) -> XinfaData:
	return xinfa_list.get(id)

func get_all_xinfa() -> Array[XinfaData]:
	return xinfa_list.values()

func get_xinfa_by_slot(slot_type: String) -> Array[XinfaData]:
	return xinfa_by_slot.get(slot_type, [])

func get_xinfa_by_color(color: String) -> Array[XinfaData]:
	return xinfa_by_color.get(color, [])

func get_xinfa_by_quality(quality: String) -> Array[XinfaData]:
	return xinfa_by_quality.get(quality, [])

func get_xinfa_set(set_id: String) -> XinfaSetData:
	return xinfa_sets.get(set_id)

func get_all_xinfa_sets() -> Array[XinfaSetData]:
	return xinfa_sets.values()

func get_random_xinfa(slot_type: String = "", color: String = "", quality_weights: Dictionary = {}) -> XinfaData:
	var candidates = xinfa_list.values()
	
	if slot_type != "":
		candidates = candidates.filter(func(x): return x.slot_type == slot_type or x.slot_type == "万能")
	
	if color != "":
		candidates = candidates.filter(func(x): return x.color == color)
	
	if candidates.is_empty():
		return null
	
	if quality_weights.is_empty():
		return candidates[randi() % candidates.size()]
	
	# 加权随机
	var rand = rng.randf_range(0.0, 1.0)
	var cumulative = 0.0
	var qualities = ["白", "绿", "蓝", "紫", "金", "红", "万能"]
	
	for q in qualities:
		cumulative += quality_weights.get(q, 0.0)
		if rand <= cumulative:
			var filtered = candidates.filter(func(x): return x.quality == q)
			if filtered.size() > 0:
				return filtered[randi() % filtered.size()]
	
	return candidates[randi() % candidates.size()]

func get_xinfa_count() -> int:
	return xinfa_list.size()