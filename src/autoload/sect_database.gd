extends Node
class_name SectDatabase

var sect_list: Dictionary = {}
var sect_by_faction: Dictionary = {}
var sect_wuxue: Dictionary = {}
var disciple_talents: Dictionary = {}
var contribution_rewards: Dictionary = {}

static var instance = null

static func get_instance():
	return instance

func _enter_tree():
	instance = self
	_load_all_sects()

func _load_all_sects():
	_create_hengshan()
	_create_huashan()
	_create_daomo()
	_create_heluo()
	_create_tieshi()
	_create_tianwu()
	_create_bada()
	_create_nanshan()
	_create_buqi()
	_build_indices()

func _create_hengshan():
	var sect = SectData.new()
	sect.id = "hengshan"
	sect.name = "恒山派"
	sect.description = "以剑法著称，擅长反击与守势，剑意绵绵不绝"
	sect.location = "恒山"
	sect.leader = "莫大先生"
	sect.background_story = "恒山派创立于北宋，传承百载，以《恒山剑法》闻名天下。派中弟子性格刚毅，信奉'守正出奇'的剑道哲学。"
	
	sect.exclusive_wuxue = ["hengshan_fanji", "hengshan_wuliang", "hengshan_hengshan"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"hengshan_fanji": {"level": 5, "contribution": 1000},
		"hengshan_wuliang": {"level": 15, "contribution": 5000, "breakthrough": 1},
		"hengshan_hengshan": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_hengshan_talents()
	
	sect.shop_items = [
		{"item_id": "sword_iron", "price": 500, "currency": "contribution"},
		{"item_id": "hengshan_wuliang_zhenjie", "price": 10000, "currency": "contribution"},
		{"item_id": "potential_pill", "price": 2000, "currency": "contribution"},
		{"item_id": "xinfa_fragment", "price": 500, "currency": "contribution"}
	] as Array[Dictionary] 
	
	sect.contribution_rewards = {
		"1000": {"type": "wuxue", "id": "hengshan_fanji"},
		"5000": {"type": "wuxue", "id": "hengshan_wuliang"},
		"10000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "hengshan_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "hengshan_wuliang", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "hengshan_guard", "name": "恒山护佑", "desc": "队友受击时，有20%几率为其格挡一次攻击", "type": "援护"},
		{"id": "hengshan_counter", "name": "以守为攻", "desc": "反击伤害提升30%，反击时有25%几率眩晕目标1回合", "type": "反击强化"}
	] as Array[Dictionary] 
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int] 
	
	sect.traits = ["反击流", "无限制反击", "团队守护"] as Array[String]
	sect.faction = "正派"
	
	sect.join_requirements = {"level": 10, "reputation": "正派 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "正派 -100"}
	
	sect_list[sect.id] = sect

func _create_hengshan_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "hengshan_fanji_master"
	t.name = "反击大师"
	t.description = "反击触发几率+20%，反击伤害+30%"
	t.talent_type = "被动"
	t.trigger_type = "常驻"
	t.max_level = 3
	t.unlock_level = 20
	t.effects = [{"type": "属性加成", "params": {"counter_chance": 0.2, "counter_dmg": 0.3}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "hengshan_wuliang_jianshi"
	t.name = "无量剑势"
	t.description = "使用恒山剑法时，攻击范围扩大1格，且必定触发反击"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 40
	t.exclusive_sect = "恒山派"
	t.effects = [{"type": "特殊效果", "params": {"wuxue_range_bonus": 1, "guaranteed_counter": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "hengshan_hengshan_zhishou"
	t.name = "恒山之守"
	t.description = "队友血量低于30%时，获得[护盾]并分担30%伤害"
	t.talent_type = "被动"
	t.trigger_type = "队友受击"
	t.trigger_chance = 1.0
	t.max_level = 1
	t.unlock_level = 60
	t.exclusive_sect = "恒山派"
	t.effects = [{"type": "特殊效果", "params": {"ally_shield_on_low_hp": true, "damage_share": 0.3}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents 

func _create_huashan():
	var sect = SectData.new()
	sect.id = "huashan"
	sect.name = "华山派"
	sect.description = "阴阳内气，封印剑气，攻守兼备的剑宗气宗合一"
	sect.location = "华山"
	sect.leader = "岳不群"
	sect.background_story = "华山派自岳不群掌门以来，融合剑气二宗，创出独门'阴阳内气'心法。派中弟子擅长以气驭剑，封印敌人真气。"
	
	sect.exclusive_wuxue = ["huashan_yinyang", "huashan_fengyin", "huashan_jianqi"]  as Array[String] 
	sect.wuxue_unlock_requirements = {
		"huashan_yinyang": {"level": 10, "contribution": 2000},
		"huashan_fengyin": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"huashan_jianqi": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_huashan_talents()
	
	sect.shop_items = [
		{"item_id": "sword_steel", "price": 1000, "currency": "contribution"},
		{"item_id": "huashan_yinyang_zhenjie", "price": 15000, "currency": "contribution"},
		{"item_id": "potential_pill", "price": 2000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "huashan_yinyang"},
		"8000": {"type": "wuxue", "id": "huashan_fengyin"},
		"20000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "huashan_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "huashan_yinyang", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "huashan_yinyang_balance", "name": "阴阳调和", "desc": "内功伤害提升20%，治疗效果提升15%，切换阴阳态时恢复10%内力", "type": "内功强化"},
		{"id": "huashan_fengyin_master", "name": "封印大师", "desc": "封印类效果命中率+25%，封印持续时间+1回合", "type": "控制强化"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000]  as Array[int]
	sect.traits = ["阴阳内气", "封印剑气", "攻守兼备"] as Array[String]
	sect.faction = "正派"
	sect.join_requirements = {"level": 15, "reputation": "正派 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "正派 -100"}
	
	sect_list[sect.id] = sect

func _create_huashan_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent] 
	
	var t = CharacterTalent.new()
	t.id = "huashan_yinyang_master"
	t.name = "阴阳掌控"
	t.description = "阴阳内气切换冷却-1回合，阴态治疗量+40%，阳态伤害+40%"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 25
	t.exclusive_sect = "华山派"
	t.effects = [{"type": "属性加成", "params": {"yin_heal_bonus": 0.4, "yang_dmg_bonus": 0.4, "switch_cd_reduction": 1}, "level_scaling": 1.0}] as Array[Dictionary] 
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "huashan_fengyin_zhiji"
	t.name = "封印至极"
	t.description = "封印剑气命中时，额外封印目标1个随机主动技能，持续2回合"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 45
	t.exclusive_sect = "华山派"
	t.effects = [{"type": "特殊效果", "params": {"extra_skill_seal": true, "seal_duration": 2}, "level_scaling": 0.0}] as Array[Dictionary] 
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "huashan_jianqi_chongji"
	t.name = "剑气冲霄"
	t.description = "华山剑气击杀目标时，立即获得100集气并对周围2格敌人造成50%伤害"
	t.talent_type = "被动"
	t.trigger_type = "击杀"
	t.max_level = 1
	t.unlock_level = 65
	t.exclusive_sect = "华山派"
	t.effects = [{"type": "特殊效果", "params": {"kill_qi_gain": 100, "aoe_on_kill": 0.5}, "level_scaling": 0.0}] as Array[Dictionary] 
	talents.append(t)
	
	return talents

func _create_daomo():
	var sect = SectData.new()
	sect.id = "daomo"
	sect.name = "刀魔传人"
	sect.description = "魔刀吸血狂暴，佛刀免死护佑，刀法霸道至极"
	sect.location = "昆仑山魔刀洞"
	sect.leader = "刀魔"
	sect.background_story = "刀魔传人传承自上古魔刀，修习'魔刀·嗜血'与'佛刀·渡厄'两大绝学。魔刀主杀伐，佛刀主守护，二者互斥又互补。"
	
	sect.exclusive_wuxue = ["daomo_modao", "daomo_fodao", "daomo_daofa"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"daomo_modao": {"level": 5, "contribution": 1500},
		"daomo_fodao": {"level": 15, "contribution": 6000, "breakthrough": 1},
		"daomo_daofa": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_daomo_talents()
	
	sect.shop_items = [
		{"item_id": "blade_iron", "price": 800, "currency": "contribution"},
		{"item_id": "daomo_modao_zhenjie", "price": 12000, "currency": "contribution"},
		{"item_id": "daomo_fodao_zhenjie", "price": 12000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"1500": {"type": "wuxue", "id": "daomo_modao"},
		"6000": {"type": "wuxue", "id": "daomo_fodao"},
		"15000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "daomo_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "daomo_modao", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "daomo_mofa_switch", "name": "魔佛转换", "desc": "战斗中可在魔刀/佛刀形态间切换，切换时获得3层对应强化，冷却3回合", "type": "形态切换"},
		{"id": "daomo_shaxue", "name": "杀戮之心", "desc": "击杀单位获得[杀气]层数，每层增加3%攻击和5%吸血，最多20层", "type": "击杀强化"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["魔刀吸血", "佛刀免死", "刀法霸道"] as Array[String]
	sect.faction = "魔道"
	sect.join_requirements = {"level": 30, "reputation": "魔道 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "魔道 -100"}
	
	sect_list[sect.id] = sect

func _create_daomo_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "daomo_xueyin_shizhe"
	t.name = "嗜血噬者"
	t.description = "魔刀形态下，吸血率额外+20%，击杀回复20%最大气血和30怒气"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 22
	t.exclusive_sect = "刀魔传人"
	t.effects = [{"type": "属性加成", "params": {"lifesteal_bonus": 0.2, "kill_heal": 0.2, "kill_rage": 30}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "daomo_fodao_huti"
	t.name = "佛佑护体"
	t.description = "佛刀形态下，格挡几率+30%，格挡成功为全队添加护盾(10%最大气血)"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 28
	t.exclusive_sect = "刀魔传人"
	t.effects = [{"type": "属性加成", "params": {"block_chance": 0.3, "team_shield_on_block": 0.1}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "daomo_shalu_zhixing"
	t.name = "杀戮执行"
	t.description = "击杀后立即获得一次额外行动机会(每回合限1次)，且下次攻击必定暴击"
	t.talent_type = "被动"
	t.trigger_type = "击杀"
	t.trigger_chance = 1.0
	t.max_level = 1
	t.unlock_level = 50
	t.exclusive_sect = "刀魔传人"
	t.effects = [{"type": "特殊效果", "params": {"extra_action_on_kill": true, "next_crit": true, "once_per_turn": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _create_heluo():
	var sect = SectData.new()
	sect.id = "heluo"
	sect.name = "河洛帮"
	sect.description = "召唤帮众协助战斗，擅长群体治疗与多目标输出"
	sect.location = "洛阳"
	sect.leader = "帮主"
	sect.background_story = "河洛帮立足中原洛阳，广纳江湖豪杰。帮众众多，擅长群体作战，有'人多势众'之称。"
	
	sect.exclusive_wuxue = ["heluo_zhaohuan", "heluo_huixue", "heluo_bangfa"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"heluo_zhaohuan": {"level": 10, "contribution": 2000},
		"heluo_huixue": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"heluo_bangfa": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_heluo_talents()
	
	sect.shop_items = [
		{"item_id": "staff_iron", "price": 800, "currency": "contribution"},
		{"item_id": "heluo_bangfa_zhenjie", "price": 15000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "heluo_zhaohuan"},
		"8000": {"type": "wuxue", "id": "heluo_huixue"},
		"15000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "heluo_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "heluo_bangfa", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "heluo_renshuo", "name": "人多势众", "desc": "每有1个友方召唤物/幻影/分身在场，全队攻防+5%，最多叠加10层", "type": "召唤强化"},
		{"id": "heluo_bangzhong", "name": "帮众相助", "desc": "召唤物继承主人30%属性，且拥有独立AI可自动释放技能", "type": "召唤强化"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["召唤流", "回血", "群体输出"] as Array[String]
	sect.faction = "正派"
	sect.join_requirements = {"level": 20, "reputation": "正派 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "正派 -100"}
	
	sect_list[sect.id] = sect

func _create_heluo_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "heluo_zhaohuan_qunzhu"
	t.name = "群主召唤"
	t.description = "召唤物数量上限+2，召唤物属性继承+20%，且拥有主人的心诀效果"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 22
	t.exclusive_sect = "河洛帮"
	t.effects = [{"type": "属性加成", "params": {"summon_count": 2, "summon_stat_inherit": 0.2, "summon_xinfa": true}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "heluo_huixue_dashu"
	t.name = "大树底下好乘凉"
	t.description = "群体治疗时，额外为血量最低的单位提供双倍治疗并清除所有减益"
	t.talent_type = "被动"
	t.trigger_type = "治疗"
	t.max_level = 1
	t.unlock_level = 40
	t.exclusive_sect = "河洛帮"
	t.effects = [{"type": "特殊效果", "params": {"lowest_hp_double_heal": true, "cleanse_all_debuffs": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "heluo_bangzhong_xieyi"
	t.name = "帮众协议"
	t.description = "友方召唤物/幻影/分身行动后，有30%几率触发协同攻击，造成50%伤害"
	t.talent_type = "被动"
	t.trigger_type = "友方行动"
	t.trigger_chance = 0.3
	t.max_level = 1
	t.unlock_level = 55
	t.exclusive_sect = "河洛帮"
	t.effects = [{"type": "特殊效果", "params": {"summon_coop_chance": 0.3, "coop_dmg": 0.5}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _create_tieshi():
	var sect = SectData.new()
	sect.id = "tieshi"
	sect.name = "铁石岛"
	sect.description = "重剑击退破盾，剑气内伤无视防御"
	sect.location = "东海铁石岛"
	sect.leader = "岛主"
	sect.background_story = "铁石岛弟子终年与海浪搏击，练就一身铁骨铮铮。重剑无锋，大巧不工，剑气内伤直透经脉。"
	
	sect.exclusive_wuxue = ["tieshi_zhongjian", "tieshi_jianqi", "tieshi_tieshi"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"tieshi_zhongjian": {"level": 10, "contribution": 2000},
		"tieshi_jianqi": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"tieshi_tieshi": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_tieshi_talents()
	
	sect.shop_items = [
		{"item_id": "sword_cold_moon", "price": 2000, "currency": "contribution"},
		{"item_id": "tieshi_zhongjian_zhenjie", "price": 15000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "tieshi_zhongjian"},
		"8000": {"type": "wuxue", "id": "tieshi_jianqi"},
		"20000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "tieshi_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "tieshi_zhongjian", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "tieshi_zhongjian_po", "name": "重剑破盾", "desc": "攻击附带破盾效果，击退距离+1格，击退撞墙额外造成50%伤害并眩晕1回合", "type": "击退破盾"},
		{"id": "tieshi_neishang", "name": "剑气内伤", "desc": "剑法攻击有30%几率附加[内伤]，每回合损失最大内力5%，持续3回合，不可叠加", "type": "内伤"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["重剑击退", "剑气内伤", "破盾"] as Array[String]
	sect.faction = "正派"
	sect.join_requirements = {"level": 25, "reputation": "正派 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "正派 -100"}
	
	sect_list[sect.id] = sect

func _create_tieshi_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "tieshi_zhongjian_wufeng"
	t.name = "重剑无锋"
	t.description = "重剑攻击无视目标30%防御，击退撞击墙壁/障碍物时伤害翻倍并眩晕2回合"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 25
	t.exclusive_sect = "铁石岛"
	t.effects = [{"type": "属性加成", "params": {"ignore_def": 0.3, "push_wall_dmg": 2.0, "push_wall_stun": 2}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "tieshi_jianqi_wushi"
	t.name = "剑气无视"
	t.description = "剑气内伤效果触发几率+50%，内伤伤害提升100%，且无视护盾直接作用于气血"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 35
	t.exclusive_sect = "铁石岛"
	t.effects = [{"type": "属性加成", "params": {"neishang_chance": 0.5, "neishang_dmg": 1.0, "ignore_shield": true}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "tieshi_tieshi_jinshen"
	t.name = "铁石金身"
	t.description = "血量低于30%时，获得[铁石金身]：减伤50%、免疫控制、反弹30%伤害，持续3回合(每战1次)"
	t.talent_type = "被动"
	t.trigger_type = "血量低于30%"
	t.max_level = 1
	t.unlock_level = 55
	t.exclusive_sect = "铁石岛"
	t.effects = [{"type": "特殊效果", "params": {"tieshi_jinshen": true, "dmg_reduction": 0.5, "cc_immune": true, "thorns": 0.3, "duration": 3, "once_per_battle": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _create_tianwu():
	var sect = SectData.new()
	sect.id = "tianwu"
	sect.name = "天武"
	sect.description = "强化肉身成圣，破甲碎盾所向披靡"
	sect.location = "临安天武府"
	sect.leader = "统领"
	sect.background_story = "天武军为朝廷精锐，修炼《金钟罩铁布衫》外家硬功，肉身强横，专克护盾护甲。"
	
	sect.exclusive_wuxue = ["tianwu_roushen", "tianwu_pojia", "tianwu_tianwu"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"tianwu_roushen": {"level": 10, "contribution": 2000},
		"tianwu_pojia": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"tianwu_tianwu": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_tianwu_talents()
	
	sect.shop_items = [
		{"item_id": "spear_iron", "price": 800, "currency": "contribution"},
		{"item_id": "tianwu_roushen_zhenjie", "price": 15000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "tianwu_roushen"},
		"8000": {"type": "wuxue", "id": "tianwu_pojia"},
		"20000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "tianwu_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "tianwu_roushen", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "tianwu_jinzhongzhao", "name": "金钟罩", "desc": "常驻减伤20%，受击时有25%几率触发[金钟罩]：下次受击完全免疫并反弹100%伤害", "type": "肉身强化"},
		{"id": "tianwu_pojia_cui", "name": "破甲碎盾", "desc": "攻击护盾/护甲目标时伤害+50%，破盾后目标防御-50%持续3回合", "type": "破盾"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["强化肉身", "破甲碎盾", "外功巅峰"] as Array[String]
	sect.faction = "朝廷"
	sect.join_requirements = {"level": 20, "reputation": "朝廷 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "朝廷 -100"}
	
	sect_list[sect.id] = sect

func _create_tianwu_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "tianwu_jinzhongzhao_dacheng"
	t.name = "金钟罩大成"
	t.description = "金钟罩触发几率+25%，反弹伤害+50%，且不再消耗触发次数(变为冷却3回合)"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 25
	t.exclusive_sect = "天武"
	t.effects = [{"type": "属性加成", "params": {"jinzhongzhao_chance": 0.25, "reflect_dmg": 0.5, "change_to_cd": true}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "tianwu_pojia_zhenshi"
	t.name = "破甲真势"
	t.description = "破甲碎盾效果增强：破盾后目标全属性-20%持续3回合，且你的下次攻击必定暴击"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 42
	t.exclusive_sect = "天武"
	t.effects = [{"type": "特殊效果", "params": {"break_shield_debuff_all": 0.2, "next_crit_after_break": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "tianwu_roushen_bushi"
	t.name = "肉身不死"
	t.description = "每回合结束回复最大气血10%，受到致死伤害时有50%几率触发[不死之身]：气血归1并免疫所有伤害1回合(每战1次)"
	t.talent_type = "被动"
	t.trigger_type = "回合结束/受致死伤害"
	t.max_level = 1
	t.unlock_level = 60
	t.exclusive_sect = "天武"
	t.effects = [{"type": "特殊效果", "params": {"hp_regen_pct": 0.1, "cheat_death_chance": 0.5, "cheat_death_duration": 1, "once_per_battle": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _create_bada():
	var sect = SectData.new()
	sect.id = "bada"
	sect.name = "八大门"
	sect.description = "幻影迷踪，控制流派，分身闪避让敌人找不到北"
	sect.location = "江南八大门"
	sect.leader = "门主"
	sect.background_story = "八大门传承神秘，擅长幻术与身法。弟子行踪飘忽，常以分身迷惑敌人，再以控制技能收割战果。"
	
	sect.exclusive_wuxue = ["bada_huanying", "bada_kongzhi", "bada_bada"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"bada_huanying": {"level": 10, "contribution": 2000},
		"bada_kongzhi": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"bada_bada": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_bada_talents()
	
	sect.shop_items = [
		{"item_id": "zither_jade", "price": 1000, "currency": "contribution"},
		{"item_id": "bada_huanying_zhenjie", "price": 15000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "bada_huanying"},
		"8000": {"type": "wuxue", "id": "bada_kongzhi"},
		"20000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "bada_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "bada_huanying", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "bada_huanying_mizong", "name": "幻影迷踪", "desc": "闪避成功时召唤1个幻影分身(继承30%属性)，最多同时存在3个幻影", "type": "分身闪避"},
		{"id": "bada_kongzhi_dashi", "name": "控制大师", "desc": "控制类效果命中率+30%，持续时间+1回合，且控制效果无视免疫控制(但成功率减半)", "type": "控制强化"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["幻影分身", "控制流", "高闪避"] as Array[String]
	sect.faction = "中立"
	sect.join_requirements = {"level": 30, "reputation": "任意"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false}
	
	sect_list[sect.id] = sect

func _create_bada_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "bada_huanying_wuying"
	t.name = "无影幻踪"
	t.description = "幻影分身数量上限+2，幻影继承属性+20%，且幻影拥有[隐身]效果(首次攻击前不可被选中)"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 25
	t.exclusive_sect = "八大门"
	t.effects = [{"type": "属性加成", "params": {"phantom_count": 2, "phantom_stat": 0.2, "phantom_stealth": true}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "bada_kongzhi_jueji"
	t.name = "控制绝技"
	t.description = "控制技能命中时，目标额外获得[沉默]2回合，且你获得50集气和20怒气"
	t.talent_type = "被动"
	t.trigger_type = "控制命中"
	t.max_level = 1
	t.unlock_level = 40
	t.exclusive_sect = "八大门"
	t.effects = [{"type": "特殊效果", "params": {"extra_silence": 2, "qi_gain": 50, "rage_gain": 20}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "bada_mizong_juemi"
	t.name = "迷踪绝迹"
	t.description = "战斗开始时获得[迷踪]状态：前3回合免疫单体目标技能，且闪避率+50%"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 55
	t.exclusive_sect = "八大门"
	t.effects = [{"type": "特殊效果", "params": {"mizong_immunity": 3, "dodge_bonus": 0.5}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _create_nanshan():
	var sect = SectData.new()
	sect.id = "nanshan"
	sect.name = "南山派"
	sect.description = "一波流爆发，龙拳高伤，聚气爆发毁天灭地"
	sect.location = "南山"
	sect.leader = "掌门"
	sect.background_story = "南山派武学刚猛霸道，讲究'一波流'爆发。龙拳绝学聚气而发，一拳定乾坤。"
	
	sect.exclusive_wuxue = ["nanshan_longquan", "nanshan_yibo", "nanshan_nanshan"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"nanshan_longquan": {"level": 10, "contribution": 2000},
		"nanshan_yibo": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"nanshan_nanshan": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_nanshan_talents()
	
	sect.shop_items = [
		{"item_id": "bracer_tiger", "price": 2000, "currency": "contribution"},
		{"item_id": "nanshan_longquan_zhenjie", "price": 15000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "nanshan_longquan"},
		"8000": {"type": "wuxue", "id": "nanshan_yibo"},
		"20000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "nanshan_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "nanshan_longquan", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "nanshan_longquan_baofa", "name": "龙拳爆发", "desc": "龙拳技能伤害+50%，击杀时重置冷却并获得100集气，连续击杀伤害递增20%(最多5层)", "type": "爆发强化"},
		{"id": "nanshan_yibo_jiqu", "name": "一波流聚气", "desc": "战斗前3回合集气速度+100%，第4回合开始每回合-20%，第6回合恢复正常", "type": "前期爆发"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["一波流", "龙拳高伤", "聚气爆发"] as Array[String]
	sect.faction = "正派"
	sect.join_requirements = {"level": 15, "reputation": "正派 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "正派 -100"}
	
	sect_list[sect.id] = sect

func _create_nanshan_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "nanshan_longquan_tianjiang"
	t.name = "龙拳降临"
	t.description = "龙拳技能额外造成目标最大气血20%的真实伤害，击杀后获得[龙威]：攻击+30%、暴伤+50%，持续3回合"
	t.talent_type = "被动"
	t.trigger_type = "龙拳命中/击杀"
	t.max_level = 3
	t.unlock_level = 25
	t.exclusive_sect = "南山派"
	t.effects = [{"type": "属性加成", "params": {"longquan_true_dmg": 0.2, "longwei_atk": 0.3, "longwei_crit_dmg": 0.5, "longwei_duration": 3}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "nanshan_yibo_yici"
	t.name = "一波流·以此为终"
	t.description = "前3回合暴击率+50%、暴伤+50%，第4回合开始每回合-10%，但每击杀1个单位恢复1层增益"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 45
	t.exclusive_sect = "南山派"
	t.effects = [{"type": "特殊效果", "params": {"early_crit_bonus": 0.5, "early_crit_dmg": 0.5, "decay_per_turn": 0.1, "kill_restore": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "nanshan_nanshan_wushuang"
	t.name = "南山无双"
	t.description = "气血高于80%时，普攻变为[龙拳·碎星]：攻击范围变为菱形2格，伤害系数2.0，必定暴击"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 60
	t.exclusive_sect = "南山派"
	t.effects = [{"type": "特殊效果", "params": {"hp_threshold": 0.8, "basic_becomes_longquan": true, "aoe": "菱形2", "dmg_mult": 2.0, "guaranteed_crit": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _create_buqi():
	var sect = SectData.new()
	sect.id = "buqi"
	sect.name = "不器门"
	sect.description = "机关地雷布阵，毒术折磨，战术大师"
	sect.location = "西南不器谷"
	sect.leader = "谷主"
	sect.background_story = "不器门传承古巫蛊毒术与机关术，擅长布阵陷阱，以毒攻毒，让敌人在不知不觉中走向灭亡。"
	
	sect.exclusive_wuxue = ["buqi_jiguan", "buqi_dilei", "buqi_dushu"] as Array[String]
	sect.wuxue_unlock_requirements = {
		"buqi_jiguan": {"level": 10, "contribution": 2000},
		"buqi_dilei": {"level": 20, "contribution": 8000, "breakthrough": 1},
		"buqi_dushu": {"level": 1, "contribution": 0}
	}
	
	sect.disciple_talents = _create_buqi_talents()
	
	sect.shop_items = [
		{"item_id": "hidden_needle", "price": 800, "currency": "contribution"},
		{"item_id": "buqi_jiguan_zhenjie", "price": 15000, "currency": "contribution"}
	] as Array[Dictionary]
	
	sect.contribution_rewards = {
		"2000": {"type": "wuxue", "id": "buqi_jiguan"},
		"8000": {"type": "wuxue", "id": "buqi_dilei"},
		"20000": {"type": "talent_point", "value": 1},
		"50000": {"type": "title", "id": "buqi_elder"},
		"100000": {"type": "wuxue_zhenjie", "id": "buqi_dushu", "level": 1}
	}
	
	sect.sect_passives = [
		{"id": "buqi_jiguan_dashi", "name": "机关大师", "desc": "机关/地雷伤害+50%，布置数量上限+3，触发时额外附带[缴械]2回合", "type": "机关强化"},
		{"id": "buqi_dushu_zhongdu", "name": "百毒不侵", "desc": "免疫所有中毒效果，自身毒伤害+100%，中毒目标受到的治疗-50%", "type": "毒术强化"}
	] as Array[Dictionary]
	
	sect.max_level = 10
	sect.exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000] as Array[int]
	sect.traits = ["机关地雷", "毒术折磨", "战术布阵"] as Array[String]
	sect.faction = "邪派"
	sect.join_requirements = {"level": 25, "reputation": "邪派 >= 0"}
	sect.leave_penalty = {"contribution_keep": true, "wuxue_keep": false, "reputation": "邪派 -100"}
	
	sect_list[sect.id] = sect

func _create_buqi_talents() -> Array[CharacterTalent]:
	var talents = [] as Array[CharacterTalent]
	
	var t = CharacterTalent.new()
	t.id = "buqi_jiguan_tianji"
	t.name = "天机机关"
	t.description = "机关/地雷触发时，额外在周围2格生成同类型机关，且机关隐形(敌人不可见)"
	t.talent_type = "被动"
	t.max_level = 3
	t.unlock_level = 25
	t.exclusive_sect = "不器门"
	t.effects = [{"type": "属性加成", "params": {"trap_spread": 2, "trap_invisible": true, "trap_dmg_bonus": 0.5}, "level_scaling": 1.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "buqi_dushu_shigu"
	t.name = "蚀骨毒术"
	t.description = "毒术伤害转为真实伤害，且中毒目标每回合额外损失最大内力5%，中毒层数无上限"
	t.talent_type = "被动"
	t.max_level = 1
	t.unlock_level = 40
	t.exclusive_sect = "不器门"
	t.effects = [{"type": "特殊效果", "params": {"poison_true_dmg": true, "mp_loss_pct": 0.05, "unlimited_stacks": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	t = CharacterTalent.new()
	t.id = "buqi_buqi_wuqiong"
	t.name = "不器无穷"
	t.description = "死亡时在原地留下[绝境机关]：延迟3回合爆炸，造成最大气血50%真实伤害，并传染[剧毒]给周围3格单位(每战1次)"
	t.talent_type = "被动"
	t.trigger_type = "死亡"
	t.max_level = 1
	t.unlock_level = 55
	t.exclusive_sect = "不器门"
	t.effects = [{"type": "特殊效果", "params": {"death_trap": true, "delay": 3, "dmg_pct": 0.5, "poison_spread": 3, "once_per_battle": true}, "level_scaling": 0.0}] as Array[Dictionary]
	talents.append(t)
	
	return talents

func _build_indices():
	sect_by_faction.clear()
	for sect in sect_list.values():
		if not sect_by_faction.has(sect.faction):
			sect_by_faction[sect.faction] = []
		sect_by_faction[sect.faction].append(sect)

func get_sect(id: String) -> SectData:
	return sect_list.get(id)

func get_all_sects() -> Array[SectData]:
	var result: Array[SectData] = []
	result.assign(sect_list.values())
	return result

func get_sects_by_faction(faction: String) -> Array[SectData]:
	var result: Array[SectData] = []
	result.assign(sect_by_faction.get(faction, []))
	return result

func get_sect_wuxue(sect_id: String) -> Array[WuxueData]:
	return sect_wuxue.get(sect_id, {}).values()

func get_disciple_talents(sect_id: String) -> Array[CharacterTalent]:
	return disciple_talents.get(sect_id, [])

func get_contribution_rewards(sect_id: String) -> Dictionary:
	return contribution_rewards.get(sect_id, {})

func get_sect_count() -> int:
	return sect_list.size()
