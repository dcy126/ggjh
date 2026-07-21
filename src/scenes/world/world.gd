extends Node2D
class_name WorldScene

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera2D
@onready var current_area_label: Label = %CurrentAreaLabel
@onready var minimap: TextureRect = %Minimap
@onready var time_label: Label = %TimeLabel
@onready var weather_label: Label = %WeatherLabel
@onready var season_label: Label = %SeasonLabel
@onready var quest_tracker: VBoxContainer = %QuestTracker
@onready var shortcut_bar: HBoxContainer = %ShortcutBar

var current_area: WorldArea = null
var npc_instances: Dictionary = {}
var move_target: Vector2 = Vector2.ZERO
var is_moving: bool = false
var move_speed: float = 300.0

func _ready():
	_setup_input()
	_load_current_area()
	_setup_shortcuts()
	
	TimeManager.get_instance().connect("day_changed", _on_day_changed)
	TimeManager.get_instance().connect("weather_changed", _on_weather_changed)
	TimeManager.get_instance().connect("season_changed", _on_season_changed)

func _setup_input():
	Input.map_action("move_up", KEY_W, KEY_UP)
	Input.map_action("move_down", KEY_S, KEY_DOWN)
	Input.map_action("move_left", KEY_A, KEY_LEFT)
	Input.map_action("move_right", KEY_D, KEY_RIGHT)
	Input.map_action("interact", KEY_E, KEY_SPACE)
	Input.map_action("menu", KEY_ESCAPE, KEY_TAB)
	Input.map_action("character", KEY_C)
	Input.map_action("inventory", KEY_I)
	Input.map_action("quest", KEY_Q)
	Input.map_action("map", KEY_M)

func _setup_shortcuts():
	var shortcuts = [
		{"key": "1", "action": "character", "icon": "res://src/assets/ui/icons/character.png"},
		{"key": "2", "action": "inventory", "icon": "res://src/assets/ui/icons/inventory.png"},
		{"key": "3", "action": "quest", "icon": "res://src/assets/ui/icons/quest.png"},
		{"key": "4", "action": "map", "icon": "res://src/assets/ui/icons/map.png"},
		{"key": "5", "action": "settings", "icon": "res://src/assets/ui/icons/settings.png"},
	]
	
	for sc in shortcuts:
		var btn = Button.new()
		btn.text = sc["key"]
		btn.tooltip_text = sc["action"]
		btn.custom_minimum_size = Vector2(50, 50)
		btn.pressed.connect(_on_shortcut_pressed.bind(sc["action"]))
		shortcut_bar.add_child(btn)

func _on_shortcut_pressed(action: String):
	match action:
		"character": UIManager.get_instance().toggle_ui("character")
		"inventory": UIManager.get_instance().toggle_ui("inventory")
		"quest": UIManager.get_instance().toggle_ui("quest")
		"map": UIManager.get_instance().toggle_ui("world_map")
		"settings": UIManager.get_instance().toggle_ui("settings")

func _load_current_area():
	var area_id = WorldManager.get_instance().current_area
	if area_id != "":
		_enter_area(area_id)

func _enter_area(area_id: String):
	var area = WorldManager.get_instance().get_area(area_id)
	if not area:
		return
	
	current_area = area
	WorldManager.get_instance().travel_to(area_id)
	
	# 更新UI
	current_area_label.text = "当前地点: %s" % area.name
	
	# 加载区域背景
	if area.background_image != "":
		# 这里应该设置背景
		pass
	
	# 播放背景音乐
	if area.background_music != "":
		AudioManager.get_instance().play_bgm(area.background_music)
	
	# 生成NPC
	_spawn_npcs()
	
	# 检查随机奇遇
	_check_random_encounter()

func _spawn_npcs():
	if not current_area:
		return
	
	for npc_id in current_area.npcs:
		var npc_data = StoryDatabase.get_instance().get_npc(npc_id)
		if not npc_data:
			continue
		
		# 实例化NPC
		var npc_scene = preload("res://src/scenes/world/npc.tscn")
		var npc = npc_scene.instantiate()
		npc.set_npc_data(npc_data)
		
		# 设置位置（简化处理）
		var spawn_pos = Vector2(randf_range(100, 800), randf_range(100, 500))
		npc.global_position = spawn_pos
		
		add_child(npc)
		npc_instances[npc_id] = npc
		
		# 连接交互信号
		npc.interacted.connect(_on_npc_interacted.bind(npc_id))

func _check_random_encounter():
	var encounter = StoryDatabase.get_instance().get_random_encounter(current_area.id, TimeManager.get_instance().get_time_of_day())
	if encounter:
		UIManager.get_instance().show_notification("触发奇遇: %s" % encounter.name, "info")
		# 显示奇遇对话
		_trigger_encounter(encounter)

func _trigger_encounter(quest: Quest):
	var dialogue = StoryDatabase.get_instance().get_dialogue("dialogue_%s" % quest.id)
	if dialogue:
		UIManager.get_instance().show_dialogue(dialogue.speaker, dialogue.text, dialogue.choices, dialogue.portrait)

func _on_npc_interacted(npc_id: String):
	var npc_data = StoryDatabase.get_instance().get_npc(npc_id)
	if not npc_data:
		return
	
	# 显示对话选项
	var choices = [
		{"text": "对话", "action": "dialogue"},
		{"text": "送礼", "action": "gift"},
		{"text": "任务", "action": "quest"},
	]
	if npc_data.recruitable and not npc_data.recruited:
		choices.append({"text": "招募", "action": "recruit"})
	if npc_data.shop_id != "":
		choices.append({"text": "商店", "action": "shop"})
	
	UIManager.get_instance().show_dialogue(npc_data.name, "你好，少侠。有什么我能帮你的吗？", choices, npc_data.portrait_path)

func _on_npc_choice_selected(choice: Dictionary):
	match choice["action"]:
		"dialogue":
			_show_npc_dialogue(choice["npc_id"])
		"gift":
			UIManager.get_instance().open_ui("gift")
		"quest":
			UIManager.get_instance().open_ui("quest")
		"recruit":
			_recruit_npc(choice["npc_id"])
		"shop":
			UIManager.get_instance().open_ui("shop")

func _show_npc_dialogue(npc_id: String):
	var npc_data = StoryDatabase.get_instance().get_npc(npc_id)
	if not npc_data:
		return
	
	var dialogue_id = npc_data.dialogue_ids[0] if npc_data.dialogue_ids.size() > 0 else ""
	if dialogue_id != "":
		var dialogue = StoryDatabase.get_instance().get_dialogue(dialogue_id)
		if dialogue:
			UIManager.get_instance().show_dialogue(dialogue.speaker, dialogue.text, dialogue.choices, dialogue.portrait)

func _recruit_npc(npc_id: String):
	var npc_data = StoryDatabase.get_instance().get_npc(npc_id)
	if not npc_data or not npc_data.recruitable:
		return
	
	var char_db = CharacterDatabase.get_instance()
	var companion = char_db.get_character(npc_id)
	if companion:
		PlayerData.get_instance().add_companion(companion)
		npc_data.recruited = true
		UIManager.get_instance().show_notification("成功招募 %s" % npc_data.name, "success")

func _process(delta: float):
	_update_time_display()
	_handle_movement(delta)
	_check_interactions()

func _update_time_display():
	var time_mgr = TimeManager.get_instance()
	time_label.text = time_mgr.get_time_string()
	weather_label.text = "天气: %s" % time_mgr.get_weather()
	season_label.text = "季节: %s" % time_mgr.get_season()

func _handle_movement(delta: float):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	velocity = velocity.normalized() * move_speed
	player.velocity = velocity
	player.move_and_slide()
	
	# 更新摄像机跟随
	camera.global_position = player.global_position

func _check_interactions():
	if Input.is_action_just_pressed("interact"):
		# 检查附近可交互对象
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(player.global_position, player.global_position + Vector2(50, 0))
		var result = space_state.intersect_ray(query)
		
		if result:
			var collider = result.collider
			if collider and collider.has_method("interact"):
				collider.interact()

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if UIManager.get_instance().get_open_ui_count() > 0:
				UIManager.get_instance().close_top_ui()
			else:
				UIManager.get_instance().toggle_ui("settings")
		elif event.keycode == KEY_C and event.pressed:
			UIManager.get_instance().toggle_ui("character")
		elif event.keycode == KEY_I and event.pressed:
			UIManager.get_instance().toggle_ui("inventory")
		elif event.keycode == KEY_Q and event.pressed:
			UIManager.get_instance().toggle_ui("quest")
		elif event.keycode == KEY_M and event.pressed:
			UIManager.get_instance().toggle_ui("world_map")

func _on_day_changed(date: Dictionary):
	PlayerData.get_instance().daily_login()
	UIManager.get_instance().show_notification("新的一天开始了！", "info")

func _on_weather_changed(weather: String):
	UIManager.get_instance().show_notification("天气变为: %s" % weather, "info")

func _on_season_changed(season: String):
	UIManager.get_instance().show_notification("季节更替: %s" % season, "info")

func _on_area_changed(area_id: String):
	_enter_area(area_id)