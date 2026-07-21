extends Control
class_name EquipmentPanelUI

@onready var equipment_grid: GridContainer = %EquipmentGrid
@onready var equipment_inventory: ItemList = %EquipmentInventory
@onready var equipment_detail: RichTextLabel = %EquipmentDetail
@onready var filter_slot: OptionButton = %FilterSlot
@onready var filter_quality: OptionButton = %FilterQuality
@onready var btn_equip: Button = %BtnEquip
@onready var btn_unequip: Button = %BtnUnequip
@onready var btn_enhance: Button = %BtnEnhance
@onready var btn_refine: Button = %BtnRefine
@onready var btn_wanlian: Button = %BtnWanlian
@onready var btn_gem: Button = %BtnGem
@onready var set_effects_list: ItemList = %SetEffectsList

var current_character: CharacterData = null
var selected_slot: String = ""
var selected_equipment: EquipmentData = null
var selected_inventory_equipment: EquipmentData = null

func _ready():
	equipment_inventory.item_selected.connect(_on_inventory_selected)
	btn_equip.pressed.connect(_on_equip_pressed)
	btn_unequip.pressed.connect(_on_unequip_pressed)
	btn_enhance.pressed.connect(_on_enhance_pressed)
	btn_refine.pressed.connect(_on_refine_pressed)
	btn_wanlian.pressed.connect(_on_wanlian_pressed)
	btn_gem.pressed.connect(_on_gem_pressed)
	filter_slot.item_selected.connect(_on_filter_changed)
	filter_quality.item_selected.connect(_on_filter_changed)
	
	_setup_filters()
	_create_slot_ui()

func _setup_filters():
	filter_slot.add_item("全部")
	for slot in ["武器", "头盔", "衣服", "护腕", "鞋子", "项链", "戒指", "腰带", "护符", "暗器"]:
		filter_slot.add_item(slot)
	
	filter_quality.add_item("全部")
	for quality in ["白", "绿", "蓝", "紫", "金", "红"]:
		filter_quality.add_item(quality)

func _create_slot_ui():
	for slot in ["武器", "头盔", "衣服", "护腕", "鞋子", "项链", "戒指", "腰带", "护符", "暗器"]:
		var slot_container = VBoxContainer.new()
		slot_container.custom_minimum_size = Vector2(100, 120)
		
		var slot_label = Label.new()
		slot_label.text = slot
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_container.add_child(slot_label)
		
		var equip_btn = Button.new()
		equip_btn.name = "EquipBtn_%s" % slot
		equip_btn.text = "[空]"
		equip_btn.custom_minimum_size = Vector2(80, 80)
		equip_btn.tooltip_text = "点击装备%s" % slot
		equip_btn.pressed.connect(_on_slot_clicked.bind(slot))
		slot_container.add_child(equip_btn)
		
		var enhance_label = Label.new()
		enhance_label.name = "EnhanceLabel_%s" % slot
		enhance_label.text = ""
		enhance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		enhance_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
		slot_container.add_child(enhance_label)
		
		var refine_label = Label.new()
		refine_label.name = "RefineLabel_%s" % slot
		refine_label.text = ""
		refine_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		refine_label.add_theme_color_override("font_color", Color(0, 0.8, 1))
		slot_container.add_child(refine_label)
		
		var wanlian_label = Label.new()
		wanlian_label.name = "WanlianLabel_%s" % slot
		wanlian_label.text = ""
		wanlian_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wanlian_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
		slot_container.add_child(wanlian_label)
		
		equipment_grid.add_child(slot_container)

func set_character(character: CharacterData):
	current_character = character
	_refresh_all()

func _refresh_all():
	_refresh_slots()
	_refresh_inventory()
	_refresh_set_effects()

func _refresh_slots():
	for slot in ["武器", "头盔", "衣服", "护腕", "鞋子", "项链", "戒指", "腰带", "护符", "暗器"]:
		var item_id = current_character.equipped_items.get(slot, "")
		var slot_container = equipment_grid.find_child("EquipBtn_%s" % slot).get_parent()
		var equip_btn = slot_container.find_child("EquipBtn_%s" % slot)
		var enhance_label = slot_container.find_child("EnhanceLabel_%s" % slot)
		var refine_label = slot_container.find_child("RefineLabel_%s" % slot)
		var wanlian_label = slot_container.find_child("WanlianLabel_%s" % slot)
		
		if item_id != "":
			var item = EquipmentDatabase.get_equipment(item_id)
			if item:
				equip_btn.text = "+%d %s" % [item.current_enhance_level, item.name]
				equip_btn.tooltip_text = _get_equipment_tooltip(item)
				equip_btn.add_theme_color_override("font_color", GameData.get_quality_color(item.quality))
				
				if item.current_enhance_level > 0:
					enhance_label.text = "强化 +%d" % item.current_enhance_level
				else:
					enhance_label.text = ""
				
				if item.current_refine_level > 0:
					refine_label.text = "精炼 +%d" % item.current_refine_level
				else:
					refine_label.text = ""
				
				if item.current_wanlian_level > 0:
					wanlian_label.text = "万炼 Lv.%d" % item.current_wanlian_level
				else:
					wanlian_label.text = ""
		else:
			equip_btn.text = "[空]"
			equip_btn.add_theme_color_override("font_color", Color(1, 1, 1))
			enhance_label.text = ""
			refine_label.text = ""
			wanlian_label.text = ""

func _get_equipment_tooltip(item: EquipmentData) -> String:
	var tooltip = "%s [%s]\n" % [item.name, item.type]
	tooltip += "品质: %s\n" % item.quality
	tooltip += "等级要求: %d\n" % item.level_requirement
	tooltip += "\n基础属性:\n"
	for stat in item.base_stats:
		if item.base_stats[stat] != 0:
			tooltip += "  %s: %d\n" % [stat, item.base_stats[stat]]
	
	tooltip += "\n强化成长:\n"
	for stat in item.enhance_stats_per_level:
		tooltip += "  %s: +%d/级\n" % [stat, item.enhance_stats_per_level[stat]]
	
	if item.current_enhance_level > 0:
		tooltip += "\n当前强化属性:\n"
		for stat in item.enhance_stats_per_level:
			tooltip += "  %s: +%d\n" % [stat, item.enhance_stats_per_level[stat] * item.current_enhance_level]
	
	if item.current_refine_level > 0:
		tooltip += "\n精炼属性:\n"
		for stat in item.refine_stats:
			tooltip += "  %s: +%d\n" % [stat, item.refine_stats[stat] * item.current_refine_level]
	
	if item.current_wanlian_level > 0:
		tooltip += "\n万炼属性:\n"
		for stat in item.wanlian_stats:
			tooltip += "  %s: +%d\n" % [stat, item.wanlian_stats[stat] * item.current_wanlian_level]
	
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
					var effect = set_data.get_effect(piece)
					tooltip += "  %d件: %s (激活)\n" % [piece, _format_effect(effect)]
				else:
					tooltip += "  %d件: %s (未激活)\n" % [piece, _format_effect(set_data.get_effect(piece))]
	
	return tooltip

func _format_effect(effect: Dictionary) -> String:
	var type = effect.get("type", "")
	var params = effect.get("params", {})
	match type:
		"属性加成":
			var parts = []
			for stat in params:
				parts.append("%s %+.0f%%" % [stat, params[stat] * 100])
			return ", ".join(parts)
		"特殊效果":
			return params.get("desc", "特殊效果")
		"终极效果":
			return params.get("desc", "终极效果")
	return "未知效果"

func _refresh_inventory():
	equipment_inventory.clear()
	
	var slot_filter = filter_slot.get_selected_id()
	var quality_filter = filter_quality.get_selected_id()
	
	var all_equipment = EquipmentDatabase.get_all_equipment()
	for item in all_equipment:
		if item.id in current_character.equipped_items.values():
			continue
		
		if slot_filter > 0 and item.slot != filter_slot.get_item_text(slot_filter):
			continue
		if quality_filter > 0 and item.quality != filter_quality.get_item_text(quality_filter):
			continue
		
		var item_text = "[%s] +%d %s" % [item.quality, item.current_enhance_level, item.name]
		var index = equipment_inventory.add_item(item_text)
		equipment_inventory.set_item_metadata(index, item)
		
		var color = GameData.get_quality_color(item.quality)
		equipment_inventory.set_item_custom_fg_color(index, color)

func _refresh_set_effects():
	set_effects_list.clear()
	var all_piece_ids = []
	for slot in current_character.equipment_slots:
		var item_id = current_character.equipped_items.get(slot, "")
		if item_id != "":
			var item = EquipmentDatabase.get_equipment(item_id)
			if item and item.set_id != "":
				all_piece_ids.append(item_id)
	
	# 按套装分组
	var set_counts = {}
	for item_id in all_piece_ids:
		var item = EquipmentDatabase.get_equipment(item_id)
		if item and item.set_id != "":
			if not set_counts.has(item.set_id):
				set_counts[item.set_id] = 0
			set_counts[item.set_id] += 1
	
	for set_id in set_counts:
		var set_data = EquipmentSetDatabase.get_set(set_id)
		if set_data:
			var count = set_counts[set_id]
			for piece_count_str in set_data.effects:
				var piece_count = int(piece_count_str)
				var effect = set_data.effects[piece_count_str]
				var active = count >= piece_count
				var text = "%s %d件: %s %s" % [set_data.name, piece_count, _format_effect(effect), active ? " [激活]" : " [未激活]"]
				var index = set_effects_list.add_item(text)
				if active:
					set_effects_list.set_item_custom_fg_color(index, Color(0, 1, 0))
				else:
					set_effects_list.set_item_custom_fg_color(index, Color(0.7, 0.7, 0.7))

func _on_slot_clicked(slot: String):
	selected_slot = slot
	_refresh_inventory()
	_update_detail()

func _on_inventory_selected(index: int):
	selected_inventory_equipment = equipment_inventory.get_item_metadata(index)
	_update_detail()

func _update_detail():
	var item = selected_inventory_equipment
	if not item:
		equipment_detail.text = "选择一个装备查看详情"
		btn_equip.disabled = true
		btn_unequip.disabled = true
		btn_enhance.disabled = true
		btn_refine.disabled = true
		btn_wanlian.disabled = true
		btn_gem.disabled = true
		return
	
	var detail = ""
	detail += "[color=#ffff00]%s[/color] [%s]\n" % [item.name, item.slot]
	detail += "[color=#ffffff]类型:[/color] %s\n" % item.type
	detail += "[color=#ffffff]品质:[/color] [color=%s]%s[/color]\n" % [GameData.get_quality_color(item.quality).to_html(), item.quality]
	detail += "[color=#ffffff]等级要求:[/color] %d\n" % item.level_requirement
	detail += "[color=#ffffff]强化:[/color] +%d / %d\n" % [item.current_enhance_level, item.max_enhance_level]
	detail += "[color=#ffffff]精炼:[/color] +%d / %d\n" % [item.current_refine_level, item.max_refine_level]
	detail += "[color=#ffffff]万炼:[/color] Lv.%d / %d\n" % [item.current_wanlian_level, item.max_wanlian_level]
	
	detail += "\n[color=#ffff00]基础属性:[/color]\n"
	for stat in item.base_stats:
		if item.base_stats[stat] != 0:
			detail += "  %s: %d\n" % [stat, item.base_stats[stat]]
	
	detail += "\n[color=#ffff00]强化成长:[/color]\n"
	for stat in item.enhance_stats_per_level:
		detail += "  %s: +%d/级\n" % [stat, item.enhance_stats_per_level[stat]]
	
	if item.current_refine_level > 0:
		detail += "\n[color=#ffff00]精炼属性:[/color]\n"
		for stat in item.refine_stats:
			detail += "  %s: +%d\n" % [stat, item.refine_stats[stat] * item.current_refine_level]
	
	if item.current_wanlian_level > 0:
		detail += "\n[color=#ffff00]万炼属性:[/color]\n"
		for stat in item.wanlian_stats:
			detail += "  %s: +%d\n" % [stat, item.wanlian_stats[stat] * item.current_wanlian_level]
	
	if item.set_id != "":
		var set_data = EquipmentSetDatabase.get_set(item.set_id)
		if set_data:
			detail += "\n[color=#ffff00]套装:[/color] %s\n" % set_data.name
	
	equipment_detail.text = detail
	
	btn_equip.disabled = false
	btn_unequip.disabled = true
	btn_enhance.disabled = item.current_enhance_level >= item.max_enhance_level
	btn_refine.disabled = item.current_refine_level >= item.max_refine_level
	btn_wanlian.disabled = item.current_wanlian_level >= item.max_wanlian_level
	btn_gem.disabled = item.gem_slots >= item.max_gem_slots

func _on_equip_pressed():
	if not selected_inventory_equipment or not selected_slot:
		return
	
	var old_item_id = current_character.equipped_items.get(selected_slot, "")
	current_character.equipped_items[selected_slot] = selected_inventory_equipment.id
	
	if old_item_id != "":
		# 放回背包
		pass
	
	_refresh_all()
	UIManager.get_instance().show_notification("装备了 %s" % selected_inventory_equipment.name, "success")

func _on_unequip_pressed():
	if not selected_slot:
		return
	
	var item_id = current_character.equipped_items.get(selected_slot, "")
	if item_id == "":
		return
	
	current_character.equipped_items[selected_slot] = ""
	_refresh_all()
	UIManager.get_instance().show_notification("卸下了装备", "info")

func _on_enhance_pressed():
	if not selected_inventory_equipment:
		return
	
	var item = selected_inventory_equipment
	var materials = item.enhance_materials
	var can_enhance = true
	for mat_id in materials:
		var needed = materials[mat_id]
		var has = PlayerData.get_instance().material_inventory.get(mat_id, 0)
		if has < needed:
			can_enhance = false
			break
	
	if not can_enhance:
		UIManager.get_instance().show_notification("材料不足", "warning")
		return
	
	for mat_id in materials:
		PlayerData.get_instance().material_inventory[mat_id] -= materials[mat_id]
		if PlayerData.get_instance().material_inventory[mat_id] <= 0:
			PlayerData.get_instance().material_inventory.erase(mat_id)
	
	var success = item.try_enhance()
	_update_detail()
	_refresh_slots()
	
	if success:
		UIManager.get_instance().show_notification("%s 强化成功 +%d" % [item.name, item.current_enhance_level], "success")
	else:
		UIManager.get_instance().show_notification("%s 强化失败" % item.name, "error")

func _on_refine_pressed():
	if not selected_inventory_equipment:
		return
	
	var item = selected_inventory_equipment
	var materials = item.refine_materials
	var can_refine = true
	for mat_id in materials:
		var needed = materials[mat_id]
		var has = PlayerData.get_instance().material_inventory.get(mat_id, 0)
		if has < needed:
			can_refine = false
			break
	
	if not can_refine:
		UIManager.get_instance().show_notification("材料不足", "warning")
		return
	
	for mat_id in materials:
		PlayerData.get_instance().material_inventory[mat_id] -= materials[mat_id]
		if PlayerData.get_instance().material_inventory[mat_id] <= 0:
			PlayerData.get_instance().material_inventory.erase(mat_id)
	
	item.try_refine()
	_update_detail()
	_refresh_slots()
	UIManager.get_instance().show_notification("%s 精炼成功 +%d" % [item.name, item.current_refine_level], "success")

func _on_wanlian_pressed():
	if not selected_inventory_equipment:
		return
	
	var item = selected_inventory_equipment
	var materials = item.wanlian_materials
	var can_wanlian = true
	for mat_id in materials:
		var needed = materials[mat_id]
		var has = PlayerData.get_instance().material_inventory.get(mat_id, 0)
		if has < needed:
			can_wanlian = false
			break
	
	if not can_wanlian:
		UIManager.get_instance().show_notification("材料不足", "warning")
		return
	
	for mat_id in materials:
		PlayerData.get_instance().material_inventory[mat_id] -= materials[mat_id]
		if PlayerData.get_instance().material_inventory[mat_id] <= 0:
			PlayerData.get_instance().material_inventory.erase(mat_id)
	
	item.try_wanlian()
	_update_detail()
	_refresh_slots()
	UIManager.get_instance().show_notification("%s 万炼成功 Lv.%d" % [item.name, item.current_wanlian_level], "success")

func _on_gem_pressed():
	if not selected_inventory_equipment:
		return
	UIManager.get_instance().show_notification("宝石镶嵌功能待实现", "info")

func _on_filter_changed(_index: int):
	_refresh_inventory()

func _on_close_pressed():
	visible = false
	UIManager.get_instance().remove_from_stack(self)