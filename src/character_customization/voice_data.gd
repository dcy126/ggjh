extends RefCounted
class_name VoiceData

@export var voice_type: int = 0
@export var pitch: float = 1.0
@export var speed: float = 1.0
@export var volume: float = 1.0
@export var tone: int = 0  # 0=平和, 1=威严, 2=温柔, 3=冷酷, 4=豪迈, 5=秀气, 6=稚嫩, 7=苍老
@export var accent: int = 0  # 0=标准, 1=北方, 2=南方, 3=川渝, 4=粤语, 5=吴语, 6=闽南, 7=京片子
@export var breathiness: float = 0.0
@export var roughness: float = 0.0
@export var resonance: float = 0.5
@export var formant_shift: float = 0.0
@export var vibrato: float = 0.0
@export var laughter_style: int = 0
@export var cough_style: int = 0
@export var sigh_style: int = 0

func _init():
	pass

func randomize():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	voice_type = rng.randi_range(0, 9)
	pitch = rng.randf_range(0.8, 1.2)
	speed = rng.randf_range(0.9, 1.1)
	volume = rng.randf_range(0.8, 1.0)
	tone = rng.randi_range(0, 7)
	accent = rng.randi_range(0, 7)
	breathiness = rng.randf_range(0.0, 0.3)
	roughness = rng.randf_range(0.0, 0.3)
	resonance = rng.randf_range(0.3, 0.7)
	formant_shift = rng.randf_range(-0.2, 0.2)
	vibrato = rng.randf_range(0.0, 0.2)
	laughter_style = rng.randi_range(0, 5)
	cough_style = rng.randi_range(0, 3)
	sigh_style = rng.randi_range(0, 3)

func apply_preset(preset_name: String):
	var presets = {
		"default": {},
		"young_male": {"voice_type": 1, "pitch": 1.0, "tone": 0, "speed": 1.05},
		"mature_male": {"voice_type": 2, "pitch": 0.9, "tone": 1, "speed": 0.95, "roughness": 0.2},
		"elder_male": {"voice_type": 3, "pitch": 0.85, "tone": 7, "speed": 0.9, "roughness": 0.4, "resonance": 0.6},
		"young_female": {"voice_type": 4, "pitch": 1.15, "tone": 2, "speed": 1.05},
		"mature_female": {"voice_type": 5, "pitch": 1.05, "tone": 2, "speed": 1.0, "resonance": 0.55},
		"elder_female": {"voice_type": 6, "pitch": 1.0, "tone": 7, "speed": 0.95, "roughness": 0.2, "resonance": 0.5},
		"heroic_male": {"voice_type": 2, "pitch": 0.95, "tone": 4, "speed": 1.0, "resonance": 0.7, "roughness": 0.1},
		"gentle_female": {"voice_type": 5, "pitch": 1.1, "tone": 2, "speed": 0.95, "breathiness": 0.2, "resonance": 0.4},
		"cold_male": {"voice_type": 1, "pitch": 0.95, "tone": 3, "speed": 0.95, "roughness": 0.1},
		"cold_female": {"voice_type": 4, "pitch": 1.1, "tone": 3, "speed": 1.0, "breathiness": 0.1},
		"scholar": {"voice_type": 0, "pitch": 1.0, "tone": 5, "speed": 1.0, "accent": 0},
		"villain": {"voice_type": 2, "pitch": 0.9, "tone": 3, "speed": 0.9, "roughness": 0.3, "resonance": 0.7}
	}
	
	if presets.has(preset_name):
		var preset = presets[preset_name]
		for key in preset:
			if has_property(key):
				set(key, preset[key])

func get_voice_description() -> String:
	var tones = ["平和", "威严", "温柔", "冷酷", "豪迈", "秀气", "稚嫩", "苍老"]
	var accents = ["标准", "北方", "南方", "川渝", "粤语", "吴语", "闽南", "京片子"]
	
	var desc = "%s音色" % tones[tone]
	if accent > 0:
		desc += "，%s口音" % accents[accent]
	if pitch > 1.1:
		desc += "，音调偏高"
	elif pitch < 0.9:
		desc += "，音调偏低"
	if speed > 1.1:
		desc += "，语速偏快"
	elif speed < 0.9:
		desc += "，语速偏慢"
	
	return desc

func to_dict() -> Dictionary:
	var dict = {}
	var props = get_property_list()
	for prop in props:
		var name = prop.name
		if name != "class_name":
			dict[name] = get(name)
	return dict

func from_dict(data: Dictionary) -> VoiceData:
	for key in data:
		if has_property(key):
			set(key, data[key])
	return self

func copy_from(other: VoiceData):
	from_dict(other.to_dict())