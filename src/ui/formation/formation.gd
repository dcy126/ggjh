extends Control
class_name FormationUI

@onready var formation_grid: GridContainer = %FormationGrid
@onready var formation_name: OptionButton = %FormationName
@onready var character_list: ItemList = %CharacterList
@onready var btn_save: Button = %BtnSave
@onready var btn_auto: Button = %BtnAuto
@onready var btn_clear: Button = %BtnClear

@onready var preview_container: HBoxContainer = %PreviewContainer
@onready var formation_bonus: RichTextLabel = %FormationBonus

var current_formation: String = "方阵"
var selected_character: String = ""
var formation_positions: Array[Vector2i] = []

func _ready():
	btn_save.pressed.connect(_on_save_pressed)
	btn_auto.pressed.connect(_on_auto_pressed)
	btn_clear.pressed.connect(_on_clear_pressed)
	formation_name.item_selected.connect(_on_formation_changed)
	character_list.item_selected.connect(_on_character_selected)
	
	_setup_formations()
	_load_current_formation()

func _setup_formations():
	formation_name.add_item("方阵")
	formation_name.add_item("长蛇阵")
	formation_name.add_item("雁行阵")
	formation_name.add_item("锋矢阵")
	formation_name.add_item("偃月阵")
	formation_name.add_item("鹤翼阵")

func _load_current_formation():
	current_formation = PlayerData.get_instance().formation_name
	formation_name.select(formation_name.get_item_index(current_formation))
	
	# 加载阵容
	_load_formation_preview()

func _load_formation_preview():
	for child in preview_container.get_children():
		child.queue_free()
	
	var formation = FormationDatabase.get_formation(current_formation)
	if not formation:
		return
	
	# 显示阵型预览
	for i in range(formation.positions.size()):
		var pos = formation.positions[i]
		var slot = _create_formation_slot(i, pos)
		preview_container.add_child(slot)
	
	# 显示阵法加成
	var bonus_text = "[color=#ffff00]%s 阵法加成:[/color]\n" % current_formation
	for buff_type in formation.buffs:
		bonus_text += "  %s: %+.0f%%\n" % [buff_type, formation.buffs[buff_type] * 100]
	
	for effect in formation.shared_effects:
		bonus_text += "  %s\n" % effect.get("desc", "")
	
	formation_bonus.text = bonus_text

func _create_formation_slot(index: int, pos: Vector2i) -> Control:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(80, 80)
	
	var pos_label = Label.new()
	pos_label.text = "位置 %d" % (index + 1)
	pos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(pos_label)
	
	var slot_btn = Button.new()
	slot_btn.custom_minimum_size = Vector2(64, 64)
	slot_btn.pressed.connect(_on_slot_pressed.bind(index))
	
	var char_id = PlayerData.get_instance().formation[index] if index < PlayerData.get_instance().formation.size() else ""
	if char_id != "":
		var character = CharacterDatabase.get_character(char_id)
		if character:
			slot_btn.text = "%s\nLv.%d" % [character.name, character.potential_level]
			slot_btn.tooltip_text = character.name
		else:
			slot_btn.text = "未知"
	else:
		slot_btn.text = "[空]"
	
	container.add_child(slot_btn)
	return container

func _on_formation_changed(index: int):
	current_formation = formation_name.get_item_text(index)
	_load_formation_preview()

func _on_slot_pressed(index: int):
	selected_character = ""
	_load_character_list()

func _load_character_list():
	character_list.clear()
	for char_id in PlayerData.get_instance().companions:
		var character = CharacterDatabase.get_character(char_id)
		if character:
			character_list.add_item("%s Lv.%d [%s]" % [character.name, character.potential_level, character.role])
			character_list.set_item_metadata(character_list.get_item_count() - 1, char_id)

func _on_character_selected(index: int):
	selected_character = character_list.get_item_metadata(index)
	# 将选中的角色放入当前选中的槽位
	# 这里需要记录当前选中的槽位
	pass

func _on_auto_pressed():
	# 自动排列阵容
	var formation = FormationDatabase.get_formation(current_formation)
	if not formation:
		return
	
	var new_formation = []
	var chars = PlayerData.get_instance().formation.duplicate()
	
	for i in range(formation.positions.size()):
		if i < chars.size():
			new_formation.append(chars[i])
		else:
			new_formation.append("")
	
	PlayerData.get_instance().formation = new_formation
	_load_formation_preview()
	UIManager.get_instance().show_notification("自动排列完成", "success")

func _on_clear_pressed():
	PlayerData.get_instance().formation.clear()
	for i in range(6):
		PlayerData.get_instance().formation.append("")
	_load_formation_preview()
	UIManager.get_instance().show_notification("阵容已清空", "info")

func _on_save_pressed():
	PlayerData.get_instance().formation_name = current_formation
	UIManager.get_instance().show_notification("阵法已保存", "success")
	visible = false