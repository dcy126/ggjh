extends RefCounted
class_name EquipmentSetDatabase

var equipment_sets: Dictionary = {}

static var instance: EquipmentSetDatabase = null

func _init():
	instance = self
	_load_all_sets()

func _load_all_sets():
	# 易水寒套装
	var set = EquipmentSetData.new()
	set.id = "yishuihan_set"
	set.name = "易水寒"
	set.description = "刀魔传人专用，暴击流输出套装"
	set.piece_ids = ["blade_blood", "helmet_dragon", "armor_dragon", "bracer_tiger", "boots_immortal", "necklace_heart"]
	set.max_pieces = 6
	set.quality = "金"
	set.effects = {
		"2": {"type": "属性加成", "params": {"atk%": 0.15, "crit%": 0.1}},
		"4": {"type": "特殊效果", "params": {"effect_id": "yishuihan_4pc", "desc": "暴击伤害提升30%，暴击时恢复5%最大气血"}},
		"6": {"type": "终极效果", "params": {"effect_id": "yishuihan_6pc", "desc": "每次暴击叠加1层[易水寒意]，最多10层，每层增加5%攻击和暴击伤害，持续10秒"}}
	}
	equipment_sets[set.id] = set
	
	# 流氓刀套装
	set = EquipmentSetData.new()
	set.id = "liumangdao_set"
	set.name = "流氓刀"
	set.description = "刀魔传人持续输出套装"
	set.piece_ids = ["blade_demon", "helmet_phoenix", "armor_phoenix", "bracer_asura", "boots_void", "necklace_soul"]
	set.max_pieces = 6
	set.quality = "红"
	set.effects = {
		"2": {"type": "属性加成", "params": {"atk%": 0.2, "lifesteal%": 0.1}},
		"4": {"type": "特殊效果", "params": {"effect_id": "liumangdao_4pc", "desc": "普通攻击有50%几率触发[魔刀·血饮]效果"}},
		"6": {"type": "终极效果", "params": {"effect_id": "liumangdao_6pc", "desc": "进入战斗时自动获得[魔刀]状态，持续全场，攻击力提升50%，吸血率提升20%"}}
	}
	equipment_sets[set.id] = set
	
	# 双羽套装
	set = EquipmentSetData.new()
	set.id = "shuangyu_set"
	set.name = "双羽套装"
	set.description = "平衡攻防的万金油套装"
	set.piece_ids = ["sword_nameless", "helmet_immortal", "armor_dragon", "bracer_dragon", "boots_wind", "necklace_dragon"]
	set.max_pieces = 6
	set.quality = "金"
	set.effects = {
		"2": {"type": "属性加成", "params": {"all_stats%": 0.1}},
		"4": {"type": "特殊效果", "params": {"effect_id": "shuangyu_4pc", "desc": "受击时有30%几率触发[双羽护佑]，获得等同于最大气血30%的护盾，持续2回合"}},
		"6": {"type": "终极效果", "params": {"effect_id": "shuangyu_6pc", "desc": "每回合开始时，若气血高于50%，获得[双羽·攻]状态，攻击提升20%；若气血低于50%，获得[双羽·守]状态，减伤提升30%"}}
	}
	equipment_sets[set.id] = set
	
	# 草头风云录套装
	set = EquipmentSetData.new()
	set.id = "caotou_set"
	set.name = "草头风云录"
	set.description = "主角专属脱离门派套装"
	set.piece_ids = ["sword_wooden", "helmet_cloth", "armor_cloth", "bracer_cloth", "boots_cloth", "necklace_jade"]
	set.max_pieces = 6
	set.quality = "白"
	set.effects = {
		"2": {"type": "属性加成", "params": {"all_stats%": 0.05}},
		"4": {"type": "特殊效果", "params": {"effect_id": "caotou_4pc", "desc": "可学习任意门派武学，无需加入门派"}},
		"6": {"type": "终极效果", "params": {"effect_id": "caotou_6pc", "desc": "心诀槽位上限+3，器值上限+10"}}
	}
	equipment_sets[set.id] = set
	
	# 恒山派套装
	set = EquipmentSetData.new()
	set.id = "hengshan_set"
	set.name = "恒山剑阵"
	set.description = "恒山派反击流套装"
	set.piece_ids = ["sword_cold_moon", "helmet_dragon", "armor_plate", "bracer_dragon", "boots_cloud", "necklace_dragon"]
	set.max_pieces = 6
	set.quality = "紫"
	set.effects = {
		"2": {"type": "属性加成", "params": {"counter_chance%": 0.15, "counter_dmg%": 0.2}},
		"4": {"type": "特殊效果", "params": {"effect_id": "hengshan_4pc", "desc": "反击时有30%几率触发[恒山护佑]，为全队最低气血单位添加护盾(15%最大气血)"}},
		"6": {"type": "终极效果", "params": {"effect_id": "hengshan_6pc", "desc": "获得[恒山剑阵]光环：队友受击时，你有40%几率代为格挡并反击，反击伤害提升50%"}}
	}
	equipment_sets[set.id] = set
	
	# 华山派套装
	set = EquipmentSetData.new()
	set.id = "huashan_set"
	set.name = "华山阴阳"
	set.description = "华山派阴阳内气套装"
	set.piece_ids = ["sword_nameless", "helmet_phoenix", "armor_dragon", "bracer_iron", "boots_wind", "necklace_heart"]
	set.max_pieces = 6
	set.quality = "紫"
	set.effects = {
		"2": {"type": "属性加成", "params": {"yin_dmg%": 0.2, "yang_heal%": 0.2}},
		"4": {"type": "特殊效果", "params": {"effect_id": "huashan_4pc", "desc": "切换阴阳态时，对周围2格敌人造成150%攻击伤害/治疗友方150%攻击量"}},
		"6": {"type": "终极效果", "params": {"effect_id": "huashan_6pc", "desc": "获得[阴阳合一]状态：阴阳态效果同时生效，切换冷却-1回合，内力消耗-50%"}}
	}
	equipment_sets[set.id] = set
	
	# 铁石岛套装
	set = EquipmentSetData.new()
	set.id = "tieshi_set"
	set.name = "铁石无锋"
	set.description = "铁石岛重剑击退套装"
	set.piece_ids = ["sword_red_cloud", "helmet_immortal", "armor_dragon", "bracer_tiger", "boots_immortal", "necklace_soul"]
	set.max_pieces = 6
	set.quality = "红"
	set.effects = {
		"2": {"type": "属性加成", "params": {"atk%": 0.25, "knockback_dist": 1}},
		"4": {"type": "特殊效果", "params": {"effect_id": "tieshi_4pc", "desc": "重剑技能击退距离+2，击退撞墙额外造成200%伤害并眩晕2回合"}},
		"6": {"type": "终极效果", "params": {"effect_id": "tieshi_6pc", "desc": "获得[重剑无锋]被动：普攻变为[重剑·无锋]，范围菱形2格，伤害系数3.0，必定击退3格，无视地形阻挡"}}
	}
	equipment_sets[set.id] = set
	
	# 天武套装
	set = EquipmentSetData.new()
	set.id = "tianwu_set"
	set.name = "天武金钟"
	set.description = "天武军强化肉身套装"
	set.piece_ids = ["staff_yiqi", "helmet_immortal", "armor_dragon", "bracer_asura", "boots_void", "necklace_soul"]
	set.max_pieces = 6
	set.quality = "红"
	set.effects = {
		"2": {"type": "属性加成", "params": {"hp%": 0.3, "def%": 0.3, "dmg_reduction%": 0.15}},
		"4": {"type": "特殊效果", "params": {"effect_id": "tianwu_4pc", "desc": "受击时有25%几率触发[金钟罩]，获得无敌1回合，并反弹50%伤害"}},
		"6": {"type": "终极效果", "params": {"effect_id": "tianwu_6pc", "desc": "获得[铁布衫·大成]：免疫破防破盾，受击时对攻击者施加[重伤](治疗受益-100%，持续3回合)"}}
	}
	equipment_sets[set.id] = set
	
	# 八大门套装
	set = EquipmentSetData.new()
	set.id = "bada_set"
	set.name = "八大幻影"
	set.description = "八大门幻影控制套装"
	set.piece_ids = ["whip_dragon", "helmet_phoenix", "armor_phoenix", "bracer_dragon", "boots_void", "necklace_dragon"]
	set.max_pieces = 6
	set.quality = "金"
	set.effects = {
		"2": {"type": "属性加成", "params": {"dodge%": 0.25, "phantom_chance%": 0.15}},
		"4": {"type": "特殊效果", "params": {"effect_id": "bada_4pc", "desc": "闪避成功时，目标获得[迷离](混乱+沉默，持续2回合)，你获得100集气"}},
		"6": {"type": "终极效果", "params": {"effect_id": "bada_6pc", "desc": "获得[幻影迷踪]：战斗开始召唤3个幻影分身，每回合随机协助攻击/控制/治疗，幻影继承80%属性"}}
	}
	equipment_sets[set.id] = set
	
	# 南山派套装
	set = EquipmentSetData.new()
	set.id = "nanshan_set"
	set.name = "南山龙拳"
	set.description = "南山派一波流龙拳套装"
	set.piece_ids = ["bracer_asura", "helmet_immortal", "armor_phoenix", "bracer_tiger", "boots_immortal", "necklace_heart"]
	set.max_pieces = 6
	set.quality = "红"
	set.effects = {
		"2": {"type": "属性加成", "params": {"atk%": 0.3, "longquan_dmg%": 0.5}},
		"4": {"type": "特殊效果", "params": {"effect_id": "nanshan_4pc", "desc": "龙拳击杀重置冷却，获得100集气，连续击杀伤害递增20%(最多5层)"}},
		"6": {"type": "终极效果", "params": {"effect_id": "nanshan_6pc", "desc": "气血>80%时，普攻变为[龙拳·碎星]：菱形2格，系数2.0，必暴，击杀重置冷却"}}
	}
	equipment_sets[set.id] = set
	
	# 不器门套装
	set = EquipmentSetData.new()
	set.id = "buqi_set"
	set.name = "不器天机"
	set.description = "不器门机关毒术套装"
	set.piece_ids = ["hidden_void", "helmet_phoenix", "armor_phoenix", "bracer_asura", "boots_void", "necklace_soul"]
	set.max_pieces = 6
	set.quality = "红"
	set.effects = {
		"2": {"type": "属性加成", "params": {"trap_dmg%": 0.5, "poison_true_dmg": true}},
		"4": {"type": "特殊效果", "params": {"effect_id": "buqi_4pc", "desc": "机关/地雷触发时，在周围2格生成同类型陷阱，且陷阱隐形(敌人不可见)"}},
		"6": {"type": "终极效果", "params": {"effect_id": "buqi_6pc", "desc": "死亡时留下[绝境机关]：延迟3回合爆炸，造成最大气血50%真实伤害，传染[剧毒]给周围3格(每战1次)"}}
	}
	equipment_sets[set.id] = set
	
	# 河洛帮套装
	set = EquipmentSetData.new()
	set.id = "heluo_set"
	set.name = "河洛豪杰"
	set.description = "河洛帮召唤回血套装"
	set.piece_ids = ["staff_hunyuan", "helmet_dragon", "armor_plate", "bracer_iron", "boots_cloud", "necklace_dragon"]
	set.max_pieces = 6
	set.quality = "紫"
	set.effects = {
		"2": {"type": "属性加成", "params": {"summon_hp%": 0.5, "heal_bonus%": 0.2}},
		"4": {"type": "特殊效果", "params": {"effect_id": "heluo_4pc", "desc": "召唤物继承你50%属性，且拥有[援护]：周围2格友方受击时分担30%伤害"}},
		"6": {"type": "终极效果", "params": {"effect_id": "heluo_6pc", "desc": "获得[帮众齐心]：召唤物上限+3，全体召唤物获得[不屈](死亡时复活一次，气血50%)"}}
	}
	equipment_sets[set.id] = set
	
	# 刀魔传人专用-魔刀/佛刀套装
	set = EquipmentSetData.new()
	set.id = "daomo_modao_set"
	set.name = "魔刀·嗜血"
	set.description = "刀魔传人魔刀形态专用"
	set.piece_ids = ["blade_demon", "helmet_immortal", "armor_dragon", "bracer_asura", "boots_immortal", "necklace_heart"]
	set.max_pieces = 6
	set.quality = "金"
	set.effects = {
		"2": {"type": "属性加成", "params": {"lifesteal%": 0.2, "rage_gain%": 0.3}},
		"4": {"type": "特殊效果", "params": {"effect_id": "daomo_modao_4pc", "desc": "魔刀形态下，击杀获得[杀气]层数，每层+3%攻击+5%吸血，最多20层"}},
		"6": {"type": "终极效果", "params": {"effect_id": "daomo_modao_6pc", "desc": "[魔刀·觉醒]：魔刀形态持续全场，攻击+100%，吸血+50%，普攻变为[魔刀·噬魂](单体，系数3.0，吸血100%，击杀重置冷却)"}}
	}
	equipment_sets[set.id] = set
	
	set = EquipmentSetData.new()
	set.id = "daomo_fodao_set"
	set.name = "佛刀·渡厄"
	set.description = "刀魔传人佛刀形态专用"
	set.piece_ids = ["blade_buddha", "helmet_phoenix", "armor_phoenix", "bracer_dragon", "boots_cloud", "necklace_dragon"]
	set.max_pieces = 6
	set.quality = "金"
	set.effects = {
		"2": {"type": "属性加成", "params": {"block_chance%": 0.2, "team_shield%": 0.15}},
		"4": {"type": "特殊效果", "params": {"effect_id": "daomo_fodao_4pc", "desc": "佛刀形态下，格挡成功为全队添加护盾(20%最大气血)，并清除1个减益"}},
		"6": {"type": "终极效果", "params": {"effect_id": "daomo_fodao_6pc", "desc": "[佛刀·圆满]：佛刀形态持续全场，格挡率+50%，格挡反伤100%，队友受击时你承担50%伤害并获得无敌1回合"}}
	}
	equipment_sets[set.id] = set

func get_set(set_id: String) -> EquipmentSetData:
	return equipment_sets.get(set_id)

func get_all_sets() -> Array[EquipmentSetData]:
	return equipment_sets.values()

func get_sets_by_quality(quality: String) -> Array[EquipmentSetData]:
	var result = []
	for set in equipment_sets.values():
		if set.quality == quality:
			result.append(set)
	return result

func get_equipped_set_count(equipped_items: Array[String], set_id: String) -> int:
	var set_data = equipment_sets.get(set_id)
	if not set_data:
		return 0
	var count = 0
	for item_id in equipped_items:
		if item_id in set_data.piece_ids:
			count += 1
	return count

func get_active_set_effects(equipped_items: Array[String]) -> Array[Dictionary]:
	var active = []
	for set in equipment_sets.values():
		var count = get_equipped_set_count(equipped_items, set.id)
		if count >= 2:
			for piece_count_str in set.effects:
				var piece_count = int(piece_count_str)
				if count >= piece_count:
					var effect = set.effects[piece_count_str].duplicate()
					effect["set_name"] = set.name
					effect["piece_count"] = piece_count
					effect["active"] = true
					active.append(effect)
				else:
					var effect = set.effects[piece_count_str].duplicate()
					effect["set_name"] = set.name
					effect["piece_count"] = piece_count
					effect["active"] = false
					active.append(effect)
	return active