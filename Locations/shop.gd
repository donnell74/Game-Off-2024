extends Control

signal location_simulation_done

@export var location : Location

var selected_item : InventoryItem

func _ready() -> void:
	# For run single scene support
	if not get_tree().root.has_node("Main"):
		location = preload("res://Locations/Town/town_no_station.tres")
		update_ui()

	if !location:
		print("No location data found, showing blank screen...")
		return
	
	print("Starting location: %s" % location.description )
	print("Party stats at beginning of day: %s" % location.description)
	print(PartyController)
	
	%PlayerInventoryItemList.set_inventory(PlayerInventoryController.inventory)
	PartyController.currency_changed.connect(_on_party_currency_changed)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

func _on_party_currency_changed() -> void:
	%CurrencyAmountLabel.text = "%d" % PartyController.get_party_currency()

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.SHOP:
			show_ui()
		_:
			hide_ui()

func hide_ui() -> void:
	visible = false
	%CanvasLayer.visible = false
	%ShopInventoryItemList.set_inventory(null)

func show_ui() -> void:
	visible = true
	%CanvasLayer.visible = true
	update_ui()

func update_ui() -> void:
	_on_party_currency_changed()
	var shopInventory = Inventory.new()
	# Shop expects items for sale to be in afternoon reward items
	for each_item in location.afternoonActivities[0].rewardItems:
		shopInventory.items.append(each_item)
	
	%ShopInventoryItemList.set_inventory(shopInventory)

func _on_advance_day() -> void:
	print("Shop - _on_advance_day")
	show_ui()

func _on_buy_sell_button_pressed() -> void:
	if %PlayerInventoryItemList.visible:
		var selected_item_name = %PlayerInventoryItemList.get_selected_item_name()
		for index in range(%Amount.text.to_int()):
			var item_to_sell = %PlayerInventoryItemList.take_item(selected_item_name)
			%ShopInventoryItemList.add_item(item_to_sell)
			PartyController.increment_currency(item_to_sell.value)
	else:
		var selected_item_name = %ShopInventoryItemList.get_selected_item_name()
		for index in range(%Amount.text.to_int()):
			var item_to_buy = %ShopInventoryItemList.take_item(selected_item_name)
			%PlayerInventoryItemList.add_item(item_to_buy)
			PartyController.decrement_currency(item_to_buy.value)

func calculate_new_amount(change: int) -> String:
	var new_amount = %Amount.text.to_int() + change
	var selected_item_quantity = 1
	if %PlayerInventoryItemList.visible:
		if %PlayerInventoryItemList.get_selected_items():
			var selected_text = %PlayerInventoryItemList.get_item_text(%PlayerInventoryItemList.get_selected_items()[0])
			selected_item_quantity = selected_text.substr(0, selected_text.find("x")).to_int()
	else:
		if %ShopInventoryItemList.get_selected_items():
			var selected_text = %ShopInventoryItemList.get_item_text(%ShopInventoryItemList.get_selected_items()[0])
			selected_item_quantity = selected_text.substr(0, selected_text.find("x")).to_int()
	
	if new_amount == 0:
		new_amount = selected_item_quantity
	
	if new_amount == selected_item_quantity + 1:
		new_amount = 1
	
	return "%d" % new_amount

func _on_plus_button_pressed() -> void:
	%Amount.text = calculate_new_amount(1)

func _on_minus_button_pressed() -> void:
	%Amount.text = calculate_new_amount(-1)

func _on_buy_menu_button_pressed() -> void:
	%BuyMenuButton.disabled = true
	%SaleMenuButton.disabled = false
	%PlayerInventoryItemList.visible = false
	%ShopInventoryItemList.visible = true

func _on_sale_menu_button_pressed() -> void:
	%BuyMenuButton.disabled = false
	%SaleMenuButton.disabled = true
	%PlayerInventoryItemList.visible = true
	%ShopInventoryItemList.visible = false

func _on_player_inventory_item_list_item_selected(index: int) -> void:
	print("_on_player_inventory_item_list_item_selected: ", index)
	selected_item = %PlayerInventoryItemList.get_item(index)
	%CostValueLabel.text = "%d" % selected_item.value
	%ItemNameValueLabel.text = selected_item.name
	%Amount.text = "1"

func _on_shop_inventory_item_list_item_selected(index: int) -> void:
	print("_on_shop_inventory_item_list_item_selected: ", index)
	selected_item = %ShopInventoryItemList.get_item(index)
	%CostValueLabel.text = "%d" % selected_item.value
	%ItemNameValueLabel.text = selected_item.name
	%Amount.text = "1"

func _on_continue_button_pressed() -> void:
	location.currentTimeOfDay = Location.TimeOfDay.END_OF_DAY
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
	location_simulation_done.emit()
	LocationEvents.end_of_day.emit()
