extends Node
class_name StoryDatabase

var story_chapters: Dictionary = {}
var story_events: Dictionary = {}
var dialogues: Dictionary = {}
var quests: Dictionary = {}
var choices: Dictionary = {}
var world_states: Dictionary = {}
var npcs: Dictionary = {}
var world_events: Dictionary = {}
var rng: RandomNumberGenerator

static var instance = null

static func get_instance():
	return instance

func _enter_tree():
	instance = self
	rng = RandomNumberGenerator.new()
	rng.randomize()
	_load_all_story_data()

func _load_all_story_data():
	_create_chapters()
	_create_main_quests()
	_create_side_quests()
	_create_npcs()
	_create_world_events()
	_create_dialogues()
	_build_indices()

func _create_chapters():
	# 第一章：初出茅庐
	var ch = StoryChapter.new()
	ch.id = "chapter_1"
	ch.name = "第一章：初出茅庐"
	ch.description = "少年离家闯荡江湖，初识武学奥义"
	ch.unlock_level = 1
	ch.map_areas = ["杭州", "杭州郊外", "西湖"] as Array[String]
	ch.main_quest = "quest_ch1_main"
	ch.side_quests = ["quest_ch1_side_1", "quest_ch1_side_2"] as Array[String]
	ch.boss_battle = "battle_ch1_boss"
	ch.rewards = {"exp": 5000, "copper": 10000, "items": ["wooden_sword", "cloth_clothes"]}
	ch.choices = ["choice_ch1_join_sector", "choice_ch1_help_beggar"] as Array[String]
	story_chapters[ch.id] = ch
	
	# 第二章：江湖初闻
	ch = StoryChapter.new()
	ch.id = "chapter_2"
	ch.name = "第二章：江湖初闻"
	ch.description = "初入江湖，结识同道，初闻门派纷争"
	ch.unlock_level = 10
	ch.map_areas = ["杭州", "苏州", "太湖", "虎丘"] as Array[String]
	ch.main_quest = "quest_ch2_main"
	ch.side_quests = ["quest_ch2_side_1", "quest_ch2_side_2", "quest_ch2_side_3"] as Array[String]
	ch.boss_battle = "battle_ch2_boss"
	ch.rewards = {"exp": 15000, "copper": 30000, "items": ["iron_sword", "leather_armor"]}
	ch.choices = ["choice_ch2_sect_choice", "choice_ch2_save_girl"] as Array[String]
	story_chapters[ch.id] = ch
	
	# 第三章：门派抉择
	ch = StoryChapter.new()
	ch.id = "chapter_3"
	ch.name = "第三章：门派抉择"
	ch.description = "加入门派，习得绝学，卷入门派恩怨"
	ch.unlock_level = 20
	ch.map_areas = ["恒山", "华山", "昆仑山", "洛阳", "铁石岛"] as Array[String]
	ch.main_quest = "quest_ch3_main"
	ch.side_quests = ["quest_ch3_side_1", "quest_ch3_side_2", "quest_ch3_side_3", "quest_ch3_side_4"] as Array[String]
	ch.boss_battle = "battle_ch3_boss"
	ch.rewards = {"exp": 30000, "copper": 50000, "items": ["sect_weapon", "sect_xinfa"]}
	ch.choices = ["choice_ch3_sect_loyalty", "choice_ch3_rival"] as Array[String]
	story_chapters[ch.id] = ch
	
	# 第四章：江湖风云
	ch = StoryChapter.new()
	ch.id = "chapter_4"
	ch.name = "第四章：江湖风云"
	ch.description = "门派大比，论剑天下，结识红颜知己"
	ch.unlock_level = 30
	ch.map_areas = ["京城", "少林寺", "武当山", "峨眉山", "五岳"] as Array[String]
	ch.main_quest = "quest_ch4_main"
	ch.side_quests = ["quest_ch4_side_1", "quest_ch4_side_2", "quest_ch4_side_3"] as Array[String]
	ch.boss_battle = "battle_ch4_boss"
	ch.rewards = {"exp": 50000, "copper": 100000, "items": ["famous_sword", "rare_xinfa"]}
	ch.choices = ["choice_ch4_love", "choice_ch4_righteousness"] as Array[String]
	story_chapters[ch.id] = ch
	
	# 第五~十二章...
	for i in range(5, 13):
		ch = StoryChapter.new()
		ch.id = "chapter_%d" % i
		ch.name = "第%d章：%s" % [i, _get_chapter_name(i)]
		ch.description = _get_chapter_desc(i)
		ch.unlock_level = (i - 1) * 10
		ch.map_areas = _get_chapter_areas(i)
		ch.main_quest = "quest_ch%d_main" % i
		ch.side_quests = _get_chapter_side_quests(i)
		ch.boss_battle = "battle_ch%d_boss" % i
		ch.rewards = {"exp": i * 10000, "copper": i * 20000}
		ch.choices = _get_chapter_choices(i)
		story_chapters[ch.id] = ch

func _get_chapter_name(idx: int) -> String:
	var names = {
		5: "家国大义",
		6: "十大名剑",
		7: "魔教现世",
		8: "武林大会",
		9: "长夜歌",
		10: "苍渊听涛",
		11: "踏浪歌行",
		12: "大结局"
	}
	return names.get(idx, "未知章节")

func _get_chapter_desc(idx: int) -> String:
	var descs = {
		5: "抗击外敌，家国大义，少年成长为大侠",
		6: "寻找十大名剑，揭开名剑背后的秘密",
		7: "魔教重现江湖，正邪大战一触即发",
		8: "武林大会召开，群雄逐鹿，谁主沉浮",
		9: "长夜将尽，真相大白，最终决战",
		10: "苍渊听涛，新的篇章开启",
		11: "浪子归潮，剑定澜起",
		12: "尘埃落定，江湖再无江湖"
	}
	return descs.get(idx, "")

func _get_chapter_areas(idx: int) -> Array[String]:
	var areas = {
		5: ["北疆", "边关", "塞外", "大漠"] as Array[String],
		6: ["名剑山庄", "剑冢", "紫禁城", "天山"] as Array[String],
		7: ["魔教总坛", "地牢", "血池", "祭坛"] as Array[String],
		8: ["武林盟主府", "论剑台", "观战台", "比武场"] as Array[String],
		9: ["长夜歌·终章", "忘忧谷", "离忧谷", "最终决战场"] as Array[String],
		10: ["苍渊", "听涛阁", "浪子归", "新地图"] as Array[String],
		11: ["踏浪", "歌行", "潮汐", "新剧情地图"] as Array[String],
		12: ["尾声", "江湖", "归隐", "大团圆"] as Array[String]
	}
	return areas.get(idx, ["未知地图"])

func _get_chapter_side_quests(idx: int) -> Array[String]:
	var quests = [] as Array[String]
	for j in range(1, 4):
		quests.append("quest_ch%d_side_%d" % [idx, j])
	return quests

func _get_chapter_choices(idx: int) -> Array[String]:
	var choices = {
		5: ["choice_ch5_country", "choice_ch5_friend"] as Array[String],
		6: ["choice_ch6_sword_owner", "choice_ch6_sword_secret"] as Array[String],
		7: ["choice_ch7_demon_spy", "choice_ch7_purge"] as Array[String],
		8: ["choice_ch8_champion", "choice_ch8_withdraw"] as Array[String],
		9: ["choice_ch9_truth", "choice_ch9_sacrifice"] as Array[String],
		10: ["choice_ch10_new_beginning", "choice_ch10_legacy"] as Array[String],
		11: ["choice_ch11_wanderer", "choice_ch11_settle"] as Array[String],
		12: ["choice_ch12_end_jianghu", "choice_ch12_end_retire"] as Array[String]
	}
	return choices.get(idx, [])

func _create_main_quests():
	for i in range(1, 13):
		var q = Quest.new()
		q.id = "quest_ch%d_main" % i
		q.name = "主线：%s" % _get_chapter_name(i)
		q.description = _get_chapter_desc(i)
		q.chapter = i
		q.type = "主线"
		q.objectives = _create_chapter_objectives(i)
		q.rewards = {"exp": i * 10000, "copper": i * 20000}
		q.unlock_chapter = i + 1 if i < 12 else 0
		quests[q.id] = q

func _create_chapter_objectives(chapter: int) -> Array[Dictionary]:
	var objs = [] as Array[Dictionary]
	var obj_count = 3 + int(chapter / 3)
	for j in range(obj_count):
		objs.append({
			"id": "obj_ch%d_%d" % [chapter, j],
			"type": _get_random_objective_type(),
			"description": "目标 %d: %s" % [j + 1, _get_objective_desc(chapter, j)],
			"target": _get_objective_target(chapter, j),
			"count": randi_range(1, 5),
			"completed": false
		})
	return objs

func _get_random_objective_type() -> String:
	var types = ["击杀", "收集", "对话", "到达", "保护", "调查", "挑战", "制作"]
	return types[randi() % types.size()]

func _get_objective_desc(chapter: int, index: int) -> String:
	var descs = [
		"击败%s的守卫",
		"收集%s的碎片",
		"与%s对话",
		"前往%s",
		"保护%s安全",
		"调查%s的秘密",
		"挑战%s高手",
		"制作%s装备"
	]
	var targets = ["章节BOSS", "关键道具", "关键NPC", "重要地点", "护送目标", "神秘事件", "门派长老", "稀有材料"]
	return descs[index % descs.size()] % targets[index % targets.size()]

func _get_objective_target(chapter: int, index: int) -> String:
	var targets = ["boss", "item", "npc", "location", "escort", "clue", "master", "material"]
	return targets[index % targets.size()]

func _create_side_quests():
	# 每章支线任务
	for i in range(1, 13):
		for j in range(1, 4):
			var q = Quest.new()
			q.id = "quest_ch%d_side_%d" % [i, j]
			q.name = "支线：%s·第%d支线" % [_get_chapter_name(i), j]
			q.description = "支线任务描述..."
			q.chapter = i
			q.type = "支线"
			q.objectives = _create_chapter_objectives(i)
			q.rewards = {"exp": i * 3000, "copper": i * 5000}
			q.choices = ["choice_side_%d_%d_a" % [i, j], "choice_side_%d_%d_b" % [i, j]] as Array[String]
			quests[q.id] = q
	
	# 特殊支线：侠客招募
	_create_companion_quests()
	
	# 特殊支线：门派任务
	_create_sect_quests()
	
	# 特殊支线：帮会任务
	_create_guild_quests()
	
	# 特殊支线：奇遇任务
	_create_encounter_quests()

func _create_companion_quests():
	var companions = CharacterDatabase.instance.get_recruitable_characters()
	for char in companions:
		if char.recruit_chapter > 0:
			var q = Quest.new()
			q.id = "quest_recruit_%s" % char.id
			q.name = "招募：%s" % char.name
			q.description = char.recruit_condition
			q.chapter = char.recruit_chapter
			q.type = "侠客招募"
			q.objectives = [{"id": "recruit_%s" % char.id, "type": "对话", "description": "完成%s的招募条件" % char.name, "target": char.id, "count": 1}] as Array[Dictionary]
			q.rewards = {"companion": char.id, "exp": 10000, "copper": 20000}
			quests[q.id] = q

func _create_sect_quests():
	for sect_id in SectDatabase.instance.get_all_sects():
		var sect = sect_id
		for level in [1, 5, 10, 15, 20]:
			var q = Quest.new()
			q.id = "quest_sect_%s_lvl%d" % [sect.id, level]
			q.name = "门派任务：%s·%d级" % [sect.name, level]
			q.description = "为门派贡献力量"
			q.chapter = 3
			q.type = "门派日常"
			q.objectives = [{"id": "sect_daily", "type": "击杀", "description": "完成门派日常", "target": "sect_enemy", "count": 5}] as Array[Dictionary]
			q.rewards = {"contribution": level * 100, "exp": level * 1000}
			q.repeatable = true
			q.reset_type = "每日"
			quests[q.id] = q

func _create_guild_quests():
	var types = ["捐赠", "秘境", "帮战", "建设", "巡逻"]
	for t in types:
		for level in [1, 2, 3]:
			var q = Quest.new()
			q.id = "quest_guild_%s_lvl%d" % [t, level]
			q.name = "帮会%s·%d级" % [t, level]
			q.description = "帮会%s任务" % t
			q.type = "帮会任务"
			q.objectives = [{"id": "guild_%s" % t, "type": t, "description": "完成帮会%s" % t, "target": "guild", "count": level * 10}] as Array[Dictionary]
			q.rewards = {"guild_contribution": level * 200, "guild_exp": level * 500}
			q.repeatable = true
			q.reset_type = "每周" if t != "捐赠" else "每日"
			quests[q.id] = q

func _create_encounter_quests():
	var encounters = [
		{"id": "encounter_old_man", "name": "奇遇：老者传功", "desc": "遇到一位神秘老者，传授失传绝学", "map": "random", "probability": 0.001},
		{"id": "encounter_secret_manual", "name": "奇遇：秘籍残页", "desc": "在废弃洞府中发现秘籍残页", "map": "cave", "probability": 0.005},
		{"id": "encounter_love_letter", "name": "奇遇：情书传递", "desc": "帮助痴情郎君传递情书", "map": "city", "probability": 0.01},
		{"id": "encounter_ghost", "name": "奇遇：冤魂索命", "desc": "夜遇冤魂，化解怨气或战斗", "map": "wilderness", "probability": 0.003, "time": "night"},
		{"id": "encounter_merchant", "name": "奇遇：神秘商人", "desc": "遇到神秘商人，出售稀有货物", "map": "random", "probability": 0.002},
		{"id": "encounter_duel", "name": "奇遇：江湖切磋", "desc": "路遇高手求战，切磋武艺", "map": "road", "probability": 0.005},
		{"id": "encounter_treasure_map", "name": "奇遇：藏宝图", "desc": "获得残缺藏宝图，寻找宝藏", "map": "random", "probability": 0.002},
		{"id": "encounter_medicine", "name": "奇遇：神医济世", "desc": "遇到神医传授医术", "map": "village", "probability": 0.001},
	]
	
	for e in encounters:
		var q = Quest.new()
		q.id = e["id"]
		q.name = e["name"]
		q.description = e["desc"]
		q.type = "奇遇"
		q.chapter = 0
		q.hidden = true
		q.trigger_probability = e["probability"]
		q.trigger_map = e["map"]
		if e.has("time"):
			q.trigger_time = e["time"]
		q.objectives = [{"id": "encounter_complete", "type": "完成奇遇", "description": "完成奇遇剧情", "target": "encounter", "count": 1}] as Array[Dictionary]
		q.rewards = {"exp": 20000, "copper": 50000, "special_item": true}
		quests[q.id] = q

func _create_npcs():
	# 主要NPC
	_create_main_npcs()
	# 门派NPC
	_create_sect_npcs()
	# 城市NPC
	_create_city_npcs()
	# 特殊NPC
	_create_special_npcs()

func _create_main_npcs():
	var npcs_data = [
		{"id": "npc_protagonist_father", "name": "主角父亲", "sect": "无", "role": "剧情", "location": "杭州", "affection": 100},
		{"id": "npc_protagonist_mother", "name": "主角母亲", "sect": "无", "role": "剧情", "location": "杭州", "affection": 100},
		{"id": "npc_master", "name": "恩师", "sect": "华山派", "role": "师父", "location": "华山", "affection": 80},
		{"id": "npc_rival", "name": "师兄/竞争对手", "sect": "华山派", "role": "竞争", "location": "华山", "affection": 30},
		{"id": "npc_li_peizhi", "name": "李佩芷", "sect": "不器门", "role": "大师姐", "location": "江湖", "affection": 50, "recruitable": true},
		{"id": "npc_ye_lu_hong", "name": "耶律红", "sect": "无", "role": "大侠", "location": "京城", "affection": 40, "recruitable": true},
		{"id": "npc_zhang_yue", "name": "张月", "sect": "天武", "role": "女侠", "location": "边关", "affection": 45, "recruitable": true},
		{"id": "npc_taohua", "name": "桃花仙子", "sect": "无", "role": "神秘", "location": "桃花岛", "affection": 35, "recruitable": true},
		{"id": "npc_lu_you", "name": "陆游", "sect": "无", "role": "词宗", "location": "江南", "affection": 50, "recruitable": true},
		{"id": "npc_tang_wan", "name": "唐婉", "sect": "无", "role": "才女", "location": "江南", "affection": 55, "recruitable": true},
		{"id": "npc_xin_qiji", "name": "辛弃疾", "sect": "无", "role": "爱国词人", "location": "北疆", "affection": 60, "recruitable": true},
		{"id": "npc_li_xiangjun", "name": "李香君", "sect": "无", "role": "名伶", "location": "秦淮河", "affection": 50, "recruitable": true},
	]
	
	for d in npcs_data:
		var npc = NPCData.new()
		npc.id = d["id"]
		npc.name = d["name"]
		npc.sect = d["sect"]
		npc.role = d["role"]
		npc.location = d["location"]
		npc.base_affection = d["affection"]
		npc.recruitable = d.get("recruitable", false)
		npcs[npc.id] = npc

func _create_sect_npcs():
	for sect in SectDatabase.instance.get_all_sects():
		# 掌门
		var npc = NPCData.new()
		npc.id = "npc_sect_%s_leader" % sect.id
		npc.name = "%s掌门" % sect.name
		npc.sect = sect.id
		npc.role = "掌门"
		npc.location = sect.location
		npc.base_affection = 50
		npc.is_leader = true
		npcs[npc.id] = npc
		
		# 长老
		for i in range(3):
			npc = NPCData.new()
			npc.id = "npc_sect_%s_elder_%d" % [sect.id, i]
			npc.name = "%s长老%d" % [sect.name, i + 1]
			npc.sect = sect.id
			npc.role = "长老"
			npc.location = sect.location
			npc.base_affection = 30
			npc.is_elder = true
			npcs[npc.id] = npc
		
		# 弟子
		for i in range(5):
			npc = NPCData.new()
			npc.id = "npc_sect_%s_disciple_%d" % [sect.id, i]
			npc.name = "%s弟子%d" % [sect.name, i + 1]
			npc.sect = sect.id
			npc.role = "弟子"
			npc.location = sect.location
			npc.base_affection = 20
			npc.is_disciple = true
			npcs[npc.id] = npc

func _create_city_npcs():
	var cities = ["杭州", "苏州", "洛阳", "京城", "成都", "扬州", "临安", "开封"]
	var roles = ["客栈老板", "铁匠", "药师", "说书人", "茶馆老板", "捕快", "商人", "乞丐", "守卫", "衙役"]
	
	for city in cities:
		for i in range(roles.size()):
			var role = roles[i]
			var npc = NPCData.new()
			npc.id = "npc_%s_%s" % [city, role]
			npc.name = "%s%s" % [city, role]
			npc.sect = "无"
			npc.role = role
			npc.location = city
			npc.base_affection = 10
			npc.is_city_npc = true
			npcs[npc.id] = npc

func _create_special_npcs():
	# 神秘商人
	var npc = NPCData.new()
	npc.id = "npc_mysterious_merchant"
	npc.name = "神秘商人"
	npc.sect = "无"
	npc.role = "商人"
	npc.location = "随机"
	npc.base_affection = 0
	npc.is_special = true
	npcs[npc.id] = npc
	
	# 说书人
	npc = NPCData.new()
	npc.id = "npc_storyteller"
	npc.name = "说书人"
	npc.sect = "无"
	npc.role = "说书"
	npc.location = "各大茶馆"
	npc.base_affection = 20
	npc.is_special = true
	npcs[npc.id] = npc
	
	# 寻宝人
	npc = NPCData.new()
	npc.id = "npc_treasure_hunter"
	npc.name = "寻宝人"
	npc.sect = "无"
	npc.role = "寻宝"
	npc.location = "野外"
	npc.base_affection = 15
	npc.is_special = true
	npcs[npc.id] = npc

func _create_world_events():
	# 世界事件：门派大比
	var evt = WorldEvent.new()
	evt.id = "event_sect_tournament"
	evt.name = "门派大比"
	evt.description = "各大门派弟子切磋武艺，胜者获得丰厚奖励"
	evt.type = "定期"
	evt.schedule = "每月第一周"
	evt.duration = 7
	evt.participation_req = {"level": 20, "sect": "不为空"}
	evt.rewards = {"exp": 50000, "contribution": 2000, "title": "门派武林高手"}
	evt.map_areas = ["各大门派"] as Array[String]
	world_states["event_sect_tournament"] = {"active": false, "progress": 0}
	_store_world_event(evt)
	
	# 世界事件：论剑赛季
	evt = WorldEvent.new()
	evt.id = "event_lunjian_season"
	evt.name = "论剑赛季"
	evt.description = "天下高手齐聚论剑台，争夺武林至尊"
	evt.type = "定期"
	evt.schedule = "每季度(28天)"
	evt.duration = 28
	evt.participation_req = {"level": 30}
	evt.rewards = {"rank_rewards": true, "skin": "赛季皮肤", "title": "论剑冠军"}
	evt.map_areas = ["论剑台"] as Array[String]
	world_states["event_lunjian_season"] = {"active": false, "season": 1}
	_store_world_event(evt)
	
	# 世界事件：帮会秘境
	evt = WorldEvent.new()
	evt.id = "event_guild_secret_realm"
	evt.name = "帮会秘境"
	evt.description = "帮会成员共同挑战秘境，获得稀有材料"
	evt.type = "帮会"
	evt.schedule = "每周三、六、日"
	evt.duration = 2
	evt.participation_req = {"guild": "不为空", "level": 25}
	evt.rewards = {"secret_realm_materials": true, "guild_contribution": 500}
	evt.map_areas = ["帮会秘境"] as Array[String]
	world_states["event_guild_secret_realm"] = {"active": false}
	_store_world_event(evt)
	
	# 世界事件：海市蜃楼
	evt = WorldEvent.new()
	evt.id = "event_haishi_shenlou"
	evt.name = "海市蜃楼"
	evt.description = "神秘幻境开启，内含稀世珍宝与强大BOSS"
	evt.type = "限时"
	evt.schedule = "版本更新期间"
	evt.duration = 14
	evt.participation_req = {"level": 40}
	evt.rewards = {"xinfa_materials": true, "rare_equipment": true, "title": "幻境探险家"}
	evt.map_areas = ["海市蜃楼"] as Array[String]
	world_states["event_haishi_shenlou"] = {"active": false}
	_store_world_event(evt)
	
	# 世界事件：列星巅峰
	evt = WorldEvent.new()
	evt.id = "event_liexing_dianfeng"
	evt.name = "列星巅峰"
	evt.description = "挑战强敌，勇攀星榜巅峰"
	evt.type = "挑战"
	evt.schedule = "常驻"
	evt.duration = -1
	evt.participation_req = {"level": 50}
	evt.rewards = {"star_rewards": true, "title": "列星巅峰王者"}
	evt.map_areas = ["列星塔"] as Array[String]
	world_states["event_liexing_dianfeng"] = {"active": true, "floor": 1}
	_store_world_event(evt)
	
	# 世界事件：四海浮生记
	evt = WorldEvent.new()
	evt.id = "event_sihai_fusheng"
	evt.name = "四海浮生记"
	evt.description = "大型剧情活动，体验海上风云"
	evt.type = "剧情"
	evt.schedule = "版本活动"
	evt.duration = 21
	evt.participation_req = {"level": 35, "chapter": 6}
	evt.rewards = {"story_rewards": true, "character": "季璘", "skin": "蛟龙镇海"}
	evt.map_areas = ["四海", "浮生岛", "龙宫"] as Array[String]
	world_states["event_sihai_fusheng"] = {"active": false, "progress": 0}
	_store_world_event(evt)
	
	# 世界事件：七时桃源
	evt = WorldEvent.new()
	evt.id = "event_qishi_taoyuan"
	evt.name = "七时桃源"
	evt.description = "七夕限定活动，桃源寻缘"
	evt.type = "节日"
	evt.schedule = "每年七夕"
	evt.duration = 7
	evt.participation_req = {"level": 15}
	evt.rewards = {"skin": "桃花装扮", "title": "桃源有缘人", "pet": "桃花精"}
	evt.map_areas = ["桃源"] as Array[String]
	world_states["event_qishi_taoyuan"] = {"active": false}
	_store_world_event(evt)
	
	# 世界事件：周年庆
	evt = WorldEvent.new()
	evt.id = "event_anniversary"
	evt.name = "周年庆典"
	evt.description = "汉家江湖周年庆，全服福利狂欢"
	evt.type = "周年庆"
	evt.schedule = "每年固定日期"
	evt.duration = 14
	evt.participation_req = {"level": 1}
	evt.rewards = {"login_rewards": true, "anniversary_skin": true, "title": "周年庆参与者", "copper": 1000000}
	evt.map_areas = ["主城", "活动中心"] as Array[String]
	world_states["event_anniversary"] = {"active": false, "year": 1}
	_store_world_event(evt)

func _store_world_event(evt):
	world_events[evt.id] = evt

func _create_dialogues():
	# 主线对话
	_create_main_dialogues()
	# NPC日常对话
	_create_npc_daily_dialogues()
	# 招募对话
	_create_recruit_dialogues()
	# 奇遇对话
	_create_encounter_dialogues()

func _create_main_dialogues():
	for i in range(1, 13):
		var chapter = story_chapters["chapter_%d" % i]
		if chapter:
			for j in range(3):
				var d = DialogueNode.new()
				d.id = "dialogue_ch%d_main_%d" % [i, j]
				d.chapter = i
				d.speaker = "npc_protagonist" if j % 2 == 0 else "npc_key_%d" % i
				d.text = "第%d章主线对话%d" % [i, j + 1]
				d.choices = ["choice_continue", "choice_ask_detail"] as Array[String]
				d.conditions = {"chapter_progress": j}
				d.rewards = {"exp": 1000}
				dialogues[d.id] = d

func _create_npc_daily_dialogues():
	for npc in npcs.values():
		if npc.is_city_npc or npc.is_sect_npc:
			for j in range(5):
				var d = DialogueNode.new()
				d.id = "dialogue_%s_daily_%d" % [npc.id, j]
				d.speaker = npc.id
				d.text = "%s的日常对话%d" % [npc.name, j + 1]
				d.choices = ["choice_chat", "choice_gift", "choice_leave"] as Array[String]
				d.affection_changes = {"chat": 1, "gift": 5}
				dialogues[d.id] = d

func _create_recruit_dialogues():
	for char in CharacterDatabase.instance.get_recruitable_characters():
		var d = DialogueNode.new()
		d.id = "dialogue_recruit_%s" % char.id
		d.speaker = "npc_%s" % char.id
		d.text = "%s的招募对话" % char.name
		d.choices = ["choice_recruit_accept", "choice_recruit_refuse", "choice_recruit_later"] as Array[String]
		d.conditions = {"chapter": char.recruit_chapter, "affection": 50}
		d.rewards = {"companion": char.id, "affection": 20}
		dialogues[d.id] = d

func _create_encounter_dialogues():
	for q in quests.values():
		if q.type == "奇遇":
			var d = DialogueNode.new()
			d.id = "dialogue_%s" % q.id
			d.speaker = "npc_encounter"
			d.text = "%s的奇遇对话" % q.name
			d.choices = ["choice_encounter_accept", "choice_encounter_refuse"] as Array[String]
			d.rewards = q.rewards
			dialogues[d.id] = d

func _build_indices():
	pass

func get_chapter(id: String) -> StoryChapter:
	return story_chapters.get(id)

func get_all_chapters() -> Array[StoryChapter]:
	return story_chapters.values()

func get_quest(id: String) -> Quest:
	return quests.get(id)

func get_quests_by_chapter(chapter: int) -> Array[Quest]:
	var result = []
	for q in quests.values():
		if q.chapter == chapter:
			result.append(q)
	return result

func get_quests_by_type(type: String) -> Array[Quest]:
	var result = []
	for q in quests.values():
		if q.type == type:
			result.append(q)
	return result

func get_dialogue(id: String) -> DialogueNode:
	return dialogues.get(id)

func get_npc(id: String) -> NPCData:
	return npcs.get(id)

func get_world_event(id: String) -> WorldEvent:
	return world_events.get(id)

func get_world_state(id: String) -> Dictionary:
	return world_states.get(id, {})

func set_world_state(id: String, state: Dictionary):
	world_states[id] = state
	EventManager.instance.emit("world_state_changed", id, state)

func get_random_encounter(current_map: String, time_of_day: String = "day") -> Quest:
	var candidates = []
	for q in quests.values():
		if q.type == "奇遇" and q.hidden:
			if q.trigger_map == "random" or q.trigger_map == current_map:
				if not q.trigger_time or q.trigger_time == time_of_day:
					if rng.randf() < q.trigger_probability:
						candidates.append(q)
	
	if candidates.is_empty():
		return null
	
	return candidates[randi() % candidates.size()]

func get_story_progress() -> Dictionary:
	var progress = {}
	for ch in story_chapters.values():
		progress[ch.id] = {"completed": false, "current_quest": "", "choices_made": []}
	return progress
