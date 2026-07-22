extends Resource
class_name BodyData

@export var height: float = 1.0
@export var weight: float = 1.0
@export var body_type: int = 0  # 0=标准, 1=瘦削, 2=健壮, 3=魁梧, 4=娇小
@export var shoulder_width: float = 1.0
@export var chest_size: float = 1.0
@export var waist_size: float = 1.0
@export var hip_size: float = 1.0
@export var arm_length: float = 1.0
@export var leg_length: float = 1.0
@export var neck_length: float = 1.0
@export var head_size: float = 1.0
@export var hand_size: float = 1.0
@export var foot_size: float = 1.0
@export var muscle_definition: float = 0.5
@export var body_fat: float = 0.5
@export var skin_tone: int = 0
@export var body_tattoo: int = 0
@export var body_tattoo_color: int = 0
@export var scar: int = 0
@export var scar_color: int = 0
@export var body_hair: int = 0
@export var body_hair_color: int = 0
@export var posture: int = 0  # 0=标准, 1=挺拔, 2=驼背, 3=随意, 4=武术架势
@export var walk_style: int = 0
@export var idle_animation: int = 0

func _init():
	pass

func randomize():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	height = rng.randf_range(0.9, 1.1)
	weight = rng.randf_range(0.85, 1.15)
	body_type = rng.randi_range(0, 4)
	shoulder_width = rng.randf_range(0.9, 1.1)
	chest_size = rng.randf_range(0.9, 1.1)
	waist_size = rng.randf_range(0.9, 1.1)
	hip_size = rng.randf_range(0.9, 1.1)
	arm_length = rng.randf_range(0.95, 1.05)
	leg_length = rng.randf_range(0.95, 1.05)
	neck_length = rng.randf_range(0.9, 1.1)
	head_size = rng.randf_range(0.95, 1.05)
	hand_size = rng.randf_range(0.95, 1.05)
	foot_size = rng.randf_range(0.95, 1.05)
	muscle_definition = rng.randf_range(0.3, 0.8)
	body_fat = rng.randf_range(0.3, 0.7)
	skin_tone = rng.randi_range(0, 8)
	body_tattoo = rng.randi_range(0, 10)
	body_tattoo_color = rng.randi_range(0, 10)
	scar = rng.randi_range(0, 5)
	scar_color = rng.randi_range(0, 5)
	body_hair = rng.randi_range(0, 4)
	body_hair_color = rng.randi_range(0, 8)
	posture = rng.randi_range(0, 4)
	walk_style = rng.randi_range(0, 5)
	idle_animation = rng.randi_range(0, 5)

func apply_preset(preset_name: String):
	var presets = {
		"default": {},
		"slim_male": {"height": 1.02, "weight": 0.9, "body_type": 1, "shoulder_width": 1.0, "chest_size": 0.95, "waist_size": 0.9, "muscle_definition": 0.4, "body_fat": 0.3},
		"athletic_male": {"height": 1.0, "weight": 1.05, "body_type": 2, "shoulder_width": 1.1, "chest_size": 1.1, "waist_size": 0.95, "muscle_definition": 0.7, "body_fat": 0.3},
		"bulky_male": {"height": 1.05, "weight": 1.15, "body_type": 3, "shoulder_width": 1.15, "chest_size": 1.15, "waist_size": 1.05, "muscle_definition": 0.8, "body_fat": 0.4},
		"petite_female": {"height": 0.95, "weight": 0.9, "body_type": 4, "shoulder_width": 0.9, "chest_size": 0.95, "waist_size": 0.85, "hip_size": 1.0, "muscle_definition": 0.3, "body_fat": 0.4},
		"curvy_female": {"height": 1.0, "weight": 1.05, "body_type": 0, "shoulder_width": 0.95, "chest_size": 1.1, "waist_size": 0.9, "hip_size": 1.1, "muscle_definition": 0.4, "body_fat": 0.5},
		"martial_artist": {"height": 1.0, "weight": 1.0, "body_type": 2, "shoulder_width": 1.05, "chest_size": 1.05, "waist_size": 0.95, "arm_length": 1.02, "leg_length": 1.02, "muscle_definition": 0.6, "body_fat": 0.3, "posture": 4},
		"scholar": {"height": 1.0, "weight": 0.95, "body_type": 1, "shoulder_width": 0.95, "chest_size": 0.95, "waist_size": 0.9, "muscle_definition": 0.2, "body_fat": 0.4, "posture": 1},
		"noble": {"height": 1.02, "weight": 1.0, "body_type": 0, "shoulder_width": 1.0, "chest_size": 1.0, "waist_size": 0.95, "muscle_definition": 0.3, "body_fat": 0.4, "posture": 1}
	}
	
	if presets.has(preset_name):
		var preset = presets[preset_name]
		for key in preset:
			if key in self:
				set(key, preset[key])

func calculate_bmi() -> float:
	return weight / (height * height)

func get_body_category() -> String:
	var bmi = calculate_bmi()
	if bmi < 18.5:
		return "偏瘦"
	elif bmi < 24:
		return "标准"
	elif bmi < 28:
		return "偏重"
	else:
		return "肥胖"

func to_dict() -> Dictionary:
	var dict = {}
	var props = get_property_list()
	for prop in props:
		var name = prop.name
		if name != "class_name":
			dict[name] = get(name)
	return dict

func from_dict(data: Dictionary) -> BodyData:
	for key in data:
		if key in self:
			set(key, data[key])
	return self

func copy_from(other: BodyData):
	from_dict(other.to_dict())
