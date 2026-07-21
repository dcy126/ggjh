extends RefCounted
class_name TimeManager

var game_time: int = 0
var real_time_start: int = 0
var time_scale: float = 1.0
var is_paused: bool = false

var day_cycle_duration: int = 24 * 60 * 60  # 24小时(秒)
var current_hour: int = 12
var current_minute: int = 0
var current_second: int = 0

var season: String = "春"
var season_progress: float = 0.0
var season_duration: int = 30 * 24 * 60 * 60  # 30天

var weather: String = "晴"
var weather_timer: int = 0
var weather_duration: int = 10 * 60  # 10分钟

static var instance: TimeManager = null

func _init():
	instance = self
	real_time_start = Time.get_unix_time_from_system()
	_calculate_initial_time()

func _calculate_initial_time():
	var now = Time.get_datetime_dict_from_system()
	current_hour = now.hour
	current_minute = now.minute
	current_second = now.second
	
	# 根据月份确定季节
	var month = now.month
	match month:
		3, 4, 5: season = "春"
		6, 7, 8: season = "夏"
		9, 10, 11: season = "秋"
		12, 1, 2: season = "冬"

func _process(delta: float):
	if is_paused:
		return
	
	var scaled_delta = delta * time_scale
	game_time += int(scaled_delta * 1000)
	
	_update_day_cycle(scaled_delta)
	_update_season(scaled_delta)
	_update_weather(scaled_delta)

func _update_day_cycle(delta: float):
	var seconds_per_game_hour = day_cycle_duration / 24.0
	var total_seconds = (current_hour * 3600) + (current_minute * 60) + current_second
	total_seconds += int(delta)
	
	if total_seconds >= day_cycle_duration:
		total_seconds -= day_cycle_duration
		_on_day_changed()
	
	current_hour = total_seconds / 3600
	current_minute = (total_seconds % 3600) / 60
	current_second = total_seconds % 60

func _on_day_changed():
	EventManager.get_instance().emit("day_changed", get_game_date())
	
	# 每天重置每日任务等
	if PlayerData.get_instance():
		PlayerData.get_instance().daily_login()

func _update_season(delta: float):
	season_progress += delta / season_duration
	if season_progress >= 1.0:
		season_progress = 0.0
		_cycle_season()

func _cycle_season():
	var seasons = ["春", "夏", "秋", "冬"]
	var idx = seasons.find(season)
	season = seasons[(idx + 1) % 4]
	EventManager.get_instance().emit("season_changed", season)

func _update_weather(delta: float):
	weather_timer += int(delta)
	if weather_timer >= weather_duration:
		weather_timer = 0
		_change_weather()

func _change_weather():
	var weathers = ["晴", "雨", "雪", "雾", "阴", "风"]
	var weights = {"春": [40, 20, 0, 10, 20, 10], "夏": [30, 30, 0, 5, 20, 15], "秋": [40, 15, 0, 20, 15, 10], "冬": [20, 5, 30, 15, 20, 10]}
	
	var season_weights = weights.get(season, [40, 20, 0, 10, 20, 10])
	var total = 0
	for w in season_weights:
		total += w
	
	var rand = randi() % total
	var cumulative = 0
	for i in range(season_weights.size()):
		cumulative += season_weights[i]
		if rand < cumulative:
			var new_weather = weathers[i]
			if new_weather != weather:
				weather = new_weather
				EventManager.get_instance().emit("weather_changed", weather)
			break

func get_game_time() -> int:
	return game_time

func get_real_time() -> int:
	return Time.get_unix_time_from_system() - real_time_start

func get_time_scale() -> float:
	return time_scale

func set_time_scale(scale: float):
	time_scale = clamp(scale, 0.0, 10.0)

func pause_time():
	is_paused = true

func resume_time():
	is_paused = false

func get_current_hour() -> int:
	return current_hour

func get_current_minute() -> int:
	return current_minute

func get_current_second() -> int:
	return current_second

func get_time_string() -> String:
	return "%02d:%02d:%02d" % [current_hour, current_minute, current_second]

func get_season() -> String:
	return season

func get_season_progress() -> float:
	return season_progress

func get_weather() -> String:
	return weather

func get_game_date() -> Dictionary:
	return {
		"year": 1,
		"season": season,
		"day": (game_time / day_cycle_duration) + 1,
		"hour": current_hour,
		"minute": current_minute,
		"second": current_second
	}

func is_daytime() -> bool:
	return current_hour >= 6 and current_hour < 18

func is_nighttime() -> bool:
	return not is_daytime()

func get_time_of_day() -> String:
	if current_hour >= 5 and current_hour < 7:
		return "黎明"
	elif current_hour >= 7 and current_hour < 12:
		return "上午"
	elif current_hour >= 12 and current_hour < 14:
		return "中午"
	elif current_hour >= 14 and current_hour < 18:
		return "下午"
	elif current_hour >= 18 and current_hour < 20:
		return "黄昏"
	elif current_hour >= 20 and current_hour < 23:
		return "晚上"
	else:
		return "深夜"

func add_game_time(seconds: int):
	game_time += seconds
	_calculate_time_from_game_time()

func _calculate_time_from_game_time():
	var total_seconds = game_time % day_cycle_duration
	current_hour = total_seconds / 3600
	current_minute = (total_seconds % 3600) / 60
	current_second = total_seconds % 60

func set_fixed_time(hour: int, minute: int = 0, second: int = 0):
	current_hour = clamp(hour, 0, 23)
	current_minute = clamp(minute, 0, 59)
	current_second = clamp(second, 0, 59)
	game_time = (current_hour * 3600) + (current_minute * 60) + current_second

func advance_time(hours: float = 1.0):
	add_game_time(int(hours * 3600))

def get_time_until(hour: int, minute: int = 0) -> int:
	var target = hour * 3600 + minute * 60
	var current = current_hour * 3600 + current_minute * 60 + current_second
	var diff = target - current
	if diff <= 0:
		diff += day_cycle_duration
	return diff

func format_duration(seconds: int) -> String:
	var h = seconds / 3600
	var m = (seconds % 3600) / 60
	var s = seconds % 60
	if h > 0:
		return "%d时%d分%d秒" % [h, m, s]
	elif m > 0:
		return "%d分%d秒" % [m, s]
	else:
		return "%d秒" % s

func get_weather_description() -> String:
	var desc = weather
	if weather == "雨":
		desc += "，出行减速"
	elif weather == "雪":
		desc += "，视野受阻"
	elif weather == "雾":
		desc += "，命中降低"
	elif weather == "风":
		desc += "，轻功加成"
	return desc

func to_dict() -> Dictionary:
	return {
		"game_time": game_time,
		"real_time_start": real_time_start,
		"time_scale": time_scale,
		"is_paused": is_paused,
		"current_hour": current_hour,
		"current_minute": current_minute,
		"current_second": current_second,
		"season": season,
		"season_progress": season_progress,
		"weather": weather,
		"weather_timer": weather_timer
	}

func from_dict(data: Dictionary):
	game_time = data.get("game_time", 0)
	real_time_start = data.get("real_time_start", Time.get_unix_time_from_system())
	time_scale = data.get("time_scale", 1.0)
	is_paused = data.get("is_paused", false)
	current_hour = data.get("current_hour", 12)
	current_minute = data.get("current_minute", 0)
	current_second = data.get("current_second", 0)
	season = data.get("season", "春")
	season_progress = data.get("season_progress", 0.0)
	weather = data.get("weather", "晴")
	weather_timer = data.get("weather_timer", 0)