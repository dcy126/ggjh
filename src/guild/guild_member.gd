extends Resource
class_name GuildMember

@export var player_id: String = ""
@export var player_name: String = ""
@export var level: int = 1
@export var power: int = 0
@export var position: String = "成员"
@export var contribution: int = 0
@export var weekly_contribution: int = 0
@export var total_contribution: int = 0
@export var join_time: int = 0
@export var last_online_time: int = 0
@export var is_online: bool = false
@export var avatar: String = ""
@export var title: String = ""
@export var guild_id: String = ""

func _init():
	join_time = Time.get_unix_time_from_system()
	last_online_time = join_time

func update_power(new_power: int):
	power = new_power

func add_contribution(amount: int):
	contribution += amount
	weekly_contribution += amount
	total_contribution += amount

func reset_weekly_contribution():
	weekly_contribution = 0

func set_online(online: bool):
	is_online = online
	if online:
		last_online_time = Time.get_unix_time_from_system()

func get_offline_duration() -> int:
	if is_online:
		return 0
	return Time.get_unix_time_from_system() - last_online_time

func can_be_kicked() -> bool:
	return get_offline_duration() > 7 * 86400

func to_dict() -> Dictionary:
	return {
		"player_id": player_id,
		"player_name": player_name,
		"level": level,
		"power": power,
		"position": position,
		"contribution": contribution,
		"weekly_contribution": weekly_contribution,
		"total_contribution": total_contribution,
		"join_time": join_time,
		"last_online_time": last_online_time,
		"is_online": is_online,
		"avatar": avatar,
		"title": title,
		"guild_id": guild_id
	}

func from_dict(data: Dictionary) -> GuildMember:
	player_id = data.get("player_id", "")
	player_name = data.get("player_name", "")
	level = data.get("level", 1)
	power = data.get("power", 0)
	position = data.get("position", "成员")
	contribution = data.get("contribution", 0)
	weekly_contribution = data.get("weekly_contribution", 0)
	total_contribution = data.get("total_contribution", 0)
	join_time = data.get("join_time", 0)
	last_online_time = data.get("last_online_time", 0)
	is_online = data.get("is_online", false)
	avatar = data.get("avatar", "")
	title = data.get("title", "")
	guild_id = data.get("guild_id", "")
	return self