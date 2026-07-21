extends RefCounted
class_name EquipmentDatabase

var equipment_list: Dictionary = {}
var equipment_by_slot: Dictionary = {}
var equipment_by_quality: Dictionary = {}
var equipment_by_type: Dictionary = {}
var equipment_sets: Dictionary = {}
var gem_list: Dictionary = {}

static var instance: EquipmentDatabase = null

func _init():
	instance = self
	_load_all_equipment()

func _load_all_equipment():
	_create_weapons()
	_create_helmets()
	_create_armors()
	_create_bracers()
	_create_boots()
	_create_necklaces()
	_create_rings()
	_create_belts()
	_create_talismans()
	_create_hidden_weapons()
	_create_gems()
	_create_equipment_sets()
	_build_indices()

func _create_weapons():
	# 剑类
	_create_equipment("sword_wooden", "木剑", "武器", "剑", "白", 1, {"atk": 10}, {})
	_create_equipment("sword_iron", "铁剑", "武器", "剑", "绿", 10, {"atk": 30}, {"atk": 2})
	_create_equipment("sword_steel", "精钢剑", "武器", "剑", "蓝", 20, {"atk": 60, "crit": 20}, {"atk": 4, "crit": 1})
	_create_equipment("sword_cold_moon", "冷月剑", "武器", "剑", "紫", 35, {"atk": 120, "spd": 15, "crit": 50}, {"atk": 6, "spd": 1, "crit": 2})
	_create_equipment("sword_nameless", "无名剑", "武器", "剑", "金", 50, {"atk": 200, "spd": 30, "crit": 100, "crit_dmg": 0.2}, {"atk": 10, "spd": 2, "crit": 5})
	_create_equipment("sword_red_cloud", "红云剑", "武器", "剑", "红", 60, {"atk": 300, "spd": 50, "crit": 150, "crit_dmg": 0.3, "atk%": 0.2}, {"atk": 15, "spd": 3, "crit": 8})
	
	# 刀类
	_create_equipment("blade_wooden", "木刀", "武器", "刀", "白", 1, {"atk": 12}, {})
	_create_equipment("blade_iron", "铁刀", "武器", "刀", "绿", 10, {"atk": 35}, {"atk": 2})
	_create_equipment("blade_ghost", "鬼头刀", "武器", "刀", "蓝", 20, {"atk": 70, "hp": 50}, {"atk": 4, "hp": 5})
	_create_equipment("blade_blood", "饮血刀", "武器", "刀", "紫", 35, {"atk": 130, "hp": 100, "lifesteal": 0.1}, {"atk": 6, "hp": 10})
	_create_equipment("blade_demon", "魔刀·千刃", "武器", "刀", "金", 50, {"atk": 220, "hp": 200, "lifesteal": 0.15, "rage_gain": 0.2}, {"atk": 10, "hp": 15})
	_create_equipment("blade_buddha", "佛刀·舍身", "武器", "刀", "红", 60, {"atk": 250, "def": 100, "hp": 300, "block_chance": 0.3}, {"atk": 12, "def": 5, "hp": 20})
	
	# 枪类
	_create_equipment("spear_wooden", "木枪", "武器", "枪", "白", 1, {"atk": 11, "spd": 5}, {})
	_create_equipment("spear_iron", "铁枪", "武器", "枪", "绿", 10, {"atk": 32, "spd": 10}, {"atk": 2, "spd": 1})
	_create_equipment("spear_dragon", "龙吟枪", "武器", "枪", "蓝", 20, {"atk": 65, "spd": 20, "penetration": 0.1}, {"atk": 4, "spd": 2})
	_create_equipment("spear_fire_god", "火神枪", "武器", "枪", "紫", 35, {"atk": 125, "spd": 30, "burn_dmg": 30}, {"atk": 6, "spd": 2})
	_create_equipment("spear_pojun", "破军枪", "武器", "枪", "金", 50, {"atk": 210, "spd": 40, "armor_pierce": 0.3}, {"atk": 10, "spd": 3})
	_create_equipment("spear_dragon_god", "龙神枪", "武器", "枪", "红", 60, {"atk": 280, "spd": 50, "true_dmg": 100, "charge_dmg": 0.5}, {"atk": 15, "spd": 4})
	
	# 棍类
	_create_equipment("staff_wooden", "木棍", "武器", "棍", "白", 1, {"atk": 10, "def": 5}, {})
	_create_equipment("staff_iron", "铁棍", "武器", "棍", "绿", 10, {"atk": 30, "def": 15}, {"atk": 2, "def": 1})
	_create_equipment("staff_zen", "降魔杖", "武器", "棍", "蓝", 20, {"atk": 60, "def": 30, "stun_chance": 0.15}, {"atk": 4, "def": 2})
	_create_equipment("staff_dog_beating", "打狗棒", "武器", "棍", "紫", 35, {"atk": 110, "def": 50, "disarm_chance": 0.2}, {"atk": 6, "def": 3})
	_create_equipment("staff_hunyuan", "混元棍", "武器", "棍", "金", 50, {"atk": 180, "def": 80, "shield_on_hit": 50}, {"atk": 10, "def": 4})
	_create_equipment("staff_yiqi", "混元一气棍", "武器", "棍", "红", 60, {"atk": 250, "def": 120, "team_shield": 200}, {"atk": 15, "def": 6})
	
	# 鞭类
	_create_equipment("whip_wooden", "软鞭", "武器", "鞭", "白", 1, {"atk": 9, "spd": 10}, {})
	_create_equipment("whip_snake", "灵蛇鞭", "武器", "鞭", "绿", 10, {"atk": 28, "spd": 20, "poison_chance": 0.2}, {"atk": 2, "spd": 2})
	_create_equipment("whip_dragon", "游龙鞭", "武器", "鞭", "蓝", 20, {"atk": 55, "spd": 30, "pull_chance": 0.25}, {"atk": 4, "spd": 3})
	
	# 琴类
	_create_equipment("zither_wooden", "普通古琴", "武器", "琴", "白", 1, {"atk": 5, "heal_bonus": 0.1}, {})
	_create_equipment("zither_jade", "碧玉琴", "武器", "琴", "绿", 10, {"atk": 20, "heal_bonus": 0.2, "mp": 30}, {"atk": 1, "heal_bonus": 0.01})
	_create_equipment("zither_guangling", "广陵散琴", "武器", "琴", "金", 50, {"atk": 80, "heal_bonus": 0.5, "mp": 100, "revive_chance": 0.1}, {"atk": 4, "heal_bonus": 0.02})
	
	# 暗器类
	_create_equipment("hidden_needle", "绣花针", "武器", "暗器", "白", 1, {"atk": 8, "spd": 15}, {})
	_create_equipment("hidden_yuhua", "雨花针", "武器", "暗器", "金", 50, {"atk": 100, "spd": 50, "poison": 30, "multi_hit": 3}, {"atk": 5, "spd": 3})
	_create_equipment("hidden_pearl", "夜明珠", "武器", "暗器", "红", 60, {"atk": 150, "spd": 60, "blind_chance": 0.3, "steal_rage": 10}, {"atk": 8, "spd": 4})

func _create_helmets():
	_create_equipment("helmet_cloth", "布巾", "头盔", "轻甲", "白", 1, {"hp": 50, "def": 5}, {})
	_create_equipment("helmet_leather", "皮帽", "头盔", "轻甲", "绿", 10, {"hp": 150, "def": 15, "dodge": 10}, {"hp": 10, "def": 1})
	_create_equipment("helmet_iron", "铁盔", "头盔", "重甲", "蓝", 20, {"hp": 300, "def": 40, "stun_resist": 0.1}, {"hp": 20, "def": 2})
	_create_equipment("helmet_dragon", "龙冠", "头盔", "重甲", "紫", 35, {"hp": 500, "def": 80, "crit_resist": 0.2, "rage": 20}, {"hp": 30, "def": 4})
	_create_equipment("helmet_phoenix", "凤冠", "头盔", "轻甲", "金", 50, {"hp": 600, "def": 60, "heal_received": 0.3, "mp": 100}, {"hp": 40, "def": 3, "mp": 10})
	_create_equipment("helmet_immortal", "仙冠", "头盔", "轻甲", "红", 60, {"hp": 800, "def": 100, "all_resist": 0.2, "revive": 1}, {"hp": 50, "def": 5})

func _create_armors():
	_create_equipment("armor_cloth", "布衣", "衣服", "轻甲", "白", 1, {"hp": 100, "def": 10}, {})
	_create_equipment("armor_leather", "皮甲", "衣服", "轻甲", "绿", 10, {"hp": 300, "def": 30, "spd": 10}, {"hp": 20, "def": 2, "spd": 1})
	_create_equipment("armor_chain", "锁子甲", "衣服", "重甲", "蓝", 20, {"hp": 600, "def": 80, "move_range": 1}, {"hp": 40, "def": 4})
	_create_equipment("armor_plate", "精钢铠", "衣服", "重甲", "紫", 35, {"hp": 1000, "def": 150, "dmg_reduction": 0.15}, {"hp": 60, "def": 6})
	_create_equipment("armor_dragon", "龙鳞甲", "衣服", "重甲", "金", 50, {"hp": 1500, "def": 200, "immune_burn": true, "counter_dmg": 0.2}, {"hp": 80, "def": 8})
	_create_equipment("armor_phoenix", "凤羽衣", "衣服", "轻甲", "红", 60, {"hp": 1800, "def": 150, "dodge": 0.3, "heal_amp": 0.5}, {"hp": 100, "def": 7, "dodge": 0.01})

func _create_bracers():
	_create_equipment("bracer_cloth", "布护腕", "护腕", "轻甲", "白", 1, {"atk": 5, "hit": 10}, {})
	_create_equipment("bracer_leather", "皮护腕", "护腕", "轻甲", "绿", 10, {"atk": 15, "hit": 30, "crit": 20}, {"atk": 1, "hit": 2, "crit": 1})
	_create_equipment("bracer_iron", "铁护腕", "护腕", "重甲", "蓝", 20, {"atk": 30, "hit": 60, "penetration": 0.1}, {"atk": 2, "hit": 3, "penetration": 0.01})
	_create_equipment("bracer_dragon", "龙鳞护腕", "护腕", "重甲", "紫", 35, {"atk": 50, "hit": 100, "combo_chance": 0.2}, {"atk": 3, "hit": 5, "combo_chance": 0.01})
	_create_equipment("bracer_tiger", "虎爪护腕", "护腕", "重甲", "金", 50, {"atk": 80, "hit": 150, "chase_chance": 0.15}, {"atk": 5, "hit": 8, "chase_chance": 0.01})
	_create_equipment("bracer_asura", "修罗护腕", "护腕", "重甲", "红", 60, {"atk": 120, "hit": 200, "crit_dmg": 0.3, "hp_cost": 0.05}, {"atk": 8, "hit": 10, "crit_dmg": 0.01})

func _create_boots():
	_create_equipment("boots_cloth", "布鞋", "鞋子", "轻甲", "白", 1, {"spd": 10, "move_range": 1}, {})
	_create_equipment("boots_leather", "皮靴", "鞋子", "轻甲", "绿", 10, {"spd": 30, "move_range": 1, "dodge": 20}, {"spd": 2, "dodge": 1})
	_create_equipment("boots_wind", "疾风靴", "鞋子", "轻甲", "蓝", 20, {"spd": 60, "move_range": 2, "dodge": 50, "qi_speed": 0.2}, {"spd": 4, "dodge": 2})
	_create_equipment("boots_cloud", "云履", "鞋子", "轻甲", "紫", 35, {"spd": 100, "move_range": 2, "dodge": 100, "untargetable_chance": 0.1}, {"spd": 6, "dodge": 4})
	_create_equipment("boots_immortal", "凌波微步", "鞋子", "轻甲", "金", 50, {"spd": 150, "move_range": 3, "dodge": 200, "phantom_on_dodge": 0.3}, {"spd": 10, "dodge": 8})
	_create_equipment("boots_void", "虚空行者", "鞋子", "轻甲", "红", 60, {"spd": 200, "move_range": 4, "dodge": 300, "blink_chance": 0.2}, {"spd": 15, "dodge": 12})

func _create_necklaces():
	_create_equipment("necklace_jade", "玉佩", "项链", "饰品", "白", 1, {"hp": 50, "mp": 20}, {})
	_create_equipment("necklace_pearl", "珍珠项链", "项链", "饰品", "绿", 10, {"hp": 150, "mp": 50, "heal_bonus": 0.1}, {"hp": 10, "mp": 3, "heal_bonus": 0.01})
	_create_equipment("necklace_amber", "琥珀项链", "项链", "饰品", "蓝", 20, {"hp": 300, "mp": 100, "poison_resist": 0.3, "heal_bonus": 0.2}, {"hp": 20, "mp": 5, "heal_bonus": 0.01})
	_create_equipment("necklace_dragon", "龙珠项链", "项链", "饰品", "紫", 35, {"hp": 500, "mp": 200, "rage_regen": 2, "heal_bonus": 0.3}, {"hp": 30, "mp": 10, "heal_bonus": 0.02})
	_create_equipment("necklace_heart", "护心镜", "项链", "饰品", "金", 50, {"hp": 800, "mp": 300, "shield_on_hit": 100, "revive_chance": 0.1}, {"hp": 50, "mp": 20})
	_create_equipment("necklace_soul", "魂链", "项链", "饰品", "红", 60, {"hp": 1000, "mp": 500, "soul_link": true, "dmg_share": 0.3}, {"hp": 80, "mp": 30})

func _create_rings():
	_create_equipment("ring_iron", "铁戒指", "戒指", "饰品", "白", 1, {"atk": 5, "crit": 10}, {})
	_create_equipment("ring_gold", "金戒指", "戒指", "饰品", "绿", 10, {"atk": 15, "crit": 30, "crit_dmg": 0.05}, {"atk": 1, "crit": 2, "crit_dmg": 0.01})
	_create_equipment("ring_diamond", "钻石戒指", "戒指", "饰品", "蓝", 20, {"atk": 30, "crit": 60, "crit_dmg": 0.1, "penetration": 0.1}, {"atk": 2, "crit": 3, "crit_dmg": 0.01})
	_create_equipment("ring_dragon", "龙牙戒指", "戒指", "饰品", "紫", 35, {"atk": 50, "crit": 100, "crit_dmg": 0.15, "chase_chance": 0.1}, {"atk": 3, "crit": 5, "crit_dmg": 0.01})
	_create_equipment("ring_phoenix", "凤羽戒指", "戒指", "饰品", "金", 50, {"atk": 80, "crit": 150, "crit_dmg": 0.2, "lifesteal": 0.1}, {"atk": 5, "crit": 8, "crit_dmg": 0.02})
	_create_equipment("ring_karma", "因果戒", "戒指", "饰品", "红", 60, {"atk": 120, "crit": 200, "crit_dmg": 0.3, "karma_dmg": 0.2}, {"atk": 8, "crit": 10, "crit_dmg": 0.03})

func _create_belts():
	_create_equipment("belt_cloth", "布带", "腰带", "饰品", "白", 1, {"hp": 50, "mp": 20}, {})
	_create_equipment("belt_leather", "皮带", "腰带", "饰品", "绿", 10, {"hp": 150, "mp": 50, "move_range": 1}, {"hp": 10, "mp": 3})
	_create_equipment("belt_iron", "铁带钩", "腰带", "饰品", "蓝", 20, {"hp": 300, "mp": 100, "item_find": 0.1, "move_range": 1}, {"hp": 20, "mp": 5})
	_create_equipment("belt_dragon", "龙筋带", "腰带", "饰品", "紫", 35, {"hp": 500, "mp": 200, "rage_max": 20, "item_find": 0.2}, {"hp": 30, "mp": 10, "rage_max": 2})
	_create_equipment("belt_immortal", "乾坤带", "腰带", "饰品", "金", 50, {"hp": 800, "mp": 300, "formation_bonus": 0.3, "storage": 10}, {"hp": 50, "mp": 20})
	_create_equipment("belt_universe", "混元带", "腰带", "饰品", "红", 60, {"hp": 1000, "mp": 500, "all_stats": 0.1, "wanlian_bonus": 0.2}, {"hp": 80, "mp": 30})

func _create_talismans():
	_create_equipment("talisman_peace", "平安符", "护符", "饰品", "白", 1, {"def": 10, "heal_received": 0.05}, {})
	_create_equipment("talisman_exorcism", "辟邪符", "护符", "饰品", "绿", 10, {"def": 30, "curse_resist": 0.2, "heal_received": 0.1}, {"def": 2, "heal_received": 0.01})
	_create_equipment("talisman_spirit", "镇魂符", "护符", "饰品", "蓝", 20, {"def": 60, "fear_resist": 0.5, "mp_regen": 5}, {"def": 4, "mp_regen": 1})
	_create_equipment("talisman_dragon", "龙符", "护符", "饰品", "紫", 35, {"def": 100, "all_resist": 0.2, "shield_on_hit": 50}, {"def": 6, "all_resist": 0.01})
	_create_equipment("talisman_heaven", "天机符", "护符", "饰品", "金", 50, {"def": 150, "preview_enemy_action": true, "counter_chance": 0.2}, {"def": 10, "counter_chance": 0.01})
	_create_equipment("talisman_dao", "道德经", "护符", "饰品", "红", 60, {"def": 200, "dao_protection": true, "karma_immunity": true}, {"def": 15})

func _create_hidden_weapons():
	_create_equipment("hidden_dart", "飞镖", "暗器", "暗器", "白", 1, {"atk": 10, "spd": 20}, {})
	_create_equipment("hidden_needle", "袖箭", "暗器", "暗器", "绿", 10, {"atk": 25, "spd": 40, "pierce": 1}, {"atk": 2, "spd": 3})
	_create_equipment("hidden_three", "三才针", "暗器", "暗器", "蓝", 20, {"atk": 50, "spd": 60, "multi_hit": 3, "poison": 15}, {"atk": 4, "spd": 5})
	_create_equipment("hidden_pear_flower", "梨花针", "暗器", "暗器", "紫", 35, {"atk": 80, "spd": 80, "aoe": "菱形", "blind": 0.3}, {"atk": 6, "spd": 8})
	_create_equipment("hidden_buddha", "佛门舍利", "暗器", "暗器", "金", 50, {"atk": 120, "spd": 100, "purify": true, "heal_on_kill": 0.2}, {"atk": 8, "spd": 10})
	_create_equipment("hidden_void", "虚空之针", "暗器", "暗器", "红", 60, {"atk": 200, "spd": 150, "true_dmg": 100, "ignore_stealth": true}, {"atk": 12, "spd": 15})

func _create_gems():
	# 攻击宝石
	_create_gem("gem_atk_1", "碎裂的攻击宝石", "攻击", {"atk": 10}, "白")
	_create_gem("gem_atk_2", "攻击宝石", "攻击", {"atk": 30}, "绿")
	_create_gem("gem_atk_3", "完美攻击宝石", "攻击", {"atk": 60}, "蓝")
	_create_gem("gem_atk_4", "辉煌攻击宝石", "攻击", {"atk": 100, "crit": 20}, "紫")
	_create_gem("gem_atk_5", "皇家攻击宝石", "攻击", {"atk": 150, "crit": 50, "crit_dmg": 0.05}, "金")
	
	# 生命宝石
	_create_gem("gem_hp_1", "碎裂的生命宝石", "生命", {"hp": 50}, "白")
	_create_gem("gem_hp_2", "生命宝石", "生命", {"hp": 150}, "绿")
	_create_gem("gem_hp_3", "完美生命宝石", "生命", {"hp": 300}, "蓝")
	_create_gem("gem_hp_4", "辉煌生命宝石", "生命", {"hp": 500, "heal_received": 0.05}, "紫")
	_create_gem("gem_hp_5", "皇家生命宝石", "生命", {"hp": 800, "heal_received": 0.1, "revive_chance": 0.02}, "金")
	
	# 防御宝石
	_create_gem("gem_def_1", "碎裂的防御宝石", "防御", {"def": 10}, "白")
	_create_gem("gem_def_2", "防御宝石", "防御", {"def": 30}, "绿")
	_create_gem("gem_def_3", "完美防御宝石", "防御", {"def": 60}, "蓝")
	_create_gem("gem_def_4", "辉煌防御宝石", "防御", {"def": 100, "dmg_reduction": 0.03}, "紫")
	_create_gem("gem_def_5", "皇家防御宝石", "防御", {"def": 150, "dmg_reduction": 0.05, "block_chance": 0.05}, "金")
	
	# 速度宝石
	_create_gem("gem_spd_1", "碎裂的速度宝石", "速度", {"spd": 10}, "白")
	_create_gem("gem_spd_2", "速度宝石", "速度", {"spd": 30}, "绿")
	_create_gem("gem_spd_3", "完美速度宝石", "速度", {"spd": 60}, "蓝")
	_create_gem("gem_spd_4", "辉煌速度宝石", "速度", {"spd": 100, "move_range": 1}, "紫")
	_create_gem("gem_spd_5", "皇家速度宝石", "速度", {"spd": 150, "move_range": 1, "dodge": 50}, "金")
	
	# 暴击宝石
	_create_gem("gem_crit_1", "碎裂的暴击宝石", "暴击", {"crit": 20}, "白")
	_create_gem("gem_crit_2", "暴击宝石", "暴击", {"crit": 50}, "绿")
	_create_gem("gem_crit_3", "完美暴击宝石", "暴击", {"crit": 100}, "蓝")
	_create_gem("gem_crit_4", "辉煌暴击宝石", "暴击", {"crit": 150, "crit_dmg": 0.03}, "紫")
	_create_gem("gem_crit_5", "皇家暴击宝石", "暴击", {"crit": 200, "crit_dmg": 0.05, "chase_chance": 0.05}, "金")
	
	# 内力宝石
	_create_gem("gem_mp_1", "碎裂的内力宝石", "内力", {"mp": 20}, "白")
	_create_gem("gem_mp_2", "内力宝石", "内力", {"mp": 50}, "绿")
	_create_gem("gem_mp_3", "完美内力宝石", "内力", {"mp": 100}, "蓝")
	_create_gem("gem_mp_4", "辉煌内力宝石", "内力", {"mp": 150, "mp_regen": 5}, "紫")
	_create_gem("gem_mp_5", "皇家内力宝石", "内力", {"mp": 200, "mp_regen": 10, "rage_regen": 2}, "金")
	
	# 福缘宝石
	_create_gem("gem_fortune_1", "碎裂的福缘宝石", "福缘", {"fortune": 10}, "白")
	_create_gem("gem_fortune_2", "福缘宝石", "福缘", {"fortune": 30}, "绿")
	_create_gem("gem_fortune_3", "完美福缘宝石", "福缘", {"fortune": 60}, "蓝")
	_create_gem("gem_fortune_4", "辉煌福缘宝石", "福缘", {"fortune": 100, "rage_gain": 0.1}, "紫")
	_create_gem("gem_fortune_5", "皇家福缘宝石", "福缘", {"fortune": 150, "rage_gain": 0.2, "treasure_find": 0.1}, "金")

func _create_equipment_sets():
	# 易水寒套装 - 刀魔输出
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
	
	# 流氓刀套装 - 刀魔持续输出
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
	
	# 双羽套装 - 新版本套装
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
	
	# 草头风云录 - 主角专属
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

func _create_equipment(id: String, name: String, slot: String, type: String, quality: String, level_req: int, base_stats: Dictionary, enhance_stats: Dictionary):
	var eq = EquipmentData.new()
	eq.id = id
	eq.name = name
	eq.slot = slot
	eq.type = type
	eq.quality = quality
	eq.level_requirement = level_req
	eq.base_stats = base_stats
	eq.enhance_stats_per_level = enhance_stats
	eq.max_enhance_level = 20 if quality in ["白", "绿", "蓝"] else (25 if quality in ["紫", "金"] else 30)
	eq.enhance_materials = {"强化石": 1, "铜钱": 1000}
	eq.refine_materials = {"精炼石": 1, "铜钱": 5000}
	eq.wanlian_materials = {"万炼石": 1, "元宝": 100}
	equipment_list[id] = eq

func _create_gem(id: String, name: String, type: String, stats: Dictionary, quality: String):
	var gem = GemData.new()
	gem.id = id
	gem.name = name
	gem.type = type
	gem.stats = stats
	gem.quality = quality
	gem_list[id] = gem

func _build_indices():
	equipment_by_slot.clear()
	equipment_by_quality.clear()
	equipment_by_type.clear()
	
	for eq in equipment_list.values():
		if not equipment_by_slot.has(eq.slot):
			equipment_by_slot[eq.slot] = []
		equipment_by_slot[eq.slot].append(eq)
		
		if not equipment_by_quality.has(eq.quality):
			equipment_by_quality[eq.quality] = []
		equipment_by_quality[eq.quality].append(eq)
		
		if not equipment_by_type.has(eq.type):
			equipment_by_type[eq.type] = []
		equipment_by_type[eq.type].append(eq)

func get_equipment(id: String) -> EquipmentData:
	return equipment_list.get(id)

func get_gem(id: String) -> GemData:
	return gem_list.get(id)

func get_all_equipment() -> Array[EquipmentData]:
	return equipment_list.values()

func get_equipment_by_slot(slot: String) -> Array[EquipmentData]:
	return equipment_by_slot.get(slot, [])

func get_equipment_by_quality(quality: String) -> Array[EquipmentData]:
	return equipment_by_quality.get(quality, [])

func get_equipment_by_type(type: String) -> Array[EquipmentData]:
	return equipment_by_type.get(type, [])

func get_equipment_set(set_id: String) -> EquipmentSetData:
	return equipment_sets.get(set_id)

func get_all_equipment_sets() -> Array[EquipmentSetData]:
	return equipment_sets.values()

func get_random_equipment(slot: String = "", quality: String = "", level: int = 1) -> EquipmentData:
	var candidates = equipment_list.values()
	
	if slot != "":
		candidates = candidates.filter(func(e): return e.slot == slot)
	
	if quality != "":
		candidates = candidates.filter(func(e): return e.quality == quality)
	
	candidates = candidates.filter(func(e): return e.level_requirement <= level)
	
	if candidates.is_empty():
		return null
	
	return candidates[randi() % candidates.size()]

func get_equipment_count() -> int:
	return equipment_list.size()