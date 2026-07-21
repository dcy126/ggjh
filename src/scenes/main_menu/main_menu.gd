extends Control

@onready var start_btn = $VBoxContainer/StartButton
@onready var continue_btn = $VBoxContainer/ContinueButton
@onready var settings_btn = $VBoxContainer/SettingsButton
@onready var quit_btn = $VBoxContainer/QuitButton
@onready var logo = $Logo
@onready var version_label = $VersionLabel

func _ready():
	start_btn.pressed.connect(_on_start_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	var save_mgr = SaveManager.get_instance()
	var latest = save_mgr.get_latest_save()
	continue_btn.disabled = latest == 0
	
	version_label.text = "版本 %s" % GameData.get_instance().game_version
	
	# 播放主菜单音乐
	AudioManager.get_instance().play_bgm("main_menu")
	
	# 播放Logo动画
	_play_logo_animation()

func _play_logo_animation():
	logo.modulate.a = 0.0
	var tween = logo.create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_start_pressed():
	# 创建新游戏
	UIManager.get_instance().show_loading("正在创建新游戏...")
	
	var customization_ui = UIManager.get_instance().open_ui("customization")
	if customization_ui:
		customization_ui.on_create_complete.connect(_on_character_created)
	else:
		# 直接创建默认角色
		_create_default_character()

func _on_continue_pressed():
	var save_mgr = SaveManager.get_instance()
	var latest = save_mgr.get_latest_save()
	if latest > 0:
		UIManager.get_instance().show_loading("正在读取存档...")
		save_mgr.load_game(latest)
		get_tree().change_scene_to_file("res://src/scenes/world/world.tscn")

func _on_settings_pressed():
	UIManager.get_instance().open_ui("settings")

func _on_quit_pressed():
	get_tree().quit()

func _on_character_created(customization: CharacterCustomization):
	PlayerData.get_instance().create_new_player("主角", customization.face_data, customization.body_data, customization.voice_data)
	PlayerData.get_instance().protagonist.character_customization = customization
	
	get_tree().change_scene_to_file("res://src/scenes/world/world.tscn")

func _create_default_character():
	var customization = CharacterCustomization.new()
	customization.apply_preset("protagonist")
	PlayerData.get_instance().create_new_player("主角", customization.face_data, customization.body_data, customization.voice_data)
	PlayerData.get_instance().protagonist.character_customization = customization
	
	get_tree().change_scene_to_file("res://src/scenes/world/world.tscn")