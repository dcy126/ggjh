extends RefCounted
class_name EventManager

var event_listeners: Dictionary = {}
var event_queue: Array[Dictionary] = []
var is_processing: bool = false
var event_history: Array[Dictionary] = []
var max_history: int = 1000

static var instance: EventManager = null

signal event_emitted(event_name: String, params: Array)

func _init():
	instance = self

func emit(event_name: String, *params):
	var event_data = {
		"name": event_name,
		"params": params,
		"timestamp": Time.get_unix_time_from_system(),
		"frame": Engine.get_frames_drawn()
	}
	
	# 同步调用监听器
	if event_listeners.has(event_name):
		for listener in event_listeners[event_name]:
			if listener[0].is_valid():
				var callable = listener[1]
				callable.callv(params)
	
	# 添加到队列供异步处理
	event_queue.append(event_data)
	
	# 记录历史
	_add_to_history(event_data)
	
	# 发射信号
	event_emitted.emit(event_name, params)

func emit_async(event_name: String, *params):
	# 只加入队列，不立即执行
	var event_data = {
		"name": event_name,
		"params": params,
		"timestamp": Time.get_unix_time_from_system(),
		"frame": Engine.get_frames_drawn()
	}
	event_queue.append(event_data)
	_add_to_history(event_data)

func _add_to_history(event_data: Dictionary):
	event_history.append(event_data)
	if event_history.size() > max_history:
		event_history.remove_at(0)

func connect(event_name: String, listener: Object, method: String, binds: Array = []) -> bool:
	if not event_listeners.has(event_name):
		event_listeners[event_name] = []
	
	var callable = listener.get_method(method)
	if not callable:
		return false
	
	if binds.size() > 0:
		callable = callable.bindv(binds)
	
	event_listeners[event_name].append([listener, callable])
	return true

func disconnect(event_name: String, listener: Object, method: String) -> bool:
	if not event_listeners.has(event_name):
		return false
	
	var listeners = event_listeners[event_name]
	for i in range(listeners.size()):
		if listeners[i][0] == listener and listeners[i][1].method == method:
			listeners.remove_at(i)
			return true
	
	return false

func disconnect_all(listener: Object):
	for event_name in event_listeners:
		var listeners = event_listeners[event_name]
		for i in range(listeners.size() - 1, -1, -1):
			if listeners[i][0] == listener:
				listeners.remove_at(i)

func clear_event(event_name: String):
	if event_listeners.has(event_name):
		event_listeners[event_name].clear()

def clear_all_events():
	event_listeners.clear()

func process_queue():
	if is_processing or event_queue.is_empty():
		return
	
	is_processing = true
	
	while event_queue.size() > 0:
		var event = event_queue.pop_front()
		_process_event(event)
	
	is_processing = false

func _process_event(event: Dictionary):
	# 异步处理事件（例如网络发送、日志记录等）
	var event_name = event["name"]
	var params = event["params"]
	
	# 这里可以添加异步处理逻辑
	# 例如：发送到服务器、写入日志文件等

func has_listener(event_name: String) -> bool:
	return event_listeners.has(event_name) and event_listeners[event_name].size() > 0

func get_listener_count(event_name: String) -> int:
	if event_listeners.has(event_name):
		return event_listeners[event_name].size()
	return 0

func get_all_events() -> Array[String]:
	return event_listeners.keys()

func get_event_history(limit: int = 100) -> Array[Dictionary]:
	var history = event_history.duplicate()
	history.reverse()
	return history.slice(0, min(limit, history.size()))

func clear_history():
	event_history.clear()

func get_queue_size() -> int:
	return event_queue.size()

func flush_queue():
	while event_queue.size() > 0:
		_process_event(event_queue.pop_front())

# 预定义的常用事件常量
const EVENT_PLAYER_CREATED = "player_created"
const EVENT_PLAYER_LEVEL_UP = "player_level_up"
const EVENT_CURRENCY_CHANGED = "currency_changed"
const EVENT_ITEM_ADDED = "item_added"
const EVENT_ITEM_REMOVED = "item_removed"
const EVENT_EQUIPMENT_ADDED = "equipment_added"
const EVENT_WUXUE_LEARNED = "wuxue_learned"
const EVENT_XINFA_OBTAINED = "xinfa_obtained"
const EVENT_COMPANION_ADDED = "companion_added"
const EVENT_COMPANION_REMOVED = "companion_removed"
const EVENT_FORMATION_CHANGED = "formation_changed"
const EVENT_QUEST_ACCEPTED = "quest_accepted"
const EVENT_QUEST_COMPLETED = "quest_completed"
const EVENT_STORY_CHOICE_MADE = "story_choice_made"
const EVENT_CHAPTER_COMPLETED = "chapter_completed"
const EVENT_AREA_UNLOCKED = "area_unlocked"
const EVENT_AREA_CHANGED = "area_changed"
const EVENT_SECRET_DISCOVERED = "secret_discovered"
const EVENT_WORLD_STATE_CHANGED = "world_state_changed"
const EVENT_BATTLE_STARTED = "battle_started"
const EVENT_BATTLE_ENDED = "battle_ended"
const EVENT_TURN_STARTED = "turn_started"
const EVENT_TURN_ENDED = "turn_ended"
const EVENT_CHARACTER_ACTED = "character_acted"
const EVENT_DAMAGE_DEALT = "damage_dealt"
const EVENT_HEAL_DONE = "heal_done"
const EVENT_STATUS_APPLIED = "status_applied"
const EVENT_STATUS_REMOVED = "status_removed"
const EVENT_CHARACTER_DIED = "character_died"
const EVENT_COMBO_STARTED = "combo_started"
const EVENT_COMBO_FINISHED = "combo_finished"
const EVENT_CHASE_TRIGGERED = "chase_triggered"
const EVENT_COUNTER_TRIGGERED = "counter_triggered"
const EVENT_SUMMONED = "summoned"
const EVENT_PHANTOM_SUMMONED = "phantom_summoned"
const EVENT_TRAP_TRIGGERED = "trap_triggered"
const EVENT_MINE_TRIGGERED = "mine_triggered"
const EVENT_FORMATION_CHANGED_COMBAT = "formation_changed_combat"
const EVENT_PVP_MATCH_FOUND = "pvp_match_found"
const EVENT_PVP_MATCH_END = "pvp_match_end"
const EVENT_PVP_WEEKLY_RESET = "pvp_weekly_reset"
const EVENT_PVP_SEASON_END = "pvp_season_end"
const EVENT_GUILD_CREATED = "guild_created"
const EVENT_GUILD_DISBANDED = "guild_disbanded"
const EVENT_GUILD_MEMBER_JOINED = "guild_member_joined"
const EVENT_GUILD_MEMBER_LEFT = "guild_member_left"
const EVENT_GUILD_MEMBER_PROMOTED = "guild_member_promoted"
const EVENT_GUILD_DONATION = "guild_donation"
const EVENT_GUILD_LEVEL_UP = "guild_level_up"
const EVENT_GUILD_BUILDING_UPGRADED = "guild_building_upgraded"
const EVENT_GUILD_TECH_RESEARCHED = "guild_tech_researched"
const EVENT_GUILD_SECRET_REALM_STARTED = "guild_secret_realm_started"
const EVENT_GUILD_SECRET_REALM_PROGRESS = "guild_secret_realm_progress"
const EVENT_GUILD_WAR_DECLARED = "guild_war_declared"
const EVENT_GUILD_WAR_STARTED = "guild_war_started"
const EVENT_GUILD_WAR_ENDED = "guild_war_ended"
const EVENT_GUILD_WAR_RECORD_UPDATED = "guild_war_record_updated"
const EVENT_GUILD_ACHIEVEMENT_UNLOCKED = "guild_achievement_unlocked"
const EVENT_GUILD_SHOP_PURCHASE = "guild_shop_purchase"
const EVENT_GUILD_APPLICATION_SUBMITTED = "guild_application_submitted"
const EVENT_GUILD_APPLICATION_APPROVED = "guild_application_approved"
const EVENT_GUILD_APPLICATION_REJECTED = "guild_application_rejected"
const EVENT_GUILD_LEADERSHIP_TRANSFERRED = "guild_leadership_transferred"
const EVENT_DAILY_RESET = "daily_reset"
const EVENT_WEEKLY_RESET = "weekly_reset"
const EVENT_ACHIEVEMENT_UNLOCKED = "achievement_unlocked"
const EVENT_SETTING_CHANGED = "setting_changed"
const EVENT_CONFIG_SAVED = "config_saved"
const EVENT_CONFIG_CHANGED = "config_changed"
const EVENT_SAVE_STARTED = "save_started"
const EVENT_SAVE_COMPLETED = "save_completed"
const EVENT_LOAD_STARTED = "load_started"
const EVENT_LOAD_COMPLETED = "load_completed"
const EVENT_GAME_LOADED = "game_loaded"
const EVENT_AUTO_SAVE = "auto_save"
const EVENT_UI_OPENED = "ui_opened"
const EVENT_UI_CLOSED = "ui_closed"
const EVENT_DAY_CHANGED = "day_changed"
const EVENT_SEASON_CHANGED = "season_changed"
const EVENT_WEATHER_CHANGED = "weather_changed"
const EVENT_TIME_SCALE_CHANGED = "time_scale_changed"
const EVENT_ENCOUNTER_TRIGGERED = "encounter_triggered"
const EVENT_TREASURE_FOUND = "treasure_found"
const EVENT_NPC_AFFECTION_CHANGED = "npc_affection_changed"
const EVENT_RECIPE_LEARNED = "recipe_learned"
const EVENT_CRAFT_SUCCESS = "craft_success"
const EVENT_CRAFT_FAILED = "craft_failed"
const EVENT_ENHANCE_SUCCESS = "enhance_success"
const EVENT_ENHANCE_FAILED = "enhance_failed"
const EVENT_REFINE_SUCCESS = "refine_success"
const EVENT_WANLIAN_SUCCESS = "wanlian_success"
const EVENT_POTENTIAL_BREAKTHROUGH = "potential_breakthrough"
const EVENT_TALENT_UNLOCKED = "talent_unlocked"
const EVENT_TALENT_UPGRADED = "talent_upgraded"
const EVENT_SECT_JOINED = "sect_joined"
const EVENT_SECT_LEFT = "sect_left"
const EVENT_SECT_CONTRIBUTION_CHANGED = "sect_contribution_changed"
const EVENT_SECT_WUXUE_LEARNED = "sect_wuxue_learned"
const EVENT_RECRUITMENT_COMPLETED = "recruitment_completed"
const EVENT_EXPLORATION_STARTED = "exploration_started"
const EVENT_EXPLORATION_COMPLETED = "exploration_completed"
const EVENT_DUNGEON_CLEARED = "dungeon_cleared"
const EVENT_BOSS_DEFEATED = "boss_defeated"
const EVENT_TREASURE_CHEST_OPENED = "treasure_chest_opened"
const EVENT_MATERIAL_COLLECTED = "material_collected"
const EVENT_FISH_CAUGHT = "fish_caught"
const EVENT_MINING_COMPLETED = "mining_completed"
const EVENT_HERB_GATHERED = "herb_gathered"
const EVENT_COOKING_COMPLETED = "cooking_completed"
const EVENT_FORGING_COMPLETED = "forging_completed"
const EVENT_ALCHEMY_COMPLETED = "alchemy_completed"
const EVENT_TAILORING_COMPLETED = "tailoring_completed"
const EVENT_ENCHANTING_COMPLETED = "enchanting_completed"
const EVENT_PET_OBTAINED = "pet_obtained"
const EVENT_PET_EVOLVED = "pet_evolved"
const EVENT_MOUNT_OBTAINED = "mount_obtained"
const EVENT_SKIN_UNLOCKED = "skin_unlocked"
const EVENT_TITLE_UNLOCKED = "title_unlocked"
const EVENT_EFFECT_UNLOCKED = "effect_unlocked"
const EVENT_FRIEND_ADDED = "friend_added"
const EVENT_FRIEND_REMOVED = "friend_removed"
const EVENT_CHAT_MESSAGE = "chat_message"
const EVENT_MAIL_RECEIVED = "mail_received"
const EVENT_NOTIFICATION = "notification"
const EVENT_ERROR = "error"
const EVENT_WARNING = "warning"
const EVENT_DEBUG = "debug"