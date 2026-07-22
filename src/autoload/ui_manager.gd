extends Node
class_name UIManager

var current_scene: Node = null
var ui_stack: Array[Node] = []
var overlays: Array[Node] = []
var is_ui_locked: bool = false

var main_ui: Control = null
var battle_ui: Control = null
var character_panel: Control = null
var wuxue_panel: Control = null
var xinfa_panel: Control = null
var equipment_panel: Control = null
var sect_panel: Control = null
var pvp_panel: Control = null
var guild_panel: Control = null
var character_customization_ui: Control = null
var world_map_ui: Control = null
var dialogue_ui: Control = null
var quest_ui: Control = null
var inventory_ui: Control = null
var shop_ui: Control = null
var settings_ui: Control = null
var loading_ui: Control = null
var notification_ui: Control = null
var tooltip_ui: Control = null
var context_menu_ui: Control = null

static var instance = null

static func get_instance():
	return instance

signal ui_opened(ui_name: String)
signal ui_closed(ui_name: String)
signal ui_switched(from_ui: String, to_ui: String)

func _enter_tree():
	instance = self
	_preload_ui_scenes()

func _preload_ui_scenes():
	# 预加载UI场景
	pass

func setup_main_ui(main_ui_node: Control):
	main_ui = main_ui_node
	main_ui.visible = true

func open_ui(ui_name: String) -> Control:
	if is_ui_locked:
		return null
	
	var ui = _get_ui_by_name(ui_name)
	if not ui:
		ui = _load_ui_scene(ui_name)
		if not ui:
			return null
	
	if ui.visible:
		return ui
	
	ui.visible = true
	ui_stack.append(ui)
	_play_open_animation(ui)
	
	ui_opened.emit(ui_name)
	EventManager.instance.emit("ui_opened", ui_name)
	
	return ui

func close_ui(ui_name: String) -> bool:
	var ui = _get_ui_by_name(ui_name)
	if not ui or not ui.visible:
		return false
	
	_play_close_animation(ui, Callable(self, "_on_ui_close_finished").bind(ui_name))
	return true

func _on_ui_close_finished(ui_name: String):
	var ui = _get_ui_by_name(ui_name)
	if ui:
		ui.visible = false
		ui_stack.erase(ui)
		ui_closed.emit(ui_name)
		EventManager.instance.emit("ui_closed", ui_name)

func close_top_ui() -> bool:
	if ui_stack.is_empty():
		return false
	return close_ui(ui_stack[-1].name)

func close_all_ui():
	while not ui_stack.is_empty():
		close_ui(ui_stack[-1].name)

func switch_ui(from_ui: String, to_ui: String) -> Control:
	close_ui(from_ui)
	return open_ui(to_ui)

func toggle_ui(ui_name: String) -> bool:
	var ui = _get_ui_by_name(ui_name)
	if not ui:
		return false
	
	if ui.visible:
		close_ui(ui_name)
		return false
	else:
		open_ui(ui_name)
		return true

func is_ui_open(ui_name: String) -> bool:
	var ui = _get_ui_by_name(ui_name)
	return ui and ui.visible

func get_open_ui_count() -> int:
	var count = 0
	for ui in ui_stack:
		if ui.visible:
			count += 1
	return count

func get_top_ui() -> Control:
	if ui_stack.is_empty():
		return null
	return ui_stack[-1]

func add_overlay(overlay: Control):
	overlays.append(overlay)
	get_tree().root.add_child(overlay)
	overlay.visible = true

func remove_overlay(overlay: Control):
	overlays.erase(overlay)
	overlay.queue_free()

func clear_overlays():
	for overlay in overlays:
		overlay.queue_free()
	overlays.clear()

func lock_ui():
	is_ui_locked = true

func unlock_ui():
	is_ui_locked = false

func show_notification(message: String, type: String = "info", duration: float = 3.0):
	if not notification_ui:
		notification_ui = _load_ui_scene("notification")
		if not notification_ui:
			return
	
	notification_ui.show_notification(message, type, duration)

func show_tooltip(text: String, position: Vector2 = Vector2(0, 0)):
	if not tooltip_ui:
		tooltip_ui = _load_ui_scene("tooltip")
		if not tooltip_ui:
			return
	
	tooltip_ui.show_tooltip(text, position)

func hide_tooltip():
	if tooltip_ui and tooltip_ui.visible:
		tooltip_ui.hide_tooltip()

func show_context_menu(items: Array[Dictionary], position: Vector2):
	if not context_menu_ui:
		context_menu_ui = _load_ui_scene("context_menu")
		if not context_menu_ui:
			return
	
	context_menu_ui.show_menu(items, position)

func hide_context_menu():
	if context_menu_ui and context_menu_ui.visible:
		context_menu_ui.hide_menu()

func show_loading(text: String = "加载中..."):
	if not loading_ui:
		loading_ui = _load_ui_scene("loading")
		if not loading_ui:
			return
	
	loading_ui.show_loading(text)

func hide_loading():
	if loading_ui and loading_ui.visible:
		loading_ui.hide_loading()

func show_dialogue(speaker: String, text: String, choices: Array[Dictionary] = [], portrait: String = "") -> DialogueUI:
	if not dialogue_ui:
		dialogue_ui = _load_ui_scene("dialogue")
		if not dialogue_ui:
			return null
	
	dialogue_ui.show_dialogue(speaker, text, choices, portrait)
	return dialogue_ui

func hide_dialogue():
	if dialogue_ui and dialogue_ui.visible:
		dialogue_ui.hide_dialogue()

func get_ui_by_name(ui_name: String) -> Control:
	return _get_ui_by_name(ui_name)

func _get_ui_by_name(ui_name: String) -> Control:
	match ui_name:
		"main": return main_ui
		"battle": return battle_ui
		"character": return character_panel
		"wuxue": return wuxue_panel
		"xinfa": return xinfa_panel
		"equipment": return equipment_panel
		"sect": return sect_panel
		"pvp": return pvp_panel
		"guild": return guild_panel
		"customization": return character_customization_ui
		"world_map": return world_map_ui
		"dialogue": return dialogue_ui
		"quest": return quest_ui
		"inventory": return inventory_ui
		"shop": return shop_ui
		"settings": return settings_ui
		"loading": return loading_ui
		"notification": return notification_ui
		"tooltip": return tooltip_ui
		"context_menu": return context_menu_ui
	return null

func _load_ui_scene(ui_name: String) -> Control:
	var scene_paths = {
		"main": "res://src/scenes/main_menu/main_menu.tscn",
		"battle": "res://src/scenes/battle/battle_ui.tscn",
		"character": "res://src/ui/character_panel/character_panel.tscn",
		"wuxue": "res://src/ui/wuxin_panel/wuxin_panel.tscn",
		"xinfa": "res://src/ui/xinfa_panel/xinfa_panel.tscn",
		"equipment": "res://src/ui/equipment_panel/equipment_panel.tscn",
		"sect": "res://src/ui/sect_panel/sect_panel.tscn",
		"pvp": "res://src/ui/pvp_panel/pvp_panel.tscn",
		"guild": "res://src/ui/guild_panel/guild_panel.tscn",
		"customization": "res://src/ui/character_customization/character_customization.tscn",
		"world_map": "res://src/scenes/world/world_map_ui.tscn",
		"dialogue": "res://src/ui/dialogue/dialogue_ui.tscn",
		"quest": "res://src/ui/quest/quest_ui.tscn",
		"inventory": "res://src/ui/inventory/inventory_ui.tscn",
		"shop": "res://src/ui/shop/shop_ui.tscn",
		"settings": "res://src/ui/settings/settings_ui.tscn",
		"loading": "res://src/ui/loading/loading_ui.tscn",
		"notification": "res://src/ui/notification/notification_ui.tscn",
		"tooltip": "res://src/ui/tooltip/tooltip_ui.tscn",
		"context_menu": "res://src/ui/context_menu/context_menu_ui.tscn"
	}
	
	var path = scene_paths.get(ui_name)
	if not path:
		print("UI scene not found: ", ui_name)
		return null
	
	var scene = load(path)
	if not scene:
		print("Failed to load UI scene: ", path)
		return null
	
	var instance = scene.instantiate()
	instance.name = ui_name
	instance.visible = false
	
	get_tree().root.add_child(instance)
	
	# 缓存到对应变量
	match ui_name:
		"main": main_ui = instance
		"battle": battle_ui = instance
		"character": character_panel = instance
		"wuxue": wuxue_panel = instance
		"xinfa": xinfa_panel = instance
		"equipment": equipment_panel = instance
		"sect": sect_panel = instance
		"pvp": pvp_panel = instance
		"guild": guild_panel = instance
		"customization": character_customization_ui = instance
		"world_map": world_map_ui = instance
		"dialogue": dialogue_ui = instance
		"quest": quest_ui = instance
		"inventory": inventory_ui = instance
		"shop": shop_ui = instance
		"settings": settings_ui = instance
		"loading": loading_ui = instance
		"notification": notification_ui = instance
		"tooltip": tooltip_ui = instance
		"context_menu": context_menu_ui = instance
	
	return instance

func _play_open_animation(ui: Control):
	# 简单的淡入动画
	ui.modulate.a = 0.0
	var tween = ui.create_tween()
	tween.tween_property(ui, "modulate:a", 1.0, 0.2)

func _play_close_animation(ui: Control, callback: Callable):
	var tween = ui.create_tween()
	tween.tween_property(ui, "modulate:a", 0.0, 0.15)
	tween.tween_callback(callback)

func handle_input(event: InputEvent) -> bool:
	# 优先处理顶层UI的输入
	for i in range(ui_stack.size() - 1, -1, -1):
		var ui = ui_stack[i]
		if ui.visible and ui.has_method("_handle_input"):
			if ui._handle_input(event):
				return true
	
	return false

func on_resolution_changed():
	for ui in ui_stack:
		if ui.has_method("_on_resolution_changed"):
			ui._on_resolution_changed()
	
	for overlay in overlays:
		if overlay.has_method("_on_resolution_changed"):
			overlay._on_resolution_changed()

func to_dict() -> Dictionary:
	var visible_ui_stack = []
	for ui in ui_stack:
		if ui.visible:
			visible_ui_stack.append(ui.name)
			
	var overlay_names = []
	for o in overlays:
		overlay_names.append(o.name)
		
	return {
		"ui_stack": visible_ui_stack,
		"overlays": overlay_names
	}

func from_dict(data: Dictionary):
	for ui_name in data.get("ui_stack", []):
		open_ui(ui_name)
