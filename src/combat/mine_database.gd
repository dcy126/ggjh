extends Resource
class_name MineDatabase

static var _instance = null
var mines: Dictionary = {}
var _initialized: bool = false

func _init():
	pass

func _ensure_loaded():
	if _initialized:
		return
	_initialized = true
	_load_all_mines()

func _load_all_mines():
	var data = MineData.new()
	data.mine_id = "basic_mine"
	data.name = "地雷"
	data.base_damage = 100
	mines[data.mine_id] = data

static func get_mine(mine_id: String):
	if _instance == null:
		_instance = MineDatabase.new()
	_instance._ensure_loaded()
	return _instance.mines.get(mine_id)
