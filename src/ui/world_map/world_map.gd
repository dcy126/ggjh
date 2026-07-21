extends Control
class_name WorldMapUI

@onready var map_viewport: SubViewport = %MapViewport
@onready var map_container: TextureRect = %MapContainer
@onready var area_list: ItemList = %AreaList
@onready var area_info: RichTextLabel = %AreaInfo
@onready var btn_travel: Button = %BtnTravel
@onready var btn_explore: Button = %BtnExplore
@onready var current_location_label: Label = %CurrentLocationLabel

@onready var mini_map: TextureRect = %MiniMap
@onready var player_marker: TextureRect = %PlayerMarker

var areas: Array[WorldArea] = []
var selected_area: WorldArea = null
var current_area_id: String = ""

func _ready():
	area_list.item_selected.connect(_on_area_selected)
	btn_travel.pressed.connect(_on_travel_pressed)
	btn_explore.pressed.connect(_on_explore_pressed)
	
	_load_areas()
	_update_current_location()

func _load_areas():
	areas = WorldManager.get_instance().get_all_areas()
	area_list.clear()
	
	for area in areas:
		var visited = WorldManager.get_instance().visited_areas.has(area.id)
		var item_text = "%s%s" % [area.name, visited ? "" : " (未探索)"]
		var index = area_list.add_item(item_text)
		area_list.set_item_metadata(index, area)
		
		if area.id == current_area_id:
			area_list.select(index)
			selected_area = area

func _update_current_location():
	current_area_id = PlayerData.get_instance().current_area
	var area = WorldManager.get_instance().get_area(current_area_id)
	if area:
		current_location_label.text = "当前位置: %s" % area.name
		_update_mini_map(area)

func _update_mini_map(area: WorldArea):
	# 更新小地图显示玩家位置
	pass

func _on_area_selected(index: int):
	selected_area = area_list.get_item_metadata(index)
	if not selected_area:
		return
	
	_show_area_info(selected_area)
	btn_travel.disabled = selected_area.id == current_area_id
	btn_explore.disabled = false

func _show_area_info(area: WorldArea):
	var info = ""
	info += "[color=#ffff00]%s[/color]\n" % area.name
	info += "[color=#ffffff]%s[/color]\n\n" % area.description
	info += "类型: %s\n" % area.type
	info += "推荐等级: %d-%d\n" % [area.level_range.x, area.level_range.y]
	info += "状态: %s\n\n" % [WorldManager.get_instance().visited_areas.has(area.id) ? "已探索" : "未探索"]
	
	if area.features.size() > 0:
		info += "[color=#ffff00]特色:[/color]\n"
		for feature in area.features:
			info += "  • %s\n" % feature
		info += "\n"
	
	if area.shops.size() > 0:
		info += "[color=#ffff00]商店:[/color]\n"
		for shop in area.shops:
			info += "  • %s\n" % shop
		info += "\n"
	
	if area.dungeons.size() > 0:
		info += "[color=#ffff00]副本:[/color]\n"
		for dungeon in area.dungeons:
			info += "  • %s\n" % dungeon
		info += "\n"
	
	if area.events.size() > 0:
		info += "[color=#ffff00]事件:[/color]\n"
		for event in area.events:
			info += "  • %s\n" % event
	
	area_info.text = info

func _on_travel_pressed():
	if not selected_area or selected_area.id == current_area_id:
		return
	
	if WorldManager.get_instance().can_travel_to(current_area_id, selected_area.id):
		WorldManager.get_instance().travel_to(selected_area.id)
		current_area_id = selected_area.id
		PlayerData.get_instance().set_current_area(selected_area.id)
		_update_current_location()
		_load_areas()
		UIManager.get_instance().show_notification("已前往 %s" % selected_area.name, "success")
	else:
		UIManager.get_instance().show_notification("无法前往该地点", "warning")

func _on_explore_pressed():
	if not selected_area:
		return
	
	# 进入探索模式
	UIManager.get_instance().show_loading("正在进入 %s..." % selected_area.name)
	
	# 这里应该加载探索场景
	# 暂时模拟探索结果
	var events = WorldManager.get_instance().get_area_events(selected_area.id)
	if events.size() > 0:
		var event = events[randi() % events.size()]
		UIManager.get_instance().show_notification("触发事件: %s" % event.name, "info")
	
	# 探索奖励
	var exp_gain = randi_range(500, 2000)
	var copper_gain = randi_range(1000, 5000)
	PlayerData.get_instance().gain_exp(exp_gain)
	PlayerData.get_instance().gain_copper(copper_gain)
	
	WorldManager.get_instance().travel_to(selected_area.id)
	PlayerData.get_instance().record_visit(selected_area.id)
	
	UIManager.get_instance().show_notification("探索完成! 经验+%d 铜钱+%d" % [exp_gain, copper_gain], "success")
	_update_current_location()
	_load_areas()