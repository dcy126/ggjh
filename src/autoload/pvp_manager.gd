extends Node
class_name PvPManager

var current_match: PvPMatch = null
var match_history: Array[PvPMatch] = []
var season_rewards: Dictionary = {}
var rank_rewards: Dictionary = {}
var weekly_rewards: Dictionary = {}
var daily_rewards: Dictionary = {}
var matchmaking_queue: Array[Dictionary] = []
var is_searching: bool = false
var current_season: int = 1
var season_end_time: int = 0

static var instance = null

static func get_instance():
	return instance

func _enter_tree():
	instance = self
	_load_pvp_data()

func _load_pvp_data():
	# 段位奖励
	rank_rewards = {
		"青铜": {"gold": 100, "pvp_points": 500, "title": "青铜论剑士"},
		"白银": {"gold": 200, "pvp_points": 1000, "title": "白银论剑士"},
		"黄金": {"gold": 500, "pvp_points": 2000, "title": "黄金论剑士"},
		"铂金": {"gold": 1000, "pvp_points": 5000, "title": "铂金论剑士"},
		"钻石": {"gold": 2000, "pvp_points": 10000, "title": "钻石论剑士"},
		"大师": {"gold": 5000, "pvp_points": 20000, "title": "大师论剑士", "skin": "大师专属装扮"},
		"宗师": {"gold": 10000, "pvp_points": 50000, "title": "宗师论剑士", "skin": "宗师专属装扮"},
		"王者": {"gold": 20000, "pvp_points": 100000, "title": "王者论剑士", "skin": "王者专属装扮", "mount": "王者坐骑"},
		"传说": {"gold": 50000, "pvp_points": 200000, "title": "传说论剑士", "skin": "传说专属装扮", "mount": "传说坐骑", "effect": "传说光环"}
	}
	
	# 赛季奖励
	season_rewards = {
		"participation": {"pvp_points": 1000, "copper": 50000},
		"top_100": {"gold": 1000, "title": "百强论剑士", "skin": "百强装扮"},
		"top_10": {"gold": 5000, "title": "十强论剑士", "skin": "十强装扮", "mount": "十强坐骑"},
		"top_3": {"gold": 20000, "title": "三甲论剑士", "skin": "三甲装扮", "mount": "三甲坐骑", "effect": "三甲光环"},
		"champion": {"gold": 50000, "title": "论剑状元", "skin": "状元装扮", "mount": "状元坐骑", "effect": "状元光环", "pet": "状元宠物"}
	}
	
	# 周奖励
	weekly_rewards = {
		"wins_5": {"pvp_points": 500, "copper": 10000},
		"wins_10": {"pvp_points": 1000, "copper": 20000},
		"wins_20": {"pvp_points": 2000, "copper": 50000, "item": "pvp_chest"},
		"wins_30": {"pvp_points": 5000, "copper": 100000, "item": "pvp_chest_rare"},
		"rank_up": {"pvp_points": 1000, "title": "周段位晋升者"}
	}
	
	# 日奖励
	daily_rewards = {
		"win_1": {"pvp_points": 50, "copper": 2000},
		"win_3": {"pvp_points": 150, "copper": 5000},
		"win_5": {"pvp_points": 300, "copper": 10000, "item": "pvp_token"},
		"participate": {"pvp_points": 20, "copper": 1000}
	}
	
	# 计算赛季结束时间
	var now = Time.get_unix_time_from_system()
	season_end_time = now + (28 * 86400)  # 28天后

func start_matchmaking(player_team: Array[BattleCharacter], mode: String = "ranked") -> bool:
	if is_searching:
		return false
	
	is_searching = true
	var match_data = {
		"player_id": PlayerData.instance.player_id,
		"team": _team_to_dict(player_team),
		"mode": mode,
		"timestamp": Time.get_unix_time_from_system(),
		"rank_score": PlayerData.instance.pvp_rank_score
	}
	
	matchmaking_queue.append(match_data)
	
	# 尝试匹配
	_try_matchmake()
	
	EventManager.instance.emit("matchmaking_started", mode)
	return true

func _parse_team_data(team_data: Array) -> Array:
	var result = []
	for c in team_data:
		var bc = BattleCharacter.new()
		bc.from_dict(c)
		result.append(bc)
	return result

func _match_history_to_dict() -> Array:
	var result = []
	for m in match_history:
		result.append(m.to_dict())
	return result

func _team_to_dict(team: Array[BattleCharacter]) -> Array:
	var result = []
	for c in team:
		result.append(c.to_dict())
	return result

func cancel_matchmaking():
	is_searching = false
	
	# 从队列移除
	var player_id = PlayerData.instance.player_id
	for i in range(matchmaking_queue.size()):
		if matchmaking_queue[i]["player_id"] == player_id:
			matchmaking_queue.remove_at(i)
			break
	
	EventManager.instance.emit("matchmaking_cancelled")

func _try_matchmake():
	var player_id = PlayerData.instance.player_id
	var player_idx = matchmaking_queue.find(func(m): return m["player_id"] == player_id)
	if player_idx < 0:
		return
	var player_data = matchmaking_queue[player_idx]
	var player_score = player_data["rank_score"]
	var best_match = null
	var best_diff = 999999
	
	for pvp_match3 in matchmaking_queue:
		if pvp_match3["player_id"] == player_id:
			continue
		if pvp_match3["mode"] != player_data["mode"]:
			continue
		
		var diff = abs(pvp_match3["rank_score"] - player_score)
		if diff < best_diff and diff < 500:
			best_diff = diff
			best_match = pvp_match3
	
	if best_match:
		_create_match(player_data, best_match)

func _create_match(player1_data: Dictionary, player2_data: Dictionary):
	var pvp_match = PvPMatch.new()
	pvp_match.match_id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
	pvp_match.player1_id = player1_data["player_id"]
	pvp_match.player2_id = player2_data["player_id"]
	pvp_match.player1_team = _parse_team_data(player1_data["team"])
	pvp_match.player2_team = _parse_team_data(player2_data["team"])
	pvp_match.mode = player1_data["mode"]
	pvp_match.start_time = Time.get_unix_time_from_system()
	pvp_match.status = "进行中"
	
	# 从队列移除
	matchmaking_queue.erase(player1_data)
	matchmaking_queue.erase(player2_data)
	is_searching = false
	
	current_match = pvp_match
	match_history.append(pvp_match)
	
	# 启动战斗
	CombatManager.instance.setup_battle(pvp_match.player1_team, pvp_match.player2_team, "方阵")
	CombatManager.instance.on_battle_end = Callable(self, "_on_pvp_battle_end").bind(pvp_match)
	CombatManager.instance.start_battle()
	
	EventManager.instance.emit("pvp_match_found", pvp_match)

func _on_pvp_battle_end(pvp_match2: PvPMatch, result: String):
	pvp_match2.end_time = Time.get_unix_time_from_system()
	pvp_match2.result = result
	pvp_match2.duration = pvp_match2.end_time - pvp_match2.start_time
	
	var player_data = PlayerData.instance
	var is_player1 = player_data.player_id == pvp_match2.player1_id
	var player_won = (is_player1 and result == "victory") or (not is_player1 and result == "defeat")
	
	if player_won:
		pvp_match2.winner_id = player_data.player_id
		pvp_match2.loser_id = pvp_match2.player1_id if is_player1 else pvp_match2.player2_id
		player_data.update_pvp_result(true, _calculate_score_change(pvp_match2, true))
	else:
		pvp_match2.winner_id = pvp_match2.player1_id if not is_player1 else pvp_match2.player2_id
		pvp_match2.loser_id = player_data.player_id
		player_data.update_pvp_result(false, _calculate_score_change(pvp_match2, false))
	
	current_match = null
	EventManager.instance.emit("pvp_match_end", pvp_match2)

func _calculate_score_change(pvp_match4: PvPMatch, win: bool) -> int:
	var base_change = 25
	var rank_diff = 0
	
	# 根据段位差调整
	# 这里简化处理
	if win:
		return base_change + randi_range(-5, 10)
	else:
		return -(base_change + randi_range(-5, 10))

func _give_pvp_rewards(win: bool, pvp_match2: PvPMatch):
	var player_data = PlayerData.instance
	
	if win:
		# 胜利奖励
		var daily = daily_rewards["win_1"]
		player_data.gain_copper(daily["copper"])
		player_data.pvp_points += daily["pvp_points"]
		
		# 检查每日胜利次数
		var daily_wins = _get_daily_wins()
		if daily_wins == 3:
			var r = daily_rewards["win_3"]
			player_data.gain_copper(r["copper"])
			player_data.pvp_points += r["pvp_points"]
		elif daily_wins == 5:
			var r = daily_rewards["win_5"]
			player_data.gain_copper(r["copper"])
			player_data.pvp_points += r["pvp_points"]
			_add_item(r["item"], 1)
		
		# 检查周胜利
		var weekly_wins = player_data.pvp_weekly_wins
		if weekly_wins in [5, 10, 20, 30]:
			var key = "wins_%d" % weekly_wins
			if weekly_rewards.has(key):
				var r = weekly_rewards[key]
				player_data.gain_copper(r["copper"])
				player_data.pvp_points += r["pvp_points"]
				if r.has("item"):
					_add_item(r["item"], 1)
	else:
		# 参与奖励
		var daily = daily_rewards["participate"]
		player_data.gain_copper(daily["copper"])
		player_data.pvp_points += daily["pvp_points"]

func _get_daily_wins() -> int:
	# 从本地存储获取今日胜利次数
	return 0  # 简化

func _add_item(item_id: String, count: int):
	PlayerData.instance.add_item(item_id, count)

func claim_season_rewards():
	var player_data = PlayerData.instance
	var rank = player_data.pvp_rank
	
	if rank_rewards.has(rank):
		var rewards = rank_rewards[rank]
		player_data.gain_gold(rewards["gold"])
		player_data.pvp_points += rewards["pvp_points"]
		if rewards.has("title"):
			_unlock_title(rewards["title"])
		if rewards.has("skin"):
			_unlock_skin(rewards["skin"])
		if rewards.has("mount"):
			_unlock_mount(rewards["mount"])
		if rewards.has("effect"):
			_unlock_effect(rewards["effect"])
		if rewards.has("pet"):
			_unlock_pet(rewards["pet"])
	
	# 赛季参与奖
	var participation = season_rewards["participation"]
	player_data.pvp_points += participation["pvp_points"]
	player_data.gain_copper(participation["copper"])
	
	# 排名奖励（需要服务器验证）
	# 这里仅作为示例
	
	EventManager.instance.emit("season_rewards_claimed", rank)

func _unlock_title(title_id: String):
	PlayerData.instance.unlock_achievement("title_%s" % title_id)

func _unlock_skin(skin_id: String):
	PlayerData.instance.unlock_achievement("skin_%s" % skin_id)

func _unlock_mount(mount_id: String):
	PlayerData.instance.unlock_achievement("mount_%s" % mount_id)

func _unlock_effect(effect_id: String):
	PlayerData.instance.unlock_achievement("effect_%s" % effect_id)

func _unlock_pet(pet_id: String):
	PlayerData.instance.unlock_achievement("pet_%s" % pet_id)

func get_season_remaining_time() -> int:
	var now = Time.get_unix_time_from_system()
	return max(0, season_end_time - now)

func get_season_info() -> Dictionary:
	return {
		"season": current_season,
		"end_time": season_end_time,
		"remaining_time": get_season_remaining_time(),
		"rank": PlayerData.instance.pvp_rank,
		"rank_score": PlayerData.instance.pvp_rank_score,
		"wins": PlayerData.instance.pvp_wins,
		"losses": PlayerData.instance.pvp_losses,
		"weekly_wins": PlayerData.instance.pvp_weekly_wins
	}

func get_match_history(limit: int = 20) -> Array[PvPMatch]:
	var history = match_history.duplicate()
	history.reverse()
	return history.slice(0, min(limit, history.size()))

func get_rank_rewards(rank: String) -> Dictionary:
	return rank_rewards.get(rank, {})

func get_all_rank_rewards() -> Dictionary:
	return rank_rewards.duplicate()

func to_dict() -> Dictionary:
	return {
		"current_season": current_season,
		"season_end_time": season_end_time,
		"match_history": _match_history_to_dict(),
		"matchmaking_queue": matchmaking_queue,
		"is_searching": is_searching
	}

func from_dict(data: Dictionary):
	current_season = data.get("current_season", 1)
	season_end_time = data.get("season_end_time", 0)
	
	match_history = []
	for m_data in data.get("match_history", []):
		var m = PvPMatch.new().from_dict(m_data)
		match_history.append(m)
	
	matchmaking_queue = data.get("matchmaking_queue", [])
	is_searching = data.get("is_searching", false)