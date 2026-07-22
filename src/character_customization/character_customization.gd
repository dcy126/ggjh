extends Resource
class_name CharacterCustomization

var face_data: Resource = null
var body_data: Resource = null
var voice_data: Resource = null
var character_name: String = ""
var title: String = ""
var birthday: Dictionary = {}
var blood_type: int = 0
var constellation: int = 0
var hometown: String = ""
var background_story: String = ""
var preferred_weapon: String = ""
var preferred_style: String = ""
var personality_traits: Array[int] = []
var moral_alignment: float = 0.0
var reputation: Dictionary = {}
var relationship_status: String = "单身"
var partner_id: String = ""
var master_id: String = ""
var disciple_ids: Array[String] = []
var sworn_siblings: Array[String] = []
var close_friends: Array[String] = []
var rivals: Array[String] = []
var enemies: Array[String] = []

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
	character_name = _generate_random_name()
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
			"body_preset": "standard_male",
			"voice_preset": "youth_male",
			"name": "主角",
			"title": "初出茅庐",
			"personality_traits": [0, 0, 0, 1, 0]
		},
		"scholar": {
			"face_preset": "gentle_male",
			"body_preset": "slender_male",
			"voice_preset": "calm_male",
			"name": _generate_random_name(),
			"title": "书生",
			"personality_traits": [1, 1, 0, 0, 1]
		},
		"warrior": {
			"face_preset": "rugged_male",
			"body_preset": "muscular_male",
			"voice_preset": "deep_male",
			"name": _generate_random_name(),
			"title": "武者",
			"personality_traits": [0, 1, 1, 0, 0]
		},
		"assassin": {
			"face_preset": "sharp_female",
			"body_preset": "slim_female",
			"voice_preset": "cold_female",
			"name": _generate_random_name(),
			"title": "刺客",
			"personality_traits": [1, 0, 0, 1, 1]
		},
		"mage": {
			"face_preset": "mysterious_female",
			"body_preset": "standard_female",
			"voice_preset": "soft_female",
			"name": _generate_random_name(),
			"title": "术士",
			"personality_traits": [1, 0, 1, 1, 0]
		},
		"merchant": {
			"face_preset": "smiling_male",
			"body_preset": "plump_male",
			"voice_preset": "cheerful_male",
			"name": _generate_random_name(),
			"title": "商贾",
			"personality_traits": [0, 0, 0, 0, 1]
		},
		"wanderer": {
			"face_preset": "weathered_male",
			"body_preset": "tall_male",
			"voice_preset": "gruff_male",
			"name": _generate_random_name(),
			"title": "浪客",
			"personality_traits": [0, 1, 0, 0, 1]
		},
		"nun": {
			"face_preset": "serene_female",
			"body_preset": "standard_female",
			"voice_preset": "gentle_female",
			"name": "无名",
			"title": "师太",
			"personality_traits": [1, 0, 1, 0, 0]
		}
	}
	
	if presets.has(preset_name):
		var preset = presets[preset_name]
		face_data.apply_preset(preset["face_preset"])
		body_data.apply_preset(preset["body_preset"])
		voice_data.apply_preset(preset["voice_preset"])
		if preset.has("name"):
			character_name = preset["name"]
		if preset.has("title"):
			title = preset["title"]
		if preset.has("personality_traits"):
			personality_traits.assign(preset["personality_traits"])

func to_dict() -> Dictionary:
	return {
		"name": character_name,
		"title": title,
		"face_data": face_data.to_dict() if face_data else {},
		"body_data": body_data.to_dict() if body_data else {},
		"voice_data": voice_data.to_dict() if voice_data else {},
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
	
	character_name = data.get("name", "")
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

func _generate_random_name() -> String:
	var first_names = ["苏", "林", "叶", "萧", "楚", "柳", "白", "云", "慕容", "上官", "南宫", "司徒"]
	var last_names = ["尘", "瑶", "逸", "霜", "墨", "岚", "雪", "枫", "月", "夜", "影", "寒"]
	return first_names[randi() % first_names.size()] + last_names[randi() % last_names.size()]

func _generate_random_title() -> String:
	var titles = ["初出茅庐", "江湖新秀", "无名小卒", "闲云野鹤", "风尘侠客", "隐世高人"]
	return titles[randi() % titles.size()]

func _generate_random_birthday() -> Dictionary:
	return {
		"year": randi_range(1000, 1100),
		"month": randi_range(1, 12),
		"day": randi_range(1, 28)
	}

func _get_random_location() -> String:
	var locations = ["杭州", "苏州", "洛阳", "京城", "成都", "扬州", "临安", "开封"]
	return locations[randi() % locations.size()]

func _generate_random_background() -> String:
	var backgrounds = [
		"出身武林世家，自幼习武",
		"偶遇高人，得传绝学",
		"乱世之中，被迫拿起刀剑",
		"本是富家子弟，因缘际会踏入江湖",
		"深山修炼多年，初入江湖"
	]
	return backgrounds[randi() % backgrounds.size()]

func _get_random_weapon_type() -> String:
	var weapons = ["剑", "刀", "枪", "棍", "拳", "暗器", "琴", "扇"]
	return weapons[randi() % weapons.size()]

func _get_random_fighting_style() -> String:
	var styles = ["刚猛", "阴柔", "灵动", "沉稳", "诡变", "狂暴"]
	return styles[randi() % styles.size()]

func _generate_random_personality() -> Array[int]:
	var result: Array[int] = []
	for i in range(5):
		result.append(randi_range(-1, 1))
	return result

func _generate_initial_reputation() -> Dictionary:
	return {
		"杭州": 0,
		"苏州": 0,
		"洛阳": 0,
		"京城": 0,
		"成都": 0
	}
