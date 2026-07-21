extends RefCounted
class_name Formation

@export var formation_id: String
@export var name: String = ""
@export var description: String = ""
@export var positions: Array[Vector2i] = []
@export var leader_position: int = 0
@export var buffs: Dictionary = {}
@export var shared_effects: Array[Dictionary] = []
@export var requirements: Dictionary = {}
@export var max_members: int = 5
@export var min_members: int = 2
@export var tags: Array[String] = []

var current_formation: String = ""
var formation_members: Array[BattleCharacter] = []
var active_buffs: Dictionary = {}

func _init():
	if positions.is_empty():
		positions = []
	if buffs.is_empty():
		buffs = {}
	if shared_effects.is_empty():
		shared_effects = []
	if requirements.is_empty():
		requirements = {}
	if tags.is_empty():
		tags = []
	if active_buffs.is_empty():
		active_buffs = {}

func apply(formation_data: Dictionary, team_chars: Array[BattleCharacter]):
	current_formation = formation_data.get("id", "")
	formation_members = team_chars.filter(func(c): return c.is_alive())
	
	# 分配位置
	for i in range(min(formation_members.size(), positions.size())):
		var pos = positions[i]
		formation_members[i].formation_position = i
		formation_members[i].preferred_formation = current_formation
	
	# 应用光环buff
	apply_auras(formation_data)
	
	# 应用共享效果
	apply_shared_effects(formation_data, team_chars)

func apply_auras(formation_data: Dictionary):
	for buff_type in formation_data.get("buffs", {}):
		var buff_value = formation_data["buffs"][buff_type]
		active_buffs[buff_type] = buff_value
		
		for member in formation_members:
			member.add_temp_stat(buff_type, buff_value)

func apply_shared_effects(formation_data: Dictionary, team_chars: Array[BattleCharacter]):
	for effect in formation_data.get("shared_effects", []):
		var effect_type = effect.get("type", "")
		match effect_type:
			"共享护盾":
				var total_shield = 0
				for member in formation_members:
					total_shield += member.shields.size() > 0 ? member.shields[0].amount : 0
				var avg_shield = total_shield / max(formation_members.size(), 1)
				for member in formation_members:
					member.add_shield(int(avg_shield * effect.get("multiplier", 1.0)), "阵法", 2)
			"共享怒气":
				var total_rage = 0
				for member in formation_members:
					total_rage += member.rage
				var avg_rage = total_rage / max(formation_members.size(), 1)
				for member in formation_members:
					if member.rage < avg_rage:
						member.add_rage(int((avg_rage - member.rage) * effect.get("transfer_rate", 0.5)))
			"共享治疗":
				for member in formation_members:
					var heal_received = member.heal_done_this_turn * effect.get("share_rate", 0.2)
					if heal_received > 0:
						for other in formation_members:
							if other != member:
								other.heal(int(heal_received), member)
			"分摊伤害":
				pass  # 在受击时处理

func get_position(index: int) -> Vector2i:
	if index >= 0 and index < positions.size():
		return positions[index]
	return Vector2i(0, 0)

func get_formation_bonus(buff_type: String) -> float:
	return active_buffs.get(buff_type, 0.0)

func can_activate(team_chars: Array[BattleCharacter]) -> bool:
	var alive_count = team_chars.filter(func(c): return c.is_alive()).size()
	return alive_count >= min_members and alive_count <= max_members

func remove():
	for member in formation_members:
		member.formation_position = -1
		member.preferred_formation = ""
	
	for buff_type in active_buffs:
		for member in formation_members:
			member.add_temp_stat(buff_type, -active_buffs[buff_type])
	
	active_buffs.clear()
	current_formation = ""
	formation_members.clear()

func on_member_died(dead_member: BattleCharacter):
	formation_members.erase(dead_member)
	
	# 重新分配位置
	for i in range(formation_members.size()):
		formation_members[i].formation_position = i
	
	# 检查是否仍满足最小人数
	if formation_members.size() < min_members:
		remove()

func on_member_joined(new_member: BattleCharacter):
	if formation_members.size() >= max_members:
		return
	
	formation_members.append(new_member)
	new_member.formation_position = formation_members.size() - 1
	new_member.preferred_formation = current_formation
	
	# 重新应用光环
	for buff_type in active_buffs:
		new_member.add_temp_stat(buff_type, active_buffs[buff_type])

func get_formation_info() -> Dictionary:
	return {
		"id": formation_id,
		"name": name,
		"members": [m.character_name for m in formation_members],
		"buffs": active_buffs,
		"positions": positions
	}

func to_dict() -> Dictionary:
	return {
		"id": formation_id,
		"name": name,
		"description": description,
		"positions": positions,
		"leader_position": leader_position,
		"buffs": buffs,
		"shared_effects": shared_effects,
		"requirements": requirements,
		"max_members": max_members,
		"min_members": min_members,
		"tags": tags
	}

func from_dict(data: Dictionary) -> Formation:
	formation_id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	positions = data.get("positions", [])
	leader_position = data.get("leader_position", 0)
	buffs = data.get("buffs", {})
	shared_effects = data.get("shared_effects", [])
	requirements = data.get("requirements", {})
	max_members = data.get("max_members", 5)
	min_members = data.get("min_members", 2)
	tags = data.get("tags", [])
	return self