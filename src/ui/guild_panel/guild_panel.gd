extends Control
class_name GuildPanelUI

@onready var guild_info: VBoxContainer = %GuildInfo
@onready var guild_name_label: Label = %GuildNameLabel
@onready var guild_level_label: Label = %GuildLevelLabel
@onready var guild_exp_bar: ProgressBar = %GuildExpBar
@onready var guild_members_label: Label = %GuildMembersLabel
@onready var guild_funds_label: Label = %GuildFundsLabel
@onready var guild_notice: TextEdit = %GuildNotice
@onready var btn_edit_notice: Button = %BtnEditNotice

@onready var member_list: ItemList = %MemberList
@onready var btn_promote: Button = %BtnPromote
@onready var btn_demote: Button = %BtnDemote
@onready var btn_kick: Button = %BtnKick
@onready var btn_transfer: Button = %BtnTransfer

@onready var building_list: ItemList = %BuildingList
@onready var building_detail: RichTextLabel = %BuildingDetail
@onready var btn_upgrade_building: Button = %BtnUpgradeBuilding

@onready var tech_list: ItemList = %TechList
@onready var tech_detail: RichTextLabel = %TechDetail
@onready var btn_research: Button = %BtnResearch

@onready var secret_realm_btn: Button = %SecretRealmButton
@onready var secret_realm_progress: ProgressBar = %SecretRealmProgress
@onready var secret_realm_floor: Label = %SecretRealmFloor

@onready var shop_list: ItemList = %ShopList
@onready var shop_detail: RichTextLabel = %ShopDetail
@onready var btn_buy: Button = %BtnBuy

@onready var btn_donate: Button = %BtnDonate
@onready var btn_guild_war: Button = %BtnGuildWar
@onready var btn_leave: Button = %BtnLeave

var current_guild: Guild = null

func _ready():
	btn_edit_notice.pressed.connect(_on_edit_notice)
	btn_promote.pressed.connect(_on_promote)
	btn_demote.pressed.connect(_on_demote)
	btn_kick.pressed.connect(_on_kick)
	btn_transfer.pressed.connect(_on_transfer)
	btn_upgrade_building.pressed.connect(_on_upgrade_building)
	btn_research.pressed.connect(_on_research)
	secret_realm_btn.pressed.connect(_on_secret_realm)
	btn_buy.pressed.connect(_on_buy)
	btn_donate.pressed.connect(_on_donate)
	btn_guild_war.pressed.connect(_on_guild_war)
	btn_leave.pressed.connect(_on_leave)
	building_list.item_selected.connect(_on_building_selected)
	tech_list.item_selected.connect(_on_tech_selected)
	shop_list.item_selected.connect(_on_shop_selected)
	member_list.item_selected.connect(_on_member_selected)

func _refresh_all():
	if not current_guild:
		return
	
	_refresh_info()
	_refresh_members()
	_refresh_buildings()
	_refresh_techs()
	_refresh_secret_realm()
	_refresh_shop()

func set_guild(guild: Guild):
	current_guild = guild
	_refresh_all()

func _refresh_info():
	guild_name_label.text = "%s (Lv.%d)" % [current_guild.name, current_guild.level]
	guild_exp_bar.max_value = current_guild.level * 10000
	guild_exp_bar.value = current_guild.exp
	guild_members_label.text = "成员: %d / %d" % [current_guild.get_member_count(), current_guild.max_members]
	guild_funds_label.text = "资金: %d" % current_guild.funds
	guild_notice.text = current_guild.notice

func _refresh_members():
	member_list.clear()
	for member in current_guild.members:
		var online_text = member.is_online ? "[在线]" : "[离线 %s]" % TimeManager.get_instance().format_duration(member.get_offline_duration())
		var item_text = "%s %s Lv.%d 战力:%d 贡献:%d %s" % [member.position, member.player_name, member.level, member.power, member.contribution, online_text]
		var index = member_list.add_item(item_text)
		member_list.set_item_metadata(index, member)
		
		if member.player_id == PlayerData.get_instance().player_id:
			member_list.set_item_custom_bg_color(index, Color(0.2, 0.5, 0.8, 0.3))

func _on_member_selected(index: int):
	var member = member_list.get_item_metadata(index)
	if not member:
		return
	
	var player_id = PlayerData.get_instance().player_id
	var my_member = current_guild.get_member(player_id)
	var my_rank = _get_rank_value(my_member.position) if my_member else 0
	var target_rank = _get_rank_value(member.position)
	
	btn_promote.disabled = my_rank <= target_rank or my_rank < 4
	btn_demote.disabled = my_rank <= target_rank or my_rank < 4
	btn_kick.disabled = my_rank <= target_rank or my_rank < 4
	btn_transfer.disabled = my_rank < 5 or member.player_id == player_id

func _refresh_buildings():
	building_list.clear()
	for building in current_guild.buildings:
		var item_text = "%s Lv.%d" % [building, current_guild.buildings[building]]
		var index = building_list.add_item(item_text)
		building_list.set_item_metadata(index, building)

func _on_building_selected(index: int):
	var building = building_list.get_item_metadata(index)
	if not building:
		return
	
	var level = current_guild.buildings[building]
	var next_level = level + 1
	var cost = current_guild._get_building_upgrade_cost(building, next_level)
	
	var detail = "%s Lv.%d\n" % [building, level]
	detail += "升级消耗: %d 帮会资金\n" % cost
	detail += "当前资金: %d\n" % current_guild.funds
	detail += "最大人数: %d\n" % current_guild.max_members if building == "大厅" else ""
	
	building_detail.text = detail
	btn_upgrade_building.disabled = current_guild.funds < cost

func _refresh_techs():
	tech_list.clear()
	for tech in current_guild.technologies:
		var item_text = "%s Lv.%d" % [tech, current_guild.technologies[tech]]
		var index = tech_list.add_item(item_text)
		tech_list.set_item_metadata(index, tech)

func _on_tech_selected(index: int):
	var tech = tech_list.get_item_metadata(index)
	if not tech:
		return
	
	var level = current_guild.technologies[tech]
	var next_level = level + 1
	var cost = current_guild._get_tech_cost(tech, next_level)
	
	var detail = "%s Lv.%d\n" % [tech, level]
	detail += "升级消耗: %d 帮会资金\n" % cost
	detail += "当前资金: %d\n" % current_guild.funds
	
	tech_detail.text = detail
	btn_research.disabled = current_guild.funds < cost

func _refresh_secret_realm():
	var progress = current_guild.secret_realm_progress
	secret_realm_progress.max_value = 10
	secret_realm_progress.value = progress.current_floor
	secret_realm_floor.text = "当前层数: %d / 10 (最高: %d)" % [progress.current_floor, progress.best_floor]
	
	secret_realm_btn.disabled = GuildManager.get_instance().secret_realm_state != "未开启"

func _refresh_shop():
	shop_list.clear()
	var items = GuildManager.get_instance().get_guild_shop_items()
	for item in items:
		var item_id = item["item_id"]
		var price = item["price"]
		var currency = item["currency"]
		var stock = item["stock"]
		
		var display_name = item_id
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
		
		var stock_text = stock > 0 ? "库存: %d" % stock : "无限"
		var item_text = "%s - %d %s (%s)" % [display_name, price, currency, stock_text]
		var index = shop_list.add_item(item_text)
		shop_list.set_item_metadata(index, item)

func _on_shop_selected(index: int):
	var item = shop_list.get_item_metadata(index)
	if item:
		var detail = "价格: %d %s\n库存: %s" % [item["price"], item["currency"], item["stock"] > 0 ? str(item["stock"]) : "无限"]
		shop_detail.text = detail
		
		var member = current_guild.get_member(PlayerData.get_instance().player_id)
		btn_buy.disabled = not member or member.contribution < item["price"]

func _on_edit_notice():
	if current_guild.notice != guild_notice.text:
		current_guild.notice = guild_notice.text
		UIManager.get_instance().show_notification("公告已更新", "success")

func _on_promote():
	var index = member_list.get_selected_items()
	if index.size() == 0:
		return
	
	var member = member_list.get_item_metadata(index[0])
	var positions = ["成员", "精英", "长老", "副帮主"]
	var current_idx = positions.find(member.position)
	if current_idx < positions.size() - 1:
		var new_pos = positions[current_idx + 1]
		if GuildManager.get_instance().promote_member(PlayerData.get_instance().player_id, member.player_id, new_pos):
			_refresh_members()

func _on_demote():
	var index = member_list.get_selected_items()
	if index.size() == 0:
		return
	
	var member = member_list.get_item_metadata(index[0])
	var positions = ["成员", "精英", "长老", "副帮主"]
	var current_idx = positions.find(member.position)
	if current_idx > 0:
		var new_pos = positions[current_idx - 1]
		if GuildManager.get_instance().promote_member(PlayerData.get_instance().player_id, member.player_id, new_pos):
			_refresh_members()

func _on_kick():
	var index = member_list.get_selected_items()
	if index.size() == 0:
		return
	
	var member = member_list.get_item_metadata(index[0])
	if GuildManager.get_instance().kick_member(PlayerData.get_instance().player_id, member.player_id):
		_refresh_members()

func _on_transfer():
	var index = member_list.get_selected_items()
	if index.size() == 0:
		return
	
	var member = member_list.get_item_metadata(index[0])
	if GuildManager.get_instance().promote_member(PlayerData.get_instance().player_id, member.player_id, "帮主"):
		UIManager.get_instance().show_notification("已转让帮主", "success")
		_refresh_members()

func _on_upgrade_building():
	var index = building_list.get_selected_items()
	if index.size() == 0:
		return
	
	var building = building_list.get_item_metadata(index[0])
	if current_guild.upgrade_building(building):
		_refresh_buildings()

func _on_research():
	var index = tech_list.get_selected_items()
	if index.size() == 0:
		return
	
	var tech = tech_list.get_item_metadata(index[0])
	if current_guild.research_technology(tech):
		_refresh_techs()

func _on_secret_realm():
	if GuildManager.get_instance().start_secret_realm():
		_refresh_secret_realm()
		UIManager.get_instance().show_notification("帮会秘境已开启", "success")

func _on_buy():
	var index = shop_list.get_selected_items()
	if index.size() == 0:
		return
	
	var item = shop_list.get_item_metadata(index[0])
	if GuildManager.get_instance().buy_from_guild_shop(item["item_id"]):
		_refresh_shop()

func _on_donate():
	UIManager.get_instance().show_notification("捐赠界面待实现", "info")

func _on_guild_war():
	UIManager.get_instance().show_notification("帮战功能待实现", "info")

func _on_leave():
	if current_guild.leader_id == PlayerData.get_instance().player_id:
		UIManager.get_instance().show_notification("帮主需先转让职位", "warning")
		return
	
	if GuildManager.get_instance().leave_guild(PlayerData.get_instance().player_id):
		visible = false
		UIManager.get_instance().remove_from_stack(self)