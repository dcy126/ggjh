extends RefCounted
class_name CharacterCustomization

@export var face_data: FaceData = null
@export var body_data: BodyData = null
@export var voice_data: VoiceData = null
@export var name: String = ""
@export var title: String = ""
@export var birthday: Dictionary = {}
@export var blood_type: int = 0
@export var constellation: int = 0
@export var hometown: String = ""
@export var background_story: String = ""
@export var preferred_weapon: String = ""
@export var preferred_style: String = ""
@export var personality_traits: Array[int] = []
@export var moral_alignment: float = 0.0  # -1.0 邪恶 ~ 1.0 善良
@export var reputation: Dictionary = {}
@export var relationship_status: String = "单身"
@export var partner_id: String = ""
@export var master_id: String = ""
@export var disciple_ids: Array[String] = []
@export var sworn_siblings: Array[String] = []
@export var close_friends: Array[String] = []
@export var rivals: Array[String] = []
@export var enemies: Array[String] = []

func _init():
	if not face_data:
		face_data = FaceData.new()
	if not body_data:
		body_data = BodyData.new()
	if not voice_data:
		voice_data = VoiceData.new()

func randomize_all():
	face_data.randomize()
	body_data.randomize()
	voice_data.randomize()
	name = _generate_random_name()
	title = _generate_random_title()
	birthday = _generate_random_birthday()
	blood_type = randi_range(0, 3)
	constellation = randi_range(0, 11)
	hometown = _get_random_location()
	background_story = _generate_random_background()
	preferred_weapon = _get_random_weapon_type()
	preferred_style = _get_random_fighting_style()
	personality_traits = _generate_random_personality()
	moral_alignment = randf_range(-1.0, 1.0)
	reputation = _generate_initial_reputation()
	relationship_status = "单身"

func apply_preset(preset_name: String):
	var presets = {
		"protagonist": {
			"face_preset": "handsome_male",
			"body_preset": "martial_artist",
			"voice_preset": "heroic_male",
			"name": "主角",
			"title": "初出茅庐",
			"background_story": "出生于杭州的一个普通武馆家庭，幼时便习武强身。父母双亡后，独自闯荡江湖，誓要寻找失散多年的师兄，揭开身世之谜。"
		},
		"heroic_male": {
			"face_preset": "heroic",
			"body_preset": "martial_artist",
			"voice_preset": "heroic_male",
			"name": _generate_random_name(),
			"title": "侠肝义胆",
			"background_story": "自幼习武，行侠仗义，路见不平拔刀相助。虽无名门正派传承，却凭借一己之力在江湖闯出名号。"
		},
		"gentle_female": {
			"face_preset": "gentle_female",
			"body_preset": "curvy_female",
			"voice_preset": "gentle_female",
			"name": _generate_random_name(),
			"title": "巾帼不让须眉",
			"background_story": "出身名门闺秀，却厌倦了深宅大院的生活，毅然决然投身江湖，用医术救人，用琴音抚慰人心。"
		},
		"cold_assassin": {
			"face_preset": "cold_male",
			"body_preset": "slim_male",
			"voice_preset": "cold_male",
			"name": _generate_random_name(),
			"title": "影杀",
			"background_story": "从小被暗杀组织收养训练，是最顶尖的杀手。一次任务失败后，开始反思自己的人生，试图摆脱组织的控制。"
		},
		"scholar_swordsman": {
			"face_preset": "scholar",
			"body_preset": "scholar",
			"voice_preset": "scholar",
			"name": _generate_random_name(),
			"title": "文武双全",
			"background_story": "满腹经纶的读书人，因家族变故被迫习武。手持长剑，心怀天下，以笔为剑，以剑护道。"
		},
		"villain": {
			"face_preset": "villain",
			"body_preset": "athletic_male",
			"voice_preset": "villain",
			"name": _generate_random_name(),
			"title": "魔头",
			"background_story": "曾是名门正派大弟子，因得罪长老被逐出师门。心怀怨恨，投身魔道，誓要让昔日同门付出代价。"
		},
		"wandering_monk": {
			"face_preset": "mature_male",
			"body_preset": "martial_artist",
			"voice_preset": "elder_male",
			"name": _generate_random_name(),
			"title": "苦行僧",
			"background_story": "云游四方的和尚，不问世事，只求心安。虽不修佛法，却有佛心，以拳脚护佑苍生。"
		},
		"mysterious_wanderer": {
			"face_preset": "mysterious",
			"body_preset": "slim_male",
			"voice_preset": "cold_male",
			"name": "无名",
			"title": "过客",
			"background_story": "来历不明的浪人，不说话，不留名。路过之处，总留下或好或坏的传说。"
		}
	}
	
	if presets.has(preset_name):
		var preset = presets[preset_name]
		if preset.has("face_preset"):
			face_data.apply_preset(preset["face_preset"])
		if preset.has("body_preset"):
			body_data.apply_preset(preset["body_preset"])
		if preset.has("voice_preset"):
			voice_data.apply_preset(preset["voice_preset"])
		if preset.has("name"):
			name = preset["name"]
		if preset.has("title"):
			title = preset["title"]
		if preset.has("background_story"):
			background_story = preset["background_story"]
		
		# 生成其他随机属性
		birthday = _generate_random_birthday()
		blood_type = randi_range(0, 3)
		constellation = randi_range(0, 11)
		hometown = _get_random_location()
		preferred_weapon = _get_random_weapon_type()
		preferred_style = _get_random_fighting_style()
		personality_traits = _generate_random_personality()
		moral_alignment = preset_name == "villain" ? randf_range(-1.0, -0.3) : (preset_name == "protagonist" ? randf_range(0.3, 1.0) : randf_range(-1.0, 1.0))
		reputation = _generate_initial_reputation()
		relationship_status = "单身"

func _generate_random_name() -> String:
	var surnames = ["李", "王", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴", "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗"]
	var given_names_male = ["伟", "强", "军", "勇", "杰", "涛", "磊", "峰", "鹏", "飞", "龙", "虎", "豪", "杰", "豪", "轩", "宇", "泽", "浩", "天"]
	var given_names_female = ["娜", "婷", "静", "敏", "丽", "娟", "芳", "燕", "红", "梅", "雪", "云", "月", "花", "雨", "霜", "烟", "霞", "岚", "韵"]
	var two_char_male = ["子轩", "浩宇", "宇轩", "博涛", "梓豪", "俊杰", "晓博", "天佑", "文昊", "修杰", "黎昕", "远航", "旭尧", "鸿涛", "伟祺", "荣轩", "越泽", "浩然", "泽洋", "天宇"]
	var two_char_female = ["梦琪", "之桃", "慕青", "问夏", "沛白", "澜菲", "雨桐", "若溪", "语嫣", "梦洁", "梦瑶", "心怡", "雨婷", "语桐", "欣怡", "雨萱", "梦瑶", "语嫣", "梦洁", "欣怡"]
	
	var surname = surnames[randi() % surnames.size()]
	var is_male = randf() > 0.5
	
	if is_male:
		if randf() > 0.5:
			return surname + given_names_male[randi() % given_names_male.size()]
		else:
			return surname + two_char_male[randi() % two_char_male.size()]
	else:
		if randf() > 0.5:
			return surname + given_names_female[randi() % given_names_female.size()]
		else:
			return surname + two_char_female[randi() % two_char_female.size()]

func _generate_random_title() -> String:
	var titles = [
		"初出茅庐", "崭露头角", "小有名气", "声名远扬", "一代宗师", "武林盟主",
		"侠之大者", "剑指苍穹", "刀断山河", "拳震八方", "琴音动天", "医术济世",
		"毒医双绝", "机关大师", "轻功巅峰", "内功深厚", "佛心魔行", "正邪难辨",
		"孤独求败", "天下无双", "江湖故人", "过客匆匆", "归隐山林", "浪迹天涯"
	]
	return titles[randi() % titles.size()]

func _generate_random_birthday() -> Dictionary:
	return {
		"year": randi_range(1980, 2005),
		"month": randi_range(1, 12),
		"day": randi_range(1, 28)
	}

func _get_random_location() -> String:
	var locations = ["杭州", "苏州", "洛阳", "京城", "成都", "扬州", "临安", "开封", "太原", "大理", "桂林", "西湖", "峨眉", "武当", "少林", "昆仑", "长白", "天山", "青城", "青海"]
	return locations[randi() % locations.size()]

func _generate_random_background() -> String:
	var backgrounds = [
		"出生于武学世家，自幼习武，因家族衰败独自闯荡江湖。",
		"孤儿院长大，被路过高人收为弟子，学得一身本领后下山历练。",
		"原是朝廷命官，因得罪权贵被贬，流落江湖，以武会友。",
		"商贾子弟，厌倦了逐利生涯，弃商从武，寻求人生意义。",
		"书生落第，误入武林，以文入武，另辟蹊径成就一番事业。",
		"江湖骗子，靠说书算卦为生，机缘巧合习得真功夫。",
		"采花大盗改邪归正，洗手作羹汤，却因过往恩怨被迫重披战袍。",
		"失忆浪人，不知来历，只身寻找记忆碎片，途中结识众多豪杰。",
		"公主/王爷微服出行，体验民间疾苦，结识主角成为伙伴。",
		"外族使者，来中原交流武学，被中原文化吸引决定留下。"
	]
	return backgrounds[randi() % backgrounds.size()]

func _get_random_weapon_type() -> String:
	var weapons = ["剑", "刀", "枪", "棍", "鞭", "拳", "掌", "指", "腿", "暗器", "琴", "扇", "伞", "笔", "剑扇"]
	return weapons[randi() % weapons.size()]

func _get_random_fighting_style() -> String:
	var styles = ["刚猛", "阴柔", "迅捷", "厚重", "诡异", "正统", "偏门", "融合", "御敌", "控制", "爆发", "持久"]
	return styles[randi() % styles.size()]

func _generate_random_personality() -> Array[int]:
	var traits = []
	var all_traits = [
		0,  # 正义
		1,  # 仁慈
		2,  # 勇敢
		3,  # 智慧
		4,  # 忠诚
		5,  # 谦逊
		6,  # 自信
		7,  # 固执
		8,  # 冲动
		9,  # 谨慎
		10, # 乐观
		11, # 悲观
		12, # 社交
		13, # 孤僻
		14, # 野心
		15  # 无欲
	]
	
	var count = randi_range(3, 6)
	for i in range(count):
		var trait = all_traits[randi() % all_traits.size()]
		if trait not in traits:
			traits.append(trait)
	return traits

func _generate_initial_reputation() -> Dictionary:
	var factions = ["正派", "魔道", "朝廷", "江湖", "商贾", "百姓", "门派", "帮会"]
	var rep = {}
	for f in factions:
		rep[f] = randi_range(-50, 50)
	return rep

func get_personality_description() -> String:
	var trait_names = {
		0: "正义", 1: "仁慈", 2: "勇敢", 3: "智慧", 4: "忠诚",
		5: "谦逊", 6: "自信", 7: "固执", 8: "冲动", 9: "谨慎",
		10: "乐观", 11: "悲观", 12: "社交", 13: "孤僻", 14: "野心", 15: "无欲"
	}
	
	var descs = []
	for trait in personality_traits:
		if trait_names.has(trait):
			descs.append(trait_names[trait])
	
	return descs.join("、")

func get_moral_description() -> String:
	if moral_alignment > 0.7:
		return "大善"
	elif moral_alignment > 0.3:
		return "向善"
	elif moral_alignment > -0.3:
		return "中立"
	elif moral_alignment > -0.7:
		return "向恶"
	else:
		return "大恶"

func get_age() -> int:
	var current_year = Time.get_datetime_dict_from_system().year
	return current_year - birthday.get("year", 2000)

func get_zodiac() -> String:
	var zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
	var year = birthday.get("year", 2000)
	return zodiacs[(year - 1900) % 12]

func get_constellation_name() -> String:
	var constellations = ["摩羯座", "水瓶座", "双鱼座", "白羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座"]
	return constellations[constellation] if constellation < constellations.size() else "未知"

func get_blood_type_name() -> String:
	var types = ["A型", "B型", "AB型", "O型"]
	return types[blood_type] if blood_type < types.size() else "未知"

func to_dict() -> Dictionary:
	return {
		"face_data": face_data.to_dict() if face_data else {},
		"body_data": body_data.to_dict() if body_data else {},
		"voice_data": voice_data.to_dict() if voice_data else {},
		"name": name,
		"title": title,
		"birthday": birthday,
		"blood_type": blood_type,
		"constellation": constellation,
		"hometown": hometown,
		"background_story": background_story,
		"preferred_weapon": preferred_weapon,
		"preferred_style": preferred_style,
		"personality_traits": personality_traits,
		"moral_alignment": moral_alignment,
		"reputation": reputation,
		"relationship_status": relationship_status,
		"partner_id": partner_id,
		"master_id": master_id,
		"disciple_ids": disciple_ids,
		"sworn_siblings": sworn_siblings,
		"close_friends": close_friends,
		"rivals": rivals,
		"enemies": enemies
	}

func from_dict(data: Dictionary):
	if data.has("face_data") and data["face_data"]:
		face_data = FaceData.new().from_dict(data["face_data"])
	if data.has("body_data") and data["body_data"]:
		body_data = BodyData.new().from_dict(data["body_data"])
	if data.has("voice_data") and data["voice_data"]:
		voice_data = VoiceData.new().from_dict(data["voice_data"])
	
	name = data.get("name", "")
	title = data.get("title", "")
	birthday = data.get("birthday", {})
	blood_type = data.get("blood_type", 0)
	constellation = data.get("constellation", 0)
	hometown = data.get("hometown", "")
	background_story = data.get("background_story", "")
	preferred_weapon = data.get("preferred_weapon", "")
	preferred_style = data.get("preferred_style", "")
	personality_traits = data.get("personality_traits", [])
	moral_alignment = data.get("moral_alignment", 0.0)
	reputation = data.get("reputation", {})
	relationship_status = data.get("relationship_status", "单身")
	partner_id = data.get("partner_id", "")
	master_id = data.get("master_id", "")
	disciple_ids = data.get("disciple_ids", [])
	sworn_siblings = data.get("sworn_siblings", [])
	close_friends = data.get("close_friends", [])
	rivals = data.get("rivals", [])
	enemies = data.get("enemies", [])