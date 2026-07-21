extends Control
class_name WuxinPanelUI

@onready var wuxue_list: ItemList = %WuxueList
@onready var wuxue_detail: RichTextLabel = %WuxueDetail
@onready var filter_type: OptionButton = %FilterType
@onready var filter_quality: OptionButton = %FilterQuality
@onready var btn_learn: Button = %BtnLearn
@onready var btn_equip: Button = %BtnEquip
@onready var btn_upgrade: Button = %BtnUpgrade
@onready var btn_unequip: Button = %BtnUnequip

var current_character: CharacterData = null
var selected_wuxue: WuxueData = null

func _ready():
	wuxue_list.item_selected.connect(_on_wuxue_selected)
	btn_learn.pressed.connect(_on_learn_pressed)
	btn_equip.pressed.connect(_on_equip_pressed)
	btn_upgrade.pressed.connect(_on_upgrade_pressed)
	btn_unequip.pressed.connect(_on_unequip_pressed)
	filter_type.item_selected.connect(_on_filter_changed)
	filter_quality.item_selected.connect(_on_filter_changed)
	
	_setup_filters()

func _setup_filters():
	filter_type.add_item("全部")
	for type in GameData.WUXUE_TYPES:
		filter_type.add_item(type)
	
	filter_quality.add_item("全部")
	for quality in GameData.WUXUE_QUALITIES:
		filter_quality.add_item(quality)

func set_character(character: CharacterData):
	current_character = character
	_refresh_wuxue_list()

func _refresh_wuxue_list():
	wuxue_list.clear()
	
	var type_filter = filter_type.get_selected_id()
	var quality_filter = filter_quality.get_selected_id()
	
	var all_wuxue = WuxueDatabase.get_instance().get_all_wuxue()
	for wuxue in all_wuxue:
		if type_filter > 0 and wuxue.type != filter_type.get_item_text(type_filter):
			continue
		if quality_filter > 0 and wuxue.quality != filter_quality.get_item_text(quality_filter):
			continue
		
		var item_text = "[%s] %s (Lv.%d/%d)" % [wuxue.quality, wuxue.name, wuxue.current_level, wuxue.max_level]
		if wuxue in current_character.known_wuxue:
			item_text = "✓ " + item_text
		if wuxue in current_character.equipped_wuxue:
			item_text = "★ " + item_text
		
		var index = wuxue_list.add_item(item_text)
		wuxue_list.set_item_metadata(index, wuxue)
		
		var color = GameData.get_quality_color(wuxue.quality)
		wuxue_list.set_item_custom_fg_color(index, color)

func _on_wuxue_selected(index: int):
	selected_wuxue = wuxue_list.get_item_metadata(index)
	if selected_wuxue:
		_show_wuxue_detail(selected_wuxue)
		_update_buttons()

func _show_wuxue_detail(wuxue: WuxueData):
	var detail = ""
	detail += "[color=#ffff00]%s[/color] [%s]\n" % [wuxue.name, wuxue.type]
	detail += "[color=#ffffff]品质:[/color] [color=%s]%s[/color]\n" % [GameData.get_quality_color(wuxue.quality).to_html(), wuxue.quality]
	detail += "[color=#ffffff]伤害类型:[/color] %s\n" % wuxue.damage_type
	detail += "[color=#ffffff]目标类型:[/color] %s\n" % wuxue.target_type
	detail += "[color=#ffffff]射程:[/color] %d-%d\n" % [wuxue.range_min, wuxue.range_max]
	detail += "[color=#ffffff]内力消耗:[/color] %d\n" % wuxue.mp_cost
	detail += "[color=#ffffff]怒气消耗:[/color] %d\n" % wuxue.rage_cost
	detail += "[color=#ffffff]集气消耗:[/color] %d\n" % wuxue.qi_cost
	detail += "[color=#ffffff]冷却回合:[/color] %d\n" % wuxue.max_cooldown
	
	if wuxue.base_damage > 0:
		var dmg = wuxue.get_damage_at_level(wuxue.current_level, 100, 100, 100, 50)
		detail += "[color=#ffffff]基础伤害:[/color] %d (Lv.%d: ~%d)\n" % [wuxue.base_damage, wuxue.current_level, dmg]
	
	if wuxue.base_heal > 0:
		detail += "[color=#ffffff]基础治疗:[/color] %d\n" % wuxue.base_heal
	
	if wuxue.shield_amount > 0:
		detail += "[color=#ffffff]护盾值:[/color] %d\n" % wuxue.shield_amount
	
	detail += "\n[color=#ffff00]效果:[/color]\n"
	for effect in wuxue.effects:
		detail += "  • %s\n" % effect.get_description()
	
	if wuxue.zhenjie_level > 0:
		detail += "\n[color=#ff0000]真解 Lv.%d:[/color]\n" % wuxue.zhenjie_level
		for effect in wuxue.zhenjie_effects:
			detail += "  • %s\n" % effect.get_description()
	
	if wuxue.requires_weapon != "":
		detail += "\n[color=#ffffff]需要武器:[/color] %s\n" % wuxue.requires_weapon
	if wuxue.requires_sect != "":
		detail += "[color=#ffffff]需要门派:[/color] %s\n" % wuxue.requires_sect
	
	wuxue_detail.text = detail

func _update_buttons():
	btn_learn.disabled = not selected_wuxue or selected_wuxue in current_character.known_wuxue
	btn_equip.disabled = not selected_wuxue or selected_wuxue not in current_character.known_wuxue or selected_wuxue in current_character.equipped_wuxue or current_character.equipped_wuxue.size() >= current_character.max_wuxue_slots
	btn_unequip.disabled = not selected_wuxue or selected_wuxue not in current_character.equipped_wuxue
	btn_upgrade.disabled = not selected_wuxue or selected_wuxue.current_level >= selected_wuxue.max_level

func _on_learn_pressed():
	if not selected_wuxue or selected_wuxue in current_character.known_wuxue:
		return
	
	# 检查是否满足学习条件
	if selected_wuxue.requires_weapon != "" and not current_character.has_weapon(selected_wuxue.requires_weapon):
		UIManager.get_instance().show_notification("需要装备 %s 类武器" % selected_wuxue.requires_weapon, "warning")
		return
	
	if selected_wuxue.requires_sect != "" and current_character.current_sect != selected_wuxue.requires_sect:
		UIManager.get_instance().show_notification("需要加入 %s" % selected_wuxue.requires_sect, "warning")
		return
	
	current_character.known_wuxue.append(selected_wuxue)
	_refresh_wuxue_list()
	UIManager.get_instance().show_notification("学会了 %s" % selected_wuxue.name, "success")

func _on_equip_pressed():
	if not selected_wuxue or selected_wuxue in current_character.equipped_wuxue:
		return
	
	if current_character.equipped_wuxue.size() >= current_character.max_wuxue_slots:
		UIManager.get_instance().show_notification("武学槽位已满", "warning")
		return
	
	current_character.equipped_wuxue.append(selected_wuxue)
	_refresh_wuxue_list()
	_update_buttons()
	UIManager.get_instance().show_notification("装备了 %s" % selected_wuxue.name, "success")

func _on_unequip_pressed():
	if not selected_wuxue or selected_wuxue not in current_character.equipped_wuxue:
		return
	
	current_character.equipped_wuxue.erase(selected_wuxue)
	_refresh_wuxue_list()
	_update_buttons()
	UIManager.get_instance().show_notification("卸下了 %s" % selected_wuxue.name, "info")

func _on_upgrade_pressed():
	if not selected_wuxue or selected_wuxue.current_level >= selected_wuxue.max_level:
		return
	
	# 检查材料
	var materials = selected_wuxue.upgrade_materials
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
	
	# 消耗材料
	for mat_id in materials:
		PlayerData.get_instance().material_inventory[mat_id] -= materials[mat_id]
		if PlayerData.get_instance().material_inventory[mat_id] <= 0:
			PlayerData.get_instance().material_inventory.erase(mat_id)
	
	selected_wuxue.current_level += 1
	selected_wuxue.exp = 0
	_show_wuxue_detail(selected_wuxue)
	_update_buttons()
	UIManager.get_instance().show_notification("%s 升级到 Lv.%d" % [selected_wuxue.name, selected_wuxue.current_level], "success")

func _on_filter_changed(_index: int):
	_refresh_wuxue_list()

func _on_close_pressed():
	visible = false
	UIManager.get_instance().remove_from_stack(self)