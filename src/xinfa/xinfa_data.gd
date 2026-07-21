extends Resource
class_name XinfaData

@export var id: String
@export var name: String
@export var description: String = ""
@export var slot_type: String = "通用"
@export var color: String = "白"
@export var quality: String = "白"
@export var base_qi_cost: int = 0

## 属性加成
@export var stat_bonuses: Dictionary = {}

## 战斗效果
@export var combat_effects: Array[XinfaEffect] = []

## 升级
@export var max_level: int = 20
@export var current_level: int = 1
@export var exp: int = 0
@export var upgrade_materials: Dictionary = {}

## 套装效果
@export var set_id: String = ""
@export var set_piece_count: int = 0
@export var set_effects: Dictionary = {}

## 专属
@export var exclusive_character: String = ""
@export var exclusive_sect: String = ""

## 标签
@export var tags: Array[String] = []

func _init():
	_init_defaults()

func _init_defaults():
	if stat_bonuses.is_empty():
		stat_bonuses = {
			"hp": 0,
			"mp": 0,
			"atk": 0,
			"def": 0,
			"spd": 0,
			"hit": 0,
			"dodge": 0,
			"crit": 0,
			"crit_dmg": 0.0,
			"fortune": 0,
			"move_range": 0,
			"qi_speed": 0.0,
			"rage_gain": 0.0,
			"damage_reduction": 0.0,
			"damage_bonus": 0.0,
			"heal_bonus": 0.0,
			"shield_bonus": 0.0
		}
	if upgrade_materials.is_empty():
		upgrade_materials = {"器意": 10, "铜钱": 500}
	if set_effects.is_empty():
		set_effects = {}

func get_qi_cost() -> int:
	return GameData.instance.get_xinfa_cost(color)

func get_stat_bonus_at_level(stat: String, level: int) -> float:
	var base = stat_bonuses.get(stat, 0)
	if base == 0:
		return 0
	var mult = 1.0 + (level - 1) * 0.05
	if stat == "crit_dmg":
		return base * mult
	return int(base * mult)

func get_all_stat_bonuses(level: int) -> Dictionary:
	var result = {}
	for stat in stat_bonuses:
		result[stat] = get_stat_bonus_at_level(stat, level)
	return result

func get_combat_effects_at_level(level: int) -> Array[XinfaEffect]:
	var result = []
	for effect in combat_effects:
		var scaled = effect.duplicate()
		scaled.scale_with_level(level)
		result.append(scaled)
	return result

func can_equip(character: CharacterData) -> bool:
	if exclusive_character and character.id != exclusive_character:
		return false
	if exclusive_sect and character.current_sect != exclusive_sect:
		return false
	if slot_type != "通用" and slot_type != "万能":
		return character.equipped_xinfa.has(slot_type)
	return true

func get_set_effect(piece_count: int) -> Dictionary:
	return set_effects.get(str(piece_count), {})

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"slot_type": slot_type,
		"color": color,
		"current_level": current_level,
		"exp": exp
	}

func from_dict(data: Dictionary):
	id = data.get("id", "")
	name = data.get("name", "")
	slot_type = data.get("slot_type", "通用")
	color = data.get("color", "白")
	current_level = data.get("current_level", 1)
	exp = data.get("exp", 0)
