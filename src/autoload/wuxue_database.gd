extends Node
class_name WuxueDatabase

var wuxue_list: Dictionary = {}
var wuxue_by_type: Dictionary = {}
var wuxue_by_quality: Dictionary = {}
var wuxue_by_sect: Dictionary = {}
var sect_wuxue: Dictionary = {}
var ultimate_wuxue: Array[WuxueData] = []
var combo_wuxue: Dictionary = {}
var rng: RandomNumberGenerator

static var instance: WuxueDatabase = null

func _enter_tree():
	instance = self
	rng = RandomNumberGenerator.new()
	rng.randomize()
	_load_all_wuxue()

func _load_all_wuxue():
	# 拳掌类武学
	_create_quanzhang_wuxue()
	
	# 指法类武学
	_create_zhifa_wuxue()
	
	# 腿法类武学
	_create_tuifa_wuxue()
	
	# 剑法类武学
	_create_jianfa_wuxue()
	
	# 刀法类武学
	_create_daofa_wuxue()
	
	# 枪法类武学
	_create_qiangfa_wuxue()
	
	# 棍法类武学
	_create_gunfa_wuxue()
	
	# 鞭法类武学
	_create_bianfa_wuxue()
	
	# 暗器类武学
	_create_anqi_wuxue()
	
	# 琴音类武学
	_create_qinyin_wuxue()
	
	# 医术类武学
	_create_yishu_wuxue()
	
	# 毒术类武学
	_create_dushu_wuxue()
	
	# 机关类武学
	_create_jiguan_wuxue()
	
	# 轻功类武学
	_create_qinggong_wuxue()
	
	# 内功类武学
	_create_neigong_wuxue()
	
	# 心法类武学
	_create_xinfa_wuxue()
	
	# 门派武学
	_create_sect_wuxue()
	
	# 构建索引
	_build_indices()

func _create_quanzhang_wuxue():
	# 铁布衫 - 白色外功单体
	var w = _create_base_wuxue("tiebushan", "铁布衫", "拳掌", "白", "外功", "单体", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 80
	w.damage_scaling = {"atk": 1.2}
	w.description = "以内功护体，硬抗敌人攻击并反击"
	w.effects.append(_create_effect("护盾", "受击", 0.3, {"value": 50, "duration": 1}))
	w.tags = ["防御", "反击"]
	
	# 降龙十八掌 - 金色外功全体
	w = _create_base_wuxue("xianglong_shiba", "降龙十八掌", "拳掌", "金", "外功", "全体", 1, 3, 30, 20, 0, 3, 0)
	w.base_damage = 300
	w.damage_scaling = {"atk": 2.0, "spd": 0.5}
	w.is_ultimate = true
	w.description = "天下至刚至阳的掌法，威力惊人"
	w.effects.append(_create_effect("击退", "命中", 1.0, {"distance": 2}))
	w.effects.append(_create_effect("眩晕", "命中", 0.2, {"duration": 1}))
	w.tags = ["大招", "击退", "控制"]
	
	# 太极拳 - 紫色内功单体
	w = _create_base_wuxue("taiji_quan", "太极拳", "拳掌", "紫", "内功", "单体", 1, 1, 15, 0, 0, 1, 0)
	w.base_damage = 120
	w.damage_scaling = {"atk": 1.0, "def": 0.5}
	w.description = "以柔克刚，四两拨千斤"
	w.effects.append(_create_effect("反击", "受击", 0.5, {"chance": 0.8, "duration": 2}))
	w.effects.append(_create_effect("化劲", "常驻", 1.0, {"damage_reduction": 0.15}))
	w.tags = ["反击", "减伤", "内功"]
	
	# 野蛮冲撞 - 绿色外功单体位移
	w = _create_base_wuxue("yeman_chongzhuang", "野蛮冲撞", "拳掌", "绿", "外功", "单体", 1, 2, 5, 0, 0, 0, 0)
	w.base_damage = 100
	w.damage_scaling = {"atk": 1.5}
	w.description = "蛮力冲撞，击退敌人"
	w.effects.append(_create_effect("击退", "命中", 1.0, {"distance": 3}))
	w.effects.append(_create_effect("位移", "施放前", 1.0, {"direction": "向目标", "distance": 3}))
	w.tags = ["位移", "击退"]
	
	# 百步神拳 - 蓝色外功竖排
	w = _create_base_wuxue("baibu_shenquan", "百步神拳", "拳掌", "蓝", "外功", "竖排", 1, 3, 10, 0, 0, 2, 0)
	w.base_damage = 150
	w.damage_scaling = {"atk": 1.3}
	w.description = "拳风如箭，穿透直线上的敌人"
	w.effects.append(_create_effect("内伤", "命中", 0.3, {"value": 20, "duration": 3}))
	w.tags = ["穿透", "内伤"]
	
	# 如来神掌 - 红色外功全体
	w = _create_base_wuxue("rulai_shenzhang", "如来神掌", "拳掌", "红", "外功", "全体", 1, 4, 50, 30, 0, 5, 0)
	w.base_damage = 400
	w.damage_scaling = {"atk": 2.5, "hp": 0.01}
	w.is_ultimate = true
	w.description = "佛门绝学，掌心佛国，普度众生"
	w.effects.append(_create_effect("封印", "命中", 0.4, {"duration": 2}))
	w.effects.append(_create_effect("禁疗", "命中", 0.3, {"duration": 3}))
	w.tags = ["大招", "封印", "禁疗"]

func _create_zhifa_wuxue():
	# 一阳指 - 白色内功单体
	var w = _create_base_wuxue("iyang_zhi", "一阳指", "指法", "白", "内功", "单体", 1, 1, 5, 0, 0, 0, 0)
	w.base_damage = 60
	w.damage_scaling = {"atk": 0.8, "spd": 0.5}
	w.description = "指力贯穿，点穴封血"
	w.effects.append(_create_effect("封印", "命中", 0.15, {"duration": 1}))
	w.tags = ["封印", "点穴"]
	
	# 六脉神剑 - 金色内功横排
	w = _create_base_wuxue("liu_mai_shen_jian", "六脉神剑", "指法", "金", "内功", "横排", 1, 3, 25, 15, 0, 3, 0)
	w.base_damage = 200
	w.damage_scaling = {"atk": 1.5, "spd": 1.0}
	w.description = "六脉剑气纵横，无坚不摧"
	w.effects.append(_create_effect("剑气", "命中", 1.0, {"damage_bonus": 0.3, "duration": 2}))
	w.effects.append(_create_effect("流血", "命中", 0.4, {"damage": 30, "duration": 3}))
	w.tags = ["剑气", "流血", "大招"]
	
	# 弹指神通 - 紫色内功单体
	w = _create_base_wuxue("tanzhi_shentong", "弹指神通", "指法", "紫", "内功", "单体", 1, 2, 15, 5, 0, 2, 0)
	w.base_damage = 150
	w.damage_scaling = {"atk": 1.2, "spd": 0.8}
	w.description = "弹指间灰飞烟灭"
	w.effects.append(_create_effect("沉默", "命中", 0.3, {"duration": 2}))
	w.effects.append(_create_effect("推条", "命中", 1.0, {"value": 30}))
	w.tags = ["沉默", "推条"]
	
	# 兰花拂穴手 - 蓝色内功单体
	w = _create_base_wuxue("lanhua_fuxue", "兰花拂穴手", "指法", "蓝", "内功", "单体", 1, 1, 10, 0, 0, 1, 0)
	w.base_damage = 100
	w.damage_scaling = {"atk": 1.0, "spd": 0.6}
	w.description = "手法轻柔如兰花，暗藏杀机"
	w.effects.append(_create_effect("定身", "命中", 0.25, {"duration": 1}))
	w.effects.append(_create_effect("减速", "命中", 0.5, {"value": 0.3, "duration": 2}))
	w.tags = ["定身", "减速"]

func _create_tuifa_wuxue():
	# 腿法 - 基础
	var w = _create_base_wuxue("tui_fa", "腿法", "腿法", "白", "外功", "单体", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 70
	w.damage_scaling = {"atk": 1.1, "spd": 0.3}
	w.description = "基础腿法，快速连踢"
	w.tags = ["连击"]
	
	# 狮吼功 - 绿色内功十字
	w = _create_base_wuxue("shihou_gong", "狮吼功", "腿法", "绿", "内功", "十字", 1, 2, 10, 0, 0, 2, 0)
	w.base_damage = 120
	w.damage_scaling = {"atk": 1.0, "spd": 0.5}
	w.description = "佛门狮吼，声震四方"
	w.effects.append(_create_effect("眩晕", "命中", 0.3, {"duration": 1}))
	w.effects.append(_create_effect("推条", "命中", 1.0, {"value": 20}))
	w.tags = ["眩晕", "范围"]
	
	# 乾坤大挪移 - 金色内功单体位移
	w = _create_base_wuxue("qiankun_danyi", "乾坤大挪移", "腿法", "金", "内功", "单体", 1, 1, 30, 20, 0, 3, 0)
	w.base_damage = 100
	w.damage_scaling = {"atk": 0.5, "spd": 1.5}
	w.is_ultimate = true
	w.description = "移形换位，化解攻击并反击"
	w.effects.append(_create_effect("位移", "施放前", 1.0, {"direction": "远离最近敌人", "distance": 4}))
	w.effects.append(_create_effect("无敌", "施放前", 1.0, {"duration": 1}))
	w.effects.append(_create_effect("反击", "受击", 1.0, {"chance": 1.0, "damage_multiplier": 2.0}))
	w.tags = ["位移", "无敌", "反击", "大招"]
	
	# 龙腿 - 红色外功菱形
	w = _create_base_wuxue("long_tui", "龙腿", "腿法", "红", "外功", "菱形", 1, 2, 40, 25, 0, 4, 0)
	w.base_damage = 350
	w.damage_scaling = {"atk": 2.0, "spd": 1.0}
	w.is_ultimate = true
	w.description = "龙行天下，腿影重重"
	w.effects.append(_create_effect("龙拳", "命中", 1.0, {"combo_count": 3, "damage_per_hit": 0.4}))
	w.effects.append(_create_effect("击退", "命中", 1.0, {"distance": 2}))
	w.tags = ["连击", "击退", "龙拳", "大招"]

func _create_jianfa_wuxue():
	# 基础剑法
	var w = _create_base_wuxue("jichu_jianfa", "基础剑法", "剑法", "白", "外功", "单体", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 80
	w.damage_scaling = {"atk": 1.2}
	w.requires_weapon = "剑"
	w.description = "剑法入门，直刺横扫"
	w.tags = ["剑", "基础"]
	
	# 独孤九剑 - 金色外功单体
	w = _create_base_wuxue("dugu_jiujian", "独孤九剑", "剑法", "金", "外功", "单体", 1, 1, 25, 10, 0, 2, 0)
	w.base_damage = 250
	w.damage_scaling = {"atk": 1.8, "spd": 1.2}
	w.requires_weapon = "剑"
	w.is_combo_starter = true
	w.description = "破招式之总诀，无招胜有招"
	w.effects.append(_create_effect("破防", "命中", 1.0, {"value": 0.5, "duration": 2}))
	w.effects.append(_create_effect("连击", "命中", 0.5, {"count": 3}))
	w.effects.append(_create_effect("追击", "击杀", 1.0, {"chance": 1.0}))
	w.tags = ["破招", "连击", "追击", "剑"]
	
	# 太极剑 - 紫色内功横排
	w = _create_base_wuxue("taiji_jian", "太极剑", "剑法", "紫", "内功", "横排", 1, 3, 20, 0, 0, 3, 0)
	w.base_damage = 180
	w.damage_scaling = {"atk": 1.2, "def": 0.5}
	w.requires_weapon = "剑"
	w.description = "剑意阴阳，绵绵不绝"
	w.effects.append(_create_effect("阴阳", "常驻", 1.0, {"damage_bonus": 0.2, "heal_on_hit": 0.1}))
	w.effects.append(_create_effect("护盾", "回合开始", 1.0, {"value": 100, "duration": 1}))
	w.tags = ["阴阳", "护盾", "吸血", "剑"]
	
	# 玉女素心剑 - 红色外功全体
	w = _create_base_wuxue("yunu_suxin_jian", "玉女素心剑", "剑法", "红", "外功", "全体", 1, 4, 40, 20, 0, 4, 0)
	w.base_damage = 300
	w.damage_scaling = {"atk": 1.5, "spd": 1.5}
	w.requires_weapon = "剑"
	w.is_ultimate = true
	w.description = "玉女心经与素心剑合二为一"
	w.effects.append(_create_effect("清除增益", "命中", 1.0, {"count": 3}))
	w.effects.append(_create_effect("幻影", "施放后", 1.0, {"duration": 2, "dodge_bonus": 0.5}))
	w.tags = ["清除增益", "幻影", "大招", "剑"]
	
	# 华山剑法 - 蓝色外功竖排
	w = _create_base_wuxue("huashan_jianfa", "华山剑法", "剑法", "蓝", "外功", "竖排", 1, 3, 15, 5, 0, 2, 0)
	w.base_damage = 160
	w.damage_scaling = {"atk": 1.4}
	w.requires_weapon = "剑"
	w.description = "华山一派剑法，气势磅礴"
	w.effects.append(_create_effect("剑气", "命中", 0.5, {"damage_bonus": 0.3, "duration": 2}))
	w.tags = ["剑气", "剑"]

func _create_daofa_wuxue():
	# 基础刀法
	var w = _create_base_wuxue("jichu_daofa", "基础刀法", "刀法", "白", "外功", "单体", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 90
	w.damage_scaling = {"atk": 1.3}
	w.requires_weapon = "刀"
	w.description = "刀法入门，劈砍挑刺"
	w.tags = ["刀", "基础"]
	
	# 魔刀·血饮 - 金色外功单体吸血
	w = _create_base_wuxue("modao_xueyin", "魔刀·血饮", "刀法", "金", "外功", "单体", 1, 1, 20, 15, 0, 3, 0)
	w.base_damage = 220
	w.damage_scaling = {"atk": 1.6, "hp": 0.02}
	w.requires_weapon = "刀"
	w.description = "饮血魔刀，杀人越强"
	w.effects.append(_create_effect("吸血", "命中", 1.0, {"rate": 0.5}))
	w.effects.append(_create_effect("狂战", "击杀", 1.0, {"atk_bonus": 0.2, "max_stacks": 5}))
	w.effects.append(_create_effect("魔刀", "施放后", 1.0, {"duration": 3, "form": "魔刀"}))
	w.tags = ["吸血", "狂战", "魔刀", "变身", "刀"]
	
	# 佛刀·舍身 - 紫色外功横排格挡
	w = _create_base_wuxue("fodao_shehen", "佛刀·舍身", "刀法", "紫", "外功", "横排", 1, 3, 20, 10, 0, 2, 0)
	w.base_damage = 160
	w.damage_scaling = {"atk": 1.2, "def": 0.8}
	w.requires_weapon = "刀"
	w.description = "舍身成佛，护佑众生"
	w.effects.append(_create_effect("格挡", "常驻", 1.0, {"chance": 0.4, "reduction": 0.5}))
	w.effects.append(_create_effect("援护", "友方受击", 0.5, {"range": 2, "damage_share": 0.3}))
	w.effects.append(_create_effect("佛刀", "施放后", 1.0, {"duration": 3, "form": "佛刀"}))
	w.tags = ["格挡", "援护", "佛刀", "变身", "刀"]
	
	# 刀魔·斩业 - 红色外功全体
	w = _create_base_wuxue("daomo_zhanye", "刀魔·斩业", "刀法", "红", "外功", "全体", 1, 4, 50, 30, 0, 5, 0)
	w.base_damage = 400
	w.damage_scaling = {"atk": 2.5, "hp": 0.05}
	w.requires_weapon = "刀"
	w.is_ultimate = true
	w.description = "一刀斩断红尘业障"
	w.effects.append(_create_effect("破盾", "命中", 1.0, {"ignore_shield": true}))
	w.effects.append(_create_effect("重伤", "命中", 0.5, {"heal_reduction": 1.0, "duration": 3}))
	w.effects.append(_create_effect("斩杀", "击杀", 1.0, {"rage_gain": 50}))
	w.tags = ["破盾", "重伤", "斩杀", "大招", "刀"]

func _create_qiangfa_wuxue():
	# 基础枪法
	var w = _create_base_wuxue("jichu_qiangfa", "基础枪法", "枪法", "白", "外功", "单体", 1, 2, 0, 0, 0, 0, 0)
	w.base_damage = 85
	w.damage_scaling = {"atk": 1.2, "spd": 0.4}
	w.requires_weapon = "枪"
	w.description = "枪如游龙，攻守兼备"
	w.tags = ["枪", "基础"]
	
	# 百鸟朝凤枪 - 蓝色外功竖排
	w = _create_base_wuxue("bainiao_chaofeng", "百鸟朝凤枪", "枪法", "蓝", "外功", "竖排", 1, 3, 15, 5, 0, 2, 0)
	w.base_damage = 160
	w.damage_scaling = {"atk": 1.3, "spd": 0.8}
	w.requires_weapon = "枪"
	w.description = "枪尖如百鸟朝凤，变幻莫测"
	w.effects.append(_create_effect("穿透", "命中", 1.0, {"ignore_def": 0.3}))
	w.effects.append(_create_effect("连击", "命中", 0.4, {"count": 2}))
	w.tags = ["穿透", "连击", "枪"]
	
	# 火神枪 - 金色外功十字
	w = _create_base_wuxue("huoshen_qiang", "火神枪", "枪法", "金", "外功", "十字", 1, 2, 30, 20, 0, 3, 0)
	w.base_damage = 280
	w.damage_scaling = {"atk": 1.8, "spd": 0.6}
	w.requires_weapon = "枪"
	w.description = "枪出如火龙，焚烧八荒"
	w.effects.append(_create_effect("燃烧", "命中", 0.6, {"damage": 50, "duration": 3}))
	w.effects.append(_create_effect("击退", "命中", 1.0, {"distance": 2}))
	w.effects.append(_create_effect("灼热", "时序", 1.0, {"timestamps": [100, 200, 300], "damage": 30}))
	w.tags = ["燃烧", "击退", "时序", "枪"]
	
	# 破军枪 - 红色外功单体
	w = _create_base_wuxue("pojun_qiang", "破军枪", "枪法", "红", "外功", "单体", 1, 1, 40, 25, 0, 4, 0)
	w.base_damage = 500
	w.damage_scaling = {"atk": 3.0, "spd": 1.0}
	w.requires_weapon = "枪"
	w.is_ultimate = true
	w.description = "破军星现，一枪定乾坤"
	w.effects.append(_create_effect("破甲", "命中", 1.0, {"def_reduction": 0.8, "duration": 3}))
	w.effects.append(_create_effect("真实伤害", "命中", 1.0, {"value": 200}))
	w.effects.append(_create_effect("霸体", "施放前", 1.0, {"duration": 1}))
	w.tags = ["破甲", "真伤", "霸体", "大招", "枪"]

func _create_gunfa_wuxue():
	# 基础棍法
	var w = _create_base_wuxue("jichu_gunfa", "基础棍法", "棍法", "白", "外功", "单体", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 80
	w.damage_scaling = {"atk": 1.2, "def": 0.3}
	w.requires_weapon = "棍"
	w.description = "棍打一片，防守反击"
	w.tags = ["棍", "基础"]
	
	# 降魔杖法 - 绿色外功十字
	w = _create_base_wuxue("xiangmo_zhangfa", "降魔杖法", "棍法", "绿", "外功", "十字", 1, 2, 10, 0, 0, 2, 0)
	w.base_damage = 130
	w.damage_scaling = {"atk": 1.1, "def": 0.5}
	w.requires_weapon = "棍"
	w.description = "佛门降魔，正气凛然"
	w.effects.append(_create_effect("眩晕", "命中", 0.3, {"duration": 1}))
	w.effects.append(_create_effect("净化", "命中", 1.0, {"remove_debuffs": 1}))
	w.tags = ["眩晕", "净化", "棍"]
	
	# 打狗棒法 - 金色外功菱形
	w = _create_base_wuxue("dagou_bangfa", "打狗棒法", "棍法", "金", "外功", "菱形", 1, 2, 25, 15, 0, 3, 0)
	w.base_damage = 200
	w.damage_scaling = {"atk": 1.4, "spd": 1.0}
	w.requires_weapon = "棍"
	w.description = "丐帮绝学，巧打妙拨"
	w.effects.append(_create_effect("缴械", "命中", 0.3, {"duration": 2}))
	w.effects.append(_create_effect("偷怒气", "命中", 0.5, {"value": 10}))
	w.effects.append(_create_effect("协同", "队友行动", 0.3, {"ally_action": "attack"}))
	w.tags = ["缴械", "偷怒气", "协同", "棍"]
	
	# 混元一气棍 - 红色外功全体
	w = _create_base_wuxue("hunyuan_yiqi_gun", "混元一气棍", "棍法", "红", "外功", "全体", 1, 3, 45, 25, 0, 4, 0)
	w.base_damage = 350
	w.damage_scaling = {"atk": 2.0, "def": 1.0}
	w.requires_weapon = "棍"
	w.is_ultimate = true
	w.description = "混元一气，万法归一"
	w.effects.append(_create_effect("护盾", "施放前", 1.0, {"value": 500, "duration": 2, "team": true}))
	w.effects.append(_create_effect("混元", "命中", 1.0, {"damage_types": ["外功", "内功", "真实"]}))
	w.tags = ["护盾", "混元", "大招", "棍"]

func _create_bianfa_wuxue():
	# 基础鞭法
	var w = _create_base_wuxue("jichu_bianfa", "基础鞭法", "鞭法", "白", "外功", "单体", 1, 2, 0, 0, 0, 0, 0)
	w.base_damage = 75
	w.damage_scaling = {"atk": 1.1, "spd": 0.6}
	w.requires_weapon = "鞭"
	w.description = "鞭长莫及，柔中带刚"
	w.tags = ["鞭", "基础"]
	
	# 灵蛇鞭法 - 蓝色外功横排
	w = _create_base_wuxue("lingshe_bianfa", "灵蛇鞭法", "鞭法", "蓝", "外功", "横排", 1, 3, 15, 5, 0, 2, 0)
	w.base_damage = 140
	w.damage_scaling = {"atk": 1.2, "spd": 0.8}
	w.requires_weapon = "鞭"
	w.description = "鞭影如灵蛇，难以捉摸"
	w.effects.append(_create_effect("中毒", "命中", 0.5, {"damage": 25, "duration": 3}))
	w.effects.append(_create_effect("拉近", "命中", 0.3, {"distance": 2}))
	w.tags = ["中毒", "拉近", "鞭"]

func _create_anqi_wuxue():
	# 基础暗器
	var w = _create_base_wuxue("jichu_anqi", "基础暗器", "暗器", "白", "外功", "单体", 1, 3, 0, 0, 0, 0, 0)
	w.base_damage = 60
	w.damage_scaling = {"atk": 0.8, "spd": 1.0}
	w.requires_weapon = "暗器"
	w.description = "暗器手法，出其不意"
	w.tags = ["暗器", "基础"]
	
	# 雨花针 - 金色外功全体
	w = _create_base_wuxue("yuhua_zhen", "雨花针", "暗器", "金", "外功", "全体", 1, 3, 25, 15, 0, 3, 0)
	w.base_damage = 120
	w.damage_scaling = {"atk": 1.0, "spd": 1.5}
	w.requires_weapon = "暗器"
	w.description = "满天花雨，无处可躲"
	w.effects.append(_create_effect("中毒", "命中", 0.8, {"damage": 15, "duration": 3}))
	w.effects.append(_create_effect("流血", "命中", 0.4, {"damage": 20, "duration": 2}))
	w.effects.append(_create_effect("随机", "额外", 0.3, {"target_count": 2}))
	w.tags = ["中毒", "流血", "随机", "暗器"]
	
	# 满天花雨 - 红色外功菱形
	w = _create_base_wuxue("mantian_huayu", "满天花雨", "暗器", "红", "外功", "菱形", 2, 3, 40, 20, 0, 4, 0)
	w.base_damage = 180
	w.damage_scaling = {"atk": 1.2, "spd": 1.8}
	w.requires_weapon = "暗器"
	w.is_ultimate = true
	w.description = "漫天花雨，无孔不入"
	w.effects.append(_create_effect("暴雨", "时序", 1.0, {"timestamps": [50, 100, 150, 200, 250], "damage": 80}))
	w.effects.append(_create_effect("百毒", "命中", 0.6, {"poison_damage": 30, "duration": 5}))
	w.tags = ["时序", "百毒", "大招", "暗器"]

func _create_qinyin_wuxue():
	# 基础琴音
	var w = _create_base_wuxue("jichu_qinyin", "基础琴音", "琴音", "白", "内功", "友方全体", 1, 1, 0, 0, 10, 0, 0)
	w.base_heal = 50
	w.heal_scaling = {"atk": 0.5}
	w.requires_weapon = "琴"
	w.description = "琴音悠扬，抚慰人心"
	w.tags = ["治疗", "琴"]
	
	# 高山流水 - 紫色内功友方全体
	w = _create_base_wuxue("gaoshan_liushui", "高山流水", "琴音", "紫", "内功", "友方全体", 1, 1, 30, 0, 0, 3, 0)
	w.base_heal = 200
	w.heal_scaling = {"atk": 0.8}
	w.requires_weapon = "琴"
	w.description = "高山流水，遇知音者"
	w.effects.append(_create_effect("加怒气", "治疗", 1.0, {"value": 10}))
	w.effects.append(_create_effect("清除减益", "治疗", 1.0, {"count": 2}))
	w.effects.append(_create_effect("护盾", "治疗", 1.0, {"value": 150, "duration": 2}))
	w.tags = ["治疗", "加怒", "净化", "护盾", "琴"]
	
	# 广陵散 - 金色内功友方全体
	w = _create_base_wuxue("guangling_san", "广陵散", "琴音", "金", "内功", "友方全体", 1, 1, 40, 0, 15, 4, 0)
	w.base_heal = 300
	w.heal_scaling = {"atk": 1.2}
	w.requires_weapon = "琴"
	w.is_ultimate = true
	w.description = "绝响之曲，起死回生"
	w.effects.append(_create_effect("复活", "治疗", 0.2, {"hp_percent": 0.5}))
	w.effects.append(_create_effect("无敌", "治疗", 1.0, {"duration": 1}))
	w.effects.append(_create_effect("全属性", "常驻", 1.0, {"all_stats": 0.2, "duration": 3}))
	w.tags = ["复活", "无敌", "全属性", "大招", "琴"]
	
	# 十面埋伏 - 红色内功敌方全体
	w = _create_base_wuxue("shimian_maifu", "十面埋伏", "琴音", "红", "内功", "敌方全体", 1, 1, 50, 30, 0, 5, 0)
	w.base_damage = 200
	w.damage_scaling = {"atk": 1.5, "spd": 1.0}
	w.requires_weapon = "琴"
	w.is_ultimate = true
	w.description = "琴声杀机，十面埋伏"
	w.effects.append(_create_effect("恐惧", "命中", 0.5, {"duration": 2}))
	w.effects.append(_create_effect("混乱", "命中", 0.3, {"duration": 2}))
	w.effects.append(_create_effect("禁音", "命中", 1.0, {"duration": 3}))
	w.tags = ["恐惧", "混乱", "禁音", "大招", "琴"]

func _create_yishu_wuxue():
	# 基础医术
	var w = _create_base_wuxue("jichu_yishu", "基础医术", "医术", "白", "内功", "友方单体", 1, 1, 0, 0, 10, 0, 0)
	w.base_heal = 80
	w.heal_scaling = {"atk": 0.6}
	w.description = "悬壶济世，妙手回春"
	w.tags = ["治疗", "医术"]
	
	# 回春术 - 蓝色内功友方单体
	w = _create_base_wuxue("huichun_shu", "回春术", "医术", "蓝", "内功", "友方单体", 1, 1, 15, 0, 0, 2, 0)
	w.base_heal = 250
	w.heal_scaling = {"atk": 1.0}
	w.description = "起死回生，春回大地"
	w.effects.append(_create_effect("清除减益", "治疗", 1.0, {"count": 3}))
	w.effects.append(_create_effect("护盾", "治疗", 1.0, {"value": 200, "duration": 2}))
	w.tags = ["治疗", "净化", "护盾", "医术"]
	
	# 九转还魂丹 - 金色内功友方单体
	w = _create_base_wuxue("jiuzhuan_huanhun", "九转还魂丹", "医术", "金", "内功", "友方单体", 1, 1, 50, 0, 20, 5, 0)
	w.base_heal = 500
	w.heal_scaling = {"atk": 1.5}
	w.is_ultimate = true
	w.description = "九转丹成，可救死人"
	w.effects.append(_create_effect("复活", "治疗", 1.0, {"hp_percent": 0.8}))
	w.effects.append(_create_effect("满状态", "复活", 1.0, {"clear_all_debuffs": true, "full_mp": true, "rage": 100}))
	w.tags = ["复活", "满状态", "大招", "医术"]
	
	# 悬壶济世 - 紫色内功友方全体
	w = _create_base_wuxue("xuanhu_jishi", "悬壶济世", "医术", "紫", "内功", "友方全体", 1, 1, 35, 0, 0, 3, 0)
	w.base_heal = 180
	w.heal_scaling = {"atk": 0.8}
	w.description = "大医精诚，普济众生"
	w.effects.append(_create_effect("持续治疗", "治疗", 1.0, {"heal_per_turn": 100, "duration": 3}))
	w.effects.append(_create_effect("免疫减益", "治疗", 1.0, {"duration": 2}))
	w.tags = ["持续治疗", "免疫减益", "医术"]

func _create_dushu_wuxue():
	# 基础毒术
	var w = _create_base_wuxue("jichu_dushu", "基础毒术", "毒术", "白", "内功", "单体", 1, 2, 0, 0, 5, 0, 0)
	w.base_damage = 50
	w.damage_scaling = {"atk": 0.5, "spd": 0.5}
	w.description = "毒药入门，细水长流"
	w.effects.append(_create_effect("中毒", "命中", 1.0, {"damage": 15, "duration": 3}))
	w.tags = ["中毒", "毒术"]
	
	# 五毒教秘毒 - 紫色内功十字
	w = _create_base_wuxue("wudu_midu", "五毒教秘毒", "毒术", "紫", "内功", "十字", 1, 2, 20, 10, 0, 2, 0)
	w.base_damage = 100
	w.damage_scaling = {"atk": 0.8, "spd": 0.6}
	w.description = "五毒俱全，中者必亡"
	w.effects.append(_create_effect("剧毒", "命中", 1.0, {"damage": 40, "duration": 4, "spread": true}))
	w.effects.append(_create_effect("腐蚀", "命中", 0.5, {"def_reduction": 0.2, "duration": 3}))
	w.tags = ["剧毒", "腐蚀", "传播", "毒术"]
	
	# 蚀骨穿心散 - 红色内功单体
	w = _create_base_wuxue("shigu_chuanxin", "蚀骨穿心散", "毒术", "红", "内功", "单体", 1, 1, 40, 20, 0, 4, 0)
	w.base_damage = 50
	w.damage_scaling = {"atk": 0.3}
	w.is_ultimate = true
	w.description = "剧毒攻心，骨肉俱碎"
	w.effects.append(_create_effect("蚀骨", "命中", 1.0, {"damage_per_turn": 100, "duration": 5, "ignore_def": true}))
	w.effects.append(_create_effect("穿心", "命中", 1.0, {"true_damage": 200, "heal_ban": 3}))
	w.effects.append(_create_effect("传染", "死亡", 1.0, {"radius": 2, "damage": 200}))
	w.tags = ["蚀骨", "穿心", "传染", "禁疗", "大招", "毒术"]

func _create_jiguan_wuxue():
	# 基础机关
	var w = _create_base_wuxue("jichu_jiguan", "基础机关", "机关", "白", "外功", "单体", 1, 1, 0, 0, 5, 0, 0)
	w.base_damage = 70
	w.damage_scaling = {"atk": 1.0, "spd": 0.5}
	w.description = "机关术入门，巧制木鸟"
	w.tags = ["机关", "基础"]
	
	# 木牛流马 - 蓝色外功召唤
	w = _create_base_wuxue("muniu_liuma", "木牛流马", "机关", "蓝", "外功", "自身", 1, 1, 20, 0, 0, 3, 0)
	w.base_damage = 0
	w.description = "制造机关兽协助战斗"
	w.effects.append(_create_effect("召唤", "施放", 1.0, {"summon_id": "muniu", "count": 1, "duration": 5}))
	w.effects.append(_create_effect("召唤", "施放", 1.0, {"summon_id": "liuma", "count": 1, "duration": 5}))
	w.tags = ["召唤", "机关兽", "机关"]
	
	# 诸葛连弩 - 金色外功全体
	w = _create_base_wuxue("zhuge_liannu", "诸葛连弩", "机关", "金", "外功", "全体", 1, 3, 30, 15, 0, 3, 0)
	w.base_damage = 150
	w.damage_scaling = {"atk": 1.5, "spd": 0.8}
	w.description = "连弩齐发，箭雨如林"
	w.effects.append(_create_effect("连射", "命中", 1.0, {"hit_count": 5, "damage_per_hit": 0.3}))
	w.effects.append(_create_effect("破甲", "命中", 0.5, {"def_reduction": 0.3, "duration": 2}))
	w.tags = ["连射", "破甲", "机关"]
	
	# 天机阵 - 红色外功地面
	w = _create_base_wuxue("tianji_zhen", "天机阵", "机关", "红", "外功", "指定", 3, 3, 50, 25, 0, 5, 0)
	w.base_damage = 300
	w.damage_scaling = {"atk": 1.8, "spd": 0.5}
	w.is_ultimate = true
	w.description = "布下天机，步步杀机"
	w.effects.append(_create_effect("地雷", "施放", 1.0, {"mine_id": "tianji", "count": 5, "damage": 300, "duration": 5}))
	w.effects.append(_create_effect("机关", "时序", 1.0, {"timestamps": [100, 200, 300], "trigger": "tianji_explode"}))
	w.tags = ["地雷", "机关", "时序", "大招", "机关"]

func _create_qinggong_wuxue():
	# 基础轻功
	var w = _create_base_wuxue("jichu_qinggong", "基础轻功", "轻功", "白", "内功", "自身", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 0
	w.description = "轻功入门，行云流水"
	w.effects.append(_create_effect("加移动", "常驻", 1.0, {"move_range": 1}))
	w.effects.append(_create_effect("加集气", "常驻", 1.0, {"qi_speed": 0.2}))
	w.tags = ["移动", "集气", "轻功"]
	
	# 凌波微步 - 金色内功自身
	w = _create_base_wuxue("lingbo_weibu", "凌波微步", "轻功", "金", "内功", "自身", 1, 1, 30, 0, 0, 3, 0)
	w.base_damage = 0
	w.description = "逍遥派绝学，步法神妙"
	w.effects.append(_create_effect("闪避", "常驻", 1.0, {"dodge_chance": 0.4}))
	w.effects.append(_create_effect("位移", "受击", 0.5, {"distance": 2, "avoid_damage": true}))
	w.effects.append(_create_effect("加移动", "常驻", 1.0, {"move_range": 2}))
	w.effects.append(_create_effect("幻影", "施放后", 1.0, {"duration": 2, "dodge_bonus": 0.3}))
	w.tags = ["闪避", "位移", "幻影", "移动", "轻功"]
	
	# 一苇渡江 - 红色内功自身位移
	w = _create_base_wuxue("yiwei_dujiang", "一苇渡江", "轻功", "红", "内功", "自身", 1, 5, 40, 0, 0, 4, 0)
	w.base_damage = 0
	w.is_ultimate = true
	w.description = "以内力为舟，渡江而过"
	w.effects.append(_create_effect("超远位移", "施放", 1.0, {"max_distance": 6, "ignore_obstacle": true}))
	w.effects.append(_create_effect("无敌", "位移中", 1.0, {"duration": 1}))
	w.effects.append(_create_effect("留影", "位移后", 1.0, {"phantom_count": 2, "duration": 2}))
	w.tags = ["超远位移", "无敌", "留影", "大招", "轻功"]

func _create_neigong_wuxue():
	# 基础内功
	var w = _create_base_wuxue("jichu_neigong", "基础内功", "内功", "白", "内功", "自身", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 0
	w.description = "内功心法，练气养生"
	w.effects.append(_create_effect("加血上限", "常驻", 1.0, {"hp_percent": 0.1}))
	w.effects.append(_create_effect("加内力", "常驻", 1.0, {"mp_percent": 0.15}))
	w.effects.append(_create_effect("回内", "回合开始", 1.0, {"mp_regen": 10}))
	w.tags = ["血上限", "内力", "回内", "内功"]
	
	# 九阳神功 - 金色内功自身
	w = _create_base_wuxue("jiuyang_shengong", "九阳神功", "内功", "金", "内功", "自身", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 0
	w.description = "至阳至刚，百毒不侵"
	w.effects.append(_create_effect("免疫毒", "常驻", 1.0, {"poison_immune": true}))
	w.effects.append(_create_effect("反伤", "受击", 0.3, {"rate": 0.5}))
	w.effects.append(_create_effect("回血", "回合开始", 1.0, {"hp_regen_percent": 0.05}))
	w.effects.append(_create_effect("狂暴", "血量低", 0.5, {"hp_threshold": 0.3, "atk_bonus": 0.5}))
	w.tags = ["免疫毒", "反伤", "回血", "狂暴", "内功"]
	
	# 九阴真经 - 红色内功自身
	w = _create_base_wuxue("jiuyin_zhenjing", "九阴真经", "内功", "红", "内功", "自身", 1, 1, 0, 0, 0, 0, 0)
	w.base_damage = 0
	w.description = "阴阳互补，武学总纲"
	w.effects.append(_create_effect("阴阳", "常驻", 1.0, {"yin_damage": 0.3, "yang_heal": 0.3}))
	w.effects.append(_create_effect("化劲", "受击", 0.5, {"redirect_damage": 0.5}))
	w.effects.append(_create_effect("吸星", "命中", 0.2, {"steal_mp": 20, "steal_rage": 10}))
	w.effects.append(_create_effect("易筋", "时序", 1.0, {"timestamps": [200, 400, 600], "random_buff": true}))
	w.tags = ["阴阳", "化劲", "吸星", "易筋", "内功"]
	
	# 北冥神功 - 紫色内功单体
	w = _create_base_wuxue("beiming_shengong", "北冥神功", "内功", "紫", "内功", "单体", 1, 1, 20, 0, 0, 2, 0)
	w.base_damage = 0
	w.description = "化敌内力为己用"
	w.effects.append(_create_effect("吸内力", "命中", 1.0, {"mp_steal": 30}))
	w.effects.append(_create_effect("吸怒气", "命中", 0.5, {"rage_steal": 15}))
	w.effects.append(_create_effect("反噬", "自身", 0.1, {"damage_percent": 0.1}))
	w.tags = ["吸内力", "吸怒气", "反噬", "内功"]

func _create_xinfa_wuxue():
	# 心法类武学通常是被动，这里作为特殊主动技
	var w = _create_base_wuxue("xinfa_kuangbao", "狂暴心法", "心法", "金", "内功", "自身", 1, 1, 30, 20, 0, 3, 0)
	w.base_damage = 0
	w.description = "激发潜能，陷入狂暴"
	w.effects.append(_create_effect("狂暴", "施放", 1.0, {"atk_bonus": 1.0, "def_penalty": 0.5, "duration": 3, "rage_per_turn": 20}))
	w.tags = ["狂暴", "变身", "心法"]
	
	w = _create_base_wuxue("xinfa_bingxin", "冰心诀", "心法", "紫", "内功", "自身", 1, 1, 20, 0, 0, 2, 0)
	w.base_damage = 0
	w.description = "心如止水，免疫控制"
	w.effects.append(_create_effect("冰心", "施放", 1.0, {"control_immune": true, "damage_reduction": 0.3, "duration": 3}))
	w.tags = ["免疫控制", "减伤", "心法"]

func _create_sect_wuxue():
	# 恒山派 - 反击流
	_create_sect_wuxue_branch("hengshan", "恒山派", [
		{"id": "hengshan_fanji", "name": "恒山反击剑", "type": "剑法", "quality": "紫", "damage_type": "外功", "target_type": "单体", "range_min": 1, "range_max": 1, "mp_cost": 10, "rage_cost": 0, "qi_cost": 0, "cooldown": 2, "timestamp_offset": 0, "description": "反击概率提升"},
		{"id": "hengshan_wuliang", "name": "无量剑意", "type": "剑法", "quality": "金", "damage_type": "外功", "target_type": "十字", "range_min": 1, "range_max": 2, "mp_cost": 20, "rage_cost": 10, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "全方位反击"},
		{"id": "hengshan_hengshan", "name": "恒山剑法", "type": "剑法", "quality": "蓝", "damage_type": "外功", "target_type": "横排", "range_min": 1, "range_max": 3, "mp_cost": 5, "rage_cost": 0, "qi_cost": 0, "cooldown": 1, "timestamp_offset": 0, "description": "基础剑法"},
	])
	
	# 华山派 - 阴阳内气
	_create_sect_wuxue_branch("huashan", "华山派", [
		{"id": "huashan_yinyang", "name": "阴阳内气", "type": "内功", "quality": "金", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 15, "rage_cost": 0, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "阴阳转换"},
		{"id": "huashan_fengyin", "name": "封印剑气", "type": "剑法", "quality": "紫", "damage_type": "内功", "target_type": "竖排", "range_min": 1, "range_max": 3, "mp_cost": 15, "rage_cost": 5, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "封印敌人技能"},
		{"id": "huashan_jianqi", "name": "华山剑气", "type": "剑法", "quality": "蓝", "damage_type": "外功", "target_type": "单体", "range_min": 1, "range_max": 1, "mp_cost": 10, "rage_cost": 0, "qi_cost": 0, "cooldown": 2, "timestamp_offset": 0, "description": "基础剑气"},
	])
	
	# 刀魔传人 - 魔刀/佛刀
	_create_sect_wuxue_branch("daomo", "刀魔传人", [
		{"id": "daomo_modao", "name": "魔刀·嗜血", "type": "刀法", "quality": "金", "damage_type": "外功", "target_type": "单体", "range_min": 1, "range_max": 1, "mp_cost": 20, "rage_cost": 15, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "吸血狂暴"},
		{"id": "daomo_fodao", "name": "佛刀·渡厄", "type": "刀法", "quality": "金", "damage_type": "外功", "target_type": "横排", "range_min": 1, "range_max": 3, "mp_cost": 20, "rage_cost": 10, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "格挡援护"},
		{"id": "daomo_daofa", "name": "刀魔心法", "type": "内功", "quality": "紫", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 0, "rage_cost": 0, "qi_cost": 0, "cooldown": 0, "timestamp_offset": 0, "description": "魔佛切换"},
	])
	
	# 河洛帮 - 召唤/回血/输出
	_create_sect_wuxue_branch("heluo", "河洛帮", [
		{"id": "heluo_zhaohuan", "name": "河洛召唤", "type": "机关", "quality": "金", "damage_type": "外功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 25, "rage_cost": 0, "qi_cost": 0, "cooldown": 4, "timestamp_offset": 0, "description": "召唤帮众"},
		{"id": "heluo_huixue", "name": "帮众回血", "type": "医术", "quality": "紫", "damage_type": "内功", "target_type": "友方全体", "range_min": 1, "range_max": 1, "mp_cost": 20, "rage_cost": 0, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "群体治疗"},
		{"id": "heluo_bangfa", "name": "帮派棒法", "type": "棍法", "quality": "蓝", "damage_type": "外功", "target_type": "菱形", "range_min": 1, "range_max": 2, "mp_cost": 10, "rage_cost": 5, "qi_cost": 0, "cooldown": 2, "timestamp_offset": 0, "description": "群体输出"},
	])
	
	# 铁石岛 - 重剑击退/剑气内伤
	_create_sect_wuxue_branch("tieshi", "铁石岛", [
		{"id": "tieshi_zhongjian", "name": "重剑无锋", "type": "剑法", "quality": "金", "damage_type": "外功", "target_type": "单体", "range_min": 1, "range_max": 1, "mp_cost": 25, "rage_cost": 15, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "击退破盾"},
		{"id": "tieshi_jianqi", "name": "剑气内伤", "type": "剑法", "quality": "紫", "damage_type": "内功", "target_type": "竖排", "range_min": 1, "range_max": 3, "mp_cost": 20, "rage_cost": 10, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "无视防御内伤"},
		{"id": "tieshi_tieshi", "name": "铁石心法", "type": "内功", "quality": "蓝", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 0, "rage_cost": 0, "qi_cost": 0, "cooldown": 0, "timestamp_offset": 0, "description": "重剑护体"},
	])
	
	# 天武 - 强化肉身/破甲碎盾
	_create_sect_wuxue_branch("tianwu", "天武", [
		{"id": "tianwu_roushen", "name": "金钟罩铁布衫", "type": "内功", "quality": "金", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 30, "rage_cost": 0, "qi_cost": 0, "cooldown": 5, "timestamp_offset": 0, "description": "肉身成圣"},
		{"id": "tianwu_pojia", "name": "破甲碎盾", "type": "拳掌", "quality": "紫", "damage_type": "外功", "target_type": "十字", "range_min": 1, "range_max": 2, "mp_cost": 20, "rage_cost": 15, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "破防破盾"},
		{"id": "tianwu_tianwu", "name": "天武枪法", "type": "枪法", "quality": "蓝", "damage_type": "外功", "target_type": "横排", "range_min": 1, "range_max": 3, "mp_cost": 10, "rage_cost": 5, "qi_cost": 0, "cooldown": 2, "timestamp_offset": 0, "description": "军阵枪法"},
	])
	
	# 八大门 - 幻影/控制流
	_create_sect_wuxue_branch("bada", "八大门", [
		{"id": "bada_huanying", "name": "幻影迷踪", "type": "轻功", "quality": "金", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 25, "rage_cost": 0, "qi_cost": 0, "cooldown": 4, "timestamp_offset": 0, "description": "分身闪避"},
		{"id": "bada_kongzhi", "name": "迷魂阵", "type": "琴音", "quality": "紫", "damage_type": "内功", "target_type": "菱形", "range_min": 1, "range_max": 2, "mp_cost": 20, "rage_cost": 10, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "群体控制"},
		{"id": "bada_bada", "name": "八大门轻功", "type": "轻功", "quality": "蓝", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 5, "rage_cost": 0, "qi_cost": 0, "cooldown": 1, "timestamp_offset": 0, "description": "移动闪避"},
	])
	
	# 南山派 - 一波流/高伤龙拳
	_create_sect_wuxue_branch("nanshan", "南山派", [
		{"id": "nanshan_longquan", "name": "龙拳绝杀", "type": "拳掌", "quality": "金", "damage_type": "外功", "target_type": "单体", "range_min": 1, "range_max": 1, "mp_cost": 30, "rage_cost": 20, "qi_cost": 0, "cooldown": 4, "timestamp_offset": 0, "description": "龙拳爆发"},
		{"id": "nanshan_yibo", "name": "一波流心法", "type": "内功", "quality": "紫", "damage_type": "内功", "target_type": "自身", "range_min": 1, "range_max": 1, "mp_cost": 20, "rage_cost": 0, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "聚气爆发"},
		{"id": "nanshan_nanshan", "name": "南山拳法", "type": "拳掌", "quality": "蓝", "damage_type": "外功", "target_type": "横排", "range_min": 1, "range_max": 3, "mp_cost": 10, "rage_cost": 5, "qi_cost": 0, "cooldown": 2, "timestamp_offset": 0, "description": "连环拳"},
	])
	
	# 不器门 - 机关地雷/毒术折磨
	_create_sect_wuxue_branch("buqi", "不器门", [
		{"id": "buqi_jiguan", "name": "机关术", "type": "机关", "quality": "金", "damage_type": "外功", "target_type": "指定", "range_min": 1, "range_max": 3, "mp_cost": 20, "rage_cost": 10, "qi_cost": 0, "cooldown": 3, "timestamp_offset": 0, "description": "布置机关"},
		{"id": "buqi_dilei", "name": "地雷阵", "type": "机关", "quality": "紫", "damage_type": "外功", "target_type": "菱形", "range_min": 2, "range_max": 3, "mp_cost": 25, "rage_cost": 15, "qi_cost": 0, "cooldown": 4, "timestamp_offset": 0, "description": "延时爆炸"},
		{"id": "buqi_dushu", "name": "毒术折磨", "type": "毒术", "quality": "蓝", "damage_type": "内功", "target_type": "十字", "range_min": 1, "range_max": 2, "mp_cost": 15, "rage_cost": 5, "qi_cost": 0, "cooldown": 2, "timestamp_offset": 0, "description": "持续伤害"},
	])

func _create_sect_wuxue_branch(sect_id: String, sect_name: String, wuxue_list: Array[Dictionary]):
	if not sect_wuxue.has(sect_id):
		sect_wuxue[sect_id] = {}
	
	for wuxue in wuxue_list:
		var w = _create_base_wuxue(
			wuxue[0], wuxue[1], wuxue[2], wuxue[3], wuxue[4], wuxue[5],
			wuxue[6].get("range_min", 1), wuxue[6].get("range_max", 1),
			wuxue[6].get("mp_cost", 0), wuxue[6].get("rage_cost", 0), wuxue[6].get("qi_cost", 0),
			wuxue[6].get("cooldown", 0), wuxue[6].get("timestamp_offset", 0)
		)
		w.description = wuxue[6].get("description", "")
		w.is_sect_wuxue = true
		w.exclusive_sect = sect_id
		sect_wuxue[sect_id][wuxue[0]] = w

func _create_base_wuxue(id: String, name: String, type: String, quality: String, damage_type: String, target_type: String, 
	range_min: int, range_max: int, mp_cost: int, rage_cost: int, qi_cost: int, cooldown: int, timestamp_offset: int) -> WuxueData:
	var w = WuxueData.new()
	w.id = id
	w.name = name
	w.type = type
	w.quality = quality
	w.damage_type = damage_type
	w.target_type = target_type
	w.range_min = range_min
	w.range_max = range_max
	w.mp_cost = mp_cost
	w.rage_cost = rage_cost
	w.qi_cost = qi_cost
	w.cooldown = cooldown
	w.max_cooldown = cooldown
	w.timestamp_offset = timestamp_offset
	wuxue_list[id] = w
	return w

func _create_effect(effect_type: String, trigger: String, chance: float, params: Dictionary) -> WuxueEffect:
	var e = WuxueEffect.new()
	e.effect_type = effect_type
	e.trigger = trigger
	e.trigger_chance = chance
	e.params = params
	return e

func _build_indices():
	wuxue_by_type.clear()
	wuxue_by_quality.clear()
	wuxue_by_sect.clear()
	ultimate_wuxue.clear()
	combo_wuxue.clear()
	
	for w in wuxue_list.values():
		# 类型索引
		if not wuxue_by_type.has(w.type):
			wuxue_by_type[w.type] = []
		wuxue_by_type[w.type].append(w)
		
		# 品质索引
		if not wuxue_by_quality.has(w.quality):
			wuxue_by_quality[w.quality] = []
		wuxue_by_quality[w.quality].append(w)
		
		# 门派索引
		if w.exclusive_sect != "":
			if not wuxue_by_sect.has(w.exclusive_sect):
				wuxue_by_sect[w.exclusive_sect] = []
			wuxue_by_sect[w.exclusive_sect].append(w)
		
		# 大招
		if w.is_ultimate:
			ultimate_wuxue.append(w)
		
		# 连招
		if w.is_combo_starter or w.is_combo_finisher:
			if w.combo_id != "":
				if not combo_wuxue.has(w.combo_id):
					combo_wuxue[w.combo_id] = {"starter": null, "finisher": null}
				if w.is_combo_starter:
					combo_wuxue[w.combo_id]["starter"] = w
				if w.is_combo_finisher:
					combo_wuxue[w.combo_id]["finisher"] = w

func get_wuxue(id: String) -> WuxueData:
	return wuxue_list.get(id)

func get_all_wuxue() -> Array[WuxueData]:
	return wuxue_list.values()

func get_wuxue_by_type(type: String) -> Array[WuxueData]:
	return wuxue_by_type.get(type, [])

func get_wuxue_by_quality(quality: String) -> Array[WuxueData]:
	return wuxue_by_quality.get(quality, [])

func get_wuxue_by_sect(sect: String) -> Array[WuxueData]:
	return wuxue_by_sect.get(sect, [])

func get_ultimate_wuxue() -> Array[WuxueData]:
	return ultimate_wuxue

func get_combo_wuxue(combo_id: String) -> Dictionary:
	return combo_wuxue.get(combo_id, {})

func get_sect_wuxue(sect: String) -> Dictionary:
	return sect_wuxue.get(sect, {})

func get_random_wuxue(quality_weights: Dictionary = {}) -> WuxueData:
	var weights = quality_weights.duplicate()
	if weights.is_empty():
		weights = {"白": 0.5, "绿": 0.25, "蓝": 0.15, "紫": 0.07, "金": 0.025, "红": 0.005}
	
	var rand = rng.randf_range(0.0, 1.0)
	var cumulative = 0.0
	
	for quality in ["白", "绿", "蓝", "紫", "金", "红"]:
		cumulative += weights.get(quality, 0.0)
		if rand <= cumulative:
			var list = wuxue_by_quality.get(quality, [])
			if list.size() > 0:
				return list[rng.randi_range(0, list.size() - 1)]
	
	var all = wuxue_list.values()
	return all[rng.randi_range(0, all.size() - 1)]

func get_wuxue_count() -> int:
	return wuxue_list.size()
