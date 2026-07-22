extends Node
class_name GuildManager

var current_guild: Guild = null
var guild_list: Array[Guild] = []
var guild_applications: Dictionary = {}  # guild_id -> Array[application]
var player_application: String = ""  # guild_id player applied to
var guild_war_state: String = "休战期"
var guild_war_match: String = ""
var secret_realm_state: String = "未开启"

static var instance = null

static func get_instance():
	return instance

func _enter_tree():
	instance = self

func create_guild(name: String, description: String, leader_id: String, leader_name: String, min_level: int = 1) -> bool:
	var player_data = PlayerData.instance
	if player_data.player_id != leader_id:
		return false
	if player_data.gold < 100:
		return false
	if player_data.current_guild != "":
		return false
	
	if not player_data.spend_gold(100):
		return false
	
	var guild = Guild.new()
	guild.guild_id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
	guild.name = name
	guild.description = description
	guild.leader_id = leader_id
	guild.created_time = Time.get_unix_time_from_system()
	guild.min_level_req = min_level
	
	var member = GuildMember.new()
	member.player_id = leader_id
	member.player_name = leader_name
	member.position = "帮主"
	member.guild_id = guild.guild_id
	member.level = player_data.level
	member.power = _calculate_player_power()
	
	guild.add_member(member)
	current_guild = guild
	guild_list.append(guild)
	
	player_data.set_guild(guild.guild_id, "帮主")
	
	EventManager.instance.emit("guild_created", guild.guild_id)
	return true

func _calculate_player_power() -> int:
	var protagonist = PlayerData.instance.protagonist
	if not protagonist:
		return 0
	var bc = protagonist.get_battle_character()
	return bc.atk + bc.def + bc.spd + bc.max_hp / 10

func apply_to_guild(guild_id: String, player_id: String, player_name: String, player_level: int, player_power: int) -> bool:
	var guild = _find_guild(guild_id)
	if not guild:
		return false
	
	if not guild.recruitment_open:
		return false
	if player_level < guild.min_level_req:
		return false
	if player_power < guild.min_power_req:
		return false
	if guild.get_member_count() >= guild.max_members:
		return false
	
	if player_application != "":
		return false
	
	if not guild_applications.has(guild_id):
		guild_applications[guild_id] = []
	
	var application = {
		"player_id": player_id,
		"player_name": player_name,
		"level": player_level,
		"power": player_power,
		"time": Time.get_unix_time_from_system()
	}
	
	guild_applications[guild_id].append(application)
	player_application = guild_id
	
	EventManager.instance.emit("guild_application_submitted", guild_id, player_id)
	return true

func cancel_application():
	if player_application != "":
		var apps = guild_applications.get(player_application, [])
		for i in range(apps.size()):
			if apps[i]["player_id"] == PlayerData.instance.player_id:
				apps.remove_at(i)
				break
		player_application = ""
		EventManager.instance.emit("guild_application_cancelled")

func approve_application(guild_id: String, approver_id: String, player_id: String) -> bool:
	var guild = _find_guild(guild_id)
	if not guild:
		return false
	
	var approver = guild.get_member(approver_id)
	if not approver or _get_rank_value(approver.position) < 4:
		return false
	
	var apps = guild_applications.get(guild_id, [])
	var app_index = -1
	for i in range(apps.size()):
		if apps[i]["player_id"] == player_id:
			app_index = i
			break
	
	if app_index == -1:
		return false
	
	var app = apps[app_index]
	apps.remove_at(app_index)
	
	var member = GuildMember.new()
	member.player_id = app["player_id"]
	member.player_name = app["player_name"]
	member.level = app["level"]
	member.power = app["power"]
	member.guild_id = guild_id
	
	guild.add_member(member)
	
	var player_data = PlayerData.instance
	if player_data.player_id == player_id:
		player_data.set_guild(guild_id, "成员")
		player_application = ""
	
	EventManager.instance.emit("guild_application_approved", guild_id, player_id)
	return true

func reject_application(guild_id: String, approver_id: String, player_id: String) -> bool:
	var guild = _find_guild(guild_id)
	if not guild:
		return false
	
	var approver = guild.get_member(approver_id)
	if not approver or _get_rank_value(approver.position) < 4:
		return false
	
	var apps = guild_applications.get(guild_id, [])
	for i in range(apps.size()):
		if apps[i]["player_id"] == player_id:
			apps.remove_at(i)
			break
	
	if PlayerData.instance.player_id == player_id:
		player_application = ""
	
	EventManager.instance.emit("guild_application_rejected", guild_id, player_id)
	return true

func leave_guild(player_id: String) -> bool:
	if not current_guild or current_guild.guild_id != PlayerData.instance.current_guild:
		return false
	
	var is_leader = current_guild.leader_id == player_id
	if is_leader and current_guild.get_member_count() > 1:
		return false  # 帮主不能直接退出，需转让
	
	current_guild.remove_member(player_id)
	PlayerData.instance.leave_guild()
	
	if is_leader:
		_transfer_leadership()
	
	EventManager.instance.emit("guild_left", player_id)
	return true

func _transfer_leadership():
	if current_guild.get_member_count() == 0:
		_disband_guild()
		return
	
	# 找贡献最高的副帮主或长老
	var candidates = []
	for m in current_guild.members:
		if m.position in ["副帮主", "长老"]:
			candidates.append(m)
	
	if candidates.is_empty():
		for m in current_guild.members:
			if m.position == "精英":
				candidates.append(m)
	
	if candidates.is_empty():
		candidates = current_guild.members.duplicate()
	
	candidates.sort_custom(_compare_contribution)
	var new_leader = candidates[0]
	current_guild.leader_id = new_leader.player_id
	new_leader.position = "帮主"
	
	EventManager.instance.emit("guild_leadership_transferred", current_guild.guild_id, new_leader.player_id)

func _compare_contribution(a: GuildMember, b: GuildMember) -> int:
	return -1 if a.total_contribution > b.total_contribution else 1

func _disband_guild():
	guild_list.erase(current_guild)
	current_guild = null
	EventManager.instance.emit("guild_disbanded")

func kick_member(kicker_id: String, target_id: String) -> bool:
	if not current_guild:
		return false
	return current_guild.kick_member(kicker_id, target_id)

func promote_member(promoter_id: String, target_id: String, new_position: String) -> bool:
	if not current_guild:
		return false
	return current_guild.promote_member(promoter_id, target_id, new_position)

func donate(copper: int, gold: int = 0) -> bool:
	if not current_guild:
		return false
	return current_guild.donate(PlayerData.instance.player_id, copper, gold)

func upgrade_building(building_name: String) -> bool:
	if not current_guild:
		return false
	return current_guild.upgrade_building(building_name)

func research_technology(tech_name: String) -> bool:
	if not current_guild:
		return false
	return current_guild.research_technology(tech_name)

func start_secret_realm() -> bool:
	if not current_guild:
		return false
	
	var now = Time.get_unix_time_from_system()
	var day_of_week = (now / 86400) % 7
	# 周三(2)、周六(5)、周日(6)开放
	if day_of_week not in [2, 5, 6]:
		return false
	
	secret_realm_state = "进行中"
	return current_guild.start_secret_realm()

func complete_secret_realm_floor(floor: int):
	if not current_guild:
		return
	current_guild.complete_secret_realm_floor(floor)

func get_guild_info(guild_id: String) -> Guild:
	return _find_guild(guild_id)

func get_all_guilds() -> Array[Guild]:
	return guild_list.duplicate()

func get_recommended_guilds(count: int = 10) -> Array[Guild]:
	var sorted = guild_list.duplicate()
	sorted.sort_custom(_compare_guild_activity)
	return sorted.slice(0, min(count, sorted.size()))

func _compare_guild_activity(a: Guild, b: Guild) -> int:
	return -1 if a.last_active_time > b.last_active_time else 1

func search_guilds(keyword: String) -> Array[Guild]:
	var results = []
	for g in guild_list:
		if g.name.to_lower().contains(keyword.to_lower()):
			results.append(g)
	return results

func _find_guild(guild_id: String) -> Guild:
	for g in guild_list:
		if g.guild_id == guild_id:
			return g
	return null

func _get_rank_value(position: String) -> int:
	match position:
		"帮主": return 5
		"副帮主": return 4
		"长老": return 3
		"精英": return 2
		"成员": return 1
	return 0

func start_guild_war(opponent_guild_id: String) -> bool:
	if not current_guild:
		return false
	if guild_war_state != "休战期":
		return false
	
	var opponent = _find_guild(opponent_guild_id)
	if not opponent:
		return false
	
	guild_war_state = "宣战中"
	guild_war_match = opponent_guild_id
	EventManager.instance.emit("guild_war_declared", current_guild.guild_id, opponent_guild_id)
	return true

func accept_guild_war(challenger_guild_id: String) -> bool:
	if not current_guild:
		return false
	if guild_war_state != "宣战中" or guild_war_match != challenger_guild_id:
		return false
	
	guild_war_state = "战斗中"
	EventManager.instance.emit("guild_war_started", current_guild.guild_id, challenger_guild_id)
	return true

func end_guild_war(winner_guild_id: String):
	if not current_guild:
		return
	
	var is_winner = current_guild.guild_id == winner_guild_id
	current_guild.record_guild_war(is_winner)
	
	var opponent = _find_guild(guild_war_match)
	if opponent:
		opponent.record_guild_war(not is_winner)
	
	guild_war_state = "休战期"
	guild_war_match = ""
	EventManager.instance.emit("guild_war_ended", winner_guild_id)

func get_guild_shop_items() -> Array[Dictionary]:
	if not current_guild:
		return []
	
	var level = current_guild.buildings.get("帮会商店", 1)
	var tech_level = current_guild.technologies.get("帮会商店", 1)
	
	var items = [
		{"item_id": "hp_potion_large", "price": 500, "currency": "contribution", "stock": -1, "req_level": 1},
		{"item_id": "mp_potion_large", "price": 500, "currency": "contribution", "stock": -1, "req_level": 1},
		{"item_id": "potential_pill", "price": 2000, "currency": "contribution", "stock": 10, "req_level": 2},
		{"item_id": "xinfa_fragment", "price": 500, "currency": "contribution", "stock": 20, "req_level": 2},
		{"item_id": "wuxue_fragment", "price": 1000, "currency": "contribution", "stock": 10, "req_level": 3},
		{"item_id": "equipment_enhance_stone", "price": 1000, "currency": "contribution", "stock": 5, "req_level": 3},
		{"item_id": "equipment_refine_stone", "price": 2000, "currency": "contribution", "stock": 3, "req_level": 4},
		{"item_id": "wanlian_stone", "price": 5000, "currency": "contribution", "stock": 1, "req_level": 5},
	]
	
	var available = []
	for item in items:
		if item["req_level"] <= max(level, tech_level):
			available.append(item)
	
	return available

func buy_from_guild_shop(item_id: String, count: int = 1) -> bool:
	if not current_guild:
		return false
	
	var items = get_guild_shop_items()
	var shop_item = null
	for item in items:
		if item["item_id"] == item_id:
			shop_item = item
			break
	
	if not shop_item:
		return false
	
	var total_price = shop_item["price"] * count
	var currency = shop_item["currency"]
	
	var member = current_guild.get_member(PlayerData.instance.player_id)
	if not member:
		return false
	
	if currency == "contribution":
		if member.contribution < total_price:
			return false
		member.contribution -= total_price
	else:
		# 其他货币
		return false
	
	PlayerData.instance.add_item(item_id, count)
	EventManager.instance.emit("guild_shop_purchase", current_guild.guild_id, item_id, count)
	return true

func to_dict() -> Dictionary:
	return {
		"current_guild": current_guild.to_dict() if current_guild else {},
		"guild_list": _guild_list_to_dict(),
		"guild_applications": guild_applications,
		"player_application": player_application,
		"guild_war_state": guild_war_state,
		"guild_war_match": guild_war_match,
		"secret_realm_state": secret_realm_state
	}

func _guild_list_to_dict() -> Array:
	var result = []
	for g in guild_list:
		result.append(g.to_dict())
	return result

func from_dict(data: Dictionary):
	if data.has("current_guild") and data["current_guild"]:
		current_guild = Guild.new().from_dict(data["current_guild"])
	
	guild_list = []
	for g_data in data.get("guild_list", []):
		var g = Guild.new().from_dict(g_data)
		guild_list.append(g)
	
	guild_applications = data.get("guild_applications", {})
	player_application = data.get("player_application", "")
	guild_war_state = data.get("guild_war_state", "休战期")
	guild_war_match = data.get("guild_war_match", "")
	secret_realm_state = data.get("secret_realm_state", "未开启")