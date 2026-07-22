extends Resource
class_name NPCData

@export var id: String
@export var name: String
@export var sect: String = ""
@export var role: String = ""
@export var location: String = ""
@export var base_affection: int = 0
@export var current_affection: int = 0
@export var max_affection: int = 10000
@export var affection_level: int = 0
@export var recruited: bool = false
@export var recruitable: bool = false
@export var recruit_condition: String = ""
@export var dialogue_ids: Array[String] = []
@export var quest_ids: Array[String] = []
@export var shop_id: String = ""
@export var schedule: Dictionary = {}
@export var is_leader: bool = false
@export var is_elder: bool = false
@export var is_disciple: bool = false
@export var is_city_npc: bool = false
@export var is_special: bool = false
@export var portrait_path: String = ""
@export var sprite_path: String = ""
@export var voice_id: String = ""
@export var gossip_pool: Array[String] = []
@export var gift_preferences: Dictionary = {}
@export var relationship_changes: Dictionary = {}

func _init():
	if dialogue_ids.is_empty():
		dialogue_ids = []
	if quest_ids.is_empty():
		quest_ids = []
	if schedule.is_empty():
		schedule = {}
	if gossip_pool.is_empty():
		gossip_pool = []
	if gift_preferences.is_empty():
		gift_preferences = {}
	if relationship_changes.is_empty():
		relationship_changes = {}

func change_affection(amount: int):
	current_affection = clamp(current_affection + amount, -max_affection, max_affection)
	_update_affection_level()

func _update_affection_level():
	var thresholds = [0, 100, 500, 1500, 3000, 5000, 7500, 10000]
	for i in range(thresholds.size()):
		if current_affection >= thresholds[i]:
			affection_level = i
		else:
			break

func get_affection_level_name() -> String:
	var names = ["陌生人", "路人", "相识", "朋友", "好友", "挚友", "亲密", "至交", "灵魂伴侣"]
	if affection_level >= 0 and affection_level < names.size():
		return names[affection_level]
	return "陌生人"

func can_recruit(player_data: PlayerData) -> bool:
	if not recruitable or recruited:
		return false
	if recruit_condition == "":
		return true
	# 这里可以解析recruit_condition
	return true

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"sect": sect,
		"role": role,
		"location": location,
		"base_affection": base_affection,
		"current_affection": current_affection,
		"max_affection": max_affection,
		"affection_level": affection_level,
		"recruited": recruited,
		"recruitable": recruitable,
		"recruit_condition": recruit_condition,
		"dialogue_ids": dialogue_ids,
		"quest_ids": quest_ids,
		"shop_id": shop_id,
		"schedule": schedule,
		"is_leader": is_leader,
		"is_elder": is_elder,
		"is_disciple": is_disciple,
		"is_city_npc": is_city_npc,
		"is_special": is_special,
		"portrait_path": portrait_path,
		"sprite_path": sprite_path,
		"voice_id": voice_id,
		"gossip_pool": gossip_pool,
		"gift_preferences": gift_preferences,
		"relationship_changes": relationship_changes
	}

func from_dict(data: Dictionary) -> NPCData:
	id = data.get("id", "")
	name = data.get("name", "")
	sect = data.get("sect", "")
	role = data.get("role", "")
	location = data.get("location", "")
	base_affection = data.get("base_affection", 0)
	current_affection = data.get("current_affection", 0)
	max_affection = data.get("max_affection", 10000)
	affection_level = data.get("affection_level", 0)
	recruited = data.get("recruited", false)
	recruitable = data.get("recruitable", false)
	recruit_condition = data.get("recruit_condition", "")
	dialogue_ids = data.get("dialogue_ids", [])
	quest_ids = data.get("quest_ids", [])
	shop_id = data.get("shop_id", "")
	schedule = data.get("schedule", {})
	is_leader = data.get("is_leader", false)
	is_elder = data.get("is_elder", false)
	is_disciple = data.get("is_disciple", false)
	is_city_npc = data.get("is_city_npc", false)
	is_special = data.get("is_special", false)
	portrait_path = data.get("portrait_path", "")
	sprite_path = data.get("sprite_path", "")
	voice_id = data.get("voice_id", "")
	gossip_pool = data.get("gossip_pool", [])
	gift_preferences = data.get("gift_preferences", {})
	relationship_changes = data.get("relationship_changes", {})
	return self