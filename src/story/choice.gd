extends RefCounted
class_name Choice

@export var id: String
@export var text: String = ""
@export var description: String = ""
@export var conditions: Dictionary = {}
@export var consequences: Dictionary = {}
@export var immediate_effects: Dictionary = {}
@export var delayed_effects: Array[Dictionary] = []
@export var permanent: bool = false
@export var hidden: bool = false
@export var required_affection: Dictionary = {}
@export var required_items: Array[String] = []
@export var required_quests: Array[String] = []
@export var moral_impact: float = 0.0
@export var reputation_changes: Dictionary = {}
@export var relationship_changes: Dictionary = {}
@export var unlock_content: Array[String] = []
@export var lock_content: Array[String] = []
@export var next_node: String = ""
@export var next_chapter: int = 0
@export var callback: String = ""

func _init():
	if conditions.is_empty():
		conditions = {}
	if consequences.is_empty():
		consequences = {}
	if immediate_effects.is_empty():
		immediate_effects = {}
	if delayed_effects.is_empty():
		delayed_effects = []
	if required_affection.is_empty():
		required_affection = {}
	if required_items.is_empty():
		required_items = []
	if required_quests.is_empty():
		required_quests = []
	if reputation_changes.is_empty():
		reputation_changes = {}
	if relationship_changes.is_empty():
		relationship_changes = {}
	if unlock_content.is_empty():
		unlock_content = []
	if lock_content.is_empty():
		lock_content = []

func check_conditions(player_data: PlayerData, world_state: Dictionary) -> bool:
	for key in conditions:
		var cond = conditions[key]
		match key:
			"level":
				if player_data.level < cond:
					return false
			"chapter":
				if player_data.current_chapter < cond:
					return false
			"affection":
				var npc_aff = player_data.npc_affection.get(cond.get("npc", ""), 0)
				if npc_aff < cond.get("value", 0):
					return false
			"has_item":
				if not player_data.has_item(cond):
					return false
			"completed_quest":
				if cond not in player_data.completed_quests:
					return false
			"moral":
				var custom = player_data.character_customization
				if custom and abs(custom.moral_alignment - cond) > 0.1:
					return false
			"reputation":
				var faction = cond.get("faction", "")
				var value = cond.get("value", 0)
				if custom and custom.reputation.has(faction):
					if custom.reputation[faction] < value:
						return false
			"money":
				if player_data.copper < cond:
					return false
			"gold":
				if player_data.gold < cond:
					return false
			"sect":
				if player_data.current_sect != cond:
					return false
			"guild":
				if player_data.current_guild != cond:
					return false
			"world_state":
				var state_key = cond.get("key", "")
				var state_value = cond.get("value", true)
				if world_state.get(state_key, false) != state_value:
					return false
			"random":
				if randf() > cond:
					return false
	return true

func apply_consequences(player_data: PlayerData, world_state: Dictionary):
	# 立即效果
	for key in immediate_effects:
		var effect = immediate_effects[key]
		match key:
			"exp":
				player_data.gain_exp(effect)
			"copper":
				player_data.gain_copper(effect)
			"gold":
				player_data.gain_gold(effect)
			"item":
				player_data.add_item(effect.get("id", ""), effect.get("count", 1))
			"remove_item":
				player_data.remove_item(effect.get("id", ""), effect.get("count", 1))
			"moral":
				if player_data.character_customization:
					player_data.character_customization.moral_alignment = clamp(player_data.character_customization.moral_alignment + effect, -1.0, 1.0)
			"reputation":
				if player_data.character_customization:
					for faction in effect:
						player_data.character_customization.reputation[faction] = player_data.character_customization.reputation.get(faction, 0) + effect[faction]
			"affection":
				# 好感度变化
				pass
			"relationship":
				# 关系变化
				pass
			"unlock":
				for content in effect:
					if content not in player_data.unlocked_content:
						player_data.unlocked_content.append(content)
			"lock":
				for content in effect:
					if content in player_data.unlocked_content:
						player_data.unlocked_content.erase(content)
			"chapter":
				player_data.current_chapter = effect
			"quest":
				var quest = StoryDatabase.get_instance().get_quest(effect)
				if quest:
					player_data.accept_quest(quest)
			"complete_quest":
				player_data.complete_quest(effect)
			"recruit":
				# 招募伙伴
				pass
			"learn_wuxue":
				var wx = WuxueDatabase.get_instance().get_wuxue(effect)
				if wx:
					player_data.add_wuxue(wx)
			"learn_xinfa":
				var xf = XinfaDatabase.get_instance().get_xinfa(effect)
				if xf:
					player_data.add_xinfa(xf)
			"get_equipment":
				var eq = EquipmentDatabase.get_instance().get_equipment(effect)
				if eq:
					player_data.add_equipment(eq)
	
	# 延迟效果
	for delayed in delayed_effects:
		var delay = delayed.get("delay", 0)
		var effect = delayed.get("effect", {})
		# 这里需要时间管理器来调度
		TimeManager.get_instance().add_timer(delay, Callable(self, "_apply_delayed_effect").bind(effect, player_data, world_state))
	
	# 永久后果
	for key in consequences:
		var consequence = consequences[key]
		match key:
			"story_branch":
				world_state[consequence.get("branch_id", "")] = consequence.get("value", true)
			"npc_attitude":
				# NPC态度永久改变
				pass
			"world_change":
				# 世界状态永久改变
				world_state[consequence.get("key", "")] = consequence.get("value", true)
			"ending":
				# 结局分支
				world_state["ending_branch"] = consequence.get("ending_id", "")

func _apply_delayed_effect(effect: Dictionary, player_data: PlayerData, world_state: Dictionary):
	for key in effect:
		var val = effect[key]
		match key:
			"exp":
				player_data.gain_exp(val)
			"copper":
				player_data.gain_copper(val)
			"gold":
				player_data.gain_gold(val)
			"item":
				player_data.add_item(val.get("id", ""), val.get("count", 1))
			"moral":
				if player_data.character_customization:
					player_data.character_customization.moral_alignment = clamp(player_data.character_customization.moral_alignment + val, -1.0, 1.0)
			"reputation":
				if player_data.character_customization:
					for faction in val:
						player_data.character_customization.reputation[faction] = player_data.character_customization.reputation.get(faction, 0) + val[faction]

func to_dict() -> Dictionary:
	return {
		"id": id,
		"text": text,
		"description": description,
		"conditions": conditions,
		"consequences": consequences,
		"immediate_effects": immediate_effects,
		"delayed_effects": delayed_effects,
		"permanent": permanent,
		"hidden": hidden,
		"required_affection": required_affection,
		"required_items": required_items,
		"required_quests": required_quests,
		"moral_impact": moral_impact,
		"reputation_changes": reputation_changes,
		"relationship_changes": relationship_changes,
		"unlock_content": unlock_content,
		"lock_content": lock_content,
		"next_node": next_node,
		"next_chapter": next_chapter,
		"callback": callback
	}

func from_dict(data: Dictionary) -> Choice:
	id = data.get("id", "")
	text = data.get("text", "")
	description = data.get("description", "")
	conditions = data.get("conditions", {})
	consequences = data.get("consequences", {})
	immediate_effects = data.get("immediate_effects", {})
	delayed_effects = data.get("delayed_effects", [])
	permanent = data.get("permanent", false)
	hidden = data.get("hidden", false)
	required_affection = data.get("required_affection", {})
	required_items = data.get("required_items", [])
	required_quests = data.get("required_quests", [])
	moral_impact = data.get("moral_impact", 0.0)
	reputation_changes = data.get("reputation_changes", {})
	relationship_changes = data.get("relationship_changes", {})
	unlock_content = data.get("unlock_content", [])
	lock_content = data.get("lock_content", [])
	next_node = data.get("next_node", "")
	next_chapter = data.get("next_chapter", 0)
	callback = data.get("callback", "")
	return self