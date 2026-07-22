extends Control
class_name CharacterCustomizationUI

@onready var portrait: TextureRect = %Portrait
@onready var name_input: LineEdit = %NameInput
@onready var random_name_btn: Button = %RandomNameBtn

@onready var face_container: VBoxContainer = %FaceContainer
@onready var body_container: VBoxContainer = %BodyContainer
@onready var voice_container: VBoxContainer = %VoiceContainer

@onready var preset_buttons: GridContainer = %PresetButtons
@onready var btn_randomize: Button = %BtnRandomize
@onready var btn_confirm: Button = %BtnConfirm
@onready var btn_cancel: Button = %BtnCancel

@onready var face_sliders: Dictionary = {}
@onready var body_sliders: Dictionary = {}
@onready var voice_sliders: Dictionary = {}

var current_customization: CharacterCustomization = null

signal on_create_complete(customization: CharacterCustomization)

func _ready():
	btn_randomize.pressed.connect(_on_randomize_pressed)
	btn_confirm.pressed.connect(_on_confirm_pressed)
	btn_cancel.pressed.connect(_on_cancel_pressed)
	random_name_btn.pressed.connect(_on_random_name_pressed)
	
	_create_face_sliders()
	_create_body_sliders()
	_create_voice_sliders()
	_create_preset_buttons()

func _create_face_sliders():
	var face_props = [
		{"name": "face_shape", "label": "脸型", "min": 0, "max": 7, "step": 1, "prop": "face_shape"},
		{"name": "skin_color", "label": "肤色", "type": "color", "prop": "skin_color"},
		{"name": "eye_shape", "label": "眼型", "min": 0, "max": 9, "step": 1, "prop": "eye_shape"},
		{"name": "eye_color", "label": "瞳色", "type": "color", "prop": "eye_color"},
		{"name": "eye_size", "label": "眼大小", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "eye_size"},
		{"name": "eye_spacing", "label": "眼距", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "eye_spacing"},
		{"name": "eye_angle", "label": "眼角", "min": -0.3, "max": 0.3, "step": 0.01, "prop": "eye_angle"},
		{"name": "eyebrow_shape", "label": "眉型", "min": 0, "max": 7, "step": 1, "prop": "eyebrow_shape"},
		{"name": "eyebrow_color", "label": "眉色", "type": "color", "prop": "eyebrow_color"},
		{"name": "eyebrow_thickness", "label": "眉粗", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "eyebrow_thickness"},
		{"name": "eyebrow_angle", "label": "眉角", "min": -0.3, "max": 0.3, "step": 0.01, "prop": "eyebrow_angle"},
		{"name": "eyebrow_height", "label": "眉高", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "eyebrow_height"},
		{"name": "nose_shape", "label": "鼻型", "min": 0, "max": 7, "step": 1, "prop": "nose_shape"},
		{"name": "nose_size", "label": "鼻大小", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "nose_size"},
		{"name": "nose_height", "label": "鼻高", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "nose_height"},
		{"name": "nose_width", "label": "鼻宽", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "nose_width"},
		{"name": "mouth_shape", "label": "嘴型", "min": 0, "max": 7, "step": 1, "prop": "mouth_shape"},
		{"name": "mouth_size", "label": "嘴大小", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "mouth_size"},
		{"name": "mouth_width", "label": "嘴宽", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "mouth_width"},
		{"name": "lip_thickness", "label": "唇厚", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "lip_thickness"},
		{"name": "lip_color", "label": "唇色", "type": "color", "prop": "lip_color"},
		{"name": "ear_shape", "label": "耳型", "min": 0, "max": 5, "step": 1, "prop": "ear_shape"},
		{"name": "ear_size", "label": "耳大小", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "ear_size"},
		{"name": "ear_position", "label": "耳位", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "ear_position"},
		{"name": "jaw_shape", "label": "颌型", "min": 0, "max": 5, "step": 1, "prop": "jaw_shape"},
		{"name": "jaw_width", "label": "颌宽", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "jaw_width"},
		{"name": "jaw_height", "label": "颌高", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "jaw_height"},
		{"name": "chin_shape", "label": "下巴型", "min": 0, "max": 5, "step": 1, "prop": "chin_shape"},
		{"name": "chin_size", "label": "下巴大小", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "chin_size"},
		{"name": "cheek_bones", "label": "颧骨", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "cheek_bones"},
		{"name": "forehead_height", "label": "额高", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "forehead_height"},
		{"name": "forehead_width", "label": "额宽", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "forehead_width"},
		{"name": "temple_width", "label": "太阳穴", "min": 0.5, "max": 1.5, "step": 0.05, "prop": "temple_width"},
	]
	
	for prop in face_props:
		var slider = _create_slider(prop)
		face_container.add_child(slider)
		face_sliders[prop["prop"]] = slider

func _create_body_sliders():
	var body_props = [
		{"name": "height", "label": "身高", "min": 0.8, "max": 1.2, "step": 0.01, "prop": "height"},
		{"name": "weight", "label": "体重", "min": 0.7, "max": 1.3, "step": 0.01, "prop": "weight"},
		{"name": "body_type", "label": "体型", "min": 0, "max": 4, "step": 1, "prop": "body_type"},
		{"name": "shoulder_width", "label": "肩宽", "min": 0.7, "max": 1.3, "step": 0.01, "prop": "shoulder_width"},
		{"name": "chest_size", "label": "胸围", "min": 0.7, "max": 1.3, "step": 0.01, "prop": "chest_size"},
		{"name": "waist_size", "label": "腰围", "min": 0.7, "max": 1.3, "step": 0.01, "prop": "waist_size"},
		{"name": "hip_size", "label": "臀围", "min": 0.7, "max": 1.3, "step": 0.01, "prop": "hip_size"},
		{"name": "arm_length", "label": "臂长", "min": 0.8, "max": 1.2, "step": 0.01, "prop": "arm_length"},
		{"name": "leg_length", "label": "腿长", "min": 0.8, "max": 1.2, "step": 0.01, "prop": "leg_length"},
		{"name": "neck_length", "label": "颈长", "min": 0.7, "max": 1.3, "step": 0.01, "prop": "neck_length"},
		{"name": "head_size", "label": "头大小", "min": 0.8, "max": 1.2, "step": 0.01, "prop": "head_size"},
		{"name": "hand_size", "label": "手大小", "min": 0.8, "max": 1.2, "step": 0.01, "prop": "hand_size"},
		{"name": "foot_size", "label": "脚大小", "min": 0.8, "max": 1.2, "step": 0.01, "prop": "foot_size"},
		{"name": "muscle_definition", "label": "肌肉线条", "min": 0.0, "max": 1.0, "step": 0.05, "prop": "muscle_definition"},
		{"name": "body_fat", "label": "体脂", "min": 0.0, "max": 1.0, "step": 0.05, "prop": "body_fat"},
		{"name": "skin_tone", "label": "肤色深度", "min": 0, "max": 8, "step": 1, "prop": "skin_tone"},
		{"name": "posture", "label": "体态", "min": 0, "max": 4, "step": 1, "prop": "posture"},
	]
	
	for prop in body_props:
		var slider = _create_slider(prop)
		body_container.add_child(slider)
		body_sliders[prop["prop"]] = slider

func _create_voice_sliders():
	var voice_props = [
		{"name": "voice_type", "label": "音色", "min": 0, "max": 9, "step": 1, "prop": "voice_type"},
		{"name": "pitch", "label": "音调", "min": 0.5, "max": 1.5, "step": 0.01, "prop": "pitch"},
		{"name": "speed", "label": "语速", "min": 0.5, "max": 1.5, "step": 0.01, "prop": "speed"},
		{"name": "volume", "label": "音量", "min": 0.5, "max": 1.5, "step": 0.01, "prop": "volume"},
		{"name": "tone", "label": "语气", "min": 0, "max": 7, "step": 1, "prop": "tone"},
		{"name": "accent", "label": "口音", "min": 0, "max": 7, "step": 1, "prop": "accent"},
		{"name": "breathiness", "label": "气息感", "min": 0.0, "max": 1.0, "step": 0.05, "prop": "breathiness"},
		{"name": "roughness", "label": "沙哑度", "min": 0.0, "max": 1.0, "step": 0.05, "prop": "roughness"},
		{"name": "resonance", "label": "共鸣", "min": 0.0, "max": 1.0, "step": 0.05, "prop": "resonance"},
		{"name": "formant_shift", "label": "共振峰", "min": -0.5, "max": 0.5, "step": 0.01, "prop": "formant_shift"},
		{"name": "vibrato", "label": "颤音", "min": 0.0, "max": 1.0, "step": 0.05, "prop": "vibrato"},
	]
	
	for prop in voice_props:
		var slider = _create_slider(prop)
		voice_container.add_child(slider)
		voice_sliders[prop["prop"]] = slider

func _create_slider(prop: Dictionary) -> Control:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 30)
	container.set_meta("prop_name", prop["name"])
	
	var label = Label.new()
	label.text = prop["label"]
	label.custom_minimum_size = Vector2(80, 0)
	container.add_child(label)
	
	if prop.get("type") == "color":
		var color_picker = ColorPickerButton.new()
		color_picker.custom_minimum_size = Vector2(100, 30)
		color_picker.color_changed.connect(_on_color_changed.bind(prop["prop"]))
		container.add_child(color_picker)
		return container
	
	var slider = HSlider.new()
	slider.min_value = prop["min"]
	slider.max_value = prop["max"]
	slider.step = prop["step"]
	slider.value = (prop["min"] + prop["max"]) / 2
	slider.custom_minimum_size = Vector2(200, 0)
	slider.value_changed.connect(_on_slider_changed.bind(prop["prop"]))
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.custom_minimum_size = Vector2(60, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.text = str(slider.value)
	container.add_child(value_label)
	
	return container

func _create_preset_buttons():
	var presets = ["protagonist", "heroic_male", "gentle_female", "cold_assassin", "scholar_swordsman", "villain", "wandering_monk", "mysterious_wanderer"]
	
	for preset in presets:
		var btn = Button.new()
		btn.text = preset
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(_on_preset_pressed.bind(preset))
		preset_buttons.add_child(btn)

func _on_slider_changed(value: float, prop_name: String):
	if current_customization and current_customization.face_data and current_customization.face_data.has_property(prop_name):
		current_customization.face_data.set(prop_name, value)
		_update_portrait()
	elif current_customization and current_customization.body_data and current_customization.body_data.has_property(prop_name):
		current_customization.body_data.set(prop_name, value)
		_update_portrait()
	elif current_customization and current_customization.voice_data and current_customization.voice_data.has_property(prop_name):
		current_customization.voice_data.set(prop_name, value)
	
# 更新数值标签（通过我们刚才存的字典 face_sliders / body_sliders / voice_sliders 查找）
	var container = face_sliders.get(prop_name)
	if not container:
		container = body_sliders.get(prop_name)
	if not container:
		container = voice_sliders.get(prop_name)
		
	if container:
		var label = container.get_child(-1)
		if label:
			label.text = "%.2f" % value

func _on_color_changed(color: Color, prop_name: String):
	if current_customization and current_customization.face_data and current_customization.face_data.has_property(prop_name):
		current_customization.face_data.set(prop_name, color)
		_update_portrait()

func _on_randomize_pressed():
	if not current_customization:
		current_customization = CharacterCustomization.new()
	
	current_customization.randomize_all()
	_update_sliders_from_data()
	_update_portrait()
	name_input.text = current_customization.character_name

func _on_preset_pressed(preset: String):
	if not current_customization:
		current_customization = CharacterCustomization.new()
	
	current_customization.apply_preset(preset)
	_update_sliders_from_data()
	_update_portrait()
	name_input.text = current_customization.character_name

func _on_random_name_pressed():
	if not current_customization:
		current_customization = CharacterCustomization.new()
	name_input.text = current_customization._generate_random_name()

func _on_confirm_pressed():
	if not current_customization:
		return
	
	current_customization.character_name = name_input.text
	if current_customization.character_name == "":
		current_customization.character_name = current_customization._generate_random_name()
	
	on_create_complete.emit(current_customization)
	visible = false

func _on_cancel_pressed():
	visible = false

func _update_sliders_from_data():
	if not current_customization:
		return
	
	for prop_name in face_sliders:
		var container = face_sliders[prop_name]
		var slider = container.find_child("HSlider")
		if slider and current_customization.face_data.has_property(prop_name):
			slider.value = current_customization.face_data.get(prop_name)
			var label = container.get_child(-1)
			if label:
				label.text = "%.2f" % slider.value
	
	for prop_name in body_sliders:
		var container = body_sliders[prop_name]
		var slider = container.find_child("HSlider")
		if slider and current_customization.body_data.has_property(prop_name):
			slider.value = current_customization.body_data.get(prop_name)
			var label = container.get_child(-1)
			if label:
				label.text = "%.2f" % slider.value
	
	for prop_name in voice_sliders:
		var container = voice_sliders[prop_name]
		var slider = container.find_child("HSlider")
		if slider and current_customization.voice_data.has_property(prop_name):
			slider.value = current_customization.voice_data.get(prop_name)
			var label = container.get_child(-1)
			if label:
				label.text = "%.2f" % slider.value

func _update_portrait():
	if current_customization:
		# 这里应该根据捏脸数据生成头像
		# 暂时使用默认头像
		portrait.texture = load("res://src/assets/portraits/default.png")
