extends Resource
class_name CharacterData

@export var id: String
@export var name: String
@export var title: String = ""
@export var description: String = ""
@export var quality: String = "普通"
@export var role: String = "万金油"
@export var sect: String = ""
@export var is_protagonist: bool = false
@export var is_recruitable: bool = true
@export var recruit_chapter: int = 0
@export var recruit_condition: String = ""
@export var portrait_path: String = ""
@export var sprite_path: String = ""
@export var battle_sprite_path: String = ""
@export var voice_id: String = ""

## 基础属性 (1级满潜质)
@export var base_hp: int = 1000
@export var base_mp: int = 100
@export var base_atk: int = 100
@export var base_def: int = 100
@export var base_spd: int = 100
@export var base_hit: int = 100
@export var base_dodge: int = 50
@export var base_crit: int = 50
@export var base_crit_dmg: float = 1.5
@export var base_fortune: int = 50
@export var base_move_range: int = 2
@export var base_qi_speed: float = 1.0

## 资质成长
@export var potential_growth: Dictionary = {
	"根骨": 1.0,
	"悟性": 1.0,
	"身法": 1.0,
	"福缘": 1.0,
	"定力": 1.0
}

## 潜质突破
@export var potential_level: int = 0
@export var potential_breakthrough: int = 0
@export var potential_exp: int = 0
@export var max_potential_level: int = 100
@export var max_breakthrough: int = 3

## 天赋
@export var talents: Array[CharacterTalent] = []
@export var exclusive_talent: CharacterTalent = null
@export var talent_points: int = 0

## 武学
@export var known_wuxue: Array[String] = []
@export var equipped_wuxue: Array[String] = []
@export var wuxue_slots: int = 4
@export var max_wuxue_slots: int = 6

## 心诀
@export var equipped_xinfa: Dictionary = {}  # slot_type -> xinfa_id
@export var xinfa_slots: int = 4
@export var max_xinfa_slots: int = 7
@export var qi_value: int = 29
@export var max_qi_value: int = 29

## 装备
@export var equipped_items: Dictionary = {}  # slot -> equipment_id
@export var equipment_slots: Array[String] = ["武器", "头盔", "衣服", "护腕", "鞋子", "项链", "戒指", "腰带", "护符", "暗器"]

## 门派
@export var current_sect: String = ""
@export var sect_contribution: int = 0
@export var sect_level: int = 0
@export var sect_wuxue: Array[String] = []

## 羁绊/缘分
@export var bonds: Array[String] = []
@export var bond_levels: Dictionary = {}

## 捏脸数据
var face_data: FaceData = null
var body_data: BodyData = null
var voice_data: VoiceData = null

## 战斗相关
@export var ai_priority: Dictionary = {}
@export var formation_position: int = 0
@export var preferred_formation: String = ""

## 成长曲线
@export var growth_curve: Dictionary = {
	"hp": 1.0,
	"mp": 1.0,
	"atk": 1.0,
	"def": 1.0,
	"spd": 1.0
}

## 特殊标记
@export var tags: Array[String] = []
@export var is_limited: bool = false
@export var release_version: String = ""
@export var story_chapter_unlock: int = 0

func _init():
	_init_defaults()

func _init_defaults():
	if potential_growth.is_empty():
		potential_growth = {
			"根骨": 1.0,
			"悟性": 1.0,
			"身法": 1.0,
			"福缘": 1.0,
			"定力": 1.0
		}
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
		for slot in equipment_slots:
			equipped_items[slot] = ""
	if bond_levels.is_empty():
		bond_levels = {}
	if ai_priority.is_empty():
		ai_priority = {
			"attack": 1.0,
			"defend": 1.0,
			"support": 1.0,
			"move": 1.0,
			"use_skill": 1.0
		}

func get_current_qi_value() -> int:
	return qi_value

func get_max_qi_value() -> int:
	return max_qi_value

func add_qi_value(amount: int):
	qi_value = clamp(qi_value + amount, 0, max_qi_value)

func set_breakthrough(level: int):
	potential_breakthrough = clamp(level, 0, max_breakthrough)
	max_qi_value = GameData.POTENTIAL_QI_VALUES[potential_breakthrough] if potential_breakthrough < GameData.POTENTIAL_QI_VALUES.size() else GameData.POTENTIAL_QI_VALUES[0]
	qi_value = min(qi_value, max_qi_value)

func can_equip_xinfa(xinfa_data: XinfaData) -> bool:
	var current_cost = calculate_current_qi_cost()
	var new_cost = current_cost + GameData.instance.get_xinfa_cost(xinfa_data.color)
	return new_cost <= max_qi_value

func calculate_current_qi_cost() -> int:
	var total = 0
	for slot_id in equipped_xinfa:
		var xinfa_id = equipped_xinfa[slot_id]
		if xinfa_id:
			var xinfa = XinfaDatabase.instance.get_xinfa(xinfa_id)
			if xinfa:
				total += GameData.instance.get_xinfa_cost(xinfa.color)
	return total

func get_available_xinfa_slots() -> Array[String]:
	var slots = []
	for slot_type in GameData.XINFA_SLOT_TYPES:
		if not equipped_xinfa.has(slot_type) or not equipped_xinfa[slot_type]:
			slots.append(slot_type)
	if xinfa_slots > GameData.XINFA_SLOT_TYPES.size():
		for i in range(GameData.XINFA_SLOT_TYPES.size() + 1, xinfa_slots + 1):
			var slot_name = "通用%d" % (i - 4)
			if not equipped_xinfa.has(slot_name) or not equipped_xinfa[slot_name]:
				slots.append(slot_name)
	return slots

func get_total_potential() -> float:
	var total = 0.0
	for key in potential_growth:
		total += potential_growth[key]
	return total

func get_stat_at_level(level: int, stat: String) -> int:
	var base = 0
	match stat:
		"hp": base = base_hp
		"mp": base = base_mp
		"atk": base = base_atk
		"def": base = base_def
		"spd": base = base_spd
		"hit": base = base_hit
		"dodge": base = base_dodge
		"crit": base = base_crit
		"fortune": base = base_fortune
		_: return 0
	
	var growth = growth_curve.get(stat, 1.0)
	var potential_bonus = 0.0
	match stat:
		"hp": potential_bonus = potential_growth["根骨"]
		"mp": potential_bonus = potential_growth["定力"]
		"atk": potential_bonus = potential_growth["悟性"]
		"def": potential_bonus = potential_growth["根骨"]
		"spd": potential_bonus = potential_growth["身法"]
		"hit": potential_bonus = potential_growth["悟性"]
		"dodge": potential_bonus = potential_growth["身法"]
		"crit": potential_bonus = potential_growth["悟性"]
		"fortune": potential_bonus = potential_growth["福缘"]
	
	return int(base * pow(growth, level - 1) * (1.0 + potential_bonus * 0.1 * potential_level / 100.0))

func get_battle_character() -> BattleCharacter:
	var bc = BattleCharacter.new()
	bc.character_id = id
	bc.character_name = name
	bc.level = potential_level
	bc.breakthrough = potential_breakthrough
	bc.max_hp = get_stat_at_level(potential_level, "hp")
	bc.current_hp = bc.max_hp
	bc.max_mp = get_stat_at_level(potential_level, "mp")
	bc.current_mp = bc.max_mp
	bc.atk = get_stat_at_level(potential_level, "atk")
	bc.def = get_stat_at_level(potential_level, "def")
	bc.spd = get_stat_at_level(potential_level, "spd")
	bc.hit = get_stat_at_level(potential_level, "hit")
	bc.dodge = get_stat_at_level(potential_level, "dodge")
	bc.crit = get_stat_at_level(potential_level, "crit")
	bc.crit_dmg = base_crit_dmg
	bc.fortune = get_stat_at_level(potential_level, "fortune")
	bc.move_range = base_move_range
	bc.qi_speed = base_qi_speed
	bc.qi = 0
	bc.max_qi = 100
	bc.rage = 0
	bc.max_rage = 100
	bc.status_effects = []
	bc.known_wuxue = known_wuxue.duplicate()
	bc.equipped_wuxue = equipped_wuxue.duplicate()
	bc.equipped_xinfa = equipped_xinfa.duplicate()
	bc.equipped_items = equipped_items.duplicate()
	bc.talents = talents.duplicate()
	bc.exclusive_talent = exclusive_talent
	bc.formation_position = formation_position
	return bc

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"title": title,
		"quality": quality,
		"role": role,
		"sect": sect,
		"is_protagonist": is_protagonist,
		"potential_level": potential_level,
		"potential_breakthrough": potential_breakthrough,
		"potential_exp": potential_exp,
		"known_wuxue": known_wuxue,
		"equipped_wuxue": equipped_wuxue,
		"equipped_xinfa": equipped_xinfa,
		"equipped_items": equipped_items,
		"current_sect": current_sect,
		"sect_contribution": sect_contribution,
		"sect_level": sect_level,
		"face_data": face_data.to_dict() if face_data else {},
		"body_data": body_data.to_dict() if body_data else {},
		"voice_data": voice_data.to_dict() if voice_data else {},
		"formation_position": formation_position,
		"tags": tags
	}

func from_dict(data: Dictionary):
	id = data.get("id", "")
	name = data.get("name", "")
	title = data.get("title", "")
	quality = data.get("quality", "普通")
	role = data.get("role", "万金油")
	sect = data.get("sect", "")
	is_protagonist = data.get("is_protagonist", false)
	potential_level = data.get("potential_level", 0)
	potential_breakthrough = data.get("potential_breakthrough", 0)
	potential_exp = data.get("potential_exp", 0)
	known_wuxue = data.get("known_wuxue", [])
	equipped_wuxue = data.get("equipped_wuxue", [])
	equipped_xinfa = data.get("equipped_xinfa", {})
	equipped_items = data.get("equipped_items", {})
	current_sect = data.get("current_sect", "")
	sect_contribution = data.get("sect_contribution", 0)
	sect_level = data.get("sect_level", 0)
	formation_position = data.get("formation_position", 0)
	tags = data.get("tags", [])
	
	if data.has("face_data") and data["face_data"]:
		face_data = FaceData.new().from_dict(data["face_data"])
	if data.has("body_data") and data["body_data"]:
		body_data = BodyData.new().from_dict(data["body_data"])
	if data.has("voice_data") and data["voice_data"]:
		voice_data = VoiceData.new().from_dict(data["voice_data"])
	
	set_breakthrough(potential_breakthrough)
