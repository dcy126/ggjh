extends Resource
class_name WuxueEffect

@export var effect_type: String = ""
@export var trigger: String = "常驻"
@export var trigger_chance: float = 1.0
@export var params: Dictionary = {}
@export var duration: int = 0
@export var max_stacks: int = 1
@export var stack_type: String = "刷新"
@export var target: String = "自身"
@export var conditions: Array[Dictionary] = []
@export var description: String = ""

func _init():
	if params.is_empty():
		params = {}

func get_description() -> String:
	if description != "":
		return description
	
	var desc = ""
	match effect_type:
		"伤害":
			var dmg_type = params.get("damage_type", "所有")
			var value = params.get("value", 0)
			desc = "%s伤害 %+.0f%%" % [dmg_type, value * 100]
		"治疗":
			var value = params.get("value", 0)
			desc = "治疗 %d" % value
		"护盾":
			var value = params.get("value", 0)
			desc = "护盾 %d" % value
		"加怒气":
			var value = params.get("value", 0)
			desc = "怒气 +%d" % value
		"减怒气":
			var value = params.get("value", 0)
			desc = "怒气 -%d" % value
		"加集气":
			var value = params.get("value", 0.0)
			desc = "集气速度 %+.0f%%" % [value * 100]
		"减集气":
			var value = params.get("value", 0.0)
			desc = "集气速度 %-.0f%%" % [value * 100]
		"眩晕":
			var chance = params.get("chance", 0.0)
			desc = "眩晕 %.0f%%" % [chance * 100]
		"定身":
			var chance = params.get("chance", 0.0)
			desc = "定身 %.0f%%" % [chance * 100]
		"沉默":
			var chance = params.get("chance", 0.0)
			desc = "沉默 %.0f%%" % [chance * 100]
		"缴械":
			var chance = params.get("chance", 0.0)
			desc = "缴械 %.0f%%" % [chance * 100]
		"中毒":
			var dmg = params.get("damage", 0)
			var dur = params.get("duration", 0)
			desc = "中毒 %d/回合(%d回合)" % [dmg, dur]
		"燃烧":
			var dmg = params.get("damage", 0)
			var dur = params.get("duration", 0)
			desc = "燃烧 %d/回合(%d回合)" % [dmg, dur]
		"流血":
			var dmg = params.get("damage", 0)
			var dur = params.get("duration", 0)
			desc = "流血 %d/回合(%d回合)" % [dmg, dur]
		"反击":
			var chance = params.get("chance", 0.0)
			desc = "反击 %.0f%%" % [chance * 100]
		"反伤":
			var value = params.get("value", 0.0)
			desc = "反伤 %+.0f%%" % [value * 100]
		"吸血":
			var value = params.get("value", 0.0)
			desc = "吸血 %+.0f%%" % [value * 100]
		"格挡":
			var chance = params.get("chance", 0.0)
			var value = params.get("value", 0.0)
			desc = "格挡 %.0f%%(%+.0f%%)" % [chance * 100, value * 100]
		"无敌":
			var dur = params.get("duration", 0)
			desc = "无敌 %d回合" % dur
		"隐身":
			var dur = params.get("duration", 0)
			desc = "隐身 %d回合" % dur
		"分身":
			var count = params.get("count", 0)
			desc = "分身 %d个" % count
		"召唤":
			var id = params.get("summon_id", "")
			desc = "召唤 %s" % id
		"清除减益":
			var count = params.get("count", 0)
			desc = "清除%d个减益" % count
		"清除增益":
			var count = params.get("count", 0)
			desc = "清除%d个增益" % count
		"复活":
			var hp_pct = params.get("hp_percent", 0.0)
			desc = "复活(%.0f%%血量)" % [hp_pct * 100]
		"延迟生效":
			var timestamp = params.get("timestamp", 0)
			var effect_id = params.get("effect_id", "")
			desc = "%d时序触发%s" % [timestamp, effect_id]
		"按时序触发":
			var timestamps = params.get("timestamps", [])
			var effect_id = params.get("effect_id", "")
			desc = "时序%s触发%s" % [timestamps, effect_id]
		"连击":
			var count = params.get("count", 0)
			desc = "连击%d次" % count
		"追击":
			var chance = params.get("chance", 0.0)
			desc = "追击 %.0f%%" % [chance * 100]
		"协同":
			var ally = params.get("ally", "")
			desc = "与%s协同" % ally
		"合击":
			var allies = params.get("allies", [])
			desc = "与%s合击" % allies
		"连环":
			var count = params.get("count", 0)
			desc = "连环%d次" % count
		"连舞":
			desc = "连舞"
		"连斩":
			desc = "连斩"
		"连刺":
			desc = "连刺"
		"连射":
			desc = "连射"
		"连劈":
			desc = "连劈"
		"连砍":
			desc = "连砍"
		"连扫":
			desc = "连扫"
		"连点":
			desc = "连点"
		"连按":
			desc = "连按"
		"连推":
			desc = "连推"
		"连拉":
			desc = "连拉"
		"连转":
			desc = "连转"
		"连飞":
			desc = "连飞"
		"连落":
			desc = "连落"
		"连滚":
			desc = "连滚"
		"连跳":
			desc = "连跳"
		"连闪":
			desc = "连闪"
		"连影":
			desc = "连影"
		"连分身":
			desc = "连分身"
		"连召唤":
			desc = "连召唤"
		"连变身":
			desc = "连变身"
		"连化蝶":
			desc = "连化蝶"
		"连魔刀":
			desc = "连魔刀"
		"连佛刀":
			desc = "连佛刀"
		"连阴阳":
			desc = "连阴阳"
		"连幻影":
			desc = "连幻影"
		"连机关":
			desc = "连机关"
		"连地雷":
			desc = "连地雷"
		"连龙拳":
			desc = "连龙拳"
		"连剑气":
			desc = "连剑气"
		"连内伤":
			desc = "连内伤"
		"连重剑":
			desc = "连重剑"
		"连慈悲":
			desc = "连慈悲"
		"连忿怒":
			desc = "连忿怒"
		"连援护":
			desc = "连援护"
		"连挡刀":
			desc = "连挡刀"
		_:
			desc = effect_type
	
	if trigger != "常驻":
		desc = "[%s] %s" % [trigger, desc]
	if trigger_chance < 1.0:
		desc = "%.0f%% %s" % [trigger_chance * 100, desc]
	
	return desc