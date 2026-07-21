extends Control
class_name PvPPanelUI

@onready var rank_label: Label = %RankLabel
@onready var rank_score_label: Label = %RankScoreLabel
@onready var season_label: Label = %SeasonLabel
@onready var season_timer_label: Label = %SeasonTimerLabel
@onready var wins_losses_label: Label = %WinsLossesLabel
@onready var weekly_wins_label: Label = %WeeklyWinsLabel

@onready var match_btn: Button = %MatchButton
@onready var cancel_btn: Button = %CancelButton
@onready var match_status_label: Label = %MatchStatusLabel
@onready var match_progress: ProgressBar = %MatchProgress

@onready var history_list: ItemList = %HistoryList
@onready var rank_rewards_list: ItemList = %RankRewardsList

@onready var rewards_panel: VBoxContainer = %RewardsPanel
@onready var btn_claim_season: Button = %BtnClaimSeason

@onready var formation_btn: Button = %FormationButton
@onready var team_list: ItemList = %TeamList

var is_matching: bool = false
var match_timer: float = 0.0

func _ready():
	match_btn.pressed.connect(_on_match_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	btn_claim_season.pressed.connect(_on_claim_season_pressed)
	formation_btn.pressed.connect(_on_formation_pressed)
	
	_refresh_all()

func _refresh_all():
	_refresh_rank_info()
	_refresh_history()
	_refresh_rank_rewards()
	_refresh_team()

func _refresh_rank_info():
	var pvp = PvPManager.get_instance()
	var player = PlayerData.get_instance()
	
	rank_label.text = "段位: %s" % player.pvp_rank
	rank_score_label.text = "积分: %d" % player.pvp_rank_score
	season_label.text = "赛季: S%d" % player.pvp_season
	
	var remaining = pvp.get_season_remaining_time()
	var days = remaining / 86400
	var hours = (remaining % 86400) / 3600
	season_timer_label.text = "剩余: %d天 %d小时" % [days, hours]
	
	wins_losses_label.text = "胜率: %d / %d (%.1f%%)" % [player.pvp_wins, player.pvp_losses, player.pvp_wins + player.pvp_losses > 0 ? player.pvp_wins * 100.0 / (player.pvp_wins + player.pvp_losses) : 0]
	weekly_wins_label.text = "本周胜利: %d" % player.pvp_weekly_wins

func _refresh_history():
	history_list.clear()
	var history = PvPManager.get_instance().get_match_history(20)
	for match in history:
		var player = PlayerData.get_instance()
		var is_player1 = player.player_id == match.player1_id
		var won = (is_player1 and match.result == "victory") or (not is_player1 and match.result == "defeat")
		
		var result_text = won ? "[color=green]胜利[/color]" : "[color=red]失败[/color]"
		var score_text = match.score_change > 0 ? "+%d" % match.score_change : "%d" % match.score_change
		var item_text = "[%s] %s (%s)" % [Time.get_datetime_string_from_unix(match.start_time), result_text, score_text]
		
		var index = history_list.add_item(item_text)
		history_list.set_item_metadata(index, match)
		if won:
			history_list.set_item_custom_fg_color(index, Color(0, 1, 0))
		else:
			history_list.set_item_custom_fg_color(index, Color(1, 0, 0))

func _refresh_rank_rewards():
	rank_rewards_list.clear()
	var rewards = PvPManager.get_instance().get_all_rank_rewards()
	for rank in ["青铜", "白银", "黄金", "铂金", "钻石", "大师", "宗师", "王者", "传说"]:
		if rewards.has(rank):
			var reward = rewards[rank]
			var current = PlayerData.get_instance().pvp_rank
			var achieved = _compare_ranks(current, rank) >= 0
			
			var item_text = "%s: %d元宝, %d论剑积分" % [rank, reward.get("gold", 0), reward.get("pvp_points", 0)]
			if achieved:
				item_text = "✓ " + item_text
			else:
				item_text = "○ " + item_text
			
			if reward.has("skin"):
				item_text += " (皮肤)"
			if reward.has("mount"):
				item_text += " (坐骑)"
			if reward.has("effect"):
				item_text += " (光环)"
			
			var index = rank_rewards_list.add_item(item_text)
			if achieved:
				rank_rewards_list.set_item_custom_fg_color(index, Color(0, 1, 0))
			else:
				rank_rewards_list.set_item_custom_fg_color(index, Color(1, 1, 0))

func _compare_ranks(rank1: String, rank2: String) -> int:
	var ranks = ["青铜", "白银", "黄金", "铂金", "钻石", "大师", "宗师", "王者", "传说"]
	var idx1 = ranks.find(rank1)
	var idx2 = ranks.find(rank2)
	return idx1 - idx2

func _refresh_team():
	team_list.clear()
	for char in PlayerData.get_instance().formation:
		var character = CharacterDatabase.get_character(char)
		if character:
			team_list.add_item("%s Lv.%d [%s]" % [character.name, character.potential_level, character.role])
		else:
			team_list.add_item("空位")

func _on_match_pressed():
	var player = PlayerData.get_instance()
	var team = []
	for char_id in player.formation:
		var char = CharacterDatabase.get_character(char_id)
		if char:
			team.append(char.get_battle_character())
	
	if team.is_empty():
		UIManager.get_instance().show_notification("请先设置阵容", "warning")
		return
	
	if PvPManager.get_instance().start_matchmaking(team):
		is_matching = true
		match_btn.disabled = true
		cancel_btn.disabled = false
		match_status_label.text = "正在匹配..."
		match_progress.value = 0
		match_timer = 0.0
		AudioManager.get_instance().play_sfx("click")

func _on_cancel_pressed():
	PvPManager.get_instance().cancel_matchmaking()
	is_matching = false
	match_btn.disabled = false
	cancel_btn.disabled = true
	match_status_label.text = "已取消匹配"
	match_progress.value = 0

func _on_claim_season_pressed():
	PvPManager.get_instance().claim_season_rewards()
	_refresh_rank_info()
	_refresh_rank_rewards()

func _on_formation_pressed():
	UIManager.get_instance().open_ui("formation")

func _process(delta: float):
	if is_matching:
		match_timer += delta
		match_progress.value = min(match_timer / 30.0, 1.0)
		match_status_label.text = "正在匹配... %.0f%%" % (match_progress.value * 100)
		
		if match_progress.value >= 1.0:
			# 匹配超时，AI模拟
			_start_ai_match()

func _start_ai_match():
	# 创建AI对手
	var ai_team = _create_ai_team()
	var player_team = []
	for char_id in PlayerData.get_instance().formation:
		var char = CharacterDatabase.get_character(char_id)
		if char:
			player_team.append(char.get_battle_character())
	
	# 模拟战斗结果
	var win = randf() > 0.4
	var score_change = win ? randi_range(15, 35) : -randi_range(15, 35)
	
	var match = PvPMatch.new()
	match.match_id = "ai_" + str(Time.get_unix_time_from_system())
	match.player1_id = PlayerData.get_instance().player_id
	match.player2_id = "ai_opponent"
	match.result = win ? "victory" : "defeat"
	match.score_change = score_change
	match.duration = randi_range(60, 180)
	
	PvPManager.get_instance().match_history.append(match)
	PlayerData.get_instance().update_pvp_result(win, score_change)
	
	is_matching = false
	match_btn.disabled = false
	cancel_btn.disabled = true
	match_status_label.text = win ? "匹配成功 - 胜利!" : "匹配成功 - 失败"
	
	_refresh_all()
	UIManager.get_instance().show_notification(win ? "论剑胜利!" : "论剑失败", win ? "success" : "error")

func _create_ai_team() -> Array[BattleCharacter]:
	var team = []
	var all_chars = CharacterDatabase.get_all_characters()
	var count = randi_range(3, 5)
	
	for i in range(count):
		var char = all_chars[randi() % all_chars.size()]
		team.append(char.get_battle_character())
	
	return team