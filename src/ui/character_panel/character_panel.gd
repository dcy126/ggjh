extends Control
class_name CharacterPanelUI

@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var title_label: Label = %TitleLabel
@onready var level_label: Label = %LevelLabel
@onready var exp_bar: ProgressBar = %ExpBar
@onready var breakthrough_label: Label = %BreakthroughLabel
@onready var potential_label: Label = %PotentialLabel

@onready var hp_label: Label = %HPLabel
@onready var mp_label: Label = %MPLabel
@onready var atk_label: Label = %ATKLabel
@onready var def_label: Label = %DEFLabel
@onready var spd_label: Label = %SPDLabel
@onready var hit_label: Label = %HITLabel
@onready var dodge_label: Label = %DODGELabel
@onready var crit_label: Label = %CRITLabel
@onready var crit_dmg_label: Label = %CRITDMGLabel
@onready var fortune_label: Label = %FORTUNELabel
@onready var move_range_label: Label = %MoveRangeLabel
@onready var qi_speed_label: Label = %QISpeedLabel

@onready var equipped_items: GridContainer = %EquippedItems
@onready var equipped_wuxue: GridContainer = %EquippedWuxue
@onready var equipped_xinfa: GridContainer = %EquippedXinfa
@onready var talents_list: ItemList = %TalentsList

@onready var btn_potential: Button = %BtnPotential
@onready var btn_wuxue: Button = %BtnWuxue
@onready var btn_equipment: Button = %BtnEquipment
@onready var btn_xinfa: Button = %BtnXinfa
@onready var btn_talents: Button = %BtnTalents
@onready var btn_customization: Button = %BtnCustomization

var current_character: CharacterData = null

func _ready():
	btn_potential.pressed.connect(_on_potential_pressed)
	btn_wuxue.pressed.connect(_on_wuxue_pressed)
	btn_equipment.pressed.connect(_on_equipment_pressed)
	btn_xinfa.pressed.connect(_on_xinfa_pressed)
	btn_talents.pressed.connect(_on_talents_pressed)
	btn_customization.pressed.connect(_on_customization_pressed)

func set_character(character: CharacterData):
	current_character = character
	_refresh_all()

func _refresh_all():
	if not current_character:
		return
	
	_refresh_basic_info()
	_refresh_attributes()
	_refresh_equipment()
	_refresh_wuxue()
	_refresh_xinfa()
	_refresh_talents()

func _refresh_basic_info():
	name_label.text = "%s  %s" % [current_character.name, current_character.title]
	level_label.text = "Lv.%d" % current_character.potential_level
	exp_bar.max_value = GameData.POTENTIAL_EXP_PER_LEVEL[current_character.potential_level + 1] if current_character.potential_level < GameData.POTENTIAL_MAX_LEVEL else 1
	exp_bar.value = current_character.potential_exp
	breakthrough_label.text = "突破: %d/%d" % [current_character.potential_breakthrough, current_character.max_breakthrough]
	potential_label.text = "资质总和: %.1f" % current_character.get_total_potential()
	
	if current_character.portrait_path != "":
		portrait.texture = load(current_character.portrait_path)

func _refresh_attributes():
	var stats = ["hp", "mp", "atk", "def", "spd", "hit", "dodge", "crit", "fortune"]
	var labels = [hp_label, mp_label, atk_label, def_label, spd_label, hit_label, dodge_label, crit_label, fortune_label]
	
	for i in range(stats.size()):
		var value = current_character.get_stat_at_level(current_character.potential_level, stats[i])
		labels[i].text = "%s: %d" % [stats[i].to_upper(), value]
	
	move_range_label.text = "移动: %d" % current_character.base_move_range
	qi_speed_label.text = "集气: %.1f" % current_character.base_qi_speed
	crit_dmg_label.text = "暴伤: %.0f%%" % (current_character.base_crit_dmg * 100)

func _refresh_equipment():
	for child in equipped_items.get_children():
		child.queue_free()
	
	for slot in current_character.equipment_slots:
		var item_id = current_character.equipped_items.get(slot, "")
		var item_btn = _create_equipment_button(slot, item_id)
		equipped_items.add_child(item_btn)

func _create_equipment_button(slot: String, item_id: String) -> Control:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(80, 100)
	
	var slot_label = Label.new()
	slot_label.text = slot
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(slot_label)
	
	var item_btn = Button.new()
	item_btn.custom_minimum_size = Vector2(64, 64)
	
	if item_id != "":
		var item = EquipmentDatabase.get_equipment(item_id)
		if item:
			item_btn.text = item.name
			item_btn.tooltip_text = _get_equipment_tooltip(item)
			item_btn.add_theme_color_override("font_color", GameData.get_quality_color(item.quality))
	else:
		item_btn.text = "[空]"
	
	item_btn.pressed.connect(_on_equipment_clicked.bind(slot, item_id))
	container.add_child(item_btn)
	
	var enhance_label = Label.new()
	if item_id != "":
		var item = EquipmentDatabase.get_equipment(item_id)
		if item and item.current_enhance_level > 0:
			enhance_label.text = "+%d" % item.current_enhance_level
			enhance_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
	else:
		enhance_label.text = ""
	enhance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(enhance_label)
	
	return container

func _get_equipment_tooltip(item: EquipmentData) -> String:
	var tooltip = "%s [%s]\n" % [item.name, item.type]
	tooltip += "品质: %s\n" % item.quality
	tooltip += "强化: +%d\n" % item.current_enhance_level
	tooltip += "精炼: +%d\n" % item.current_refine_level
	tooltip += "万炼: Lv.%d\n" % item.current_wanlian_level
	
	if item.set_id != "":
		var set_data = EquipmentSetDatabase.get_set(item.set_id)
		if set_data:
			tooltip += "\n套装: %s\n" % set_data.name
			var count = 0
			for slot in current_character.equipment_slots:
				var eq_id = current_character.equipped_items.get(slot, "")
				if eq_id != "":
					var eq = EquipmentDatabase.get_equipment(eq_id)
					if eq and eq.set_id == item.set_id:
						count += 1
			for piece in [2, 4, 6]:
				if count >= piece:
					tooltip += "  %d件效果: 激活\n" % piece
				else:
					tooltip += "  %d件效果: 未激活\n" % piece
	
	return tooltip

func _on_equipment_clicked(slot: String, item_id: String):
	UIManager.get_instance().show_notification("点击了 %s" % slot, "info")

func _refresh_wuxue():
	for child in equipped_wuxue.get_children():
		child.queue_free()
	
	for wuxue_id in current_character.equipped_wuxue:
		var wuxue = WuxueDatabase.get_wuxue(wuxue_id)
		if wuxue:
			var wuxue_btn = Button.new()
			wuxue_btn.text = "Lv.%d %s" % [wuxue.current_level, wuxue.name]
			wuxue_btn.tooltip_text = wuxue.description
			wuxue_btn.custom_minimum_size = Vector2(200, 40)
			wuxue_btn.add_theme_color_override("font_color", GameData.get_quality_color(wuxue.quality))
			wuxue_btn.pressed.connect(_on_wuxue_clicked.bind(wuxue))
			equipped_wuxue.add_child(wuxue_btn)

func _on_wuxue_clicked(wuxue: WuxueData):
	UIManager.get_instance().show_notification("武学: %s" % wuxue.name, "info")

func _refresh_xinfa():
	for child in equipped_xinfa.get_children():
		child.queue_free()
	
	for slot_type in GameData.XINFA_SLOT_TYPES:
		var xinfa_id = current_character.equipped_xinfa.get(slot_type, "")
		var container = HBoxContainer.new()
		container.custom_minimum_size = Vector2(300, 40)
		
		var slot_label = Label.new()
		slot_label.text = "[%s]" % slot_type
		slot_label.custom_minimum_size = Vector2(80, 40)
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(slot_label)
		
		if xinfa_id != "":
			var xinfa = XinfaDatabase.get_xinfa(xinfa_id)
			if xinfa:
				var xinfa_btn = Button.new()
				xinfa_btn.text = "Lv.%d %s" % [xinfa.current_level, xinfa.name]
				xinfa_btn.tooltip_text = xinfa.get_description()
				xinfa_btn.custom_minimum_size = Vector2(200, 40)
				xinfa_btn.add_theme_color_override("font_color", GameData.get_quality_color(xinfa.color))
				xinfa_btn.pressed.connect(_on_xinfa_clicked.bind(xinfa))
				container.add_child(xinfa_btn)
				
				var qi_label = Label.new()
				qi_label.text = "器值: %d" % GameData.get_xinfa_cost(xinfa.color)
				qi_label.custom_minimum_size = Vector2(80, 40)
				qi_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
				container.add_child(qi_label)
		else:
			var empty_label = Label.new()
			empty_label.text = "[空]"
			empty_label.custom_minimum_size = Vector2(200, 40)
			empty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			container.add_child(empty_label)
		
		equipped_xinfa.add_child(container)
	
	for i in range(3):
		var slot_name = "通用%d" % (i + 1)
		var xinfa_id = current_character.equipped_xinfa.get(slot_name, "")
		var container = HBoxContainer.new()
		container.custom_minimum_size = Vector2(300, 40)
		
		var slot_label = Label.new()
		slot_label.text = "[%s]" % slot_name
		slot_label.custom_minimum_size = Vector2(80, 40)
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(slot_label)
		
		if xinfa_id != "":
			var xinfa = XinfaDatabase.get_xinfa(xinfa_id)
			if xinfa:
				var xinfa_btn = Button.new()
				xinfa_btn.text = "Lv.%d %s" % [xinfa.current_level, xinfa.name]
				xinfa_btn.tooltip_text = xinfa.get_description()
				xinfa_btn.custom_minimum_size = Vector2(200, 40)
				xinfa_btn.add_theme_color_override("font_color", GameData.get_quality_color(xinfa.color))
				xinfa_btn.pressed.connect(_on_xinfa_clicked.bind(xinfa))
				container.add_child(xinfa_btn)
				
				var qi_label = Label.new()
				qi_label.text = "器值: %d" % GameData.get_xinfa_cost(xinfa.color)
				qi_label.custom_minimum_size = Vector2(80, 40)
				qi_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
				container.add_child(qi_label)
		else:
			var empty_label = Label.new()
			empty_label.text = "[空]"
			empty_label.custom_minimum_size = Vector2(200, 40)
			empty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			container.add_child(empty_label)
		
		equipped_xinfa.add_child(container)

func _on_xinfa_clicked(xinfa: XinfaData):
	UIManager.get_instance().show_notification("心诀: %s" % xinfa.name, "info")

func _refresh_talents():
	talents_list.clear()
	for talent in current_character.talents:
		var index = talents_list.add_item("[Lv.%d] %s" % [talent.current_level, talent.name])
		talents_list.set_item_metadata(index, talent)
		if talent.current_level > 0:
			talents_list.set_item_custom_fg_color(index, Color(1, 1, 0))
	
	if current_character.exclusive_talent:
		var index = talents_list.add_item("[专属] Lv.%d %s" % [current_character.exclusive_talent.current_level, current_character.exclusive_talent.name])
		talents_list.set_item_metadata(index, current_character.exclusive_talent)
		talents_list.set_item_custom_fg_color(index, Color(1, 0.5, 0))

func _on_potential_pressed():
	UIManager.get_instance().open_ui("potential")

func _on_wuxue_pressed():
	UIManager.get_instance().open_ui("wuxue")

func _on_equipment_pressed():
	UIManager.get_instance().open_ui("equipment")

func _on_xinfa_pressed():
	UIManager.get_instance().open_ui("xinfa")

func _on_talents_pressed():
	UIManager.get_instance().open_ui("talents")

func _on_customization_pressed():
	UIManager.get_instance().open_ui("customization")