extends Node
class_name CharacterDatabase

static var characters: Dictionary = {}
static var characters_by_quality: Dictionary = {}
static var characters_by_sect: Dictionary = {}
static var characters_by_role: Dictionary = {}
static var recruitable_characters: Array[CharacterData] = []
static var protagonist: CharacterData = null

static var instance = null

static func get_instance():
	return instance

var rng: RandomNumberGenerator = null

func _enter_tree():
	instance = self
	rng = RandomNumberGenerator.new()
	rng.randomize()
	_load_all_characters()

func _load_all_characters():
	# 这里会在实际项目中从资源文件加载
	# 暂时创建一些示例数据
	_create_sample_characters()

func _create_sample_characters():
	# 主角
	var mc = CharacterData.new()
	mc.id = "protagonist"
	mc.name = "主角"
	mc.title = "初出茅庐"
	mc.quality = "传说"
	mc.role = "万金油"
	mc.is_protagonist = true
	mc.base_hp = 1000
	mc.base_mp = 100
	mc.base_atk = 100
	mc.base_def = 100
	mc.base_spd = 100
	mc.base_hit = 100
	mc.base_dodge = 50
	mc.base_crit = 50
	mc.base_crit_dmg = 1.5
	mc.base_fortune = 50
	mc.base_move_range = 2
	mc.base_qi_speed = 1.0
	mc.potential_growth = {"根骨": 1.5, "悟性": 1.5, "身法": 1.5, "福缘": 1.5, "定力": 1.5}
	mc.max_potential_level = 100
	mc.max_breakthrough = 3
	mc.known_wuxue = ["草头风云录"]
	mc.equipped_wuxue = ["草头风云录"]
	mc.xinfa_slots = 7
	mc.max_xinfa_slots = 7
	mc.qi_value = 29
	mc.max_qi_value = 29
	mc.growth_curve = {"hp": 1.1, "mp": 1.0, "atk": 1.1, "def": 1.0, "spd": 1.0}
	characters[mc.id] = mc
	protagonist = mc
	
	# 辛弃疾《楚狂》
	var xin = CharacterData.new()
	xin.id = "xin_qiji_chu_kuang"
	xin.name = "辛弃疾"
	xin.title = "楚狂"
	xin.quality = "绝世"
	xin.role = "主攻"
	xin.sect = "铁石岛"
	xin.is_recruitable = true
	xin.recruit_chapter = 3
	xin.base_hp = 1200
	xin.base_mp = 120
	xin.base_atk = 150
	xin.base_def = 80
	xin.base_spd = 110
	xin.base_hit = 120
	xin.base_dodge = 60
	xin.base_crit = 80
	xin.base_crit_dmg = 1.8
	xin.base_fortune = 80
	xin.base_move_range = 2
	xin.base_qi_speed = 1.2
	xin.potential_growth = {"根骨": 1.8, "悟性": 1.6, "身法": 1.4, "福缘": 1.7, "定力": 1.2}
	xin.known_wuxue = ["楚狂剑法", "破阵子", "满江红"]
	xin.equipped_wuxue = ["楚狂剑法"]
	xin.xinfa_slots = 7
	xin.max_xinfa_slots = 7
	xin.qi_value = 29
	xin.max_qi_value = 36
	characters[xin.id] = xin
	
	# 柳如是《蝶恋花》
	var liu = CharacterData.new()
	liu.id = "liu_rusi_die_lian_hua"
	liu.name = "柳如是"
	liu.title = "蝶恋花"
	liu.quality = "绝世"
	liu.role = "副攻"
	liu.sect = "华山派"
	liu.is_recruitable = true
	liu.recruit_chapter = 2
	liu.base_hp = 1000
	liu.base_mp = 150
	liu.base_atk = 130
	liu.base_def = 70
	liu.base_spd = 130
	liu.base_hit = 130
	liu.base_dodge = 80
	liu.base_crit = 100
	liu.base_crit_dmg = 2.0
	liu.base_fortune = 60
	liu.base_move_range = 3
	liu.base_qi_speed = 1.3
	liu.potential_growth = {"根骨": 1.2, "悟性": 1.8, "身法": 1.9, "福缘": 1.3, "定力": 1.1}
	liu.known_wuxue = ["蝶恋花剑法", "化蝶", "花影重重"]
	liu.equipped_wuxue = ["蝶恋花剑法"]
	liu.xinfa_slots = 7
	liu.max_xinfa_slots = 7
	liu.qi_value = 29
	liu.max_qi_value = 33
	characters[liu.id] = liu
	
	# 纳兰《长白朔雪》
	var nalan = CharacterData.new()
	nalan.id = "nalan_changbai_shuoxue"
	nalan.name = "纳兰"
	nalan.title = "长白朔雪"
	nalan.quality = "绝世"
	nalan.role = "主坦"
	nalan.sect = "恒山派"
	nalan.is_recruitable = true
	nalan.recruit_chapter = 4
	nalan.base_hp = 1800
	nalan.base_mp = 80
	nalan.base_atk = 70
	nalan.base_def = 180
	nalan.base_spd = 60
	nalan.base_hit = 80
	nalan.base_dodge = 40
	nalan.base_crit = 30
	nalan.base_crit_dmg = 1.5
	nalan.base_fortune = 50
	nalan.base_move_range = 2
	nalan.base_qi_speed = 0.9
	nalan.potential_growth = {"根骨": 2.0, "悟性": 1.2, "身法": 1.0, "福缘": 1.1, "定力": 1.5}
	nalan.known_wuxue = ["长白剑法", "朔雪挡刀", "恒山剑气"]
	nalan.equipped_wuxue = ["长白剑法"]
	nalan.xinfa_slots = 7
	nalan.max_xinfa_slots = 7
	nalan.qi_value = 29
	nalan.max_qi_value = 36
	characters[nalan.id] = nalan
	
	# 叶雨时《沧海月明》
	var ye = CharacterData.new()
	ye.id = "ye_yushi_canghai_yue_ming"
	ye.name = "叶雨时"
	ye.title = "沧海月明"
	ye.quality = "传说"
	ye.role = "副坦"
	ye.sect = "河洛帮"
	ye.is_recruitable = true
	ye.recruit_chapter = 5
	ye.base_hp = 1600
	ye.base_mp = 100
	ye.base_atk = 80
	ye.base_def = 150
	ye.base_spd = 80
	ye.base_hit = 100
	ye.base_dodge = 60
	ye.base_crit = 40
	ye.base_crit_dmg = 1.5
	ye.base_fortune = 70
	ye.base_move_range = 2
	ye.base_qi_speed = 1.0
	ye.potential_growth = {"根骨": 1.8, "悟性": 1.4, "身法": 1.2, "福缘": 1.6, "定力": 1.3}
	ye.known_wuxue = ["沧海月明", "护佑苍生", "月下独酌"]
	ye.equipped_wuxue = ["沧海月明"]
	ye.xinfa_slots = 7
	ye.max_xinfa_slots = 7
	ye.qi_value = 29
	ye.max_qi_value = 33
	characters[ye.id] = ye
	
	# 李佩芷《莫失莫忘》
	var li = CharacterData.new()
	li.id = "li_peizhi_mo_shi_mo_wang"
	li.name = "李佩芷"
	li.title = "莫失莫忘"
	li.quality = "绝世"
	li.role = "特殊"
	li.sect = "八大门"
	li.is_recruitable = true
	li.recruit_chapter = 6
	li.base_hp = 1100
	li.base_mp = 180
	li.base_atk = 120
	li.base_def = 90
	li.base_spd = 120
	li.base_hit = 140
	li.base_dodge = 70
	li.base_crit = 90
	li.base_crit_dmg = 1.8
	li.base_fortune = 90
	li.base_move_range = 2
	li.base_qi_speed = 1.2
	li.potential_growth = {"根骨": 1.3, "悟性": 2.0, "身法": 1.5, "福缘": 1.9, "定力": 1.4}
	li.known_wuxue = ["莫失莫忘", "大师姐威严", "琴剑双绝"]
	li.equipped_wuxue = ["莫失莫忘"]
	li.xinfa_slots = 7
	li.max_xinfa_slots = 7
	li.qi_value = 29
	li.max_qi_value = 33
	characters[li.id] = li
	
	# 花镜棠《八风不动》
	var hua = CharacterData.new()
	hua.id = "hua_jingtang_bafeng_budong"
	hua.name = "花镜棠"
	hua.title = "八风不动"
	hua.quality = "传说"
	hua.role = "万金油"
	hua.sect = "不器门"
	hua.is_recruitable = true
	hua.recruit_chapter = 7
	hua.base_hp = 1300
	hua.base_mp = 200
	hua.base_atk = 110
	hua.base_def = 110
	hua.base_spd = 100
	hua.base_hit = 110
	hua.base_dodge = 80
	hua.base_crit = 70
	hua.base_crit_dmg = 1.7
	hua.base_fortune = 80
	hua.base_move_range = 3
	hua.base_qi_speed = 1.1
	hua.potential_growth = {"根骨": 1.5, "悟性": 1.5, "身法": 1.6, "福缘": 1.5, "定力": 1.7}
	hua.known_wuxue = ["慈悲相", "忿怒相", "八风不动"]
	hua.equipped_wuxue = ["慈悲相"]
	hua.xinfa_slots = 7
	hua.max_xinfa_slots = 7
	hua.qi_value = 29
	hua.max_qi_value = 33
	characters[hua.id] = hua
	
	# 唐婉《三生愿》
	var tang = CharacterData.new()
	tang.id = "tang_wan_sansheng_yuan"
	tang.name = "唐婉"
	tang.title = "三生愿"
	tang.quality = "绝世"
	tang.role = "主辅"
	tang.sect = "南山派"
	tang.is_recruitable = true
	tang.recruit_chapter = 8
	tang.base_hp = 900
	tang.base_mp = 200
	tang.base_atk = 60
	tang.base_def = 60
	tang.base_spd = 90
	tang.base_hit = 100
	tang.base_dodge = 50
	tang.base_crit = 30
	tang.base_crit_dmg = 1.5
	tang.base_fortune = 100
	tang.base_move_range = 2
	tang.base_qi_speed = 1.0
	tang.potential_growth = {"根骨": 1.1, "悟性": 1.8, "身法": 1.3, "福缘": 2.0, "定力": 1.2}
	tang.known_wuxue = ["三生愿", "为我而生", "桃花誓"]
	tang.equipped_wuxue = ["三生愿"]
	tang.xinfa_slots = 7
	tang.max_xinfa_slots = 7
	tang.qi_value = 29
	tang.max_qi_value = 31
	characters[tang.id] = tang
	
	# 陆游《东灵剑气》
	var lu = CharacterData.new()
	lu.id = "lu_you_dongling_jianqi"
	lu.name = "陆游"
	lu.title = "东灵剑气"
	lu.quality = "传说"
	lu.role = "副攻"
	lu.sect = "铁石岛"
	lu.is_recruitable = true
	lu.recruit_chapter = 8
	lu.base_hp = 1100
	lu.base_mp = 150
	lu.base_atk = 140
	lu.base_def = 80
	lu.base_spd = 100
	lu.base_hit = 120
	lu.base_dodge = 60
	lu.base_crit = 80
	lu.base_crit_dmg = 1.9
	lu.base_fortune = 70
	lu.base_move_range = 2
	lu.base_qi_speed = 1.1
	lu.potential_growth = {"根骨": 1.6, "悟性": 1.7, "身法": 1.3, "福缘": 1.4, "定力": 1.3}
	lu.known_wuxue = ["东灵剑气", "剑气纵横", "陆游诗剑"]
	lu.equipped_wuxue = ["东灵剑气"]
	lu.xinfa_slots = 7
	lu.max_xinfa_slots = 7
	lu.qi_value = 29
	lu.max_qi_value = 33
	characters[lu.id] = lu
	
	# 王维《摩诘诗画》
	var wang = CharacterData.new()
	wang.id = "wang_wei_mojie_shihua"
	wang.name = "王维"
	wang.title = "摩诘诗画"
	wang.quality = "绝世"
	wang.role = "主辅"
	wang.sect = "华山派"
	wang.is_recruitable = true
	wang.recruit_chapter = 9
	wang.base_hp = 800
	wang.base_mp = 220
	wang.base_atk = 50
	wang.base_def = 50
	wang.base_spd = 80
	wang.base_hit = 110
	wang.base_dodge = 60
	wang.base_crit = 40
	wang.base_crit_dmg = 1.5
	wang.base_fortune = 120
	wang.base_move_range = 2
	wang.base_qi_speed = 0.9
	wang.potential_growth = {"根骨": 1.0, "悟性": 2.0, "身法": 1.2, "福缘": 1.8, "定力": 1.5}
	wang.known_wuxue = ["空谷幽兰", "诗画江湖", "摩诘无我"]
	wang.equipped_wuxue = ["空谷幽兰"]
	wang.xinfa_slots = 7
	wang.max_xinfa_slots = 7
	wang.qi_value = 29
	wang.max_qi_value = 31
	characters[wang.id] = wang
	
	# 李香君《空山凝云》
	var li_x = CharacterData.new()
	li_x.id = "li_xiangjun_kongshan_ningyun"
	li_x.name = "李香君"
	li_x.title = "空山凝云"
	li_x.quality = "传说"
	li_x.role = "副辅"
	li_x.sect = "河洛帮"
	li_x.is_recruitable = true
	li_x.recruit_chapter = 10
	li_x.base_hp = 900
	li_x.base_mp = 180
	li_x.base_atk = 70
	li_x.base_def = 70
	li_x.base_spd = 110
	li_x.base_hit = 120
	li_x.base_dodge = 70
	li_x.base_crit = 60
	li_x.base_crit_dmg = 1.6
	li_x.base_fortune = 80
	li_x.base_move_range = 3
	li_x.base_qi_speed = 1.2
	li_x.potential_growth = {"根骨": 1.2, "悟性": 1.6, "身法": 1.8, "福缘": 1.5, "定力": 1.3}
	li_x.known_wuxue = ["桃花扇", "空山凝云", "血溅桃花"]
	li_x.equipped_wuxue = ["桃花扇"]
	li_x.xinfa_slots = 7
	li_x.max_xinfa_slots = 7
	li_x.qi_value = 29
	li_x.max_qi_value = 33
	characters[li_x.id] = li_x
	
	# 翠袖《云淡风轻》
	var cui = CharacterData.new()
	cui.id = "cuixiu_yundan_fengqing"
	cui.name = "翠袖"
	cui.title = "云淡风轻"
	cui.quality = "绝世"
	cui.role = "副辅"
	cui.sect = "不器门"
	cui.is_recruitable = true
	cui.recruit_chapter = 11
	cui.base_hp = 1000
	cui.base_mp = 160
	cui.base_atk = 80
	cui.base_def = 90
	cui.base_spd = 120
	cui.base_hit = 110
	cui.base_dodge = 90
	cui.base_crit = 50
	cui.base_crit_dmg = 1.5
	cui.base_fortune = 70
	cui.base_move_range = 3
	cui.base_qi_speed = 1.3
	cui.potential_growth = {"根骨": 1.3, "悟性": 1.5, "身法": 1.9, "福缘": 1.4, "定力": 1.4}
	cui.known_wuxue = ["云淡风轻", "机关百变", "毒术折磨"]
	cui.equipped_wuxue = ["云淡风轻"]
	cui.xinfa_slots = 7
	cui.max_xinfa_slots = 7
	cui.qi_value = 29
	cui.max_qi_value = 31
	characters[cui.id] = cui
	
	# 曲玉《蔷薇之心》
	var qu = CharacterData.new()
	qu.id = "qu_yu_qiangwei_zhixin"
	qu.name = "曲玉"
	qu.title = "蔷薇之心"
	qu.quality = "传说"
	qu.role = "主辅"
	qu.sect = "天武"
	qu.is_recruitable = true
	qu.recruit_chapter = 12
	qu.base_hp = 850
	qu.base_mp = 250
	qu.base_atk = 40
	qu.base_def = 40
	qu.base_spd = 70
	qu.base_hit = 90
	qu.base_dodge = 50
	qu.base_crit = 20
	qu.base_crit_dmg = 1.5
	qu.base_fortune = 150
	qu.base_move_range = 2
	qu.base_qi_speed = 0.8
	qu.potential_growth = {"根骨": 1.0, "悟性": 1.5, "身法": 1.0, "福缘": 2.2, "定力": 1.8}
	qu.known_wuxue = ["蔷薇之心", "群体治疗", "集气怒气"]
	qu.equipped_wuxue = ["蔷薇之心"]
	qu.xinfa_slots = 7
	qu.max_xinfa_slots = 7
	qu.qi_value = 29
	qu.max_qi_value = 31
	characters[qu.id] = qu
	
	# 分类索引
	_build_indices()

func _build_indices():
	characters_by_quality.clear()
	characters_by_sect.clear()
	characters_by_role.clear()
	recruitable_characters.clear()
	
	for char in characters.values():
		# 品质索引
		if not characters_by_quality.has(char.quality):
			characters_by_quality[char.quality] = []
		characters_by_quality[char.quality].append(char)
		
		# 门派索引
		if char.sect != "":
			if not characters_by_sect.has(char.sect):
				characters_by_sect[char.sect] = []
			characters_by_sect[char.sect].append(char)
		
		# 定位索引
		if not characters_by_role.has(char.role):
			characters_by_role[char.role] = []
		characters_by_role[char.role].append(char)
		
		# 可招募
		if char.is_recruitable:
			recruitable_characters.append(char)

func get_character(id: String) -> CharacterData:
	return characters.get(id)

func get_all_characters() -> Array[CharacterData]:
	return characters.values()

func get_characters_by_quality(quality: String) -> Array[CharacterData]:
	return characters_by_quality.get(quality, [])

func get_characters_by_sect(sect: String) -> Array[CharacterData]:
	return characters_by_sect.get(sect, [])

func get_characters_by_role(role: String) -> Array[CharacterData]:
	return characters_by_role.get(role, [])

func get_recruitable_characters(chapter: int = -1) -> Array[CharacterData]:
	if chapter == -1:
		return recruitable_characters
	return recruitable_characters.filter(func(c): return c.recruit_chapter <= chapter)

func get_protagonist() -> CharacterData:
	return protagonist

func get_random_character(quality_weights: Dictionary = {}) -> CharacterData:
	var weights = quality_weights.duplicate()
	if weights.is_empty():
		weights = {
			"普通": 0.5,
			"优秀": 0.25,
			"精英": 0.15,
			"名士": 0.07,
			"大师": 0.025,
			"宗师": 0.005,
			"绝世": 0.001,
			"传说": 0.0005,
			"神话": 0.0001
		}
	
	var rand = rng.randf_range(0.0, 1.0)
	var cumulative = 0.0
	
	for quality in ["普通", "优秀", "精英", "名士", "大师", "宗师", "绝世", "传说", "神话"]:
		cumulative += weights.get(quality, 0.0)
		if rand <= cumulative:
			var list = characters_by_quality.get(quality, [])
			if list.size() > 0:
				return list[rng.randi_range(0, list.size() - 1)]
	
	# 兜底返回第一个
	var all = characters.values()
	return all[rng.randi_range(0, all.size() - 1)]

func get_character_count() -> int:
	return characters.size()
