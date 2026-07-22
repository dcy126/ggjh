extends Node
class_name PlayerData

var player_id: String = ""
var player_name: String = ""
var level: int = 1
var exp: int = 0
var exp_to_next_level: int = 100
var potential_level: int = 0
var potential_exp: int = 0
var potential_breakthrough: int = 0

var copper: int = 0
var gold: int = 0
var sect_contribution: int = 0
var guild_contribution: int = 0
var pvp_points: int = 0
var exploration_points: int = 0

var current_sect: String = ""
var sect_level: int = 0
var current_guild: String = ""
var guild_position: String = ""

var protagonist: CharacterData = null
var companions: Array[CharacterData] = []
var formation: Array[String] = []  # character_ids in formation order
var formation_name: String = "方阵"

var inventory: Dictionary = {}  # item_id -> count
var equipment_inventory: Array[EquipmentData] = []
var wuxue_inventory: Array[WuxueData] = []
var xinfa_inventory: Array[XinfaData] = []
var material_inventory: Dictionary = {}  # material_id -> count

var known_recipes: Array[String] = []
var completed_quests: Array[String] = []
var active_quests: Array[Quest] = []
var completed_chapters: Array[int] = []
var current_chapter: int = 1
var story_choices: Dictionary = {}  # choice_id -> choice_result

var unlocked_areas: Array[String] = ["hangzhou"]
var current_area: String = "hangzhou"
var visited_locations: Dictionary = {}

var pvp_rank: String = "青铜"
var pvp_rank_score: int = 0
var pvp_season: int = 1
var pvp_wins: int = 0
var pvp_losses: int = 0
var pvp_weekly_wins: int = 0

var guild_secret_realm_progress: Dictionary = {}
var liexing_tower_floor: int = 0
var haishi_shenlou_progress: Dictionary = {}

var character_customization: CharacterCustomization = null

var play_time: int = 0
var login_days: int = 0
var last_login_time: int = 0
var daily_tasks_completed: Array[String] = []
var weekly_tasks_completed: Array[String] = []
var achievements: Dictionary = {}

var settings: Dictionary = {}

static var instance = null

static func get_instance():
	return instance

func _enter_tree():
	instance = self
	_load_settings()

func _load_settings():
	settings = {
		"music_volume": 0.8,
		"sfx_volume": 0.8,
		"ui_volume": 0.8,
		"auto_battle": false,
		"battle_speed": 1.0,
		"skip_animations": false,
		"show_damage_numbers": true,
		"show_status_effects": true,
		"camera_shake": true,
		"language": "zh_CN",
		"graphics_quality": "high",
		"fullscreen": false,
		"vsync": true,
		"frame_rate_limit": 60
	}

func create_new_player(name: String, face_data: FaceData = null, body_data: BodyData = null, voice_data: VoiceData = null):
	player_id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
	player_name = name
	level = 1
	exp = 0
	exp_to_next_level = 100
	
	copper = 10000
	gold = 0
	
	# 创建主角
	var char_db = CharacterDatabase.instance
	protagonist = char_db.get_protagonist().duplicate()
	protagonist.potential_level = 1
	protagonist.potential_exp = 0
	protagonist.potential_breakthrough = 0
	protagonist.face_data = face_data or FaceData.new().randomize()
	protagonist.body_data = body_data or BodyData.new().randomize()
	protagonist.voice_data = voice_data or VoiceData.new().randomize()
	
	companions = [protagonist]
	formation = [protagonist.id]
	
	# 初始物品
	inventory = {
		"wooden_sword": 1,
		"cloth_clothes": 1,
		"hp_potion_small": 5,
		"mp_potion_small": 3
	}
	
	equipment_inventory = []
	wuxue_inventory = []
	xinfa_inventory = []
	material_inventory = {}
	
	known_recipes = []
	completed_quests = []
	active_quests = []
	completed_chapters = []
	current_chapter = 1
	story_choices = {}
	
	unlocked_areas = ["hangzhou"]
	current_area = "hangzhou"
	visited_locations = {}
	
	pvp_rank = "青铜"
	pvp_rank_score = 0
	pvp_season = 1
	pvp_wins = 0
	pvp_losses = 0
	pvp_weekly_wins = 0
	
	guild_secret_realm_progress = {}
	liexing_tower_floor = 0
	haishi_shenlou_progress = {}
	
	character_customization = CharacterCustomization.new()
	character_customization.face_data = protagonist.face_data
	character_customization.body_data = protagonist.body_data
	character_customization.voice_data = protagonist.voice_data
	
	play_time = 0
	login_days = 1
	last_login_time = Time.get_unix_time_from_system()
	daily_tasks_completed = []
	weekly_tasks_completed = []
	achievements = {}
	
	EventManager.instance.emit("player_created", player_id)

func gain_exp(amount: int):
	exp += amount
	while exp >= exp_to_next_level:
		level_up()

func level_up():
	level += 1
	exp -= exp_to_next_level
	exp_to_next_level = int(exp_to_next_level * 1.2)
	
	# 主角属性成长
	if protagonist:
		protagonist.potential_level += 1
		protagonist.potential_exp += 100
	
	EventManager.instance.emit("player_level_up", level)

func gain_copper(amount: int):
	copper += amount
	EventManager.instance.emit("currency_changed", "copper", copper)

func spend_copper(amount: int) -> bool:
	if copper >= amount:
		copper -= amount
		EventManager.instance.emit("currency_changed", "copper", copper)
		return true
	return false

func gain_gold(amount: int):
	gold += amount
	EventManager.instance.emit("currency_changed", "gold", gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		EventManager.instance.emit("currency_changed", "gold", gold)
		return true
	return false

func add_companion(character: CharacterData):
	if character not in companions:
		companions.append(character)
		EventManager.instance.emit("companion_added", character.id)

func remove_companion(character_id: String):
	companions.erase(character_id)
	if character_id in formation:
		formation.erase(character_id)
	EventManager.instance.emit("companion_removed", character_id)

func set_formation(new_formation: Array[String]):
	formation = new_formation
	EventManager.instance.emit("formation_changed", formation)

func add_item(item_id: String, count: int = 1):
	inventory[item_id] = inventory.get(item_id, 0) + count
	EventManager.instance.emit("item_added", item_id, count)

func remove_item(item_id: String, count: int = 1) -> bool:
	var current = inventory.get(item_id, 0)
	if current >= count:
		inventory[item_id] = current - count
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
		EventManager.instance.emit("item_removed", item_id, count)
		return true
	return false

func has_item(item_id: String, count: int = 1) -> bool:
	return inventory.get(item_id, 0) >= count

func add_equipment(equipment: EquipmentData):
	equipment_inventory.append(equipment)
	EventManager.instance.emit("equipment_added", equipment.id)

func remove_equipment(equipment_id: String) -> EquipmentData:
	for i in range(equipment_inventory.size()):
		if equipment_inventory[i].id == equipment_id:
			var item = equipment_inventory[i]
			equipment_inventory.remove_at(i)
			return item
	return null

func add_wuxue(wuxue: WuxueData):
	if wuxue not in wuxue_inventory:
		wuxue_inventory.append(wuxue)
		EventManager.instance.emit("wuxue_learned", wuxue.id)

func add_xinfa(xinfa: XinfaData):
	if xinfa not in xinfa_inventory:
		xinfa_inventory.append(xinfa)
		EventManager.instance.emit("xinfa_obtained", xinfa.id)

func add_material(material_id: String, count: int = 1):
	material_inventory[material_id] = material_inventory.get(material_id, 0) + count
	EventManager.instance.emit("material_added", material_id, count)

func learn_recipe(recipe_id: String):
	if recipe_id not in known_recipes:
		known_recipes.append(recipe_id)

func complete_quest(quest_id: String):
	if quest_id not in completed_quests:
		completed_quests.append(quest_id)
		
	# 从活跃任务中移除
	for i in range(active_quests.size()):
		if active_quests[i].id == quest_id:
			active_quests.remove_at(i)
			break
	
	EventManager.instance.emit("quest_completed", quest_id)

func accept_quest(quest: Quest):
	if quest not in active_quests:
		active_quests.append(quest)
		EventManager.instance.emit("quest_accepted", quest.id)

func make_story_choice(choice_id: String, result: Dictionary):
	story_choices[choice_id] = result
	EventManager.instance.emit("story_choice_made", choice_id, result)

func complete_chapter(chapter: int):
	if chapter not in completed_chapters:
		completed_chapters.append(chapter)
		if chapter >= current_chapter:
			current_chapter = chapter + 1
		EventManager.instance.emit("chapter_completed", chapter)

func unlock_area(area_id: String):
	if area_id not in unlocked_areas:
		unlocked_areas.append(area_id)
		EventManager.instance.emit("area_unlocked", area_id)

func set_current_area(area_id: String):
	current_area = area_id
	WorldManager.instance.travel_to(area_id)

func record_visit(location_id: String):
	visited_locations[location_id] = {"count": visited_locations.get(location_id, {"count": 0})["count"] + 1, "last_visit": Time.get_unix_time_from_system()}

func update_pvp_result(win: bool, score_change: int):
	if win:
		pvp_wins += 1
		pvp_weekly_wins += 1
	else:
		pvp_losses += 1
	
	pvp_rank_score = max(0, pvp_rank_score + score_change)
	_update_pvp_rank()
	EventManager.instance.emit("pvp_result", win, pvp_rank_score)

func _update_pvp_rank():
	var ranks = ["青铜", "白银", "黄金", "铂金", "钻石", "大师", "宗师", "王者", "传说"]
	var thresholds = [0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000]
	
	for i in range(ranks.size()):
		if pvp_rank_score < thresholds[i] or i == ranks.size() - 1:
			pvp_rank = ranks[i]
			break

func reset_weekly_pvp():
	pvp_weekly_wins = 0
	EventManager.instance.emit("pvp_weekly_reset")

func add_guild_contribution(amount: int):
	guild_contribution += amount
	EventManager.instance.emit("guild_contribution_changed", guild_contribution)

func add_sect_contribution(amount: int):
	sect_contribution += amount
	EventManager.instance.emit("sect_contribution_changed", sect_contribution)

func set_guild(guild_id: String, position: String = "成员"):
	current_guild = guild_id
	guild_position = position
	EventManager.instance.emit("guild_joined", guild_id, position)

func leave_guild():
	current_guild = ""
	guild_position = ""
	EventManager.instance.emit("guild_left")

func set_sect(sect_id: String):
	current_sect = sect_id
	sect_level = 1
	sect_contribution = 0
	if protagonist:
		protagonist.current_sect = sect_id
	EventManager.instance.emit("sect_joined", sect_id)

func leave_sect():
	current_sect = ""
	sect_level = 0
	sect_contribution = 0
	if protagonist:
		protagonist.current_sect = ""
	EventManager.instance.emit("sect_left")

func update_play_time(delta: int):
	play_time += delta

func daily_login():
	var now = Time.get_unix_time_from_system()
	var last = last_login_time
	
	# 检查是否跨天
	if now - last >= 86400:
		login_days += 1
		last_login_time = now
		daily_tasks_completed = []
		EventManager.instance.emit("daily_reset")
	elif now - last >= 604800:  # 跨周
		weekly_tasks_completed = []
		EventManager.instance.emit("weekly_reset")

func complete_daily_task(task_id: String):
	if task_id not in daily_tasks_completed:
		daily_tasks_completed.append(task_id)

func complete_weekly_task(task_id: String):
	if task_id not in weekly_tasks_completed:
		weekly_tasks_completed.append(task_id)

func unlock_achievement(achievement_id: String):
	if achievement_id not in achievements:
		achievements[achievement_id] = {"unlocked_time": Time.get_unix_time_from_system(), "progress": 100}
		EventManager.instance.emit("achievement_unlocked", achievement_id)

func update_achievement_progress(achievement_id: String, progress: int):
	if achievement_id in achievements:
		achievements[achievement_id]["progress"] = progress
	else:
		achievements[achievement_id] = {"unlocked_time": 0, "progress": progress}

func get_setting(key: String, default = null):
	return settings.get(key, default)

func set_setting(key: String, value):
	settings[key] = value
	EventManager.instance.emit("setting_changed", key, value)
	_save_settings()

func _save_settings():
	# 保存到本地配置文件
	var config = ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save("user://settings.cfg")

func to_dict() -> Dictionary:
	return {
		"player_id": player_id,
		"player_name": player_name,
		"level": level,
		"exp": exp,
		"potential_level": potential_level,
		"potential_exp": potential_exp,
		"potential_breakthrough": potential_breakthrough,
		"copper": copper,
		"gold": gold,
		"sect_contribution": sect_contribution,
		"guild_contribution": guild_contribution,
		"pvp_points": pvp_points,
		"current_sect": current_sect,
		"sect_level": sect_level,
		"current_guild": current_guild,
		"guild_position": guild_position,
		"protagonist": protagonist.to_dict() if protagonist else {},
		"companions": _companions_to_dict(),
		"formation": formation,
		"formation_name": formation_name,
		"inventory": inventory,
		"material_inventory": material_inventory,
		"known_recipes": known_recipes,
		"completed_quests": completed_quests,
		"active_quests": _active_quests_to_dict(),
		"completed_chapters": completed_chapters,
		"current_chapter": current_chapter,
		"story_choices": story_choices,
		"unlocked_areas": unlocked_areas,
		"current_area": current_area,
		"visited_locations": visited_locations,
		"pvp_rank": pvp_rank,
		"pvp_rank_score": pvp_rank_score,
		"pvp_season": pvp_season,
		"pvp_wins": pvp_wins,
		"pvp_losses": pvp_losses,
		"play_time": play_time,
		"login_days": login_days,
		"achievements": achievements,
		"settings": settings,
		"character_customization": character_customization.to_dict() if character_customization else {}
	}

func _companions_to_dict() -> Array:
	var result = []
	for c in companions:
		result.append(c.to_dict())
	return result

func _active_quests_to_dict() -> Array:
	var result = []
	for q in active_quests:
		result.append(q.id)
	return result

func from_dict(data: Dictionary):
	player_id = data.get("player_id", "")
	player_name = data.get("player_name", "")
	level = data.get("level", 1)
	exp = data.get("exp", 0)
	potential_level = data.get("potential_level", 0)
	potential_exp = data.get("potential_exp", 0)
	potential_breakthrough = data.get("potential_breakthrough", 0)
	copper = data.get("copper", 0)
	gold = data.get("gold", 0)
	sect_contribution = data.get("sect_contribution", 0)
	guild_contribution = data.get("guild_contribution", 0)
	pvp_points = data.get("pvp_points", 0)
	current_sect = data.get("current_sect", "")
	sect_level = data.get("sect_level", 0)
	current_guild = data.get("current_guild", "")
	guild_position = data.get("guild_position", "")
	
	if data.has("protagonist") and data["protagonist"]:
		protagonist = CharacterData.new().from_dict(data["protagonist"])
	
	companions = []
	for c_data in data.get("companions", []):
		var c = CharacterData.new().from_dict(c_data)
		companions.append(c)
	
	formation = data.get("formation", [])
	formation_name = data.get("formation_name", "方阵")
	inventory = data.get("inventory", {})
	material_inventory = data.get("material_inventory", {})
	known_recipes = data.get("known_recipes", [])
	completed_quests = data.get("completed_quests", [])
	active_quests = []
	for q_id in data.get("active_quests", []):
		var q = StoryDatabase.instance.get_quest(q_id)
		if q:
			active_quests.append(q)
	completed_chapters = data.get("completed_chapters", [])
	current_chapter = data.get("current_chapter", 1)
	story_choices = data.get("story_choices", {})
	unlocked_areas = data.get("unlocked_areas", ["hangzhou"])
	current_area = data.get("current_area", "hangzhou")
	visited_locations = data.get("visited_locations", {})
	pvp_rank = data.get("pvp_rank", "青铜")
	pvp_rank_score = data.get("pvp_rank_score", 0)
	pvp_season = data.get("pvp_season", 1)
	pvp_wins = data.get("pvp_wins", 0)
	pvp_losses = data.get("pvp_losses", 0)
	play_time = data.get("play_time", 0)
	login_days = data.get("login_days", 0)
	achievements = data.get("achievements", {})
	settings = data.get("settings", settings)
	
	if data.has("character_customization") and data["character_customization"]:
		character_customization = CharacterCustomization.new().from_dict(data["character_customization"])