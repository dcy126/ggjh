extends Resource
class_name PvPMatch

@export var match_id: String
@export var player1_id: String
@export var player2_id: String
@export var player1_team: Array[BattleCharacter] = []
@export var player2_team: Array[BattleCharacter] = []
@export var mode: String = "ranked"
@export var start_time: int = 0
@export var end_time: int = 0
@export var duration: int = 0
@export var result: String = ""  # victory, defeat, draw
@export var winner_id: String = ""
@export var loser_id: String = ""
@export var status: String = "等待中"
@export var replay_data: Dictionary = {}
@export var score_change: int = 0

func _init():
	pass

func to_dict() -> Dictionary:
	return {
		"match_id": match_id,
		"player1_id": player1_id,
		"player2_id": player2_id,
		"mode": mode,
		"start_time": start_time,
		"end_time": end_time,
		"duration": duration,
		"result": result,
		"winner_id": winner_id,
		"loser_id": loser_id,
		"status": status,
		"score_change": score_change
	}

func from_dict(data: Dictionary) -> PvPMatch:
	match_id = data.get("match_id", "")
	player1_id = data.get("player1_id", "")
	player2_id = data.get("player2_id", "")
	mode = data.get("mode", "ranked")
	start_time = data.get("start_time", 0)
	end_time = data.get("end_time", 0)
	duration = data.get("duration", 0)
	result = data.get("result", "")
	winner_id = data.get("winner_id", "")
	loser_id = data.get("loser_id", "")
	status = data.get("status", "等待中")
	score_change = data.get("score_change", 0)
	return self