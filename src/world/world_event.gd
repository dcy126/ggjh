extends Resource
class_name WorldEvent

@export var id: String
@export var name: String
@export var description: String
@export var type: String = "定期"
@export var schedule: String = ""
@export var duration: int = 0
@export var participation_req: Dictionary = {}
@export var rewards: Dictionary = {}
@export var map_areas: Array[String] = []
@export var is_active: bool = false
@export var start_time: int = 0
@export var end_time: int = 0
@export var progress: float = 0.0
@export var participants: Array[String] = []
@export var ranking: Array[Dictionary] = []
@export var special_data: Dictionary = {}

func _init():
	if participation_req.is_empty():
		participation_req = {}
	if rewards.is_empty():
		rewards = {}
	if map_areas.is_empty():
		map_areas = []
	if participants.is_empty():
		participants = []
	if ranking.is_empty():
		ranking = []
	if special_data.is_empty():
		special_data = {}

func can_participate(player_data: PlayerData) -> bool:
	if participation_req.has("level") and player_data.level < participation_req["level"]:
		return false
	if participation_req.has("sect") and participation_req["sect"] != "不为空" and player_data.current_sect == "":
		return false
	if participation_req.has("guild") and participation_req["guild"] != "不为空" and player_data.current_guild == "":
		return false
	if participation_req.has("chapter") and player_data.current_chapter < participation_req["chapter"]:
		return false
	return true

func start():
	is_active = true
	start_time = Time.get_unix_time_from_system()
	end_time = start_time + duration
	EventManager.get_instance().emit("world_event_started", id)

func end():
	is_active = false
	EventManager.get_instance().emit("world_event_ended", id)

func add_participant(player_id: String):
	if player_id not in participants:
		participants.append(player_id)

func update_progress(player_id: String, progress_value: float):
	# 更新参与者进度
	pass

func add_ranking_entry(player_id: String, score: int, data: Dictionary = {}):
	ranking.append({
		"player_id": player_id,
		"score": score,
		"data": data,
		"time": Time.get_unix_time_from_system()
	})
	ranking.sort_custom(_compare_score)

func _compare_score(a: Dictionary, b: Dictionary) -> int:
	return -1 if a["score"] > b["score"] else 1

func get_rank(player_id: String) -> int:
	for i in range(ranking.size()):
		if ranking[i]["player_id"] == player_id:
			return i + 1
	return -1

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"type": type,
		"schedule": schedule,
		"duration": duration,
		"participation_req": participation_req,
		"rewards": rewards,
		"map_areas": map_areas,
		"is_active": is_active,
		"start_time": start_time,
		"end_time": end_time,
		"progress": progress,
		"participants": participants,
		"ranking": ranking,
		"special_data": special_data
	}

func from_dict(data: Dictionary) -> WorldEvent:
	id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	type = data.get("type", "定期")
	schedule = data.get("schedule", "")
	duration = data.get("duration", 0)
	participation_req = data.get("participation_req", {})
	rewards = data.get("rewards", {})
	map_areas = data.get("map_areas", [])
	is_active = data.get("is_active", false)
	start_time = data.get("start_time", 0)
	end_time = data.get("end_time", 0)
	progress = data.get("progress", 0.0)
	participants = data.get("participants", [])
	ranking = data.get("ranking", [])
	special_data = data.get("special_data", {})
	return self