extends Node2D
class_name BattleScene

@onready var battle_ui: Control = %BattleUI
@onready var battle_grid: TileMap = %BattleGrid

var combat_manager: CombatManager = null
var player_team: Array[BattleCharacter] = []
var enemy_team: Array[BattleCharacter] = []

func _ready():
	combat_manager = CombatManager.get_instance()
	combat_manager.on_battle_end.connect(_on_battle_end)
	
	# 从GameData获取当前战斗数据
	var game_data = GameData.get_instance()
	
	# 这里应该根据实际情况加载战斗数据
	# 暂时使用测试数据
	_load_test_battle()

func _load_test_battle():
	var char_db = CharacterDatabase.get_instance()
	
	# 玩家队伍
	player_team = [
		char_db.get_character("protagonist").get_battle_character(),
		char_db.get_character("xin_qiji_chu_kuang").get_battle_character(),
		char_db.get_character("liu_rusi_die_lian_hua").get_battle_character(),
	]
	
	# 敌方队伍
	enemy_team = [
		char_db.get_character("nalan_changbai_shuoxue").get_battle_character(),
		char_db.get_character("ye_yushi_canghai_yue_ming").get_battle_character(),
	]
	
	for char in player_team:
		char.team = 0
		char.is_player_controlled = true
	
	for char in enemy_team:
		char.team = 1
	
	combat_manager.setup_battle(player_team, enemy_team, "方阵")
	combat_manager.start_battle()

func _on_battle_end(result: String):
	match result:
		"victory":
			print("战斗胜利!")
			_give_rewards()
		"defeat":
			print("战斗失败!")
		"time_up":
			print("时间耗尽!")
	
	# 返回世界地图
	get_tree().change_scene_to_file("res://src/scenes/world/world.tscn")

func _give_rewards():
	var exp = 10000
	var copper = 5000
	PlayerData.get_instance().gain_exp(exp)
	PlayerData.get_instance().gain_copper(copper)
	UIManager.get_instance().show_notification("获得经验 %d, 铜钱 %d" % [exp, copper], "success")