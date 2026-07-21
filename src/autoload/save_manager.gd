extends RefCounted
class_name SaveManager

var save_slots: Dictionary = {}
var current_slot: int = 1
var max_slots: int = 10
var auto_save_interval: int = 300  # 5分钟
var auto_save_timer: int = 0
var is_saving: bool = false

static var instance: SaveManager = null

signal save_started(slot: int)
signal save_completed(slot: int, success: bool)
signal load_started(slot: int)
signal load_completed(slot: int, success: bool)
signal auto_save_triggered()

func _init():
	instance = self
	_load_save_index()

func _load_save_index():
	var file = FileAccess.open("user://save_index.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var json = JSON.parse_string(text)
		if json.error == OK:
			save_slots = json.get_var()
	else:
		save_slots = {}

func _save_save_index():
	var file = FileAccess.open("user://save_index.json", FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(save_slots))
		file.close()

func save_game(slot: int = -1, description: String = "") -> bool:
	if is_saving:
		return false
	
	is_saving = true
	var save_slot = slot if slot > 0 else current_slot
	
	save_started.emit(save_slot)
	EventManager.instance.emit("save_started", save_slot)
	
	var save_data = _create_save_data(description)
	var success = _write_save_file(save_slot, save_data)
	
	if success:
		_update_save_slot_info(save_slot, description)
		_save_save_index()
	
	is_saving = false
	save_completed.emit(save_slot, success)
	EventManager.instance.emit("save_completed", save_slot, success)
	
	return success

func _create_save_data(description: String) -> Dictionary:
	var player = PlayerData.instance
	var combat = CombatManager.instance
	var world = WorldManager.instance
	var pvp = PvPManager.instance
	var guild = GuildManager.instance
	
	var data = {
		"version": GameData.instance.game_version,
		"save_time": Time.get_unix_time_from_system(),
		"description": description if description != "" else _generate_description(),
		"player": player.to_dict(),
		"world": world.get_world_state(),
		"pvp": pvp.to_dict(),
		"guild": guild.to_dict(),
		"combat": combat.get_battle_state(),
		"game_settings": AudioManager.instance.to_dict(),
		"ui_state": UIManager.instance.to_dict(),
		"system": {
			"play_time": Time.get_ticks_msec() / 1000,
			"save_count": save_slots.get(str(save_slot), {"save_count": 0}).save_count + 1
		}
	}
	
	return data

func _generate_description() -> String:
	var player = PlayerData.instance
	var chapter_names = {
		1: "初出茅庐", 2: "江湖初闻", 3: "门派抉择", 4: "江湖风云",
		5: "家国大义", 6: "十大名剑", 7: "魔教现世", 8: "武林大会",
		9: "长夜歌", 10: "苍渊听涛", 11: "踏浪歌行", 12: "大结局"
	}
	
	var chapter_name = chapter_names.get(player.current_chapter, "未知章节")
	return "第%d级 %s %s %d天" % [player.level, chapter_name, player.player_name, player.login_days]

func _write_save_file(slot: int, data: Dictionary) -> bool:
	var file = FileAccess.open("user://save_%d.sav" % slot, FileAccess.WRITE)
	if not file:
		return false
	
	# 压缩和加密
	var json = JSON.new()
	var text = json.stringify(data)
	
	# 简单加密（实际项目中应该用更强的加密）
	var encrypted = _simple_encrypt(text)
	
	file.store_string(encrypted)
	file.close()
	
	return true

func _simple_encrypt(text: String) -> String:
	# 简单的异或加密
	var key = "hanjiajianghu2024"
	var result = ""
	for i in range(text.length()):
		var c = text[i]
		var k = key[i % key.length()]
		result += char(ord(c) ^ ord(k))
	return result

func _simple_decrypt(text: String) -> String:
	return _simple_encrypt(text)  # 异或加密是对称的

func load_game(slot: int) -> bool:
	if not _save_exists(slot):
		return false
	
	load_started.emit(slot)
	EventManager.instance.emit("load_started", slot)
	
	var data = _read_save_file(slot)
	if not data:
		load_completed.emit(slot, false)
		return false
	
	var success = _apply_save_data(data)
	
	if success:
		current_slot = slot
		EventManager.instance.emit("game_loaded", slot)
	
	load_completed.emit(slot, success)
	EventManager.instance.emit("load_completed", slot, success)
	
	return success

func _read_save_file(slot: int) -> Dictionary:
	var file = FileAccess.open("user://save_%d.sav" % slot, FileAccess.READ)
	if not file:
		return null
	
	var encrypted = file.get_as_text()
	file.close()
	
	var text = _simple_decrypt(encrypted)
	var json = JSON.parse_string(text)
	if json.error != OK:
		return null
	
	return json.get_var()

func _apply_save_data(data: Dictionary) -> bool:
	var player = PlayerData.instance if "instance" in PlayerData else PlayerData
	var world = WorldManager.instance if "instance" in WorldManager else WorldManager
	var pvp = PvPManager.instance if "instance" in PvPManager else PvPManager
	var guild = GuildManager.instance if "instance" in GuildManager else GuildManager
	var combat = CombatManager.instance if "instance" in CombatManager else CombatManager
	var audio = AudioManager.instance if "instance" in AudioManager else AudioManager
	var ui = UIManager.instance if "instance" in UIManager else UIManager
	
	if player and player.has_method("from_dict"):
		player.from_dict(data.get("player", {}))
	if world and world.has_method("set_world_state"):
		world.set_world_state(data.get("world", {}))
	if pvp and pvp.has_method("from_dict"):
		pvp.from_dict(data.get("pvp", {}))
	if guild and guild.has_method("from_dict"):
		guild.from_dict(data.get("guild", {}))
	if combat and combat.has_method("from_dict"):
		combat.from_dict(data.get("combat", {}))
	if audio and audio.has_method("from_dict"):
		audio.from_dict(data.get("game_settings", {}))
	if ui and ui.has_method("from_dict"):
		ui.from_dict(data.get("ui_state", {}))
	
	return true

func _save_exists(slot: int) -> bool:
	return FileAccess.file_exists("user://save_%d.sav" % slot)

func _update_save_slot_info(slot: int, description: String):
	save_slots[str(slot)] = {
		"slot": slot,
		"description": description,
		"save_time": Time.get_unix_time_from_system(),
		"player_level": PlayerData.instance.level,
		"player_name": PlayerData.instance.player_name,
		"chapter": PlayerData.instance.current_chapter,
		"play_time": Time.get_ticks_msec() / 1000,
		"save_count": save_slots.get(str(slot), {"save_count": 0}).save_count + 1
	}

func delete_save(slot: int) -> bool:
	if FileAccess.file_exists("user://save_%d.sav" % slot):
		DirAccess.remove_absolute("user://save_%d.sav" % slot)
		save_slots.erase(str(slot))
		_save_save_index()
		return true
	return false

func get_save_info(slot: int) -> Dictionary:
	return save_slots.get(str(slot), {})

func get_all_save_infos() -> Array[Dictionary]:
	var infos = []
	for i in range(1, max_slots + 1):
		var info = get_save_info(i)
		info["slot"] = i
		info["exists"] = _save_exists(i)
		infos.append(info)
	return infos

func get_latest_save() -> int:
	var latest = 0
	var latest_time = 0
	
	for i in range(1, max_slots + 1):
		if _save_exists(i):
			var info = get_save_info(i)
			var time = info.get("save_time", 0)
			if time > latest_time:
				latest_time = time
				latest = i
	
	return latest

func auto_save():
	if is_saving:
		return
	
	auto_save_timer += 1
	if auto_save_timer >= auto_save_interval:
		auto_save_timer = 0
		save_game(current_slot, "自动存档")
		auto_save_triggered.emit()
		EventManager.instance.emit("auto_save")

func update_auto_save_timer(delta: float):
	auto_save_timer += delta

func quick_save():
	save_game(current_slot, "快速存档")

func quick_load() -> bool:
	var slot = get_latest_save()
	if slot > 0:
		return load_game(slot)
	return false

func export_save(slot: int, path: String) -> bool:
	if not _save_exists(slot):
		return false
	
	var file_src = FileAccess.open("user://save_%d.sav" % slot, FileAccess.READ)
	var file_dst = FileAccess.open(path, FileAccess.WRITE)
	
	if file_src and file_dst:
		file_dst.store_string(file_src.get_as_text())
		file_src.close()
		file_dst.close()
		return true
	
	if file_src:
		file_src.close()
	if file_dst:
		file_dst.close()
	
	return false

func import_save(slot: int, path: String) -> bool:
	var file_src = FileAccess.open(path, FileAccess.READ)
	var file_dst = FileAccess.open("user://save_%d.sav" % slot, FileAccess.WRITE)
	
	if file_src and file_dst:
		file_dst.store_string(file_src.get_as_text())
		file_src.close()
		file_dst.close()
		_update_save_slot_info(slot, "导入存档")
		_save_save_index()
		return true
	
	if file_src:
		file_src.close()
	if file_dst:
		file_dst.close()
	
	return false

func get_current_slot() -> int:
	return current_slot

func set_current_slot(slot: int):
	if slot >= 1 and slot <= max_slots:
		current_slot = slot

func to_dict() -> Dictionary:
	return {
		"save_slots": save_slots,
		"current_slot": current_slot,
		"max_slots": max_slots,
		"auto_save_interval": auto_save_interval
	}

func from_dict(data: Dictionary):
	save_slots = data.get("save_slots", {})
	current_slot = data.get("current_slot", 1)
	max_slots = data.get("max_slots", 10)
	auto_save_interval = data.get("auto_save_interval", 300)
