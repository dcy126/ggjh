extends Node
class_name WorldManager

var areas: Dictionary = {}
var current_area: WorldArea = null
var visited_areas: Dictionary = {}
var area_progress: Dictionary = {}
var npcs_in_area: Dictionary = {}
var events_in_area: Dictionary = {}
var treasures_in_area: Dictionary = {}
var world_time: int = 0
var day_cycle: int = 0
var weather: String = "晴"
var season: String = "春"
var rng: RandomNumberGenerator

static var instance = null

static func get_instance():
	return instance

func _enter_tree():
	instance = self
	rng = RandomNumberGenerator.new()
	_load_world_data()

func _load_world_data():
	_create_areas()
	_create_world_events()
	_initialize_time()

func _create_areas():
	# 主城区域
	var area = WorldArea.new()
	area.id = "hangzhou"
	area.name = "杭州"
	area.description = "江南繁华都市，西湖美景，武林人士云集"
	area.type = "主城"
	area.level_range = Vector2i(1, 20)
	area.connected_areas = ["hangzhou_outskirts", "west_lake", "suzhou"]
	area.npcs = ["npc_hangzhou_innkeeper", "npc_hangzhou_blacksmith", "npc_hangzhou_apothecary", "npc_hangzhou_storyteller", "npc_hangzhou_teahouse", "npc_hangzhou_constable", "npc_hangzhou_merchant", "npc_hangzhou_beggar", "npc_hangzhou_guard", "npc_hangzhou_yamen"]
	area.shops = ["hangzhou_weapon_shop", "hangzhou_armor_shop", "hangzhou_item_shop", "hangzhou_book_shop"]
	area.features = ["西湖", "断桥", "雷峰塔", "灵隐寺", "苏堤"]
	area.events = ["event_hangzhou_festival", "event_hangzhou_tournament"]
	area.secret_locations = ["hangzhou_secret_cave", "hangzhou_underground_market"]
	area.background_music = "hangzhou_theme"
	area.background_image = "hangzhou_bg"
	
	areas[area.id] = area
	
	# 杭州郊外
	area = WorldArea.new()
	area.id = "hangzhou_outskirts"
	area.name = "杭州郊外"
	area.description = "西湖周边山林，野兽出没，适合新手历练"
	area.type = "野外"
	area.level_range = Vector2i(1, 10)
	area.connected_areas = ["hangzhou", "west_lake", "bamboo_forest"]
	area.npcs = ["npc_hunter", "npc_herbalist", "npc_wanderer"]
	area.enemies = ["wolf", "bandit", "wild_boar", "snake"]
	area.resources = ["herb", "wood", "ore"]
	area.dungeons = ["wolf_den", "bandit_camp"]
	area.events = ["event_wild_encounter"]
	
	areas[area.id] = area
	
	# 西湖
	area = WorldArea.new()
	area.id = "west_lake"
	area.name = "西湖"
	area.description = "杭州标志性景点，藏有不少江湖秘密"
	area.type = "景点"
	area.level_range = Vector2i(5, 15)
	area.connected_areas = ["hangzhou", "hangzhou_outskirts", "broken_bridge", "leifeng_pagoda"]
	area.npcs = ["npc_fisherman", "npc_boatman", "npc_poet"]
	area.features = ["断桥残雪", "苏堤春晓", "三潭印月", "雷峰夕照"]
	area.secret_locations = ["white_snake_cave", "xu_xian_home"]
	area.events = ["event_west_lake_poetry", "event_west_lake_moon"]
	
	areas[area.id] = area
	
	# 苏州
	area = WorldArea.new()
	area.id = "suzhou"
	area.name = "苏州"
	area.description = "江南水乡，园林甲天下，暗流涌动"
	area.type = "主城"
	area.level_range = Vector2i(15, 30)
	area.connected_areas = ["hangzhou", "tiger_hill", "hanshan_temple", "tai_lake"]
	area.npcs = ["npc_suzhou_innkeeper", "npc_suzhou_blacksmith", "npc_suzhou_apothecary", "npc_suzhou_storyteller", "npc_suzhou_garden_owner"]
	area.shops = ["suzhou_weapon_shop", "suzhou_armor_shop", "suzhou_item_shop", "suzhou_silk_shop"]
	area.features = ["拙政园", "留园", "虎丘", "寒山寺", "太湖"]
	area.events = ["event_suzhou_garden_party", "event_suzhou_silk_road"]
	
	areas[area.id] = area
	
	# 洛阳
	area = WorldArea.new()
	area.id = "luoyang"
	area.name = "洛阳"
	area.description = "河洛帮总部所在，十三朝古都，帮派势力盘根错节"
	area.type = "主城"
	area.level_range = Vector2i(20, 40)
	area.connected_areas = ["heluo_hq", "longmen_grottoes", "white_horse_temple", "luoyang_outskirts"]
	area.npcs = ["npc_luoyang_heluo_leader", "npc_luoyang_heluo_elder1", "npc_luoyang_heluo_elder2", "npc_luoyang_heluo_disciple1", "npc_luoyang_heluo_disciple2", "npc_luoyang_innkeeper", "npc_luoyang_blacksmith"]
	area.shops = ["luoyang_weapon_shop", "luoyang_armor_shop", "luoyang_item_shop", "luoyang_heluo_shop"]
	area.features = ["龙门石窟", "白马寺", "关林", "洛阳牡丹"]
	area.events = ["event_heluo_tournament", "event_luoyang_peony"]
	
	areas[area.id] = area
	
	# 京城
	area = WorldArea.new()
	area.id = "capital"
	area.name = "京城"
	area.description = "皇权中心，天武军驻地，武林盟主府所在"
	area.type = "主城"
	area.level_range = Vector2i(30, 50)
	area.connected_areas = ["imperial_palace", "wulin_alliance", "tianwu_hq", "capital_outskirts"]
	area.npcs = ["npc_emperor", "npc_wulin_alliance_leader", "npc_tianwu_commander", "npc_capital_innkeeper", "npc_capital_blacksmith", "npc_capital_apothecary"]
	area.shops = ["capital_weapon_shop", "capital_armor_shop", "capital_item_shop", "capital_royal_shop"]
	area.features = ["皇宫", "武林盟主府", "天武府", "论剑台", "御花园"]
	area.events = ["event_lunjian_season", "event_wulin_conference", "event_imperial_exam"]
	
	areas[area.id] = area
	
	# 门派地图
	for sect in SectDatabase.instance.get_all_sects():
		area = WorldArea.new()
		area.id = "sect_%s" % sect.id
		area.name = sect.name
		area.description = sect.background_story
		area.type = "门派"
		area.level_range = Vector2i(10, 60)
		area.connected_areas = ["capital"] if sect.id == "tianwu" else ["luoyang"] if sect.id == "heluo" else ["hangzhou"]
		area.npcs = ["npc_sect_%s_leader" % sect.id, "npc_sect_%s_elder_0" % sect.id, "npc_sect_%s_elder_1" % sect.id, "npc_sect_%s_elder_2" % sect.id]
		for i in range(5):
			area.npcs.append("npc_sect_%s_disciple_%d" % [sect.id, i])
		area.shops = ["sect_%s_shop" % sect.id]
		area.features = ["练功房", "藏经阁", "议事厅", "后山试剑台"]
		area.events = ["event_sect_%s_tournament" % sect.id]
		area.secret_locations = ["sect_%s_forbidden" % sect.id]
		
		areas[area.id] = area
	
	# 野外地图
	var wild_areas = [
		{"id": "bamboo_forest", "name": "竹林", "desc": "茂密竹林，隐世高人常居于此", "level": Vector2i(10, 20), "connected": ["hangzhou_outskirts", "west_lake"], "enemies": ["bamboo_spirit", "panda", "hidden_master"], "resources": ["bamboo", "rare_herb"]},
		{"id": "tiger_hill", "name": "虎丘", "desc": "苏州名胜，藏有吴王剑冢", "level": Vector2i(20, 35), "connected": ["suzhou", "sword_tomb"], "enemies": ["tiger", "sword_ghost", "tomb_guardian"], "features": ["剑池", "云岩寺塔", "吴王剑冢"]},
		{"id": "tai_lake", "name": "太湖", "desc": "五大淡水湖之一，水贼横行", "level": Vector2i(15, 30), "connected": ["suzhou", "dongting_mountain"], "enemies": ["water_bandit", "lake_monster", "pirate"], "features": ["洞庭山", "三山岛", "渔村"]},
		{"id": "longmen_grottoes", "name": "龙门石窟", "desc": "世界文化遗产，石窟深处藏有秘密", "level": Vector2i(25, 40), "connected": ["luoyang", "grotto_depths"], "enemies": ["stone_guardian", "buddha_ghost", "demon"], "features": ["奉先寺", "莲花洞", "古阳洞"]},
		{"id": "white_horse_temple", "name": "白马寺", "desc": "中国第一古刹，禅意深沉", "level": Vector2i(20, 35), "connected": ["luoyang", "temple_back_mountain"], "enemies": ["corrupt_monk", "demon_monk", "guardian_arhat"], "features": ["大雄宝殿", "清凉台", "毗卢阁"]},
		{"id": "imperial_palace", "name": "皇宫", "desc": "龙椅之下，暗藏杀机", "level": Vector2i(40, 60), "connected": ["capital", "imperial_garden"], "enemies": ["imperial_guard", "eunuch_master", "emperor_shadow"], "features": ["太和殿", "乾清宫", "御花园", "冷宫"]},
		{"id": "wulin_alliance", "name": "武林盟主府", "desc": "武林至尊居所，群雄毕至", "level": Vector2i(35, 55), "connected": ["capital", "lunjian_tai"], "enemies": ["alliance_elder", "challenger", "assassin"], "features": ["论剑台", "观武楼", "藏剑阁", "盟主大殿"]},
		{"id": "tianwu_hq", "name": "天武府", "desc": "天武军大本营，军纪严明", "level": Vector2i(30, 50), "connected": ["capital", "tianwu_training"], "enemies": ["tianwu_soldier", "tianwu_officer", "tianwu_general"], "features": ["演武场", "军械库", "统领府", "军医院"]},
		{"id": "hanshan_temple", "name": "寒山寺", "desc": "枫桥夜泊，钟声悠远", "level": Vector2i(15, 30), "connected": ["suzhou", "maple_bridge"], "enemies": ["monk", "ghost", "poet_ghost"], "features": ["大雄宝殿", "钟楼", "枫桥", "唐诗墙"]},
		{"id": "dongting_mountain", "name": "洞庭山", "desc": "太湖仙山，碧螺春产地", "level": Vector2i(20, 35), "connected": ["tai_lake", "tea_forest"], "enemies": ["tea_spirit", "monkey", "hermit"], "features": ["碧螺春茶园", "云峰", "陆羽泉"]},
		{"id": "temple_back_mountain", "name": "寺庙后山", "desc": "古刹后山，幽静深邃", "level": Vector2i(25, 40), "connected": ["white_horse_temple", "ancient_cave"], "enemies": ["cave_demon", "bat_swarm", "ancient_guardian"], "features": ["古洞", "地下河", "佛骨舍利"]},
		{"id": "imperial_garden", "name": "御花园", "desc": "皇家园林，美景藏杀机", "level": Vector2i(35, 55), "connected": ["imperial_palace", "concubine_palace"], "enemies": ["garden_assassin", "poison_flower", "imperial_cat"], "features": ["假山", "鱼池", "亭台楼阁", "梅花林"]},
		{"id": "concubine_palace", "name": "冷宫", "desc": "失宠妃嫔居所，怨气冲天", "level": Vector2i(40, 60), "connected": ["imperial_garden", "underground_passage"], "enemies": ["vengeful_concubine", "ghost_maid", "dark_guardian"], "features": ["枯井", "血书", "密道入口"]},
		{"id": "underground_passage", "name": "地下密道", "desc": "连通皇宫各处的秘密通道", "level": Vector2i(45, 60), "connected": ["concubine_palace", "imperial_treasury", "escape_route"], "enemies": ["trap", "mechanism", "shadow_guard"], "features": ["机关陷阱", "暗河", "宝藏库"]},
		{"id": "escape_route", "name": "逃亡路线", "desc": "皇族逃亡的秘密通道", "level": Vector2i(50, 70), "connected": ["underground_passage", "outside_capital"], "enemies": ["final_guardian", "ancient_evil"], "features": ["崩塌通道", "最后防线", "出口"]},
		{"id": "outside_capital", "name": "京城外围", "desc": "京城外围，山贼土匪盘踞", "level": Vector2i(30, 50), "connected": ["escape_route", "northern_wilderness"], "enemies": ["mountain_bandit", "warlord", "refugee"], "features": ["难民营", "土匪窝", "古战场"]},
		{"id": "northern_wilderness", "name": "北疆荒原", "desc": "北朝边境，战火纷飞", "level": Vector2i(50, 70), "connected": ["outside_capital", "border_fortress", "nomad_camp"], "enemies": ["northern_soldier", "nomad_warrior", "warlord"], "features": ["边关要塞", "游牧部落", "古长城", "战场遗骸"]},
		{"id": "border_fortress", "name": "边关要塞", "desc": "守边重镇，军令如山", "level": Vector2i(55, 75), "connected": ["northern_wilderness", "nomad_camp", "beyond_border"], "enemies": ["elite_soldier", "general", "spy"], "features": ["将台", "兵营", "粮仓", "烽火台"]},
		{"id": "nomad_camp", "name": "游牧部落", "desc": "北方游牧民族聚居地", "level": Vector2i(50, 70), "connected": ["northern_wilderness", "border_fortress", "shaman_tent"], "enemies": ["nomad_warrior", "shaman", "wolf_rider"], "features": ["大帐", "萨满帐", "马场", "祭坛"]},
		{"id": "beyond_border", "name": "塞外", "desc": "长城之外，未知领域", "level": Vector2i(60, 80), "connected": ["border_fortress", "ancient_ruins", "dragon_valley"], "enemies": ["ancient_beast", "dragon_kin", "void_creature"], "features": ["古遗迹", "龙谷", "虚空裂隙", "终极BOSS"]},
	]
	
	for a in wild_areas:
		area = WorldArea.new()
		area.id = a["id"]
		area.name = a["name"]
		area.description = a["desc"]
		area.type = "野外"
		area.level_range = a["level"]
		area.connected_areas = a["connected"]
		if a.has("enemies"):
			area.enemies = a["enemies"]
		if a.has("resources"):
			area.resources = a["resources"]
		if a.has("features"):
			area.features = a["features"]
		areas[area.id] = area
	
	# 特殊地图：副本/秘境
	var special_areas = [
		{"id": "wolf_den", "name": "狼穴", "type": "副本", "level": Vector2i(5, 15), "parent": "hangzhou_outskirts", "boss": "alpha_wolf", "rewards": ["wolf_pelt", "fang", "exp"]},
		{"id": "bandit_camp", "name": "山贼窝", "type": "副本", "level": Vector2i(8, 18), "parent": "hangzhou_outskirts", "boss": "bandit_leader", "rewards": ["copper", "iron_ore", "map_fragment"]},
		{"id": "sword_tomb", "name": "吴王剑冢", "type": "副本", "level": Vector2i(30, 50), "parent": "tiger_hill", "boss": "sword_spirit", "rewards": ["famous_sword", "sword_manual", "xinfa"]},
		{"id": "grotto_depths", "name": "石窟深处", "type": "副本", "level": Vector2i(35, 55), "parent": "longmen_grottoes", "boss": "stone_buddha", "rewards": ["buddha_relic", "zen_manual", "title"]},
		{"id": "temple_back_mountain", "name": "后山古洞", "type": "副本", "level": Vector2i(30, 50), "parent": "white_horse_temple", "boss": "ancient_demon", "rewards": ["demon_essence", "dark_manual", "equipment"]},
		{"id": "imperial_treasury", "name": "御用藏宝库", "type": "副本", "level": Vector2i(50, 70), "parent": "underground_passage", "boss": "treasure_guardian", "rewards": ["imperial_treasure", "dragon_equipment", "red_xinfa"]},
		{"id": "ancient_ruins", "name": "古遗迹", "type": "副本", "level": Vector2i(65, 80), "parent": "beyond_border", "boss": "ancient_god", "rewards": ["god_equipment", "mythic_xinfa", "title"]},
		{"id": "dragon_valley", "name": "龙谷", "type": "副本", "level": Vector2i(70, 80), "parent": "beyond_border", "boss": "dragon_king", "rewards": ["dragon_heart", "dragon_manual", "red_equipment"]},
		{"id": "haishi_shenlou", "name": "海市蜃楼", "type": "秘境", "level": Vector2i(40, 60), "parent": "capital", "boss": "mirage_lord", "rewards": ["xinfa_materials", "rare_equipment", "title"], "schedule": "限时开放"},
		{"id": "liexing_tower", "name": "列星塔", "type": "挑战塔", "level": Vector2i(50, 80), "parent": "capital", "boss": "floor_guardian", "rewards": ["star_rewards", "title", "skin"], "floors": 100},
		{"id": "guild_secret_realm", "name": "帮会秘境", "type": "帮会副本", "level": Vector2i(25, 60), "parent": "guild_hall", "boss": "realm_boss", "rewards": ["secret_realm_materials", "guild_contribution", "potential_pill"], "schedule": "周三六日"},
		{"id": "sihai_fusheng", "name": "四海浮生记", "type": "剧情副本", "level": Vector2i(35, 55), "parent": "tai_lake", "boss": "dragon_king", "rewards": ["story_rewards", "character_ji_lin", "skin"], "chapters": 2},
		{"id": "taoyuan", "name": "桃源", "type": "活动地图", "level": Vector2i(15, 60), "parent": "random", "boss": "peach_blossom_spirit", "rewards": ["peach_skin", "title", "pet"], "schedule": "七夕限定"},
	]
	
	for a in special_areas:
		area = WorldArea.new()
		area.id = a["id"]
		area.name = a["name"]
		area.type = a["type"]
		area.level_range = a["level"]
		area.connected_areas = [a["parent"]]
		area.boss = a.get("boss", "")
		area.rewards = a.get("rewards", [])
		area.schedule = a.get("schedule", "")
		area.floors = a.get("floors", 1)
		area.chapters = a.get("chapters", 1)
		areas[area.id] = area

func _create_world_events():
	# 动态世界事件
	pass

func _initialize_time():
	world_time = 0
	day_cycle = 0
	weather = "晴"
	season = "春"

func advance_time(hours: int = 1):
	world_time += hours * 3600
	day_cycle = (world_time / 3600) % 24
	
	# 更新天气/季节
	if world_time % (24 * 3600 * 30) == 0:
		_change_season()
	
	if rng.randf() < 0.1:
		_change_weather()

func _change_season():
	var seasons = ["春", "夏", "秋", "冬"]
	var idx = seasons.find(season)
	season = seasons[(idx + 1) % 4]

func _change_weather():
	var weathers = ["晴", "雨", "雪", "雾", "阴", "风"]
	weather = weathers[rng.randi_range(0, weathers.size() - 1)]

func get_current_time_text() -> String:
	var hour = day_cycle
	var period = "上午" if hour < 12 else "下午"
	var display_hour = hour if hour <= 12 else hour - 12
	if display_hour == 0:
		display_hour = 12
	return "%s %d:00 %s %s" % [season, display_hour, period, weather]

func get_area(id: String) -> WorldArea:
	return areas.get(id)

func get_all_areas() -> Array[WorldArea]:
	return areas.values()

func get_connected_areas(area_id: String) -> Array[WorldArea]:
	var area = areas.get(area_id)
	if not area:
		return []
	var result = []
	for connected_id in area.connected_areas:
		var connected = areas.get(connected_id)
		if connected:
			result.append(connected)
	return result

func can_travel_to(from_area: String, to_area: String) -> bool:
	var from = areas.get(from_area)
	if not from:
		return false
	return to_area in from.connected_areas

func travel_to(area_id: String) -> bool:
	if not areas.has(area_id):
		return false
	
	current_area = areas[area_id]
	
	if not visited_areas.has(area_id):
		visited_areas[area_id] = {"first_visit_time": world_time, "visit_count": 1}
	else:
		visited_areas[area_id]["visit_count"] += 1
		visited_areas[area_id]["last_visit_time"] = world_time
	
	area_progress[area_id] = area_progress.get(area_id, 0) + 1
	
	EventManager.instance.emit("area_changed", area_id)
	return true

func get_area_npcs(area_id: String) -> Array[NPCData]:
	var area = areas.get(area_id)
	if not area:
		return []
	var result = []
	for npc_id in area.npcs:
		var npc = StoryDatabase.instance.get_npc(npc_id)
		if npc:
			result.append(npc)
	return result

func get_area_enemies(area_id: String) -> Array[String]:
	var area = areas.get(area_id)
	if not area:
		return []
	return area.enemies

func get_area_events(area_id: String) -> Array[WorldEvent]:
	var area = areas.get(area_id)
	if not area:
		return []
	var result = []
	for event_id in area.events:
		var evt = StoryDatabase.instance.get_world_event(event_id)
		if evt:
			result.append(evt)
	return result

func discover_secret_location(area_id: String, location_id: String) -> bool:
	var area = areas.get(area_id)
	if not area:
		return false
	if location_id in area.secret_locations:
		if not area_progress.has("secrets"):
			area_progress["secrets"] = []
		if location_id not in area_progress["secrets"]:
			area_progress["secrets"].append(location_id)
			EventManager.instance.emit("secret_discovered", area_id, location_id)
			return true
	return false

func get_world_state() -> Dictionary:
	return {
		"current_area": current_area.id if current_area else "",
		"world_time": world_time,
		"day_cycle": day_cycle,
		"weather": weather,
		"season": season,
		"visited_areas": visited_areas,
		"area_progress": area_progress
	}

func set_world_state(state: Dictionary):
	current_area = areas.get(state.get("current_area", ""))
	world_time = state.get("world_time", 0)
	day_cycle = state.get("day_cycle", 0)
	weather = state.get("weather", "晴")
	season = state.get("season", "春")
	visited_areas = state.get("visited_areas", {})
	area_progress = state.get("area_progress", {})