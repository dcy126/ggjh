extends Resource
class_name TrapDatabase

static var _instance = null
var traps: Dictionary = {}
var _initialized: bool = false

func _init():
	pass

func _ensure_loaded():
	if _initialized:
		return
	_initialized = true
	_load_all_traps()

func _load_all_traps():
	var data = TrapData.new()
	data.trap_id = "basic_trap"
	data.name = "机关"
	data.base_damage = 50
	traps[data.trap_id] = data

static func get_trap(trap_id: String):
	if _instance == null:
		_instance = TrapDatabase.new()
	_instance._ensure_loaded()
	return _instance.traps.get(trap_id)
