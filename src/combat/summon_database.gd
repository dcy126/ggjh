extends Resource
class_name SummonDatabase

static var _instance = null
var summons: Dictionary = {}
var _initialized: bool = false

func _ensure_loaded():
	if _initialized:
		return
	_initialized = true
	_load_all_summons()

func _load_all_summons():
	var data = _create_summon_data()
	data.summon_id = "muniu"
	data.name = "木牛"
	data.base_hp = 500
	data.base_atk = 80
	data.base_def = 50
	data.base_spd = 60
	data.skills = ["transport"]
	data.ai = "support_owner"
	summons[data.summon_id] = data
	
	data = _create_summon_data()
	data.summon_id = "liuma"
	data.name = "流马"
	data.base_hp = 500
	data.base_atk = 100
	data.base_def = 60
	data.base_spd = 80
	data.skills = ["charge"]
	data.ai = "attack_nearest"
	summons[data.summon_id] = data
	
	data = _create_summon_data()
	data.summon_id = "heluo_bangzhong"
	data.name = "帮众"
	data.base_hp = 1000
	data.base_atk = 120
	data.base_def = 80
	data.base_spd = 80
	data.skills = ["bangzhong_attack"]
	data.ai = "attack_nearest"
	summons[data.summon_id] = data
	
	data = _create_summon_data()
	data.summon_id = "phantom"
	data.name = "幻影"
	data.base_hp = 300
	data.base_atk = 60
	data.base_def = 30
	data.base_spd = 100
	data.skills = ["phantom_strike"]
	data.ai = "attack_owner_target"
	summons[data.summon_id] = data
	
	data = _create_summon_data()
	data.summon_id = "jiguan_shou"
	data.name = "机关兽"
	data.base_hp = 800
	data.base_atk = 150
	data.base_def = 100
	data.base_spd = 70
	data.skills = ["jiguan_attack"]
	data.ai = "attack_nearest"
	summons[data.summon_id] = data
	
	data = _create_summon_data()
	data.summon_id = "tianji_mine"
	data.name = "地雷"
	data.base_hp = 1
	data.base_atk = 300
	data.base_def = 0
	data.base_spd = 0
	data.skills = ["explode"]
	data.ai = "guard_position"
	summons[data.summon_id] = data
	
	data = _create_summon_data()
	data.summon_id = "juejing_jiguan"
	data.name = "绝境机关"
	data.base_hp = 1
	data.base_atk = 500
	data.base_def = 0
	data.base_spd = 0
	data.skills = ["explode"]
	data.ai = "guard_position"
	summons[data.summon_id] = data

static func get_summon(summon_id: String):
	if _instance == null:
		_instance = SummonDatabase.new()
	_instance._ensure_loaded()
	return _instance.summons.get(summon_id)

static func get_all_summons():
	if _instance == null:
		_instance = SummonDatabase.new()
	_instance._ensure_loaded()
	return _instance.summons.values()

func _create_summon_data():
	return load("res://src/combat/summon_data.gd").new()
