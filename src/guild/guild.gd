extends Resource
class_name Guild

@export var guild_id: String
@export var name: String
@export var description: String = ""
@export var leader_id: String = ""
@export var level: int = 1
@export var exp: int = 0
@export var max_members: int = 30
@export var members: Array[GuildMember] = []
@export var contribution: int = 0
@export var weekly_contribution: int = 0
@export var funds: int = 0
@export var notice: String = ""
@export var recruitment_open: bool = true
@export var min_level_req: int = 1
@export var min_power_req: int = 0
@export var created_time: int = 0
@export var last_active_time: int = 0
@export var buildings: Dictionary = {}
@export var technologies: Dictionary = {}
@export var secret_realm_progress: Dictionary = {}
@export var guild_war_record: Dictionary = {}
@export var achievements: Array[String] = []

func _init():
	if buildings.is_empty():
		buildings = {
			"大厅": 1,
			"仓库": 1,
			"练功房": 1,
			"议事厅": 1,
			"后山": 1,
			"藏经阁": 1
		}
	if technologies.is_empty():
		technologies = {
			"帮会商店": 1,
			"帮会技能": 1,
			"秘境探索": 1,
			"帮战增益": 1,
			"资源产出": 1
		}
	if secret_realm_progress.is_empty():
		secret_realm_progress = {"current_floor": 0, "best_floor": 0, "boss_killed": []}
	if guild_war_record.is_empty():
		guild_war_record = {"wins": 0, "losses": 0, "current_streak": 0, "best_streak": 0}

func add_member(member: GuildMember) -> bool:
	if members.size() >= max_members:
		return false
	
	for m in members:
		if m.player_id == member.player_id:
			return false
	
	members.append(member)
	member.guild_id = guild_id
	member.join_time = Time.get_unix_time_from_system()
	EventManager.get_instance().emit("guild_member_joined", guild_id, member.player_id)
	return true

func remove_member(player_id: String) -> bool:
	for i in range(members.size()):
		if members[i].player_id == player_id:
			var member = members[i]
			members.remove_at(i)
			EventManager.get_instance().emit("guild_member_left", guild_id, player_id)
			return true
	return false

func get_member(player_id: String) -> GuildMember:
	for m in members:
		if m.player_id == player_id:
			return m
	return null

func get_online_members() -> Array[GuildMember]:
	var result = []
	for m in members:
		if m.is_online:
			result.append(m)
	return result

func get_member_count() -> int:
	return members.size()

func can_promote(promoter_id: String, target_id: String) -> bool:
	var promoter = get_member(promoter_id)
	var target = get_member(target_id)
	if not promoter or not target:
		return false
	
	var promoter_rank = _get_rank_value(promoter.position)
	var target_rank = _get_rank_value(target.position)
	
	return promoter_rank > target_rank

func promote_member(promoter_id: String, target_id: String, new_position: String) -> bool:
	if not can_promote(promoter_id, target_id):
		return false
	
	var target = get_member(target_id)
	if not target:
		return false
	
	target.position = new_position
	EventManager.get_instance().emit("guild_member_promoted", guild_id, target_id, new_position)
	return true

func kick_member(kicker_id: String, target_id: String) -> bool:
	var kicker = get_member(kicker_id)
	var target = get_member(target_id)
	if not kicker or not target:
		return false
	
	var kicker_rank = _get_rank_value(kicker.position)
	var target_rank = _get_rank_value(target.position)
	
	if kicker_rank <= target_rank:
		return false
	
	return remove_member(target_id)

func donate(player_id: String, copper: int, gold: int = 0) -> bool:
	var member = get_member(player_id)
	if not member:
		return false
	
	var player_data = PlayerData.get_instance()
	if player_data.player_id != player_id:
		return false
	
	if copper > 0 and not player_data.spend_copper(copper):
		return false
	if gold > 0 and not player_data.spend_gold(gold):
		return false
	
	funds += copper + gold * 10000
	contribution += copper / 100 + gold * 100
	member.contribution += copper / 100 + gold * 100
	member.weekly_contribution += copper / 100 + gold * 100
	
	EventManager.get_instance().emit("guild_donation", guild_id, player_id, copper, gold)
	return true

func add_exp(amount: int):
	exp += amount
	_check_level_up()

func _check_level_up():
	var exp_needed = level * 10000
	while exp >= exp_needed:
		level += 1
		exp -= exp_needed
		exp_needed = level * 10000
		max_members = 30 + level * 5
		EventManager.get_instance().emit("guild_level_up", guild_id, level)

func upgrade_building(building_name: String) -> bool:
	if not buildings.has(building_name):
		return false
	
	var current_level = buildings[building_name]
	var cost = _get_building_upgrade_cost(building_name, current_level + 1)
	
	if funds < cost:
		return false
	
	funds -= cost
	buildings[building_name] = current_level + 1
	EventManager.get_instance().emit("guild_building_upgraded", guild_id, building_name, current_level + 1)
	return true

func _get_building_upgrade_cost(building: String, level: int) -> int:
	var base_costs = {
		"大厅": 10000,
		"仓库": 5000,
		"练功房": 8000,
		"议事厅": 12000,
		"后山": 15000,
		"藏经阁": 20000
	}
	var base = base_costs.get(building, 10000)
	return base * level * level

func research_technology(tech_name: String) -> bool:
	if not technologies.has(tech_name):
		return false
	
	var current_level = technologies[tech_name]
	var cost = _get_tech_cost(tech_name, current_level + 1)
	
	if funds < cost:
		return false
	
	funds -= cost
	technologies[tech_name] = current_level + 1
	EventManager.get_instance().emit("guild_tech_researched", guild_id, tech_name, current_level + 1)
	return true

func _get_tech_cost(tech: String, level: int) -> int:
	var base_costs = {
		"帮会商店": 5000,
		"帮会技能": 10000,
		"秘境探索": 15000,
		"帮战增益": 20000,
		"资源产出": 8000
	}
	var base = base_costs.get(tech, 10000)
	return base * level * level

func start_secret_realm() -> bool:
	if secret_realm_progress.current_floor >= 10:
		return false
	
	secret_realm_progress.current_floor = 0
	EventManager.get_instance().emit("guild_secret_realm_started", guild_id)
	return true

func complete_secret_realm_floor(floor: Int):
	if floor > secret_realm_progress.current_floor:
		secret_realm_progress.current_floor = floor
	if floor > secret_realm_progress.best_floor:
		secret_realm_progress.best_floor = floor
	EventManager.get_instance().emit("guild_secret_realm_progress", guild_id, floor)

func record_guild_war(win: bool):
	if win:
		guild_war_record.wins += 1
		guild_war_record.current_streak += 1
		if guild_war_record.current_streak > guild_war_record.best_streak:
			guild_war_record.best_streak = guild_war_record.current_streak
	else:
		guild_war_record.losses += 1
		guild_war_record.current_streak = 0
	EventManager.get_instance().emit("guild_war_record_updated", guild_id, win)

func add_achievement(achievement_id: String):
	if achievement_id not in achievements:
		achievements.append(achievement_id)
		EventManager.get_instance().emit("guild_achievement_unlocked", guild_id, achievement_id)

func get_power_ranking() -> int:
	var total_power = 0
	for m in members:
		total_power += m.power
	return total_power

func get_top_members(count: int = 10) -> Array[GuildMember]:
	var sorted = members.duplicate()
	sorted.sort_custom(self, "_compare_power")
	return sorted.slice(0, min(count, sorted.size()))

func _compare_power(a: GuildMember, b: GuildMember) -> int:
	return -1 if a.power > b.power else 1

func _get_rank_value(position: String) -> int:
	match position:
		"帮主": return 5
		"副帮主": return 4
		"长老": return 3
		"精英": return 2
		"成员": return 1
	return 0

func to_dict() -> Dictionary:
	return {
		"guild_id": guild_id,
		"name": name,
		"description": description,
		"leader_id": leader_id,
		"level": level,
		"exp": exp,
		"max_members": max_members,
		"members": [m.to_dict() for m in members],
		"contribution": contribution,
		"weekly_contribution": weekly_contribution,
		"funds": funds,
		"notice": notice,
		"recruitment_open": recruitment_open,
		"min_level_req": min_level_req,
		"min_power_req": min_power_req,
		"created_time": created_time,
		"last_active_time": last_active_time,
		"buildings": buildings,
		"technologies": technologies,
		"secret_realm_progress": secret_realm_progress,
		"guild_war_record": guild_war_record,
		"achievements": achievements
	}

func from_dict(data: Dictionary) -> Guild:
	guild_id = data.get("guild_id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	leader_id = data.get("leader_id", "")
	level = data.get("level", 1)
	exp = data.get("exp", 0)
	max_members = data.get("max_members", 30)
	contribution = data.get("contribution", 0)
	weekly_contribution = data.get("weekly_contribution", 0)
	funds = data.get("funds", 0)
	notice = data.get("notice", "")
	recruitment_open = data.get("recruitment_open", true)
	min_level_req = data.get("min_level_req", 1)
	min_power_req = data.get("min_power_req", 0)
	created_time = data.get("created_time", 0)
	last_active_time = data.get("last_active_time", 0)
	buildings = data.get("buildings", {})
	technologies = data.get("technologies", {})
	secret_realm_progress = data.get("secret_realm_progress", {})
	guild_war_record = data.get("guild_war_record", {})
	achievements = data.get("achievements", [])
	
	members = []
	for m_data in data.get("members", []):
		var m = GuildMember.new().from_dict(m_data)
		members.append(m)
	
	return self