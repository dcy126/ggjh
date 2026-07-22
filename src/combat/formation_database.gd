extends Resource
class_name FormationDatabase

static var _instance = null
var formations: Dictionary = {}
var _initialized: bool = false

func _ensure_loaded():
	if _initialized:
		return
	_initialized = true
	_load_all_formations()

func _load_all_formations():
	var f = Formation.new()
	f.formation_id = "tianfu"
	f.name = "天覆阵"
	f.positions = [Vector2i(0, 2), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 0)]
	f.buffs = {"all_stats": 0.1}
	formations[f.formation_id] = f

static func get_formation(formation_id: String):
	if _instance == null:
		_instance = FormationDatabase.new()
	_instance._ensure_loaded()
	return _instance.formations.get(formation_id)

static func get_all_formations():
	if _instance == null:
		_instance = FormationDatabase.new()
	_instance._ensure_loaded()
	return _instance.formations.values()
