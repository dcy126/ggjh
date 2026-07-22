extends Resource
class_name DialogueNode

@export var id: String
@export var chapter: int = 0
@export var speaker: String = ""
@export var text: String = ""
@export var choices: Array[String] = []
@export var conditions: Dictionary = {}
@export var rewards: Dictionary = {}
@export var affection_changes: Dictionary = {}
@export var next_nodes: Array[String] = []
@export var portrait: String = ""
@export var background: String = ""
@export var voice_line: String = ""
@export var animation: String = ""
@export var camera_shake: bool = false
@export var screen_effect: String = ""
@export var wait_for_input: bool = true
@export var auto_advance_time: float = 0.0


func _init():
	if choices.is_empty():
		choices = []
	if conditions.is_empty():
		conditions = {}
	if rewards.is_empty():
		rewards = {}
	if affection_changes.is_empty():
		affection_changes = {}
	if next_nodes.is_empty():
		next_nodes = []

func check_conditions(player_data: PlayerData, world_state: Dictionary) -> bool:
	for key in conditions:
		var cond = conditions[key]
		match key:
			"chapter_progress":
				if player_data.current_chapter < cond:
					return false
			"affection":
				var npc_aff = player_data.npc_affection.get(speaker, 0)
				if npc_aff < cond:
					return false
			"has_item":
				if not player_data.has_item(cond):
					return false
			"completed_quest":
				if cond not in player_data.completed_quests:
					return false
			"moral_alignment":
				var custom = player_data.character_customization
				if custom and abs(custom.moral_alignment - cond) > 0.1:
					return false
			"reputation":
				var faction = cond.get("faction", "")
				var value = cond.get("value", 0)
				if player_data.character_customization and player_data.character_customization.reputation.has(faction):
					if player_data.character_customization.reputation[faction] < value:
						return false
			"world_state":
				var state_key = cond.get("key", "")
				var state_value = cond.get("value", true)
				if world_state.get(state_key, false) != state_value:
					return false
			"time_of_day":
				var time_mgr = TimeManager.get_instance()
				var current = time_mgr.get_time_of_day()
				if current != cond:
					return false
			"weather":
				var time_mgr = TimeManager.get_instance()
				if time_mgr.weather != cond:
					return false
			"season":
				var time_mgr = TimeManager.get_instance()
				if time_mgr.season != cond:
					return false
			"random":
				if randf() > cond:
					return false
	return true

func apply_rewards(player_data: PlayerData):
	for key in rewards:
		var reward = rewards[key]
		match key:
			"exp":
				player_data.gain_exp(reward)
			"copper":
				player_data.gain_copper(reward)
			"gold":
				player_data.gain_gold(reward)
			"item":
				player_data.add_item(reward.get("id", ""), reward.get("count", 1))
			"equipment":
				var eq = EquipmentDatabase.get_instance().get_equipment(reward)
				if eq:
					player_data.add_equipment(eq)
			"wuxue":
				var wx = WuxueDatabase.get_instance().get_wuxue(reward)
				if wx:
					player_data.add_wuxue(wx)
			"xinfa":
				var xf = XinfaDatabase.get_instance().get_xinfa(reward)
				if xf:
					player_data.add_xinfa(xf)
			"companion":
				# 添加伙伴
				pass
			"title":
				player_data.unlock_achievement("title_" + reward)
			"skin":
				player_data.unlock_achievement("skin_" + reward)
			"moral":
				if player_data.character_customization:
					player_data.character_customization.moral_alignment = clamp(player_data.character_customization.moral_alignment + reward, -1.0, 1.0)
			"reputation":
				if player_data.character_customization:
					for faction in reward:
						player_data.character_customization.reputation[faction] = player_data.character_customization.reputation.get(faction, 0) + reward[faction]

func apply_affection_changes(player_data: PlayerData):
	for npc_id in affection_changes:
		var change = affection_changes[npc_id]
		if player_data.character_customization:
			# 这里需要NPC好感度系统
			pass

func to_dict() -> Dictionary:
	return {
		"id": id,
		"chapter": chapter,
		"speaker": speaker,
		"text": text,
		"choices": choices,
		"conditions": conditions,
		"rewards": rewards,
		"affection_changes": affection_changes,
		"next_nodes": next_nodes,
		"portrait": portrait,
		"background": background,
		"voice_line": voice_line,
		"animation": animation,
		"camera_shake": camera_shake,
		"screen_effect": screen_effect,
		"wait_for_input": wait_for_input,
		"auto_advance_time": auto_advance_time
	}

func from_dict(data: Dictionary) -> DialogueNode:
	id = data.get("id", "")
	chapter = data.get("chapter", 0)
	speaker = data.get("speaker", "")
	text = data.get("text", "")
	choices = data.get("choices", [])
	conditions = data.get("conditions", {})
	rewards = data.get("rewards", {})
	affection_changes = data.get("affection_changes", {})
	next_nodes = data.get("next_nodes", [])
	portrait = data.get("portrait", "")
	background = data.get("background", "")
	voice_line = data.get("voice_line", "")
	animation = data.get("animation", "")
	camera_shake = data.get("camera_shake", false)
	screen_effect = data.get("screen_effect", "")
	wait_for_input = data.get("wait_for_input", true)
	auto_advance_time = data.get("auto_advance_time", 0.0)
	return self
