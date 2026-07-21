extends Control
class_name BattleUI

@onready var current_turn_label: Label = %CurrentTurnLabel
@onready var current_timestamp_label: Label = %CurrentTimestampLabel
@onready var battle_log: RichTextLabel = %BattleLog
@onready var action_panel: HBoxContainer = %ActionPanel
@onready var skill_buttons: Array[Button] = []
@onready var move_button: Button = %MoveButton
@onready var basic_attack_button: Button = %BasicAttackButton
@onready var wait_button: Button = %WaitButton
@onready var auto_battle_button: Button = %AutoBattleButton
@onready var speed_button: Button = %SpeedButton
@onready var character_portraits: HBoxContainer = %CharacterPortraits
@onready var enemy_portraits: HBoxContainer = %EnemyPortraits
@onready var selected_character_info: VBoxContainer = %SelectedCharacterInfo
@onready var target_indicator: TextureRect = %TargetIndicator
@onready var grid_highlight: TileMap = %GridHighlight
@onready var damage_numbers: CanvasLayer = %DamageNumbers
@onready var status_effect_icons: HBoxContainer = %StatusEffectIcons

var combat_manager: CombatManager = null
var selected_character: BattleCharacter = null
var selected_skill: WuxueData = null
var is_player_turn: bool = false
var show_move_range: bool = false

func _ready():
	combat_manager = CombatManager.get_instance()
	_setup_signals()
	_setup_skill_buttons()
	_hide_action_panel()

func _setup_signals():
	combat_manager.on_turn_start.connect(_on_turn_start)
	combat_manager.on_turn_end.connect(_on_turn_end)
	combat_manager.on_character_acted.connect(_on_character_acted)
	combat_manager.on_damage_dealt.connect(_on_damage_dealt)
	combat_manager.on_heal_done.connect(_on_heal_done)
	combat_manager.on_status_applied.connect(_on_status_applied)
	combat_manager.on_character_died.connect(_on_character_died)
	combat_manager.on_battle_end.connect(_on_battle_end)
	combat_manager.on_combo_started.connect(_on_combo_started)
	combat_manager.on_combo_finished.connect(_on_combo_finished)
	combat_manager.on_chase_triggered.connect(_on_chase_triggered)
	combat_manager.on_counter_triggered.connect(_on_counter_triggered)

func _setup_skill_buttons():
	for i in range(4):
		var btn = Button.new()
		btn.name = "SkillBtn_%d" % i
		btn.custom_minimum_size = Vector2(80, 80)
		btn.pressed.connect(_on_skill_button_pressed.bind(i))
		skill_buttons.append(btn)
		action_panel.add_child(btn)

func _on_turn_start(character: BattleCharacter):
	if character.team == 0 and character.is_player_controlled:
		is_player_turn = true
		selected_character = character
		_show_action_panel(character)
		_update_character_portraits()
		_update_selected_info(character)
		_show_move_range(character)
	else:
		is_player_turn = false
		_hide_action_panel()
	
	current_turn_label.text = "回合: %d" % combat_manager.current_turn
	current_timestamp_label.text = "时序: %d" % combat_manager.current_timestamp

func _on_turn_end(character: BattleCharacter):
	if character == selected_character:
		_hide_action_panel()
		_hide_move_range()

func _on_character_acted(character: BattleCharacter, action: String):
	add_battle_log("%s %s" % [character.character_name, action])

func _on_damage_dealt(attacker: BattleCharacter, defender: BattleCharacter, damage: int, damage_type: String, is_crit: bool):
	var color = "yellow" if is_crit else "white"
	if damage_type == "内功":
		color = "cyan"
	elif damage_type == "真实":
		color = "gold"
	add_battle_log("[color=%s]%s 对 %s 造成 %d 点 %s 伤害[/color]" % [color, attacker.character_name, defender.character_name, damage, damage_type])

func _on_heal_done(healer: BattleCharacter, target: BattleCharacter, amount: int):
	add_battle_log("[color=green]%s 治疗了 %s %d 点血量[/color]" % [healer.character_name, target.character_name, amount])

func _on_status_applied(target: BattleCharacter, status: StatusEffect):
	add_battle_log("[color=orange]%s 获得了状态: %s[/color]" % [target.character_name, status.get_description()])
	_update_status_icons(target)

func _on_character_died(character: BattleCharacter):
	add_battle_log("[color=red]%s 倒下了[/color]" % character.character_name)
	_update_character_portraits()

func _on_battle_end(result: String):
	_hide_action_panel()
	if result == "victory":
		add_battle_log("[color=gold]=== 胜利 ====[/color]")
		_show_victory_screen()
	elif result == "defeat":
		add_battle_log("[color=red]=== 失败 ====[/color]")
		_show_defeat_screen()
	elif result == "time_up":
		add_battle_log("[color=red]=== 时序耗尽，失败 ====[/color]")
		_show_defeat_screen()

func _on_combo_started(character: BattleCharacter, combo: Combo):
	add_battle_log("[color=purple]%s 发动了连击: %s[/color]" % [character.character_name, combo.name])

func _on_combo_finished(character: BattleCharacter, combo: Combo):
	add_battle_log("[color=purple]%s 的连击结束[/color]" % character.character_name)

func _on_chase_triggered(attacker: BattleCharacter, target: BattleCharacter):
	add_battle_log("[color=orange]%s 触发了追击！[/color]" % attacker.character_name)

func _on_counter_triggered(defender: BattleCharacter, attacker: BattleCharacter):
	add_battle_log("[color=cyan]%s 触发了反击！[/color]" % defender.character_name)

func _show_action_panel(character: BattleCharacter):
	action_panel.visible = true
	
	# 设置技能按钮
	for i in range(4):
		if i < character.equipped_wuxue.size():
			var skill_id = character.equipped_wuxue[i]
			var skill = WuxueDatabase.get_instance().get_wuxue(skill_id)
			if skill:
				skill_buttons[i].text = skill.name
				skill_buttons[i].tooltip_text = skill.description
				skill_buttons[i].disabled = not skill.can_use(character, combat_manager)
				skill_buttons[i].visible = true
			else:
				skill_buttons[i].visible = false
		else:
			skill_buttons[i].visible = false
	
	move_button.pressed = false
	basic_attack_button.pressed = false
	wait_button.pressed = false

func _hide_action_panel():
	action_panel.visible = false

func _update_character_portraits():
	_update_portrait_container(character_portraits, combat_manager.get_allies(0))
	_update_portrait_container(enemy_portraits, combat_manager.get_enemies(0))

func _update_portrait_container(container: HBoxContainer, characters: Array[BattleCharacter]):
	for child in container.get_children():
		child.queue_free()
	
	for char in characters:
		var portrait = _create_character_portrait(char)
		container.add_child(portrait)

func _create_character_portrait(character: BattleCharacter) -> Control:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(80, 100)
	
	var sprite = TextureRect.new()
	sprite.custom_minimum_size = Vector2(64, 64)
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if character.battle_sprite_path != "":
		sprite.texture = load(character.battle_sprite_path)
	container.add_child(sprite)
	
	var name_label = Label.new()
	name_label.text = character.character_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.custom_minimum_size = Vector2(80, 20)
	container.add_child(name_label)
	
	var hp_bar = ProgressBar.new()
	hp_bar.min_value = 0
	hp_bar.max_value = character.max_hp
	hp_bar.value = character.current_hp
	hp_bar.custom_minimum_size = Vector2(70, 10)
	container.add_child(hp_bar)
	
	var mp_bar = ProgressBar.new()
	mp_bar.min_value = 0
	mp_bar.max_value = character.max_mp
	mp_bar.value = character.current_mp
	mp_bar.custom_minimum_size = Vector2(70, 6)
	container.add_child(mp_bar)
	
	var qi_bar = ProgressBar.new()
	qi_bar.min_value = 0
	qi_bar.max_value = character.max_qi
	qi_bar.value = character.qi
	qi_bar.custom_minimum_size = Vector2(70, 6)
	container.add_child(qi_bar)
	
	var rage_bar = ProgressBar.new()
	rage_bar.min_value = 0
	rage_bar.max_value = character.max_rage
	rage_bar.value = character.rage
	rage_bar.custom_minimum_size = Vector2(70, 6)
	container.add_child(rage_bar)
	
	if character == selected_character:
		container.modulate = Color(1, 1, 0.5, 1)
	
	return container

func _update_selected_info(character: BattleCharacter):
	selected_character_info.visible = true
	
	var name_label = selected_character_info.get_node_or_null("NameLabel")
	if name_label:
		name_label.text = "%s (Lv.%d)" % [character.character_name, character.level]
	
	var hp_label = selected_character_info.get_node_or_null("HPLabel")
	if hp_label:
		hp_label.text = "气血: %d/%d" % [character.current_hp, character.max_hp]
	
	var mp_label = selected_character_info.get_node_or_null("MPLabel")
	if mp_label:
		mp_label.text = "内力: %d/%d" % [character.current_mp, character.max_mp]
	
	var qi_label = selected_character_info.get_node_or_null("QLabel")
	if qi_label:
		qi_label.text = "集气: %d/%d" % [character.qi, character.max_qi]
	
	var rage_label = selected_character_info.get_node_or_null("RageLabel")
	if rage_label:
		rage_label.text = "怒气: %d/%d" % [character.rage, character.max_rage]
	
	var stats_label = selected_character_info.get_node_or_null("StatsLabel")
	if stats_label:
		stats_label.text = "攻:%d 防:%d 身:%d 命:%d 闪:%d 暴:%d 福:%d" % [
			character.atk, character.def, character.spd, character.hit, character.dodge, character.crit, character.fortune
		]
	
	_update_status_icons(character)

func _update_status_icons(character: BattleCharacter):
	for child in status_effect_icons.get_children():
		child.queue_free()
	
	for effect in character.status_effects:
		if effect.is_hidden:
			continue
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.tooltip_text = "%s: %s" % [effect.display_name, effect.get_description()]
		if effect.icon != "":
			icon.texture = load(effect.icon)
		icon.modulate = effect.get_color()
		status_effect_icons.add_child(icon)

func _show_move_range(character: BattleCharacter):
	show_move_range = true
	var reachable = combat_manager.battle_grid.get_reachable_positions(character.grid_pos, character.move_range)
	grid_highlight.clear()
	for pos in reachable:
		grid_highlight.set_cell(0, pos, 0, Vector2i(0, 0))

func _hide_move_range():
	show_move_range = false
	grid_highlight.clear()

func _on_skill_button_pressed(index: int):
	if index < selected_character.equipped_wuxue.size():
		var skill_id = selected_character.equipped_wuxue[index]
		var skill = WuxueDatabase.get_instance().get_wuxue(skill_id)
		if skill and skill.can_use(selected_character, combat_manager):
			selected_skill = skill
			_hide_action_panel()
			_show_skill_targeting(skill)

func _show_skill_targeting(skill: WuxueData):
	# 高亮可选目标
	var targets = combat_manager.battle_grid.get_characters_in_aoe(
		selected_character.grid_pos, skill.target_type, skill.range_max, skill.target_type == "友方单体" or skill.target_type == "友方全体" ? 0 : 1
	)
	
	for target in targets:
		# 高亮目标
		pass
	
	# 等待玩家点击目标
	# 这里简化处理，实际需要输入处理

func _on_move_button_pressed():
	_hide_action_panel()
	_show_move_range(selected_character)

func _on_basic_attack_button_pressed():
	if selected_character and selected_character.can_act():
		var target = _find_nearest_enemy(selected_character)
		if target:
			combat_manager.execute_basic_attack(selected_character, target)
			_hide_action_panel()

func _on_wait_button_pressed():
	if selected_character:
		selected_character.add_qi(20)
		_hide_action_panel()
		combat_manager._process_turn()

func _on_auto_battle_button_pressed():
	combat_manager.is_auto_battle = not combat_manager.is_auto_battle
	auto_battle_button.button_pressed = combat_manager.is_auto_battle
	add_battle_log("自动战斗: %s" % ["开启" if combat_manager.is_auto_battle else "关闭"])

func _on_speed_button_pressed():
	var speeds = [1.0, 1.5, 2.0, 3.0]
	var current = combat_manager.battle_speed
	var idx = speeds.find(current)
	if idx >= 0:
		idx = (idx + 1) % speeds.size()
	else:
		idx = 0
	combat_manager.battle_speed = speeds[idx]
	speed_button.text = "速度: %.1fx" % speeds[idx]
	Engine.time_scale = speeds[idx]

func _find_nearest_enemy(character: BattleCharacter) -> BattleCharacter:
	var enemies = combat_manager.get_enemies(character.team)
	var nearest = null
	var min_dist = 999
	for enemy in enemies:
		if enemy.is_alive():
			var dist = character.grid_pos.distance_to(enemy.grid_pos)
			if dist < min_dist:
				min_dist = dist
				nearest = enemy
	return nearest

func add_battle_log(text: String):
	battle_log.append_text("[%s] %s\n" % [Time.get_time_string_from_system(), text])
	battle_log.scroll_to_line(battle_log.get_line_count() - 1)

func _show_victory_screen():
	var victory_panel = _create_result_panel("胜利", "gold")
	get_tree().root.add_child(victory_panel)

func _show_defeat_screen():
	var defeat_panel = _create_result_panel("失败", "red")
	get_tree().root.add_child(defeat_panel)

func _create_result_panel(title: String, color: String) -> Control:
	var panel = VBoxContainer.new()
	panel.anchors_preset = Control.PRESET_FULL_RECT
	panel.add_theme_constant_override("separation", 20)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	panel.add_child(bg)
	
	var label = Label.new()
	label.text = "[color=%s]%s[/color]" % [color, title]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(400, 100)
	label.theme_override_font_sizes/font_size = 48
	panel.add_child(label)
	
	var btn = Button.new()
	btn.text = "确定"
	btn.custom_minimum_size = Vector2(200, 60)
	btn.theme_override_font_sizes/font_size = 28
	btn.pressed.connect(_on_result_confirm.bind(panel))
	panel.add_child(btn)
	
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, PRESET_MODE_KEEP_SIZE, Vector2(400, 250))
	return panel

func _on_result_confirm(panel: Control):
	panel.queue_free()
	get_tree().change_scene_to_file("res://src/scenes/world/world.tscn")