extends Node
class_name AudioManager

var bgm_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var current_bgm: String = ""
var bgm_volume: float = 0.8
var sfx_volume: float = 0.8
var master_volume: float = 1.0
var fade_duration: float = 1.0
var is_fading: bool = false

var bgm_library: Dictionary = {}
var sfx_library: Dictionary = {}

static var instance: AudioManager = null

func _enter_tree():
	instance = self
	_setup_audio_players()
	_load_audio_library()

func _setup_audio_players():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)
	
	for i in range(16):
		var sfx = AudioStreamPlayer.new()
		sfx.bus = "SFX"
		sfx_players.append(sfx)
		add_child(sfx)

func _load_audio_library():
	# 这里应该从资源文件加载，暂时用占位符
	bgm_library = {
		"main_menu": "res://src/assets/audio/bgm/main_menu.ogg",
		"hangzhou": "res://src/assets/audio/bgm/hangzhou.ogg",
		"suzhou": "res://src/assets/audio/bgm/suzhou.ogg",
		"luoyang": "res://src/assets/audio/bgm/luoyang.ogg",
		"capital": "res://src/assets/audio/bgm/capital.ogg",
		"battle_normal": "res://src/assets/audio/bgm/battle_normal.ogg",
		"battle_boss": "res://src/assets/audio/bgm/battle_boss.ogg",
		"battle_pvp": "res://src/assets/audio/bgm/battle_pvp.ogg",
		"sect_hengshan": "res://src/assets/audio/bgm/sect_hengshan.ogg",
		"sect_huashan": "res://src/assets/audio/bgm/sect_huashan.ogg",
		"sect_daomo": "res://src/assets/audio/bgm/sect_daomo.ogg",
		"exploration": "res://src/assets/audio/bgm/exploration.ogg",
		"story_calm": "res://src/assets/audio/bgm/story_calm.ogg",
		"story_tense": "res://src/assets/audio/bgm/story_tense.ogg",
		"victory": "res://src/assets/audio/bgm/victory.ogg",
		"defeat": "res://src/assets/audio/bgm/defeat.ogg"
	}
	
	sfx_library = {
		"click": "res://src/assets/audio/sfx/click.ogg",
		"confirm": "res://src/assets/audio/sfx/confirm.ogg",
		"cancel": "res://src/assets/audio/sfx/cancel.ogg",
		"level_up": "res://src/assets/audio/sfx/level_up.ogg",
		"get_item": "res://src/assets/audio/sfx/get_item.ogg",
		"get_gold": "res://src/assets/audio/sfx/get_gold.ogg",
		"get_exp": "res://src/assets/audio/sfx/get_exp.ogg",
		"attack_melee": "res://src/assets/audio/sfx/attack_melee.ogg",
		"attack_ranged": "res://src/assets/audio/sfx/attack_ranged.ogg",
		"attack_magic": "res://src/assets/audio/sfx/attack_magic.ogg",
		"hit_normal": "res://src/assets/audio/sfx/hit_normal.ogg",
		"hit_crit": "res://src/assets/audio/sfx/hit_crit.ogg",
		"hit_block": "res://src/assets/audio/sfx/hit_block.ogg",
		"dodge": "res://src/assets/audio/sfx/dodge.ogg",
		"heal": "res://src/assets/audio/sfx/heal.ogg",
		"shield": "res://src/assets/audio/sfx/shield.ogg",
		"buff": "res://src/assets/audio/sfx/buff.ogg",
		"debuff": "res://src/assets/audio/sfx/debuff.ogg",
		"stun": "res://src/assets/audio/sfx/stun.ogg",
		"poison": "res://src/assets/audio/sfx/poison.ogg",
		"burn": "res://src/assets/audio/sfx/burn.ogg",
		"bleed": "res://src/assets/audio/sfx/bleed.ogg",
		"counter": "res://src/assets/audio/sfx/counter.ogg",
		"combo": "res://src/assets/audio/sfx/combo.ogg",
		"ultimate": "res://src/assets/audio/sfx/ultimate.ogg",
		"move": "res://src/assets/audio/sfx/move.ogg",
		"qi_full": "res://src/assets/audio/sfx/qi_full.ogg",
		"rage_full": "res://src/assets/audio/sfx/rage_full.ogg",
		"victory_fanfare": "res://src/assets/audio/sfx/victory_fanfare.ogg",
		"defeat_sound": "res://src/assets/audio/sfx/defeat_sound.ogg",
		"treasure_open": "res://src/assets/audio/sfx/treasure_open.ogg",
		"craft_success": "res://src/assets/audio/sfx/craft_success.ogg",
		"craft_fail": "res://src/assets/audio/sfx/craft_fail.ogg",
		"enhance_success": "res://src/assets/audio/sfx/enhance_success.ogg",
		"enhance_fail": "res://src/assets/audio/sfx/enhance_fail.ogg",
		"recruit": "res://src/assets/audio/sfx/recruit.ogg",
		"quest_complete": "res://src/assets/audio/sfx/quest_complete.ogg",
		"dialogue_next": "res://src/assets/audio/sfx/dialogue_next.ogg",
		"page_turn": "res://src/assets/audio/sfx/page_turn.ogg",
		"notification": "res://src/assets/audio/sfx/notification.ogg",
		"warning": "res://src/assets/audio/sfx/warning.ogg",
		"countdown": "res://src/assets/audio/sfx/countdown.ogg"
	}

func play_bgm(bgm_name: String, fade: bool = true):
	if not bgm_library.has(bgm_name):
		print("BGM not found: ", bgm_name)
		return
	
	if current_bgm == bgm_name and bgm_player.playing:
		return
	
	var stream = load(bgm_library[bgm_name])
	if not stream:
		print("Failed to load BGM: ", bgm_name)
		return
	
	if fade and bgm_player.playing:
		_fade_and_switch(stream, bgm_name)
	else:
		bgm_player.stream = stream
		bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)
		bgm_player.play()
		current_bgm = bgm_name

func _fade_and_switch(new_stream: AudioStream, new_name: String):
	is_fading = true
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
	tween.tween_callback(_switch_bgm.bind(new_stream, new_name))
	tween.tween_property(bgm_player, "volume_db", linear_to_db(bgm_volume * master_volume), fade_duration)
	tween.tween_callback(_on_fade_complete)
	tween.play()

func _switch_bgm(new_stream: AudioStream, new_name: String):
	bgm_player.stream = new_stream
	current_bgm = new_name

func _on_fade_complete():
	is_fading = false

func stop_bgm(fade: bool = true):
	if not bgm_player.playing:
		return
	
	if fade:
		var tween = create_tween()
		tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(bgm_player.stop.bind())
		tween.play()
	else:
		bgm_player.stop()
	
	current_bgm = ""

func pause_bgm():
	bgm_player.pause()

func resume_bgm():
	bgm_player.unpause()

func play_sfx(sfx_name: String, volume_scale: float = 1.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	if not sfx_library.has(sfx_name):
		return null
	
	var stream = load(sfx_library[sfx_name])
	if not stream:
		return null
	
	var player = _get_free_sfx_player()
	if not player:
		return null
	
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume * master_volume * volume_scale)
	player.pitch_scale = pitch_scale
	player.play()
	
	return player

func play_sfx_at_position(sfx_name: String, position: Vector2, volume_scale: float = 1.0):
	var player = play_sfx(sfx_name, volume_scale)
	if player:
		# 3D音效需要AudioStreamPlayer3D，这里简化处理
		pass

func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	
	# 如果都在播放，找最旧的
	var oldest = sfx_players[0]
	for player in sfx_players:
		if player.get_playback_position() > oldest.get_playback_position():
			oldest = player
	return oldest

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_all_volumes()

func set_bgm_volume(volume: float):
	bgm_volume = clamp(volume, 0.0, 1.0)
	if bgm_player.playing:
		bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func _update_all_volumes():
	if bgm_player.playing:
		bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)
	for player in sfx_players:
		if player.playing:
			# SFX音量在播放时已设置
			pass

func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log10(linear)

func get_current_bgm() -> String:
	return current_bgm

func is_bgm_playing() -> bool:
	return bgm_player.playing

func get_bgm_progress() -> float:
	if bgm_player.playing and bgm_player.stream:
		var length = bgm_player.stream.get_length()
		if length > 0:
			return bgm_player.get_playback_position() / length
	return 0.0

func seek_bgm(position: float):
	if bgm_player.playing and bgm_player.stream:
		var length = bgm_player.stream.get_length()
		bgm_player.seek(length * clamp(position, 0.0, 1.0))

func preload_bgm(bgm_name: String):
	if bgm_library.has(bgm_name):
		load_thread(bgm_library[bgm_name])

func preload_sfx(sfx_name: String):
	if sfx_library.has(sfx_name):
		load_thread(sfx_library[sfx_name])

func to_dict() -> Dictionary:
	return {
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"master_volume": master_volume,
		"current_bgm": current_bgm
	}

func from_dict(data: Dictionary):
	set_master_volume(data.get("master_volume", 1.0))
	set_bgm_volume(data.get("bgm_volume", 0.8))
	set_sfx_volume(data.get("sfx_volume", 0.8))
	if data.has("current_bgm"):
		play_bgm(data["current_bgm"], false)
