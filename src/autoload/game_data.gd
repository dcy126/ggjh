extends Node
class_name GameData

static var instance: GameData = null

@export var game_version: String = "3.8.0"
@export var game_name: String = "汉家江湖"
@export var developer: String = "汉家松鼠"

## 核心战斗常量
const MAX_QI_LIMIT: int = 100
const MAX_QI_SPEED: float = 2.5
const MIN_QI_SPEED: float = 0.8
const BASE_QI_SPEED: float = 1.0
const MAX_MOVE_RANGE: int = 5
const BASE_MOVE_RANGE: int = 2
const MAX_RAGE: int = 100
const RAGE_GAIN_INTERVAL: int = 200
const BASE_RAGE_GAIN_CHANCE: float = 0.25
const RAGE_GAIN_PER_FORTUNE: float = 0.20 / 70.0
const RAGE_GAIN_PER_BERSERK: float = 0.10
const MAX_TIMESTAMP: int = 9999
const STATUS_DURATION_PER_TURN: int = 50

## 属性上限
const MAX_HP: int = 999999
const MAX_MP: int = 99999
const MAX_ATK: int = 99999
const MAX_DEF: int = 99999
const MAX_SPD: int = 9999
const MAX_HIT: int = 9999
const MAX_DODGE: int = 9999
const MAX_CRIT: int = 9999
const MAX_CRIT_DMG: float = 5.0
const MAX_FORTUNE: int = 9999

## 心诀系统常量
const XINFA_SLOTS_BASE: int = 4
const XINFA_SLOTS_MAX: int = 7
const XINFA_SLOT_TYPES: Array[String] = ["攻击", "防御", "辅助", "特殊", "通用"]
const XINFA_COLOR_COST: Dictionary = {
	"红": 0,
	"紫": 8,
	"金": 5,
	"蓝": 3,
	"白": 1,
	"绿": -3,
	"万能": 0
}
const XINFA_UPGRADE_MATERIALS: Array[String] = ["器意", "太玄石", "太玄玉"]
const XINFA_MAX_LEVEL: int = 20

## 潜质突破
const POTENTIAL_MAX_BREAKTHROUGH: int = 3
const POTENTIAL_QI_VALUES: Array[int] = [29, 31, 33, 36]
const POTENTIAL_MAX_LEVEL: int = 100
var POTENTIAL_EXP_PER_LEVEL: Array[int] = []

## 门派
const SECT_LIST: Array[String] = ["恒山派", "华山派", "刀魔传人", "河洛帮", "铁石岛", "天武", "八大门", "南山派", "不器门"]
const SECT_CONTRIBUTION_MAX: int = 99999

## 论剑/PVP
const PVP_SEASON_DURATION_DAYS: int = 28
const PVP_RANK_TIERS: Array[String] = ["青铜", "白银", "黄金", "铂金", "钻石", "大师", "宗师", "王者", "传说"]
const PVP_MAX_RANK_SCORE: int = 5000

## 帮会
const GUILD_MAX_LEVEL: int = 10
const GUILD_MAX_MEMBERS_BASE: int = 30
const GUILD_MAX_MEMBERS_PER_LEVEL: int = 5
const GUILD_SECRET_REALM_MAX_LEVEL: int = 10

## 探索/副本
const EXPLORATION_MAX_STAMINA: int = 100
const EXPLORATION_STAMINA_REGEN_PER_MIN: float = 1.0 / 6.0
const DUNGEON_MAX_STARS: int = 3

## 捏脸系统
const FACE_SLIDER_COUNT: int = 50
const BODY_SLIDER_COUNT: int = 20
const VOICE_OPTIONS_COUNT: int = 10

## 材料/货币
const CURRENCY_TYPES: Array[String] = ["元宝", "铜钱", "门派贡献", "帮会贡献", "论剑积分", "探索点数", "器意", "太玄石", "太玄玉", "祈福灵珠", "潜质丹", "真解残页", "武学残页", "心诀残页"]
const MATERIAL_MAX_STACK: int = 9999

## 品质颜色
const QUALITY_COLORS: Dictionary = {
	"白": Color(0.8, 0.8, 0.8),
	"绿": Color(0.2, 0.8, 0.2),
	"蓝": Color(0.2, 0.4, 1.0),
	"紫": Color(0.8, 0.2, 1.0),
	"金": Color(1.0, 0.8, 0.0),
	"红": Color(1.0, 0.2, 0.2),
	"万能": Color(1.0, 1.0, 0.0)
}

## 武学类型
const WUXUE_TYPES: Array[String] = ["拳掌", "指法", "腿法", "剑法", "刀法", "枪法", "棍法", "鞭法", "暗器", "琴音", "医术", "毒术", "机关", "轻功", "内功", "心法"]

## 武学品质
const WUXUE_QUALITIES: Array[String] = ["白", "绿", "蓝", "紫", "金", "红"]

## 伤害类型
const DAMAGE_TYPES: Array[String] = ["外功", "内功", "定伤", "混合", "真实"]

## 目标类型
const TARGET_TYPES: Array[String] = ["单体", "横排", "竖排", "十字", "菱形", "全体", "随机", "指定", "自身", "友方单体", "友方全体", "敌方全体", "血量最低", "血量最高"]

## 战斗状态类型
const STATUS_TYPES: Array[String] = ["增益", "减益", "特殊"]
const STATUS_CATEGORIES: Dictionary = {
	"增益": ["护盾", "加速", "加攻", "加防", "回血", "加命中", "加闪避", "加暴击", "加暴伤", "免疫控制", "免疫减益", "反击", "反伤", "吸血", "格挡", "无敌", "隐身", "分身", "召唤"],
	"减益": ["中毒", "燃烧", "流血", "眩晕", "定身", "沉默", "缴械", "减速", "减攻", "减防", "破防", "破盾", "封印", "诅咒", "虚弱", "重伤", "内伤", "外伤", "失明", "混乱", "恐惧", "嘲讽", "拉条", "推条", "偷怒气", "禁疗", "减治疗"],
	"特殊": ["变身", "化蝶", "魔刀", "佛刀", "阴阳", "幻影", "机关", "地雷", "龙拳", "剑气", "内伤", "重剑", "召唤物", "幻影分身", "援护", "挡刀", "慈悲相", "忿怒相"]
}

## 战斗时序事件
const TIMESTAMP_EVENTS: Array[String] = [
	"回合开始", "集气", "行动开始", "移动", "技能前摇", "技能释放", "技能命中", "伤害计算", "伤害结算", "效果触发", "状态结算", "回合结束", "时序推进"
]

## 剧情分支
const STORY_CHAPTER_COUNT: int = 12
const STORY_CHOICE_IMPACT_TYPES: Array[String] = ["立即生效", "延迟生效", "永久影响", "章节影响", "全局影响", "隐藏剧情解锁", "装备获取", "侠客加入", "侠客离队", "门派关系变化", "帮会关系变化", "NPC好感度变化", "世界状态变化"]

## 稀有度/品质
const RARITY_ORDER: Array[String] = ["白", "绿", "蓝", "紫", "金", "红"]
const RARITY_WEIGHTS: Array[float] = [0.5, 0.25, 0.15, 0.07, 0.025, 0.005]

## 武学特效类型
const WUXUE_EFFECT_TYPES: Array[String] = [
	"伤害", "治疗", "护盾", "加怒气", "减怒气", "加集气", "减集气", "位移", "击退", "拉近", "眩晕", "定身", "沉默", "缴械", "中毒", "燃烧", "流血", "减速", "减攻", "减防", "破防", "破盾", "封印", "诅咒", "虚弱", "重伤", "内伤", "外伤", "失明", "混乱", "恐惧", "嘲讽", "拉条", "推条", "偷怒气", "禁疗", "减治疗", "反击", "反伤", "吸血", "格挡", "无敌", "隐身", "分身", "召唤", "变身", "化蝶", "魔刀", "佛刀", "阴阳", "幻影", "机关", "地雷", "龙拳", "剑气", "内伤特效", "重剑", "慈悲相", "忿怒相", "援护", "挡刀", "清除增益", "清除减益", "清除所有状态", "复活", "延迟生效", "按时序触发", "连击", "追击", "协同", "连携", "合击", "连环", "连舞", "连斩", "连刺", "连射", "连劈", "连砍", "连扫", "连点", "连按", "连推", "连拉", "连转", "连飞", "连落", "连滚", "连跳", "连闪", "连影", "连分身", "连召唤", "连变身", "连化蝶", "连魔刀", "连佛刀", "连阴阳", "连幻影", "连机关", "连地雷", "连龙拳", "连剑气", "连内伤", "连重剑", "连慈悲", "连忿怒", "连援护", "连挡刀"
]

## 装备部位
const EQUIPMENT_SLOTS: Array[String] = ["武器", "头盔", "衣服", "护腕", "鞋子", "项链", "戒指", "腰带", "护符", "暗器"]

## 装备套装
const EQUIPMENT_SET_MAX_PIECES: int = 6
const EQUIPMENT_SET_EFFECT_COUNT: int = 3

## 侠客品质
const CHARACTER_QUALITIES: Array[String] = ["普通", "优秀", "精英", "名士", "大师", "宗师", "绝世", "传说", "神话"]

## 侠客定位
const CHARACTER_ROLES: Array[String] = ["主攻", "副攻", "主坦", "副坦", "主辅", "副辅", "特殊", "万金油"]

## 资质/潜质类型
const POTENTIAL_TYPES: Array[String] = ["根骨", "悟性", "身法", "福缘", "定力"]

## 主角专属
const PROTAGONIST_EXCLUSIVE_WUXUE: Array[String] = ["草头风云录"]
const PROTAGONIST_MAX_XINFA_SLOTS: int = 7

## 自走棋/侠影星阵
const AUTO_CHESS_MAX_PIECES: int = 8
const AUTO_CHESS_PIECE_TIERS: Array[int] = [1, 2, 3, 4, 5]
const AUTO_CHESS_SYNERGIES: Dictionary = {}

## 肉鸽/海上千烽/沙海危途
const ROGUELIKE_MAX_FLOORS: int = 50
const ROGUELIKE_MAX_BLESSINGS: int = 10
const ROGUELIKE_BOSS_INTERVAL: int = 10

## 活动
const EVENT_TYPES: Array[String] = ["日常", "周常", "限时", "节日", "周年庆", "版本更新", "联动", "跨服", "帮会", "论剑赛季"]

func _enter_tree():
	instance = self
	_init_potential_exp()

func _init_potential_exp():
	POTENTIAL_EXP_PER_LEVEL.resize(POTENTIAL_MAX_LEVEL + 1)
	var current_exp = 0
	for i in range(1, POTENTIAL_MAX_LEVEL + 1):
		current_exp += i * 10
		POTENTIAL_EXP_PER_LEVEL[i] = current_exp

func get_qi_value_by_breakthrough(breakthrough: int) -> int:
	if breakthrough >= 0 and breakthrough < POTENTIAL_QI_VALUES.size():
		return POTENTIAL_QI_VALUES[breakthrough]
	return POTENTIAL_QI_VALUES[0]

func get_xinfa_cost(color: String) -> int:
	return XINFA_COLOR_COST.get(color, 0)

func get_quality_color(quality: String) -> Color:
	return QUALITY_COLORS.get(quality, Color.WHITE)

func get_rarity_weight(rarity: String) -> float:
	var idx = RARITY_ORDER.find(rarity)
	if idx >= 0:
		return RARITY_WEIGHTS[idx]
	return 0.0

func clamp_stat(value: int, max_value: int) -> int:
	return clamp(value, 0, max_value)

func clamp_float(value: float, min_val: float, max_val: float) -> float:
	return clamp(value, min_val, max_val)

func get_damage_type_color(damage_type: String) -> Color:
	match damage_type:
		"外功": return Color(1.0, 0.3, 0.3)
		"内功": return Color(0.3, 0.5, 1.0)
		"定伤": return Color(1.0, 1.0, 0.3)
		"混合": return Color(1.0, 0.5, 1.0)
		"真实": return Color(1.0, 1.0, 1.0)
		_: return Color.WHITE

func get_status_type_color(status_type: String) -> Color:
	match status_type:
		"增益": return Color(0.2, 0.8, 1.0)
		"减益": return Color(1.0, 0.2, 0.2)
		"特殊": return Color(0.8, 0.2, 1.0)
		_: return Color.WHITE

func get_sector_color(sect: String) -> Color:
	match sect:
		"恒山派": return Color(0.6, 0.8, 0.4)
		"华山派": return Color(0.8, 0.6, 0.4)
		"刀魔传人": return Color(0.8, 0.2, 0.2)
		"河洛帮": return Color(0.4, 0.6, 0.8)
		"铁石岛": return Color(0.6, 0.6, 0.7)
		"天武": return Color(0.8, 0.8, 0.3)
		"八大门": return Color(0.6, 0.4, 0.8)
		"南山派": return Color(0.4, 0.8, 0.6)
		"不器门": return Color(0.5, 0.3, 0.7)
		_: return Color.WHITE

func get_role_color(role: String) -> Color:
	match role:
		"主攻": return Color(1.0, 0.3, 0.3)
		"副攻": return Color(1.0, 0.6, 0.3)
		"主坦": return Color(0.3, 0.6, 1.0)
		"副坦": return Color(0.3, 0.8, 1.0)
		"主辅": return Color(0.3, 1.0, 0.5)
		"副辅": return Color(0.6, 1.0, 0.6)
		"特殊": return Color(1.0, 0.3, 1.0)
		"万金油": return Color(1.0, 1.0, 0.3)
		_: return Color.WHITE
