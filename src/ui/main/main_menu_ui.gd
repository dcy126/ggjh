extends Control
class_name MainMenuUI

@onready var btn_new_game: Button = %BtnNewGame
@onready var btn_continue: Button = %BtnContinue
@onready var btn_settings: Button = %BtnSettings
@onready var btn_exit: Button = %BtnExit
@onready var version_label: Label = %VersionLabel
@onready var background: TextureRect = %Background
@onready var logo: TextureRect = %Logo
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready():
	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_continue.pressed.connect(_on_continue_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	var save_manager = SaveManager.get_instance()
	var latest = save_manager.get_latest_save()
	btn_continue.disabled = latest == 0
	
	version_label.text = "版本: %s" % GameData.get_instance().game_version
	
	if animation_player:
		animation_player.play("intro")

func _on_new_game_pressed():
	AudioManager.get_instance().play_sfx("confirm")
	UIManager.get_instance().open_ui("customization")

func _on_continue_pressed():
	AudioManager.get_instance().play_sfx("confirm")
	var save_manager = SaveManager.get_instance()
	var slot = save_manager.get_latest_save()
	if slot > 0:
		save_manager.load_game(slot)

func _on_settings_pressed():
	AudioManager.get_instance().play_sfx("click")
	UIManager.get_instance().open_ui("settings")

func _on_exit_pressed():
	AudioManager.get_instance().play_sfx("cancel")
	get_tree().quit()

func on_language_changed():
	version_label.text = "版本: %s" % GameData.get_instance().game_version
