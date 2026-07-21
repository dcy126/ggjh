extends RefCounted
class_name FaceData

@export var face_shape: int = 0
@export var skin_color: Color = Color(1.0, 0.87, 0.75)
@export var eye_shape: int = 0
@export var eye_color: Color = Color(0.3, 0.2, 0.1)
@export var eye_size: float = 1.0
@export var eye_spacing: float = 1.0
@export var eye_angle: float = 0.0
@export var eyebrow_shape: int = 0
@export var eyebrow_color: Color = Color(0.2, 0.15, 0.1)
@export var eyebrow_thickness: float = 1.0
@export var eyebrow_angle: float = 0.0
@export var eyebrow_height: float = 1.0
@export var nose_shape: int = 0
@export var nose_size: float = 1.0
@export var nose_height: float = 1.0
@export var nose_width: float = 1.0
@export var mouth_shape: int = 0
@export var mouth_size: float = 1.0
@export var mouth_width: float = 1.0
@export var lip_thickness: float = 1.0
@export var lip_color: Color = Color(0.8, 0.4, 0.4)
@export var ear_shape: int = 0
@export var ear_size: float = 1.0
@export var ear_position: float = 1.0
@export var jaw_shape: int = 0
@export var jaw_width: float = 1.0
@export var jaw_height: float = 1.0
@export var chin_shape: int = 0
@export var chin_size: float = 1.0
@export var cheek_bones: float = 1.0
@export var forehead_height: float = 1.0
@export var forehead_width: float = 1.0
@export var temple_width: float = 1.0
@export var facial_hair: int = 0
@export var facial_hair_color: Color = Color(0.2, 0.15, 0.1)
@export var facial_hair_density: float = 1.0
@export var makeup_style: int = 0
@export var makeup_intensity: float = 0.0
@export var blush_color: Color = Color(1.0, 0.6, 0.6)
@export var blush_intensity: float = 0.0
@export var eyeshadow_color: Color = Color(0.5, 0.3, 0.6)
@export var eyeshadow_intensity: float = 0.0
@export var eyeliner_style: int = 0
@export var eyeliner_intensity: float = 0.0
@export var lipstick_color: Color = Color(0.8, 0.2, 0.3)
@export var lipstick_intensity: float = 0.0
@export var mole_positions: Array[Vector2] = []
@export var scar_positions: Array[Vector2] = []
@export var tattoo_id: String = ""
@export var tattoo_color: Color = Color(0.1, 0.1, 0.1)
@export var tattoo_scale: float = 1.0
@export var tattoo_rotation: float = 0.0
@export var tattoo_position: Vector2 = Vector2(0, 0)
@export var expression: int = 0
@export var asymmetry: float = 0.0

func _init():
	pass

func randomize():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	face_shape = rng.randi_range(0, 7)
	skin_color = Color(rng.randf_range(0.9, 1.0), rng.randf_range(0.75, 0.9), rng.randf_range(0.65, 0.85))
	eye_shape = rng.randi_range(0, 9)
	eye_color = Color(rng.randf_range(0.1, 0.5), rng.randf_range(0.1, 0.4), rng.randf_range(0.05, 0.25))
	eye_size = rng.randf_range(0.85, 1.15)
	eye_spacing = rng.randf_range(0.9, 1.1)
	eye_angle = rng.randf_range(-0.15, 0.15)
	eyebrow_shape = rng.randi_range(0, 7)
	eyebrow_color = Color(rng.randf_range(0.1, 0.3), rng.randf_range(0.05, 0.2), rng.randf_range(0.0, 0.15))
	eyebrow_thickness = rng.randf_range(0.8, 1.2)
	eyebrow_angle = rng.randf_range(-0.1, 0.1)
	eyebrow_height = rng.randf_range(0.9, 1.1)
	nose_shape = rng.randi_range(0, 7)
	nose_size = rng.randf_range(0.85, 1.15)
	nose_height = rng.randf_range(0.9, 1.1)
	nose_width = rng.randf_range(0.85, 1.15)
	mouth_shape = rng.randi_range(0, 7)
	mouth_size = rng.randf_range(0.85, 1.15)
	mouth_width = rng.randf_range(0.9, 1.1)
	lip_thickness = rng.randf_range(0.8, 1.2)
	lip_color = Color(rng.randf_range(0.7, 0.9), rng.randf_range(0.3, 0.5), rng.randf_range(0.3, 0.5))
	ear_shape = rng.randi_range(0, 5)
	ear_size = rng.randf_range(0.85, 1.15)
	ear_position = rng.randf_range(0.9, 1.1)
	jaw_shape = rng.randi_range(0, 5)
	jaw_width = rng.randf_range(0.85, 1.15)
	jaw_height = rng.randf_range(0.85, 1.15)
	chin_shape = rng.randi_range(0, 5)
	chin_size = rng.randf_range(0.85, 1.15)
	cheek_bones = rng.randf_range(0.85, 1.15)
	forehead_height = rng.randf_range(0.9, 1.1)
	forehead_width = rng.randf_range(0.9, 1.1)
	temple_width = rng.randf_range(0.9, 1.1)
	facial_hair = rng.randi_range(0, 7)
	facial_hair_color = Color(rng.randf_range(0.1, 0.3), rng.randf_range(0.05, 0.2), rng.randf_range(0.0, 0.15))
	facial_hair_density = rng.randf_range(0.5, 1.0)
	makeup_style = rng.randi_range(0, 5)
	makeup_intensity = rng.randf_range(0.0, 0.3)
	blush_color = Color(1.0, rng.randf_range(0.4, 0.7), rng.randf_range(0.4, 0.7))
	blush_intensity = rng.randf_range(0.0, 0.2)
	eyeshadow_color = Color(rng.randf_range(0.3, 0.7), rng.randf_range(0.2, 0.5), rng.randf_range(0.4, 0.8))
	eyeshadow_intensity = rng.randf_range(0.0, 0.2)
	eyeliner_style = rng.randi_range(0, 5)
	eyeliner_intensity = rng.randf_range(0.0, 0.2)
	lipstick_color = Color(rng.randf_range(0.6, 0.9), rng.randf_range(0.1, 0.4), rng.randf_range(0.1, 0.4))
	lipstick_intensity = rng.randf_range(0.0, 0.3)
	expression = rng.randi_range(0, 7)
	asymmetry = rng.randf_range(0.0, 0.05)

func apply_preset(preset_name: String):
	var presets = {
		"default": {},
		"handsome_male": {"face_shape": 1, "jaw_shape": 2, "chin_shape": 1, "eye_shape": 2, "eyebrow_shape": 3, "nose_shape": 2, "mouth_shape": 2},
		"beautiful_female": {"face_shape": 2, "jaw_shape": 3, "chin_shape": 3, "eye_shape": 4, "eyebrow_shape": 4, "nose_shape": 3, "mouth_shape": 4, "lip_thickness": 1.1, "makeup_intensity": 0.3},
		"cool_male": {"face_shape": 3, "jaw_shape": 1, "chin_shape": 2, "eye_shape": 5, "eyebrow_shape": 2, "nose_shape": 4, "mouth_shape": 3, "expression": 4},
		"elegant_female": {"face_shape": 4, "jaw_shape": 4, "chin_shape": 4, "eye_shape": 6, "eyebrow_shape": 5, "nose_shape": 5, "mouth_shape": 5, "expression": 2},
		"cute_male": {"face_shape": 5, "jaw_shape": 4, "chin_shape": 5, "eye_shape": 7, "eyebrow_shape": 6, "nose_shape": 6, "mouth_shape": 6, "expression": 5},
		"cute_female": {"face_shape": 5, "jaw_shape": 5, "chin_shape": 5, "eye_shape": 8, "eyebrow_shape": 7, "nose_shape": 7, "mouth_shape": 7, "eye_size": 1.15, "expression": 6},
		"mature_male": {"face_shape": 6, "jaw_shape": 2, "chin_shape": 2, "eye_shape": 3, "eyebrow_shape": 4, "nose_shape": 3, "mouth_shape": 4, "cheek_bones": 1.1, "expression": 1},
		"mature_female": {"face_shape": 4, "jaw_shape": 3, "chin_shape": 3, "eye_shape": 4, "eyebrow_shape": 5, "nose_shape": 4, "mouth_shape": 5, "makeup_intensity": 0.2},
		"fierce_male": {"face_shape": 3, "jaw_shape": 1, "chin_shape": 1, "eye_shape": 5, "eyebrow_shape": 1, "nose_shape": 4, "mouth_shape": 1, "cheek_bones": 1.15, "expression": 3},
		"gentle_female": {"face_shape": 2, "jaw_shape": 4, "chin_shape": 4, "eye_shape": 3, "eyebrow_shape": 6, "nose_shape": 3, "mouth_shape": 4, "blush_intensity": 0.15, "expression": 2},
		"scholar": {"face_shape": 1, "jaw_shape": 3, "chin_shape": 3, "eye_shape": 2, "eyebrow_shape": 5, "nose_shape": 2, "mouth_shape": 2, "expression": 0},
		"villain": {"face_shape": 3, "jaw_shape": 1, "chin_shape": 2, "eye_shape": 5, "eyebrow_shape": 1, "nose_shape": 4, "mouth_shape": 3, "cheek_bones": 1.15, "expression": 4},
		"heroic": {"face_shape": 1, "jaw_shape": 2, "chin_shape": 1, "eye_shape": 2, "eyebrow_shape": 3, "nose_shape": 2, "mouth_shape": 2, "cheek_bones": 1.05, "expression": 0},
		"mysterious": {"face_shape": 4, "jaw_shape": 3, "chin_shape": 3, "eye_shape": 6, "eyebrow_shape": 4, "nose_shape": 5, "mouth_shape": 5, "eye_angle": 0.1, "expression": 7}
	}
	
	if presets.has(preset_name):
		var preset = presets[preset_name]
		for key in preset:
			if key in self:
				set(key, preset[key])

func get_face_type_name() -> String:
	var shapes = ["圆脸", "方脸", "长脸", "心形脸", "椭圆脸", "菱形脸", "三角脸", "倒三角脸"]
	return shapes[face_shape] if face_shape < shapes.size() else "未知"

func get_skin_tone_name() -> String:
	var brightness = skin_color.v
	if brightness > 0.9:
		return "极白"
	elif brightness > 0.85:
		return "白皙"
	elif brightness > 0.8:
		return "偏白"
	elif brightness > 0.75:
		return "标准"
	elif brightness > 0.7:
		return "偏黑"
	else:
		return "古铜"

func to_dict() -> Dictionary:
	var dict = {}
	var props = get_property_list()
	for prop in props:
		var name = prop.name
		if name != "class_name":
			var value = get(name)
			if value is Color:
				dict[name] = {"r": value.r, "g": value.g, "b": value.b, "a": value.a}
			elif value is Vector2:
				dict[name] = {"x": value.x, "y": value.y}
			elif value is Array:
				var arr = []
				for item in value:
					if item is Vector2:
						arr.append({"x": item.x, "y": item.y})
					elif item is Color:
						arr.append({"r": item.r, "g": item.g, "b": item.b, "a": item.a})
					else:
						arr.append(item)
				dict[name] = arr
			else:
				dict[name] = value
	return dict

func from_dict(data: Dictionary) -> FaceData:
	for key in data:
		if key in self:
			var value = data[key]
			if value is Dictionary and value.has("r"):
				set(key, Color(value.r, value.g, value.b, value.a))
			elif value is Dictionary and value.has("x"):
				set(key, Vector2(value.x, value.y))
			elif value is Array:
				var arr = []
				for item in value:
					if item is Dictionary and item.has("x"):
						arr.append(Vector2(item.x, item.y))
					elif item is Dictionary and item.has("r"):
						arr.append(Color(item.r, item.g, item.b, item.a))
					else:
						arr.append(item)
				set(key, arr)
			else:
				set(key, value)
	return self

func copy_from(other: FaceData):
	from_dict(other.to_dict())
