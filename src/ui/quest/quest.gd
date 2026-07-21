extends Control
class_name QuestUI

@onready var quest_tabs: TabContainer = %QuestTabs
@onready var active_tab: Control = %ActiveTab
@onready var completed_tab: Control = %CompletedTab
@onready var daily_tab: Control = %DailyTab
@onready var weekly_tab: Control = %WeeklyTab

@onready var active_quest_list: ItemList = %ActiveQuestList
@onready var active_quest_detail: RichTextLabel = %ActiveQuestDetail
@onready var btn_track: Button = %BtnTrack
@onready var btn_abandon: Button = %BtnAbandon

@onready var completed_quest_list: ItemList = %CompletedQuestList
@onready var completed_quest_detail: RichTextLabel = %CompletedQuestDetail

@onready var daily_quest_list: ItemList = %DailyQuestList
@onready var daily_quest_detail: RichTextLabel = %DailyQuestDetail
@onready var daily_progress: ProgressBar = %DailyProgress

@onready var weekly_quest_list: ItemList = %WeeklyQuestList
@onready var weekly_quest_detail: RichTextLabel = %WeeklyQuestDetail
@onready var weekly_progress: ProgressBar = %WeeklyProgress

func _ready():
	active_quest_list.item_selected.connect(_on_active_selected)
	completed_quest_list.item_selected.connect(_on_completed_selected)
	daily_quest_list.item_selected.connect(_on_daily_selected)
	weekly_quest_list.item_selected.connect(_on_weekly_selected)
	btn_track.pressed.connect(_on_track_pressed)
	btn_abandon.pressed.connect(_on_abandon_pressed)
	
	_refresh_all()

func _refresh_all():
	_refresh_active()
	_refresh_completed()
	_refresh_daily()
	_refresh_weekly()

func _refresh_active():
	active_quest_list.clear()
	for quest in PlayerData.get_instance().active_quests:
		var progress_text = ""
		var obj = quest.get_current_objective()
		if obj:
			var completed = obj.get("completed", false)
			progress_text = " [%s]" % [completed ? "完成" : "进行中"]
		
		var index = active_quest_list.add_item("%s%s" % [quest.name, progress_text])
		active_quest_list.set_item_metadata(index, quest)

func _on_active_selected(index: int):
	var quest = active_quest_list.get_item_metadata(index)
	if quest:
		var detail = ""
		detail += "[color=#ffff00]%s[/color]\n" % quest.name
		detail += "[color=#ffffff]类型:[/color] %s\n" % quest.type
		detail += "[color=#ffffff]章节:[/color] %d\n" % quest.chapter
		detail += "[color=#ffffff]描述:[/color] %s\n\n" % quest.description
		
		detail += "[color=#ffff00]目标:[/color]\n"
		for obj in quest.objectives:
			var status = obj.get("completed", false) ? "[color=green]✓[/color]" : "[color=yellow]○[/color]"
			detail += "  %s %s\n" % [status, obj.get("description", "")]
		
		detail += "\n[color=#ffff00]奖励:[/color]\n"
		for key in quest.rewards:
			detail += "  %s: %s\n" % [key, quest.rewards[key]]
		
		active_quest_detail.text = detail
		btn_abandon.disabled = quest.type == "主线"

func _on_track_pressed():
	var index = active_quest_list.get_selected_items()
	if index.size() > 0:
		var quest = active_quest_list.get_item_metadata(index[0])
		UIManager.get_instance().show_notification("已追踪: %s" % quest.name, "success")

func _on_abandon_pressed():
	var index = active_quest_list.get_selected_items()
	if index.size() > 0:
		var quest = active_quest_list.get_item_metadata(index[0])
		if quest.type != "主线":
			PlayerData.get_instance().active_quests.erase(quest)
			_refresh_active()
			UIManager.get_instance().show_notification("已放弃: %s" % quest.name, "info")

func _refresh_completed():
	completed_quest_list.clear()
	for quest_id in PlayerData.get_instance().completed_quests:
		var quest = StoryDatabase.get_instance().get_quest(quest_id)
		if quest:
			var index = completed_quest_list.add_item(quest.name)
			completed_quest_list.set_item_metadata(index, quest)

func _on_completed_selected(index: int):
	var quest = completed_quest_list.get_item_metadata(index)
	if quest:
		var detail = ""
		detail += "[color=#ffff00]%s[/color] [color=green](已完成)[/color]\n" % quest.name
		detail += "[color=#ffffff]类型:[/color] %s\n" % quest.type
		detail += "[color=#ffffff]章节:[/color] %d\n\n" % quest.chapter
		detail += "[color=#ffffff]描述:[/color] %s\n\n" % quest.description
		
		detail += "[color=#ffff00]奖励:[/color]\n"
		for key in quest.rewards:
			detail += "  %s: %s\n" % [key, quest.rewards[key]]
		
		completed_quest_detail.text = detail

func _refresh_daily():
	daily_quest_list.clear()
	var dailies = _get_daily_quests()
	var completed = 0
	
	for quest in dailies:
		var is_completed = quest.id in PlayerData.get_instance().daily_tasks_completed
		if is_completed:
			completed += 1
		
		var status = is_completed ? "[green]✓[/color]" : "[yellow]○[/color]"
		var index = daily_quest_list.add_item("%s %s" % [status, quest.name])
		daily_quest_list.set_item_metadata(index, quest)
		if is_completed:
			daily_quest_list.set_item_custom_fg_color(index, Color(0, 1, 0))
	
	daily_progress.max_value = dailies.size()
	daily_progress.value = completed

func _get_daily_quests() -> Array[Quest]:
	var dailies = []
	var quest_db = StoryDatabase.get_instance()
	
	# 获取每日任务
	var all_quests = quest_db.get_quests_by_type("每日")
	for quest in all_quests:
		dailies.append(quest)
	
	# 如果不够，生成一些默认每日任务
	while dailies.size() < 5:
		var q = Quest.new()
		q.id = "daily_%d" % randi()
		q.name = "每日任务 %d" % (dailies.size() + 1)
		q.description = "完成每日活动获得奖励"
		q.type = "每日"
		q.objectives = [{"description": "完成指定活动", "count": randi_range(1, 5), "completed": false}]
		q.rewards = {"exp": 5000, "copper": 10000}
		dailies.append(q)
	
	return dailies

func _on_daily_selected(index: int):
	var quest = daily_quest_list.get_item_metadata(index)
	if quest:
		var detail = ""
		detail += "[color=#ffff00]%s[/color] %s\n" % [quest.name, quest.id in PlayerData.get_instance().daily_tasks_completed ? "[green](已完成)[/color]" : ""]
		detail += "[color=#ffffff]描述:[/color] %s\n\n" % quest.description
		
		detail += "[color=#ffff00]目标:[/color]\n"
		for obj in quest.objectives:
			var status = obj.get("completed", false) ? "[green]✓[/color]" : "[yellow]○[/color]"
			detail += "  %s %s\n" % [status, obj.get("description", "")]
		
		detail += "\n[color=#ffff00]奖励:[/color]\n"
		for key in quest.rewards:
			detail += "  %s: %s\n" % [key, quest.rewards[key]]
		
		daily_quest_detail.text = detail

func _refresh_weekly():
	weekly_quest_list.clear()
	var weeklies = _get_weekly_quests()
	var completed = 0
	
	for quest in weeklies:
		var is_completed = quest.id in PlayerData.get_instance().weekly_tasks_completed
		if is_completed:
			completed += 1
		
		var status = is_completed ? "[green]✓[/color]" : "[yellow]○[/color]"
		var index = weekly_quest_list.add_item("%s %s" % [status, quest.name])
		weekly_quest_list.set_item_metadata(index, quest)
		if is_completed:
			weekly_quest_list.set_item_custom_fg_color(index, Color(0, 1, 0))
	
	weekly_progress.max_value = weeklies.size()
	weekly_progress.value = completed

func _get_weekly_quests() -> Array[Quest]:
	var weeklies = []
	var quest_db = StoryDatabase.get_instance()
	
	var all_quests = quest_db.get_quests_by_type("每周")
	for quest in all_quests:
		weeklies.append(quest)
	
	while weeklies.size() < 3:
		var q = Quest.new()
		q.id = "weekly_%d" % randi()
		q.name = "周常任务 %d" % (weeklies.size() + 1)
		q.description = "完成周常活动获得丰厚奖励"
		q.type = "每周"
		q.objectives = [{"description": "完成指定活动", "count": randi_range(3, 10), "completed": false}]
		q.rewards = {"exp": 20000, "copper": 50000, "gold": 50}
		weeklies.append(q)
	
	return weeklies

func _on_weekly_selected(index: int):
	var quest = weekly_quest_list.get_item_metadata(index)
	if quest:
		var detail = ""
		detail += "[color=#ffff00]%s[/color] %s\n" % [quest.name, quest.id in PlayerData.get_instance().weekly_tasks_completed ? "[green](已完成)[/color]" : ""]
		detail += "[color=#ffffff]描述:[/color] %s\n\n" % quest.description
		
		detail += "[color=#ffff00]目标:[/color]\n"
		for obj in quest.objectives:
			var status = obj.get("completed", false) ? "[green]✓[/color]" : "[yellow]○[/color]"
			detail += "  %s %s\n" % [status, obj.get("description", "")]
		
		detail += "\n[color=#ffff00]奖励:[/color]\n"
		for key in quest.rewards:
			detail += "  %s: %s\n" % [key, quest.rewards[key]]
		
		weekly_quest_detail.text = detail