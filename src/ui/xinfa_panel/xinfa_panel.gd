extends Control
class_name XinfaPanelUI

@onready var xinfa_slots: GridContainer = %XinfaSlots
@onready var xinfa_inventory: ItemList = %XinfaInventory
@onready var xinfa_detail: RichTextLabel = %XinfaDetail
@onready var filter_slot: OptionButton = %FilterSlot
@onready var filter_color: OptionButton = %FilterColor
@onready var total_qi_label: Label = %TotalQiLabel
@onready var btn_equip: Button = %BtnEquip
@onready var btn_unequip: Button = %BtnUnequip
@onready var btn_upgrade: Button = %BtnUpgrade
@onready var btn_forget: Button = %BtnForget
@onready var set_effects_list: ItemList = %SetEffectsList

var current_character: CharacterData = null
var selected_slot_type: String = ""
var selected_xinfa: XinfaData = null
var selected_inventory_xinfa: XinfaData = null

func _ready():
	xinfa_inventory.item_selected.connect(_on_inventory_selected)
	btn_equip.pressed.connect(_on_equip_pressed)
	btn_unequip.pressed.connect(_on_unequip_pressed)
	btn_upgrade.pressed.connect(_on_upgrade_pressed)
	btn_forget.pressed.connect(_on_forget_pressed)
	filter_slot.item_selected.connect(_on_filter_changed)
	filter_color.item_selected.connect(_on_filter_changed)
	
	_setup_filters()
	_create_slot_ui()

func _setup_filters():
	filter_slot.add_item("全部")
	for slot in GameData.XINFA_SLOT_TYPES:
		filter_slot.add_item(slot)
	filter_slot.add_item("万能")
	
	filter_color.add_item("全部")
	for color in ["红", "紫", "金", "蓝", "白", "绿", "万能"]:
		filter_color.add_item(color)

func _create_slot_ui():
	for slot_type in GameData.XINFA_SLOT_TYPES:
		var slot_container = VBoxContainer.new()
		slot_container.add_theme_constant_override("separation", 5)
		
		var slot_label = Label.new()
		slot_label.text = "[%s]" % slot_type
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_container.add_child(slot_label)
		
		var equip_btn = Button.new()
		equip_btn.name = "EquipBtn_%s" % slot_type
		equip_btn.text = "[空]"
		equip_btn.custom_minimum_size = Vector2(120, 40)
		equip_btn.tooltip_text = "点击装备%s心诀" % slot_type
		equip_btn.pressed.connect(_on_slot_clicked.bind(slot_type))
		slot_container.add_child(equip_btn)
		
		var qi_label = Label.new()
		qi_label.name = "QiLabel_%s" % slot_type
		qi_label.text = "器值: 0"
		qi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qi_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		slot_container.add_child(qi_label)
		
		xinfa_slots.add_child(slot_container)
	
	# 通用槽位
	for i in range(3):
		var slot_name = "通用%d" % (i + 1)
		var slot_container = VBoxContainer.new()
		slot_container.add_theme_constant_override("separation", 5)
		
		var slot_label = Label.new()
		slot_label.text = "%s" % slot_name
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_container.add_child(slot_label)
		
		var equip_btn = Button.new()
		equip_btn.name = "EquipBtn_%s" % slot_name
		equip_btn.text = "[空]"
		equip_btn.custom_minimum_size = Vector2(120, 40)
		equip_btn.tooltip_text = "点击装备万能心诀"
		equip_btn.pressed.connect(_on_slot_clicked.bind(slot_name))
		slot_container.add_child(equip_btn)
		
		var qi_label = Label.new()
		qi_label.name = "QiLabel_%s" % slot_name
		qi_label.text = "器值: 0"
		qi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qi_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		slot_container.add_child(qi_label)
		
		xinfa_slots.add_child(slot_container)

func set_character(character: CharacterData):
	current_character = character
	_refresh_all()

func _refresh_all():
	_refresh_slots()
	_refresh_inventory()
	_refresh_qi_display()

func _refresh_slots():
	for slot_type in GameData.XINFA_SLOT_TYPES:
		var xinfa_id = current_character.equipped_xinfa.get(slot_type, "")
		var slot_container = xinfa_slots.find_child("EquipBtn_%s" % slot_type).get_parent()
		var equip_btn = slot_container.find_child("EquipBtn_%s" % slot_type)
		var qi_label = slot_container.find_child("QiLabel_%s" % slot_type)
		
		if xinfa_id != "":
			var xinfa = XinfaDatabase.get_instance().get_xinfa(xinfa_id)
			if xinfa:
				equip_btn.text = "Lv.%d %s" % [xinfa.current_level, xinfa.name]
				equip_btn.add_theme_color_override("font_color", GameData.get_quality_color(xinfa.color))
				equip_btn.tooltip_text = xinfa.get_description()
				qi_label.text = "器值: %d" % GameData.get_xinfa_cost(xinfa.color)
			else:
				equip_btn.text = "[空]"
				equip_btn.add_theme_color_override("font_color", Color(1, 1, 1))
				qi_label.text = "器值: 0"
		else:
			equip_btn.text = "[空]"
			equip_btn.add_theme_color_override("font_color", Color(1, 1, 1))
			qi_label.text = "器值: 0"
	
	for i in range(3):
		var slot_name = "通用%d" % (i + 1)
		var xinfa_id = current_character.equipped_xinfa.get(slot_name, "")
		var slot_container = xinfa_slots.find_child("EquipBtn_%s" % slot_name).get_parent()
		var equip_btn = slot_container.find_child("EquipBtn_%s" % slot_name)
		var qi_label = slot_container.find_child("QiLabel_%s" % slot_name)
		
		if xinfa_id != "":
			var xinfa = XinfaDatabase.get_instance().get_xinfa(xinfa_id)
			if xinfa:
				equip_btn.text = "Lv.%d %s" % [xinfa.current_level, xinfa.name]
				equip_btn.add_theme_color_override("font_color", GameData.get_quality_color(xinfa.color))
				equip_btn.tooltip_text = xinfa.get_description()
				qi_label.text = "器值: %d" % GameData.get_xinfa_cost(xinfa.color)
			else:
				equip_btn.text = "[空]"
				equip_btn.add_theme_color_override("font_color", Color(1, 1, 1))
				qi_label.text = "器值: 0"
		else:
			equip_btn.text = "[空]"
			equip_btn.add_theme_color_override("font_color", Color(1, 1, 1))
			qi_label.text = "器值: 0"

func _refresh_inventory():
	xinfa_inventory.clear()
	
	var slot_filter = filter_slot.get_selected_id()
	var color_filter = filter_color.get_selected_id()
	
	var all_xinfa = XinfaDatabase.get_instance().get_all_xinfa()
	for xinfa in all_xinfa:
		if xinfa.id in current_character.equipped_xinfa.values():
			continue
		
		if slot_filter > 0 and xinfa.slot_type != filter_slot.get_item_text(slot_filter) and xinfa.slot_type != "万能":
			continue
		if color_filter > 0 and xinfa.color != filter_color.get_item_text(color_filter):
			continue
		
		var item_text = "[%s] Lv.%d %s" % [xinfa.color, xinfa.current_level, xinfa.name]
		var index = xinfa_inventory.add_item(item_text)
		xinfa_inventory.set_item_metadata(index, xinfa)
		
		var color = GameData.get_quality_color(xinfa.quality)
		xinfa_inventory.set_item_custom_fg_color(index, color)

func _refresh_qi_display():
	var current = current_character.calculate_current_qi_cost()
	var max_qi = current_character.max_qi_value
	total_qi_label.text = "器值: %d / %d" % [current, max_qi]
	
	var color = Color(0, 1, 0) if current <= max_qi else Color(1, 0, 0)
	total_qi_label.add_theme_color_override("font_color", color)
	
	# 套装效果
	_refresh_set_effects()

func _refresh_set_effects():
	set_effects_list.clear()
	for set_id in current_character.equipped_xinfa.values():
		var xinfa = XinfaDatabase.get_instance().get_xinfa(set_id)
		if xinfa and xinfa.set_id != "":
			var set_data = XinfaDatabase.get_instance().get_xinfa_set(xinfa.set_id)
			if set_data:
				var count = 0
				for eq_id in current_character.equipped_xinfa.values():
					var eq_xinfa = XinfaDatabase.get_instance().get_xinfa(eq_id)
					if eq_xinfa and eq_xinfa.set_id == xinfa.set_id:
						count += 1
				
				for piece_count_str in set_data.effects:
					var piece_count = int(piece_count_str)
					var effect = set_data.effects[piece_count_str]
					var active = count >= piece_count
					var text = "%s %d件: %s %s" % [set_data.name, piece_count, effect.get("desc", ""), active ? " [激活]" : " [未激活]"]
					var index = set_effects_list.add_item(text)
					if active:
						set_effects_list.set_item_custom_fg_color(index, Color(0, 1, 0))
					else:
						set_effects_list.set_item_custom_fg_color(index, Color(0.7, 0.7, 0.7))

func _on_slot_clicked(slot_type: String):
	selected_slot_type = slot_type
	_refresh_inventory()
	_update_detail()

func _on_inventory_selected(index: int):
	selected_inventory_xinfa = xinfa_inventory.get_item_metadata(index)
	_update_detail()

func _update_detail():
	var xinfa = selected_inventory_xinfa
	if not xinfa:
		xinfa_detail.text = "选择一个心诀查看详情"
		btn_equip.disabled = true
		btn_unequip.disabled = true
		btn_upgrade.disabled = true
		btn_forget.disabled = true
		return
	
	var detail = ""
	detail += "[color=#ffff00]%s[/color] [%s]\n" % [xinfa.name, xinfa.slot_type]
	detail += "[color=#ffffff]颜色:[/color] [color=%s]%s[/color]\n" % [GameData.get_quality_color(xinfa.color).to_html(), xinfa.color]
	detail += "[color=#ffffff]器值:[/color] %d\n" % GameData.get_xinfa_cost(xinfa.color)
	detail += "[color=#ffffff]等级:[/color] %d / %d\n" % [xinfa.current_level, xinfa.max_level]
	
	detail += "\n[color=#ffff00]属性加成:[/color]\n"
	for stat in xinfa.stat_bonuses:
		var value = xinfa.get_stat_bonus_at_level(stat, xinfa.current_level)
		if value != 0:
			detail += "  %s: %+.0f\n" % [stat, value]
	
	detail += "\n[color=#ffff00]战斗效果:[/color]\n"
	for effect in xinfa.combat_effects:
		detail += "  • %s\n" % effect.get_description()
	
	if xinfa.set_id != "":
		detail += "\n[color=#ffff00]套装:[/color] %s\n" % xinfa.set_id
	
	xinfa_detail.text = detail
	
	btn_equip.disabled = not current_character.can_equip_xinfa(xinfa) or selected_slot_type == "" or (selected_slot_type != "通用" and selected_slot_type != "万能" and xinfa.slot_type != selected_slot_type and xinfa.slot_type != "万能")
	btn_unequip.disabled = true
	btn_upgrade.disabled = xinfa.current_level >= xinfa.max_level
	btn_forget.disabled = false

func _on_equip_pressed():
	if not selected_inventory_xinfa or not selected_slot_type:
		return
	
	var current_qi = current_character.calculate_current_qi_cost()
	var new_qi = current_qi + GameData.get_xinfa_cost(selected_inventory_xinfa.color)
	
	if new_qi > current_character.max_qi_value:
		UIManager.get_instance().show_notification("器值不足", "warning")
		return
	
	# 卸下当前槽位的心诀
	var old_xinfa_id = current_character.equipped_xinfa.get(selected_slot_type, "")
	if old_xinfa_id != "":
		# 放回背包
		pass
	
	current_character.equipped_xinfa[selected_slot_type] = selected_inventory_xinfa.id
	_refresh_all()
	UIManager.get_instance().show_notification("装备了 %s" % selected_inventory_xinfa.name, "success")

func _on_unequip_pressed():
	if not selected_slot_type:
		return
	
	var xinfa_id = current_character.equipped_xinfa.get(selected_slot_type, "")
	if xinfa_id == "":
		return
	
	current_character.equipped_xinfa[selected_slot_type] = ""
	_refresh_all()
	UIManager.get_instance().show_notification("卸下了心诀", "info")

func _on_upgrade_pressed():
	if not selected_inventory_xinfa or selected_inventory_xinfa.current_level >= selected_inventory_xinfa.max_level:
		return
	
	var materials = selected_inventory_xinfa.upgrade_materials
	var can_upgrade = true
	for mat_id in materials:
		var needed = materials[mat_id]
		var has = PlayerData.get_instance().material_inventory.get(mat_id, 0)
		if has < needed:
			can_upgrade = false
			break
	
	if not can_upgrade:
		UIManager.get_instance().show_notification("材料不足", "warning")
		return
	
	for mat_id in materials:
		PlayerData.get_instance().material_inventory[mat_id] -= materials[mat_id]
		if PlayerData.get_instance().material_inventory[mat_id] <= 0:
			PlayerData.get_instance().material_inventory.erase(mat_id)
	
	selected_inventory_xinfa.current_level += 1
	selected_inventory_xinfa.exp = 0
	_update_detail()
	_refresh_inventory()
	UIManager.get_instance().show_notification("%s 升级到 Lv.%d" % [selected_inventory_xinfa.name, selected_inventory_xinfa.current_level], "success")

func _on_forget_pressed():
	if not selected_inventory_xinfa:
		return
	
	# 遗忘返还材料
	var total_exp = selected_inventory_xinfa.exp
	for i in range(1, selected_inventory_xinfa.current_level):
		total_exp += XinfaDatabase.get_instance().get_exp_for_level(i)
	
	# 返还材料（简化处理）
	var materials = selected_inventory_xinfa.upgrade_materials
	for mat_id in materials:
		var return_amount = materials[mat_id] * selected_inventory_xinfa.current_level
		PlayerData.get_instance().add_material(mat_id, return_amount)
	
	# 从数据库移除（实际项目中可能只是标记为已遗忘）
	XinfaDatabase.get_instance().xinfa_list.erase(selected_inventory_xinfa.id)
	
	_refresh_inventory()
	_update_detail()
	UIManager.get_instance().show_notification("遗忘了 %s，返还材料" % selected_inventory_xinfa.name, "success")

func _on_filter_changed(_index: int):
	_refresh_inventory()

func _on_close_pressed():
	visible = false
	UIManager.get_instance().remove_from_stack(self)