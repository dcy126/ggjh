extends Resource
class_name SectData

@export var id: String
@export var name: String
@export var description: String = ""
@export var location: String = ""
@export var leader: String = ""
@export var background_story: String = ""

## 门派专属武学
@export var exclusive_wuxue: Array[String] = []
@export var wuxue_unlock_requirements: Dictionary = {}  # wuxue_id -> requirement

## 弟子天赋
@export var disciple_talents: Array[CharacterTalent] = []

## 门派商店
@export var shop_items: Array[Dictionary] = []

## 门派贡献奖励
@export var contribution_rewards: Dictionary = {}  # contribution_amount -> reward

## 门派技能/被动
@export var sect_passives: Array[Dictionary] = []

## 门派等级
@export var max_level: int = 10
@export var exp_per_level: Array[int] = []

## 门派特色标签
@export var traits: Array[String] = []

## 入门要求
@export var join_requirements: Dictionary = {}
@export var leave_penalty: Dictionary = {}

## 门派阵营
@export var faction: String = ""

func _init():
	_init_defaults()

func _init_defaults():
	if exp_per_level.is_empty():
		exp_per_level = [0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000]
	if join_requirements.is_empty():
		join_requirements = {"level": 1}
	if leave_penalty.is_empty():
		leave_penalty = {"contribution_keep": true, "wuxue_keep": false}

func get_wuxue_unlock_req(wuxue_id: String) -> Dictionary:
	return wuxue_unlock_requirements.get(wuxue_id, {})

func can_learn_wuxue(character: CharacterData, wuxue_id: String) -> bool:
	var req = get_wuxue_unlock_req(wuxue_id)
	if req.has("level") and character.sect_level < req["level"]:
		return false
	if req.has("contribution") and character.sect_contribution < req["contribution"]:
		return false
	if req.has("breakthrough") and character.potential_breakthrough < req["breakthrough"]:
		return false
	return true

func get_contribution_reward(amount: int) -> Dictionary:
	for req_amount in contribution_rewards:
		if amount >= int(req_amount):
			return contribution_rewards[req_amount]
	return {}

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"level": 1,
		"contribution": 0,
		"learned_wuxue": []
	}

func from_dict(data: Dictionary):
	pass