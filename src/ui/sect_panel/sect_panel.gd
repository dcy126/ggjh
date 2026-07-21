extends Control
class_name SectPanelUI

@onready var sect_info: VBoxContainer = %SectInfo
@onready var sect_name_label: Label = %SectNameLabel
@onready var sect_desc_label: Label = %SectDescLabel
@onready var sect_leader_label: Label = %SectLeaderLabel
@onready var sect_location_label: Label = %SectLocationLabel
@onready var sect_level_label: Label = %SectLevelLabel
@onready var sect_exp_bar: ProgressBar = %SectExpBar
@onready var sect_contribution_label: Label = %SectContributionLabel

@onready var wuxue_list: ItemList = %WuxueList
@onready var wuxue_detail: RichTextLabel = %WuxueDetail
@onready var btn_learn_wuxue: Button = %BtnLearnWuxue

@onready var talents_list: ItemList = %TalentsList
@onready var talent_detail: RichTextLabel = %TalentDetail
@onready var btn_learn_talent: Button = %BtnLearnTalent

@onready var shop_list: ItemList = %ShopList
@onready var shop_detail: RichTextLabel = %ShopDetail
@onready var btn_buy: Button = %BtnBuy

@onready var rewards_list: ItemList = %RewardsList
@onready var btn_claim: Button = %BtnClaim

@onready var btn_join: Button = %BtnJoin
@onready var btn_leave: Button = %BtnLeave
@onready var btn_donate: Button = %BtnDonate

var current_sect: SectData = null
var current_character: CharacterData = null

func _ready():
	btn_learn_wuxue.pressed.connect(_on_learn_wuxue)
	btn_learn_talent.pressed.connect(_on_learn_talent)
	btn_buy.pressed.connect(_on_buy_pressed)
	btn_claim.pressed.connect(_on_claim_pressed)
	btn_join.pressed.connect(_on_join_pressed)
	btn_leave.pressed.connect(_on_leave_pressed)
	btn_donate.pressed.connect(_on_donate_pressed)
	wuxue_list.item_selected.connect(_on_wuxue_selected)
	talents_list.item_selected.connect(_on_talent_selected)
	shop_list.item_selected.connect(_on_shop_selected)

func set_sect(sect_id: String, character: CharacterData = null):
	current_sect = SectDatabase.get_sect(sect_id)
	current_character = character
	_refresh_all()

func _refresh_all():
	if not current_sect:
		return
	
	_refresh_basic_info()
	_refresh_wuxue()
	_refresh_talents()
	_refresh_shop()
	_refresh_rewards()
	_update_buttons()

func _refresh_basic_info():
	sect_name_label.text = current_sect.name
	sect_desc_label.text = current_sect.description
	sect_leader_label.text = "掌门: %s" % current_sect.leader
	sect_location_label.text = "位置: %s" % current_sect.location
	
	if current_character and current_character.current_sect == current_sect.id:
		sect_level_label.text = "门派等级: %d" % current_character.sect_level
		sect_exp_bar.max_value = current_sect.exp_per_level[current_character.sect_level + 1] if current_character.sect_level + 1 < current_sect.exp_per_level.size() else 1
		sect_exp_bar.value = current_character.sect_contribution
		sect_contribution_label.text = "门派贡献: %d" % current_character.sect_contribution
	else:
		sect_level_label.text = "未加入"
		sect_exp_bar.value = 0
		sect_contribution_label.text = "门派贡献: 0"

func _refresh_wuxue():
	wuxue_list.clear()
	for wuxue_id in current_sect.exclusive_wuxue:
		var wuxue = WuxueDatabase.get_wuxue(wuxue_id)
		if wuxue:
			var req = current_sect.wuxue_unlock_requirements.get(wuxue_id, {})
			var learned = current_character and wuxue_id in current_character.known_wuxue
			var can_learn = true
			
			if req.has("level") and current_character and current_character.sect_level < req["level"]:
				can_learn = false
			if req.has("contribution") and current_character and current_character.sect_contribution < req["contribution"]:
				can_learn = false
			if req.has("breakthrough") and current_character and current_character.potential_breakthrough < req["breakthrough"]:
				can_learn = false
			
			var item_text = "[%s] %s (Lv.%d)" % [wuxue.quality, wuxue.name, wuxue.current_level]
			if learned:
				item_text = "✓ " + item_text
			elif not can_learn:
				item_text = "✗ " + item_text
			
			var index = wuxue_list.add_item(item_text)
			wuxue_list.set_item_metadata(index, wuxue)
			
			var color = GameData.get_quality_color(wuxue.quality)
			wuxue_list.set_item_custom_fg_color(index, color)

func _on_wuxue_selected(index: int):
	var wuxue = wuxue_list.get_item_metadata(index)
	if wuxue:
		var detail = ""
		detail += "[color=#ffff00]%s[/color] [%s]\n" % [wuxue.name, wuxue.type]
		detail += "[color=#ffffff]品质:[/color] [color=%s]%s[/color]\n" % [GameData.get_quality_color(wuxue.quality).to_html(), wuxue.quality]
		detail += "[color=#ffffff]伤害类型:[/color] %s\n" % wuxue.damage_type
		detail += "[color=#ffffff]目标类型:[/color] %s\n" % wuxue.target_type
		detail += "[color=#ffffff]射程:[/color] %d-%d\n" % [wuxue.range_min, wuxue.range_max]
		detail += "[color=#ffffff]内力消耗:[/color] %d\n" % wuxue.mp_cost
		detail += "[color=#ffffff]怒气消耗:[/color] %d\n" % wuxue.rage_cost
		detail += "[color=#ffffff]冷却回合:[/color] %d\n" % wuxue.max_cooldown
		
		if wuxue.base_damage > 0:
			var dmg = wuxue.get_damage_at_level(wuxue.current_level, 100, 100, 100, 50)
			detail += "[color=#ffffff]基础伤害:[/color] %d (Lv.%d: ~%d)\n" % [wuxue.base_damage, wuxue.current_level, dmg]
		
		detail += "\n[color=#ffff00]效果:[/color]\n"
		for effect in wuxue.effects:
			detail += "  • %s\n" % effect.get_description()
		
		wuxue_detail.text = detail
		
		btn_learn_wuxue.disabled = current_character == null or wuxue_id in current_character.known_wuxue or not can_learn
		btn_learn_wuxue.tooltip_text = can_learn ? "" : "不满足学习条件"

func _refresh_talents():
	talents_list.clear()
	for talent in current_sect.disciple_talents:
		var index = talents_list.add_item("[Lv.%d] %s" % [talent.current_level, talent.name])
		talents_list.set_item_metadata(index, talent)
		if talent.current_level > 0:
			talents_list.set_item_custom_fg_color(index, Color(1, 1, 0))

func _on_talent_selected(index: int):
	var talent = talents_list.get_item_metadata(index)
	if talent:
		var detail = "[color=#ffff00]%s[/color]\n" % talent.name
		detail += "[color=#ffffff]等级:[/color] %d / %d\n" % [talent.current_level, talent.max_level]
		detail += "[color=#ffffff]解锁条件:[/color] 门派等级%d, 突破%d\n" % [talent.unlock_level, talent.unlock_breakthrough]
		detail += "\n[color=#ffff00]效果:[/color]\n"
		detail += "%s\n" % talent.get_description()
		talent_detail.text = detail
		
		btn_learn_talent.disabled = current_character == null or not talent.can_unlock(current_character)
		btn_learn_talent.tooltip_text = talent.can_unlock(current_character) ? "" : "不满足解锁条件"

func _refresh_shop():
	shop_list.clear()
	for item_data in current_sect.shop_items:
		var item_id = item_data.get("item_id", "")
		var price = item_data.get("price", 0)
		var currency = item_data.get("currency", "contribution")
		
		var display_name = item_id
		if item_id != "":
			# 尝试从各个数据库获取名称
			var eq = EquipmentDatabase.get_equipment(item_id)
			if eq:
				display_name = eq.name
			else:
				var wx = WuxueDatabase.get_wuxue(item_id)
				if wx:
					display_name = wx.name
				else:
					var xf = XinfaDatabase.get_xinfa(item_id)
					if xf:
						display_name = xf.name
		
		var item_text = "%s - %d %s" % [display_name, price, currency]
		var index = shop_list.add_item(item_text)
		shop_list.set_item_metadata(index, item_data)
		
		var can_afford = current_character and currency == "contribution" and current_character.sect_contribution >= price
		if not can_afford:
			shop_list.set_item_custom_fg_color(index, Color(0.7, 0.7, 0.7))

func _on_shop_selected(index: int):
	var item_data = shop_list.get_item_metadata(index)
	if item_data:
		var detail = "价格: %d %s\n" % [item_data.get("price", 0), item_data.get("currency", "contribution")]
		detail += "点击购买"
		shop_detail.text = detail
		
		var can_afford = current_character and item_data.get("currency", "contribution") == "contribution" and current_character.sect_contribution >= item_data.get("price", 0)
		btn_buy.disabled = not can_afford

func _refresh_rewards():
	rewards_list.clear()
	for req_amount in current_sect.contribution_rewards:
		var reward = current_sect.contribution_rewards[req_amount]
		var achieved = current_character and current_character.sect_contribution >= int(req_amount)
		
		var item_text = "%s贡献: %s %s" % [req_amount, reward.get("type", ""), reward.get("id", "")]
		if achieved:
			item_text = "✓ " + item_text
		else:
			item_text = "○ " + item_text
		
		var index = rewards_list.add_item(item_text)
		rewards_list.set_item_metadata(index, {"amount": req_amount, "reward": reward})
		
		if achieved:
			rewards_list.set_item_custom_fg_color(index, Color(0, 1, 0))
		else:
			rewards_list.set_item_custom_fg_color(index, Color(1, 1, 0))

func _on_claim_pressed():
	var index = rewards_list.get_selected_items()
	if index.size() == 0:
		return
	
	var data = rewards_list.get_item_metadata(index[0])
	var amount = int(data["amount"])
	var reward = data["reward"]
	
	if not current_character or current_character.sect_contribution < amount:
		return
	
	# 发放奖励
	match reward["type"]:
		"wuxue":
			var wuxue = WuxueDatabase.get_wuxue(reward["id"])
			if wuxue:
				current_character.known_wuxue.append(wuxue.id)
		"wuxue_zhenjie":
			var wuxue = WuxueDatabase.get_wuxue(reward["id"])
			if wuxue:
				wuxue.zhenjie_level = reward.get("level", 1)
		"talent_point":
			if current_character:
				current_character.talent_points += reward.get("value", 1)
		"title":
			# 称号系统
			pass
	
	UIManager.get_instance().show_notification("领取了奖励: %s" % reward.get("id", ""), "success")
	_refresh_rewards()

func _update_buttons():
	var is_member = current_character and current_character.current_sect == current_sect.id
	btn_join.disabled = is_member
	btn_leave.disabled = not is_member
	btn_donate.disabled = not is_member

func _on_learn_wuxue():
	var index = wuxue_list.get_selected_items()
	if index.size() == 0 or not current_character:
		return
	
	var wuxue = wuxue_list.get_item_metadata(index[0])
	if wuxue and wuxue not in current_character.known_wuxue:
		current_character.known_wuxue.append(wuxue.id)
		_refresh_wuxue()
		UIManager.get_instance().show_notification("学会了 %s" % wuxue.name, "success")

func _on_learn_talent():
	var index = talents_list.get_selected_items()
	if index.size() == 0 or not current_character:
		return
	
	var talent = talents_list.get_item_metadata(index[0])
	if talent and talent.can_unlock(current_character):
		talent.unlock(current_character)
		_refresh_talents()
		UIManager.get_instance().show_notification("学会了天赋: %s" % talent.name, "success")

func _on_buy_pressed():
	var index = shop_list.get_selected_items()
	if index.size() == 0 or not current_character:
		return
	
	var item_data = shop_list.get_item_metadata(index[0])
	var price = item_data.get("price", 0)
	var currency = item_data.get("currency", "contribution")
	var item_id = item_data.get("item_id", "")
	
	if currency == "contribution":
		if current_character.sect_contribution < price:
			return
		current_character.sect_contribution -= price
	
	if item_id != "":
		# 给予物品
		PlayerData.get_instance().add_item(item_id, 1)
	
	UIManager.get_instance().show_notification("购买成功", "success")
	_refresh_shop()

func _on_join_pressed():
	if not current_character or current_character.current_sect != "":
		return
	
	# 检查入门要求
	var req = current_sect.join_requirements
	if req.has("level") and current_character.potential_level < req["level"]:
		UIManager.get_instance().show_notification("等级不足，需要 %d 级" % req["level"], "warning")
		return
	
	current_character.current_sect = current_sect.id
	current_character.sect_level = 1
	current_character.sect_contribution = 0
	current_character.sect_wuxue = []
	
	UIManager.get_instance().show_notification("加入了 %s" % current_sect.name, "success")
	_refresh_all()

func _on_leave_pressed():
	if not current_character or current_character.current_sect != current_sect.id:
		return
	
	var penalty = current_sect.leave_penalty
	if not penalty.get("contribution_keep", true):
		current_character.sect_contribution = 0
	if not penalty.get("wuxue_keep", false):
		current_character.sect_wuxue.clear()
	
	current_character.current_sect = ""
	current_character.sect_level = 0
	
	UIManager.get_instance().show_notification("退出了 %s" % current_sect.name, "info")
	_refresh_all()

func _on_donate_pressed():
	# 打开捐赠界面
	UIManager.get_instance().show_notification("捐赠功能待实现", "info")