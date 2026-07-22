extends Resource
class_name BattleAction

@export var action_id: String
@export var action_type: String = ""
var actor: BattleCharacter = null
var target: BattleCharacter = null
var targets: Array[BattleCharacter] = []
var skill: WuxueData = null
@export var target_position: Vector2i = Vector2i(-1, -1)
@export var priority: int = 0
@export var timestamp: int = 0
@export var is_instant: bool = false
@export var is_counter: bool = false
@export var is_chase: bool = false
@export var is_combo: bool = false
@export var combo_step: int = 0
@export var combo_id: String = ""
@export var delay: int = 0
@export var metadata: Dictionary = {}

func _init():
	action_id = str(Time.get_ticks_msec()) + "_" + str(randi())

func set_skill_action(actor_char: BattleCharacter, skill_data: WuxueData, target_char: BattleCharacter = null, target_pos: Vector2i = Vector2i(-1, -1)) -> BattleAction:
	action_type = "技能"
	actor = actor_char
	skill = skill_data
	target = target_char
	target_position = target_pos
	priority = skill.priority
	timestamp = actor_char.qi
	return self

func set_move_action(actor_char: BattleCharacter, pos: Vector2i) -> BattleAction:
	action_type = "移动"
	actor = actor_char
	target_position = pos
	priority = 100
	timestamp = actor_char.qi
	return self

func set_basic_attack_action(actor_char: BattleCharacter, target_char: BattleCharacter) -> BattleAction:
	action_type = "普通攻击"
	actor = actor_char
	target = target_char
	priority = 50
	timestamp = actor_char.qi
	return self

func set_wait_action(actor_char: BattleCharacter) -> BattleAction:
	action_type = "等待"
	actor = actor_char
	priority = 10
	timestamp = actor_char.qi
	return self

func set_item_action(actor_char: BattleCharacter, item_id: String, target_char: BattleCharacter = null) -> BattleAction:
	action_type = "使用物品"
	actor = actor_char
	target = target_char
	metadata["item_id"] = item_id
	priority = 20
	timestamp = actor_char.qi
	return self

func set_counter_action(actor_char: BattleCharacter, attacker: BattleCharacter) -> BattleAction:
	action_type = "反击"
	actor = actor_char
	target = attacker
	is_counter = true
	priority = 200
	timestamp = 0
	return self

func set_chase_action(actor_char: BattleCharacter, target_char: BattleCharacter) -> BattleAction:
	action_type = "追击"
	actor = actor_char
	target = target_char
	is_chase = true
	priority = 150
	timestamp = actor_char.qi
	return self

func set_combo_action(actor_char: BattleCharacter, combo_data: Combo, step: int) -> BattleAction:
	action_type = "连击"
	actor = actor_char
	is_combo = true
	combo_id = combo_data.combo_id
	combo_step = step
	priority = 180
	timestamp = actor_char.qi
	metadata["combo_data"] = combo_data.to_dict()
	return self

func execute(combat: CombatManager):
	match action_type:
		"技能":
			if skill and actor and actor.is_alive():
				var t = target
				if not t and target_position != Vector2i(-1, -1):
					t = combat.battle_grid.get_character_at(target_position)
				if t:
					combat.execute_skill(actor, t, skill)
		"移动":
			if actor and actor.can_move():
				combat.move_character(actor, target_position)
		"普通攻击":
			if actor and actor.is_alive() and target and target.is_alive():
				combat.execute_basic_attack(actor, target)
		"等待":
			actor.add_qi(20)
		"使用物品":
			var item_id = metadata.get("item_id", "")
			if item_id:
				combat.use_item(actor, item_id, target)
		"反击":
			if actor and actor.is_alive() and target and target.is_alive():
				combat.execute_basic_attack(actor, target)
		"追击":
			if actor and actor.is_alive() and target and target.is_alive():
				combat.execute_basic_attack(actor, target)
		"连击":
			if actor and actor.is_alive():
				var combo_data = Combo.new().from_dict(metadata.get("combo_data", {}))
				combat.combo_system.execute_combo_step(actor, combo_data, combo_step, combat)

func to_dict() -> Dictionary:
	
	var targets_arr = []
	for x in targets:
		targets_arr.append(x.character_id)
		
	return {
		"id": action_id,
		"type": action_type,
		"actor": actor.character_id if actor else "",
		"target": target.character_id if target else "",
		"targets": targets_arr,
		"skill": skill.id if skill else "",
		"position": target_position,
		"priority": priority,
		"timestamp": timestamp,
		"instant": is_instant,
		"counter": is_counter,
		"chase": is_chase,
		"combo": is_combo,
		"combo_step": combo_step,
		"combo_id": combo_id,
		"delay": delay,
		"metadata": metadata
	}

func from_dict(data: Dictionary) -> BattleAction:
	action_id = data.get("id", "")
	action_type = data.get("type", "")
	priority = data.get("priority", 0)
	timestamp = data.get("timestamp", 0)
	is_instant = data.get("instant", false)
	is_counter = data.get("counter", false)
	is_chase = data.get("chase", false)
	is_combo = data.get("combo", false)
	combo_step = data.get("combo_step", 0)
	combo_id = data.get("combo_id", "")
	delay = data.get("delay", 0)
	metadata = data.get("metadata", {})
	return self
