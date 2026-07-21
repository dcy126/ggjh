extends Control
class_name DialogueUI

@onready var dialogue_box: VBoxContainer = %DialogueBox
@onready var speaker_name: Label = %SpeakerName
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var portrait: TextureRect = %Portrait
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var next_btn: Button = %NextButton
@onready var auto_btn: Button = %AutoButton
@onready var skip_btn: Button = %SkipButton

var current_dialogue: DialogueNode = null
var dialogue_queue: Array[DialogueNode] = []
var is_auto: bool = false
var auto_timer: float = 0.0
var typewriter_effect: bool = true
var typewriter_speed: float = 30.0  # 字符/秒
var current_char_index: int = 0
var full_text: String = ""

signal dialogue_ended

func _ready():
	next_btn.pressed.connect(_on_next_pressed)
	auto_btn.pressed.connect(_on_auto_pressed)
	skip_btn.pressed.connect(_on_skip_pressed)
	
	next_btn.text = "下一句"
	auto_btn.text = "自动: 关"
	skip_btn.text = "跳过"
	
	visible = false

func show_dialogue(speaker: String, text: String, choices: Array[Dictionary] = [], portrait_path: String = ""):
	visible = true
	UIManager.get_instance().lock_ui()
	
	speaker_name.text = speaker
	
	if portrait_path != "":
		portrait.texture = load(portrait_path)
		portrait.visible = true
	else:
		portrait.visible = false
	
	_show_text(text)
	
	if choices.size() > 0:
		_show_choices(choices)
	else:
		_hide_choices()
		next_btn.visible = true

func _show_text(text: String):
	full_text = text
	current_char_index = 0
	dialogue_text.text = ""
	
	if typewriter_effect:
		_start_typewriter()
	else:
		dialogue_text.text = text

func _start_typewriter():
	# 使用Tween实现打字机效果
	var tween = create_tween()
	tween.set_parallel(false)
	
	var chars = full_text.to_char_array()
	for i in range(chars.size()):
		var char = chars[i]
		tween.tween_callback(_append_char.bind(char))
		tween.tween_interval(1.0 / typewriter_speed)
	
	tween.tween_callback(_on_typewriter_finished)

func _append_char(char: String):
	dialogue_text.append_text(char)
	current_char_index += 1

func _on_typewriter_finished():
	current_char_index = full_text.length()
	
	if is_auto:
		auto_timer = 2.0

func _show_choices(choices: Array[Dictionary]):
	for child in choices_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = choice.get("text", "选项 %d" % (i + 1))
		btn.custom_minimum_size = Vector2(400, 40)
		btn.pressed.connect(_on_choice_selected.bind(choice))
		choices_container.add_child(btn)
	
	choices_container.visible = true
	next_btn.visible = false

func _hide_choices():
	choices_container.visible = false
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_selected(choice: Dictionary):
	var choice_id = choice.get("id", "")
	var consequences = choice.get("consequences", {})
	
	# 应用选择后果
	_apply_consequences(consequences)
	
	# 跳转到下一个节点
	var next_node_id = choice.get("next_node", "")
	if next_node_id != "":
		var next_node = StoryDatabase.get_instance().get_dialogue(next_node_id)
		if next_node:
			show_dialogue(next_node.speaker, next_node.text, next_node.choices, next_node.portrait)
			return
	
	_hide_dialogue()

func _apply_consequences(consequences: Dictionary):
	for key in consequences:
		var effect = consequences[key]
		match key:
			"exp":
				PlayerData.get_instance().gain_exp(effect)
			"copper":
				PlayerData.get_instance().gain_copper(effect)
			"gold":
				PlayerData.get_instance().gain_gold(effect)
			"item":
				PlayerData.get_instance().add_item(effect.get("id", ""), effect.get("count", 1))
			"moral":
				if PlayerData.get_instance().character_customization:
					PlayerData.get_instance().character_customization.moral_alignment = clamp(PlayerData.get_instance().character_customization.moral_alignment + effect, -1.0, 1.0)
			"reputation":
				if PlayerData.get_instance().character_customization:
					for faction in effect:
						PlayerData.get_instance().character_customization.reputation[faction] = PlayerData.get_instance().character_customization.reputation.get(faction, 0) + effect[faction]
			"affection":
				# NPC好感度变化
				pass
			"relationship":
				# 关系变化
				pass
			"unlock":
				for content in effect:
					if content not in PlayerData.get_instance().unlocked_content:
						PlayerData.get_instance().unlocked_content.append(content)
			"lock":
				for content in effect:
					if content in PlayerData.get_instance().unlocked_content:
						PlayerData.get_instance().unlocked_content.erase(content)
			"chapter":
				PlayerData.get_instance().current_chapter = effect
			"quest":
				var quest = StoryDatabase.get_instance().get_quest(effect)
				if quest:
					PlayerData.get_instance().accept_quest(quest)
			"complete_quest":
				PlayerData.get_instance().complete_quest(effect)
			"recruit":
				# 招募伙伴
				pass
			"learn_wuxue":
				var wx = WuxueDatabase.get_instance().get_wuxue(effect)
				if wx:
					PlayerData.get_instance().protagonist.known_wuxue.append(wx.id)
			"learn_xinfa":
				var xf = XinfaDatabase.get_instance().get_xinfa(effect)
				if xf:
					PlayerData.get_instance().protagonist.equipped_xinfa["通用"] = xf.id
			"get_equipment":
				var eq = EquipmentDatabase.get_instance().get_equipment(effect)
				if eq:
					PlayerData.get_instance().add_equipment(eq)

func _on_next_pressed():
	if current_char_index < full_text.length():
		# 完成打字机效果
		dialogue_text.text = full_text
		current_char_index = full_text.length()
		_on_typewriter_finished()
	else:
		# 检查是否有队列中的下一句对话
		if dialogue_queue.size() > 0:
			var next_d = dialogue_queue.pop_front()
			show_dialogue(next_d.speaker, next_d.text, next_d.choices, next_d.portrait)
		else:
			_hide_dialogue()

func _on_auto_pressed():
	is_auto = not is_auto
	auto_btn.text = "自动: %s" % [is_auto ? "开" : "关"]

func _on_skip_pressed():
	_hide_dialogue()

func _hide_dialogue():
	visible = false
	UIManager.get_instance().unlock_ui()

func _process(delta: float):
	if is_auto and visible and current_char_index >= full_text.length():
		auto_timer -= delta
		if auto_timer <= 0:
			_on_next_pressed()