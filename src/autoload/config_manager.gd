extends RefCounted
class_name ConfigManager

var config: Dictionary = {}
var config_path: String = "user://config.cfg"

static var instance: ConfigManager = null

func _init():
	instance = self
	_load_config()

func _load_config():
	var file = ConfigFile.new()
	var err = file.load(config_path)
	if err == OK:
		for section in file.get_sections():
			for key in file.get_section_keys(section):
				config["%s/%s" % [section, key]] = file.get_value(section, key)
	else:
		_set_defaults()

func _set_defaults():
	config = {
		"video/fullscreen": false,
		"video/vsync": true,
		"video/resolution_x": 1280,
		"video/resolution_y": 720,
		"video/borderless": false,
		"video/frame_rate_limit": 60,
		"video/graphics_quality": 2,
		"video/vsync_mode": 1,
		"audio/master_volume": 1.0,
		"audio/bgm_volume": 0.8,
		"audio/sfx_volume": 0.8,
		"audio/ui_volume": 0.8,
		"audio/voice_volume": 1.0,
		"gameplay/language": "zh_CN",
		"gameplay/auto_battle": false,
		"gameplay/battle_speed": 1.0,
		"gameplay/skip_animations": false,
		"gameplay/show_damage_numbers": true,
		"gameplay/show_status_effects": true,
		"gameplay/camera_shake": true,
		"gameplay/auto_save": true,
		"gameplay/auto_save_interval": 300,
		"controls/mouse_sensitivity": 1.0,
		"controls/invert_mouse_y": false,
		"controls/vibration": true,
		"controls/custom_keys": {},
		"ui/scale": 1.0,
		"ui/show_tooltips": true,
		"ui/tooltip_delay": 0.5,
		"ui/minimap_enabled": true,
		"ui/compact_mode": false,
		"network/region": "cn",
		"network/auto_login": false,
		"network/remember_account": false,
		"network/proxy_enabled": false,
		"network/proxy_address": "",
		"network/proxy_port": 0,
		"privacy/analytics": true,
		"privacy/crash_reporting": true,
		"privacy/share_usage_data": false,
		"accessibility/colorblind_mode": 0,
		"accessibility/high_contrast": false,
		"accessibility/large_text": false,
		"accessibility/reduce_motion": false,
		"accessibility/screen_reader": false
	}

func get(key: String, default = null):
	return config.get(key, default)

func set(key: String, value):
	if config.has(key) and config[key] == value:
		return
	
	config[key] = value
	_apply_setting(key, value)
	EventManager.get_instance().emit("config_changed", key, value)

func _apply_setting(key: String, value):
	match key:
		"video/fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
		"video/vsync":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
		"video/resolution_x", "video/resolution_y":
			var w = config.get("video/resolution_x", 1280)
			var h = config.get("video/resolution_y", 720)
			DisplayServer.window_set_size(Vector2i(w, h))
		"video/borderless":
			if value and not config.get("video/fullscreen", false):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_BORDERLESS)
		"video/frame_rate_limit":
			Engine.max_fps = value
		"video/graphics_quality":
			_apply_graphics_quality(value)
		"audio/master_volume":
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		"audio/bgm_volume":
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		"audio/sfx_volume":
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		"audio/ui_volume":
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(value))
		"audio/voice_volume":
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear_to_db(value))
		"gameplay/language":
			TranslationServer.set_locale(value)
		"ui/scale":
			_set_ui_scale(value)

func _apply_graphics_quality(quality: int):
	match quality:
		0: # 低
			RenderingServer.canvas_item_set_default_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
			RenderingServer.set_use_2d_aa(false)
		1: # 中
			RenderingServer.canvas_item_set_default_texture_filter(CanvasItem.TEXTURE_FILTER_LINEAR)
			RenderingServer.set_use_2d_aa(true)
			RenderingServer.set_aa_samples(2)
		2: # 高
			RenderingServer.canvas_item_set_default_texture_filter(CanvasItem.TEXTURE_FILTER_LINEAR)
			RenderingServer.set_use_2d_aa(true)
			RenderingServer.set_aa_samples(4)
		3: # 超高
			RenderingServer.canvas_item_set_default_texture_filter(CanvasItem.TEXTURE_FILTER_LINEAR)
			RenderingServer.set_use_2d_aa(true)
			RenderingServer.set_aa_samples(8)

func _set_ui_scale(scale: float):
	# 应用到UI层
	var canvas_layers = get_tree().get_nodes_in_group("UI_Layer")
	for layer in canvas_layers:
		if layer is CanvasLayer:
			layer.scale = Vector2(scale, scale)

func save():
	var file = ConfigFile.new()
	
	# 按section分组
	var sections = {}
	for full_key in config:
		var parts = full_key.split("/")
		if parts.size() == 2:
			var section = parts[0]
			var key = parts[1]
			if not sections.has(section):
				sections[section] = {}
			sections[section][key] = config[full_key]
	
	for section in sections:
		for key in sections[section]:
			file.set_value(section, key, sections[section][key])
	
	file.save(config_path)
	EventManager.get_instance().emit("config_saved")

func reset_to_defaults():
	_set_defaults()
	save()

func get_all() -> Dictionary:
	return config.duplicate()

func set_multiple(settings: Dictionary):
	for key in settings:
		set(key, settings[key])

func export_config(path: String) -> bool:
	var file = ConfigFile.new()
	var sections = {}
	for full_key in config:
		var parts = full_key.split("/")
		if parts.size() == 2:
			var section = parts[0]
			var key = parts[1]
			if not sections.has(section):
				sections[section] = {}
			sections[section][key] = config[full_key]
	
	for section in sections:
		for key in sections[section]:
			file.set_value(section, key, sections[section][key])
	
	return file.save(path) == OK

func import_config(path: String) -> bool:
	var file = ConfigFile.new()
	if file.load(path) != OK:
		return false
	
	for section in file.get_sections():
		for key in file.get_section_keys(section):
			var full_key = "%s/%s" % [section, key]
			if config.has(full_key):
				config[full_key] = file.get_value(section, key)
				_apply_setting(full_key, config[full_key])
	
	save()
	return true

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80.0
	return 20.0 * log10(linear)

func db_to_linear(db: float) -> float:
	if db <= -80.0:
		return 0.0
	return pow(10.0, db / 20.0)