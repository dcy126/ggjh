extends RefCounted
class_name StatusEffect

@export var effect_id: String
@export var effect_type: String
@export var category: String = "减益"
@export var display_name: String = ""
@export var description: String = ""
@export var icon: String = ""

## 效果参数
@export var params: Dictionary = {}

## 持续时间 (回合数，每回合50时序)
@export var duration: int = 1
@export var max_duration: int = 1
@export var remaining_turns: int = 1
@export var remaining_timestamp: int = 50

## 堆叠
@export var current_stacks: int = 1
@export var max_stacks: int = 1
@export var stack_type: String = "刷新"  # 刷新, 叠加, 替换, 独立

## 触发条件
@export var trigger: String = "常驻"  # 常驻, 回合开始, 回合结束, 受击, 攻击, 治疗, 移动, 使用技能, 击杀, 死亡, 时序
@export var trigger_chance: float = 1.0
@export var trigger_params: Dictionary = {}
@export var trigger_cooldown: int = 0
@export var last_trigger_turn: int = -1

## 来源
@export var source: BattleCharacter = null
@export var caster: BattleCharacter = null

## 视觉
@export var particle_effect: String = ""
@export var color: Color = Color.RED
@export var show_particles: bool = true
@export var show_timer: bool = true

## 标签
@export var tags: Array[String] = []

## 是否可被驱散
@export var dispellable: bool = true
@export var is_hidden: bool = false
@export var is_permanent: bool = false

func _init():
	_init_defaults()

func _init_defaults():
	if params.is_empty():
		params = {}
	if trigger_params.is_empty():
		trigger_params = {}
	if tags.is_empty():
		tags = []

func get_description() -> String:
	var desc = description
	for key in params:
		var placeholder = "{" + key + "}"
		if desc.find(placeholder) >= 0:
			desc = desc.replace(placeholder, str(params[key]))
	return "[Lv.%d] %s" % [current_stacks, desc]

func refresh(new_effect: StatusEffect):
	if stack_type == "刷新":
		duration = max(duration, new_effect.duration)
		max_duration = max(max_duration, new_effect.max_duration)
		remaining_turns = duration
		remaining_timestamp = 50
		params = new_effect.params
		if current_stacks < max_stacks:
			current_stacks = min(current_stacks + 1, max_stacks)
	elif stack_type == "叠加":
		current_stacks = min(current_stacks + new_effect.current_stacks, max_stacks)
		duration = max(duration, new_effect.duration)
	elif stack_type == "替换":
		params = new_effect.params
		duration = new_effect.duration
		max_duration = new_effect.max_duration
		remaining_turns = duration
		remaining_timestamp = 50
		current_stacks = new_effect.current_stacks

func on_apply(target: BattleCharacter):
	pass

func on_remove(target: BattleCharacter):
	pass

func on_turn_start(target: BattleCharacter):
	if trigger == "回合开始" and randf() < trigger_chance:
		trigger_effect(target)

func on_turn_end(target: BattleCharacter):
	if trigger == "回合结束" and randf() < trigger_chance:
		trigger_effect(target)

func on_timestamp(target: BattleCharacter, timestamp: int):
	if trigger == "时序" and timestamp % 50 == 0:
		if randf() < trigger_chance:
			trigger_effect(target)

func on_hit(target: BattleCharacter, damage: int, damage_type: String, source: BattleCharacter, is_crit: bool):
	if trigger == "受击" and randf() < trigger_chance:
		trigger_effect(target, source)

func on_attack(target: BattleCharacter, damage: int, damage_type: String, defender: BattleCharacter, is_crit: bool):
	if trigger == "攻击" and randf() < trigger_chance:
		trigger_effect(target, defender)

func on_heal(target: BattleCharacter, amount: int, source: BattleCharacter):
	if trigger == "治疗" and randf() < trigger_chance:
		trigger_effect(target, source)

func on_move(target: BattleCharacter, from_pos: Vector2i, to_pos: Vector2i):
	if trigger == "移动" and randf() < trigger_chance:
		trigger_effect(target)

func on_skill_used(target: BattleCharacter, skill: WuxueData):
	if trigger == "使用技能" and randf() < trigger_chance:
		trigger_effect(target)

func on_kill(target: BattleCharacter, victim: BattleCharacter):
	if trigger == "击杀" and randf() < trigger_chance:
		trigger_effect(target, victim)

func on_death(target: BattleCharacter):
	if trigger == "死亡" and randf() < trigger_chance:
		trigger_effect(target)

func trigger_effect(target: BattleCharacter, trigger_source: BattleCharacter = null):
	if is_permanent:
		return
	
	var current_turn = CombatManager.get_instance().current_turn if CombatManager.get_instance() else 0
	if trigger_cooldown > 0 and current_turn - last_trigger_turn < trigger_cooldown:
		return
	
	last_trigger_turn = current_turn
	
	match effect_type:
		"伤害":
			var dmg = params.get("value", 0) * current_stacks
			target.take_damage(dmg, params.get("damage_type", "真实"), trigger_source or caster or target)
		"治疗":
			var heal = params.get("value", 0) * current_stacks
			target.heal(heal, trigger_source or caster or target)
		"护盾":
			var amount = params.get("value", 0) * current_stacks
			target.add_shield(amount, params.get("shield_type", "通用"), params.get("duration", 1), trigger_source or caster or target)
		"加怒气":
			target.add_rage(params.get("value", 0) * current_stacks)
		"减怒气":
			target.rage = max(target.rage - params.get("value", 0) * current_stacks, 0)
		"加集气":
			target.add_qi(params.get("value", 0) * current_stacks)
		"减集气":
			target.qi = max(target.qi - params.get("value", 0) * current_stacks, 0)
		"位移":
			var grid = CombatManager.get_instance().battle_grid
			if grid:
				var direction = params.get("direction", Vector2i(0, 0))
				var distance = params.get("distance", 1) * current_stacks
				var new_pos = target.grid_pos + direction * distance
				if grid.is_valid_position(new_pos) and grid.is_walkable(new_pos):
					grid.move_character(target, new_pos)
		"击退":
			var grid = CombatManager.get_instance().battle_grid
			if grid and trigger_source:
				var dir = (target.grid_pos - trigger_source.grid_pos).sign()
				var distance = params.get("distance", 1) * current_stacks
				var new_pos = target.grid_pos + dir * distance
				if grid.is_valid_position(new_pos) and grid.is_walkable(new_pos):
					grid.move_character(target, new_pos)
		"拉近":
			var grid = CombatManager.get_instance().battle_grid
			if grid and trigger_source:
				var dir = (trigger_source.grid_pos - target.grid_pos).sign()
				var distance = params.get("distance", 1) * current_stacks
				var new_pos = target.grid_pos + dir * distance
				if grid.is_valid_position(new_pos) and grid.is_walkable(new_pos):
					grid.move_character(target, new_pos)
		"眩晕":
			target.is_stunned = true
			target.cannot_act = true
		"定身":
			target.is_rooted = true
			target.cannot_move = true
		"沉默":
			target.is_silenced = true
		"缴械":
			target.is_disarmed = true
		"中毒":
			apply_dot(target, "中毒", params.get("damage_per_stack", 10) * current_stacks, params.get("duration", 2))
		"燃烧":
			apply_dot(target, "燃烧", params.get("damage_per_stack", 15) * current_stacks, params.get("duration", 2))
		"流血":
			apply_dot(target, "流血", params.get("damage_per_stack", 20) * current_stacks, params.get("duration", 3))
		"减速":
			target.add_temp_stat("move_range", -params.get("value", 1) * current_stacks)
		"减攻":
			target.add_temp_stat("atk", -params.get("value", 0) * current_stacks)
		"减防":
			target.add_temp_stat("def", -params.get("value", 0) * current_stacks)
		"破防":
			target.add_temp_stat("damage_reduction", -params.get("value", 0.0) * current_stacks)
		"破盾":
			for shield in target.shields:
				shield.amount = max(shield.amount - params.get("value", 0) * current_stacks, 0)
		"封印":
			target.cannot_act = true
			target.is_silenced = true
			target.is_disarmed = true
		"诅咒":
			target.add_temp_stat("heal_received", -params.get("value", 0.5) * current_stacks)
		"虚弱":
			target.add_temp_stat("crit", -params.get("value", 100) * current_stacks)
			target.add_temp_stat("crit_dmg", -params.get("crit_dmg", 0.2) * current_stacks)
		"重伤":
			target.add_temp_stat("heal_received", -params.get("value", 1.0) * current_stacks)
		"内伤":
			target.add_temp_stat("mp_regen", -params.get("value", 5) * current_stacks)
		"外伤":
			target.add_temp_stat("hp_regen", -params.get("value", 5) * current_stacks)
		"失明":
			target.is_blind = true
			target.add_temp_stat("hit", -params.get("value", 5000) * current_stacks)
		"混乱":
			target.is_confused = true
		"恐惧":
			target.is_feared = true
		"嘲讽":
			target.is_taunted = true
		"拉条":
			target.add_qi(params.get("value", 20) * current_stacks)
		"推条":
			target.qi = max(target.qi - params.get("value", 20) * current_stacks, 0)
		"偷怒气":
			var stolen = min(params.get("value", 10) * current_stacks, target.rage)
			target.rage -= stolen
			if caster:
				caster.add_rage(stolen)
		"禁疗":
			target.add_temp_stat("heal_received", -1.0)
		"减治疗":
			target.add_temp_stat("heal_received", -params.get("value", 0.5) * current_stacks)
		"反击":
			target.add_temp_stat("counter_chance", params.get("value", 0.2) * current_stacks)
		"反伤":
			target.add_temp_stat("thorns", params.get("value", 0.3) * current_stacks)
		"吸血":
			target.add_temp_stat("lifesteal", params.get("value", 0.2) * current_stacks)
		"格挡":
			target.add_temp_stat("block_chance", params.get("value", 0.3) * current_stacks)
		"无敌":
			target.is_invulnerable = true
		"隐身":
			target.is_stealthed = true
			target.is_untargetable = true
		"分身":
			create_phantom(target, params.get("count", 1))
		"召唤":
			create_summon(target, params.get("summon_id", ""), params.get("count", 1))
		"变身":
			transform_character(target, params.get("form_id", ""))
		"化蝶":
			target.current_form = "化蝶"
			target.form_data = params
		"魔刀":
			target.current_form = "魔刀"
			target.form_data = params
		"佛刀":
			target.current_form = "佛刀"
			target.form_data = params
		"阴阳":
			target.current_form = "阴阳"
			target.form_data = params
		"幻影":
			target.current_form = "幻影"
			target.form_data = params
		"机关":
			place_trap(target, params.get("trap_id", ""))
		"地雷":
			place_mine(target, params.get("mine_id", ""))
		"龙拳":
			target.current_form = "龙拳"
			target.form_data = params
		"剑气":
			target.current_form = "剑气"
			target.form_data = params
		"内伤特效":
			target.add_temp_stat("internal_injury", params.get("value", 10) * current_stacks)
		"重剑":
			target.current_form = "重剑"
			target.form_data = params
		"慈悲相":
			target.current_form = "慈悲相"
			target.form_data = params
		"忿怒相":
			target.current_form = "忿怒相"
			target.form_data = params
		"援护":
			target.add_temp_stat("aid_chance", params.get("value", 0.3) * current_stacks)
		"挡刀":
			target.add_temp_stat("block_forced_block_target(params.get("target_id", "")))
		"清除增益":
			target.clear_buffs()
		"清除减益":
			target.clear_debuffs()
		"清除所有状态":
			target.clear_all_status()
		"复活":
			if not target.is_alive():
				target.revive(params.get("hp_percent", 0.5))
		"延迟生效":
			# 延迟触发，存入队列
			var delayed = trigger_params.duplicate()
			delayed["delay"] = params.get("delay", 1)
			target.add_delayed_effect(delayed)
		"按时序触发":
			# 注册时序回调
			var timestamp = params.get("timestamp", 50)
			target.add_timestamp_callback(timestamp, trigger_params)
		"连击":
			target.combo_count += params.get("count", 1) * current_stacks
		"追击":
			target.chase_count += params.get("count", 1) * current_stacks
		"协同":
			trigger_coop(target, params)
		"连携":
			trigger_link(target, params)
		"合击":
			trigger_combo(target, params)
		"连环":
			trigger_chain(target, params)
		"连舞":
			trigger_dance(target, params)
		"连斩":
			trigger_slash(target, params)
		"连刺":
			trigger_stab(target, params)
		"连射":
			trigger_shot(target, params)
		"连劈":
			trigger_cleave(target, params)
		"连砍":
			trigger_chop(target, params)
		"连扫":
			trigger_sweep(target, params)
		"连点":
			trigger_poke(target, params)
		"连按":
			trigger_press(target, params)
		"连推":
			trigger_push(target, params)
		"连拉":
			trigger_pull(target, params)
		"连转":
			trigger_spin(target, params)
		"连飞":
			trigger_fly(target, params)
		"连落":
			trigger_fall(target, params)
		"连滚":
			trigger_roll(target, params)
		"连跳":
			trigger_jump(target, params)
		"连闪":
			trigger_flash(target, params)
		"连影":
			trigger_shadow(target, params)
		"连分身":
			trigger_phantom(target, params)
		"连召唤":
			trigger_summon(target, params)
		"连变身":
			trigger_transform(target, params)
		"连化蝶":
			trigger_butterfly(target, params)
		"连魔刀":
			trigger_demon_blade(target, params)
		"连佛刀":
			trigger_buddha_blade(target, params)
		"连阴阳":
			trigger_yinyang(target, params)
		"连幻影":
			trigger_phantom_form(target, params)
		"连机关":
			trigger_mechanism(target, params)
		"连地雷":
			trigger_mine(target, params)
		"连龙拳":
			trigger_dragon_fist(target, params)
		"连剑气":
			trigger_sword_qi(target, params)
		"连内伤":
			trigger_internal_injury(target, params)
		"连重剑":
			trigger_heavy_sword(target, params)
		"连慈悲":
			trigger_mercy(target, params)
		"连忿怒":
			trigger_wrath(target, params)
		"连援护":
			trigger_aid(target, params)
		"连挡刀":
			trigger_block(target, params)

func apply_dot(target: BattleCharacter, dot_type: String, damage: int, duration: int):
	var se = StatusEffect.new()
	se.effect_id = dot_type
	se.effect_type = dot_type
	se.category = "减益"
	se.params = {"value": damage}
	se.duration = duration
	se.max_duration = duration
	se.remaining_turns = duration
	se.trigger = "回合结束"
	se.trigger_params = {"damage_type": "真实"}
	se.color = get_dot_color(dot_type)
	target.apply_status_effect(se)

func get_dot_color(dot_type: String) -> Color:
	match dot_type:
		"中毒": return Color(0.2, 0.8, 0.2)
		"燃烧": return Color(1.0, 0.4, 0.1)
		"流血": return Color(0.8, 0.1, 0.1)
		_: return Color.RED

func create_phantom(owner: BattleCharacter, count: int):
	for i in range(count):
		var phantom = Phantom.new()
		phantom.owner = owner
		phantom.character_id = owner.character_id + "_phantom_" + str(i)
		phantom.max_hp = int(owner.max_hp * 0.3)
		phantom.current_hp = phantom.max_hp
		phantom.atk = int(owner.atk * 0.5)
		owner.phantoms.append(phantom)
		var grid = CombatManager.get_instance().battle_grid
		if grid:
			var pos = grid.find_empty_adjacent(owner.grid_pos)
			if pos != Vector2i(-1, -1):
				grid.add_character(phantom, pos)
				phantom.grid_pos = pos
				phantom.team = owner.team

func create_summon(owner: BattleCharacter, summon_id: String, count: int):
	for i in range(count):
		var summon = Summon.new()
		summon.summon_id = summon_id
		summon.owner = owner
		var data = SummonDatabase.get_summon(summon_id)
		if data:
			summon.max_hp = data.base_hp
			summon.current_hp = summon.max_hp
			summon.atk = data.base_atk
			summon.def = data.base_def
			summon.spd = data.base_spd
		owner.summons.append(summon)
		var grid = CombatManager.get_instance().battle_grid
		if grid:
			var pos = grid.find_empty_adjacent(owner.grid_pos)
			if pos != Vector2i(-1, -1):
				grid.add_character(summon, pos)
				summon.grid_pos = pos
				summon.team = owner.team

func transform_character(target: BattleCharacter, form_id: String):
	var form = FormDatabase.get_form(form_id)
	if form:
		target.current_form = form_id
		target.form_data = form.get_data()
		# 应用变身属性
		for stat in form.stat_modifiers:
			target.add_temp_stat(stat, form.stat_modifiers[stat])

func place_trap(caster: BattleCharacter, trap_id: String):
	var grid = CombatManager.get_instance().battle_grid
	if grid:
		grid.add_trap(caster.grid_pos, trap_id, caster)

func place_mine(caster: BattleCharacter, mine_id: String):
	var grid = CombatManager.get_instance().battle_grid
	if grid:
		grid.add_mine(caster.grid_pos, mine_id, caster)

func to_dict() -> Dictionary:
	return {
		"effect_id": effect_id,
		"effect_type": effect_type,
		"category": category,
		"params": params,
		"duration": duration,
		"max_duration": max_duration,
		"remaining_turns": remaining_turns,
		"remaining_timestamp": remaining_timestamp,
		"current_stacks": current_stacks,
		"max_stacks": max_stacks,
		"stack_type": stack_type,
		"trigger": trigger,
		"trigger_chance": trigger_chance,
		"trigger_params": trigger_params,
		"color": color,
		"tags": tags,
		"dispellable": dispellable,
		"is_hidden": is_hidden,
		"is_permanent": is_permanent
	}

func from_dict(data: Dictionary) -> StatusEffect:
	effect_id = data.get("effect_id", "")
	effect_type = data.get("effect_type", "")
	category = data.get("category", "减益")
	params = data.get("params", {})
	duration = data.get("duration", 1)
	max_duration = data.get("max_duration", 1)
	remaining_turns = data.get("remaining_turns", 1)
	remaining_timestamp = data.get("remaining_timestamp", 50)
	current_stacks = data.get("current_stacks", 1)
	max_stacks = data.get("max_stacks", 1)
	stack_type = data.get("stack_type", "刷新")
	trigger = data.get("trigger", "常驻")
	trigger_chance = data.get("trigger_chance", 1.0)
	trigger_params = data.get("trigger_params", {})
	color = data.get("color", Color.RED)
	tags = data.get("tags", [])
	dispellable = data.get("dispellable", true)
	is_hidden = data.get("is_hidden", false)
	is_permanent = data.get("is_permanent", false)
	return self