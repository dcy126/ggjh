extends Resource
class_name EffectDatabase

static var _instance = null
var effects: Dictionary = {}
var _initialized: bool = false

func _ensure_loaded():
	if _initialized:
		return
	_initialized = true
	_load_all_effects()

func _load_all_effects():
	var e = StatusEffect.new()
	e.effect_id = "stun"
	e.effect_type = "眩晕"
	e.category = "减益"
	e.display_name = "眩晕"
	e.duration = 1
	e.max_duration = 1
	e.params = {"chance": 1.0}
	effects[e.effect_id] = e
	
	e = StatusEffect.new()
	e.effect_id = "root"
	e.effect_type = "定身"
	e.category = "减益"
	e.display_name = "定身"
	e.duration = 1
	e.max_duration = 1
	e.params = {"chance": 1.0}
	effects[e.effect_id] = e
	
	e = StatusEffect.new()
	e.effect_id = "silence"
	e.effect_type = "沉默"
	e.category = "减益"
	e.display_name = "沉默"
	e.duration = 1
	e.max_duration = 1
	e.params = {"chance": 1.0}
	effects[e.effect_id] = e

static func get_effect(effect_id: String):
	if _instance == null:
		_instance = EffectDatabase.new()
	_instance._ensure_loaded()
	return _instance.effects.get(effect_id)

static func get_all_effects():
	if _instance == null:
		_instance = EffectDatabase.new()
	_instance._ensure_loaded()
	return _instance.effects.values()
