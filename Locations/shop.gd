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
	
	%PlayerInventoryGridContainer.set_inventory(PlayerInventoryController.inventory)
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
	%ShopInventoryGridContainer.set_inventory(null)

func show_ui() -> void:
	visible = true
	%CanvasLayer.visible = true
	update_ui()

func update_ui() -> void:
	_on_party_currency_changed()
	var shopInventory = Inventory.new()
	# Shop expects items for sale to be in afternoon reward items
	var index = 0
	for each_item in location.afternoonActivities[0].rewardItems:
		shopInventory.items[index] = each_item
	
	%ShopInventoryGridContainer.set_inventory(shopInventory)

func _on_advance_day() -> void:
	print("Shop - _on_advance_day")
	show_ui()

func _on_buy_sell_button_pressed() -> void:
	if %PlayerInventoryGridContainer.visible:
		var selected_items = %PlayerInventoryGridContainer.get_selected_items()
		for selected_item_index in selected_items:
			var item_to_sell = %PlayerInventoryGridContainer.take_item_index(selected_item_index)
			%ShopInventoryGridContainer.add_item(item_to_sell)
			PartyController.increment_currency(item_to_sell.value)
	else:
		var selected_items = %ShopInventoryGridContainer.get_selected_items()
		for selected_item_index in selected_items:
			var item_to_buy = %ShopInventoryGridContainer.take_item_index(selected_item_index)
			%PlayerInventoryGridContainer.add_item(item_to_buy)
			PartyController.decrement_currency(item_to_buy.value)
	
	%CostValueLabel.text = "0"


func _on_buy_menu_button_pressed() -> void:
	%BuyMenuButton.disabled = true
	%SaleMenuButton.disabled = false
	%PlayerInventoryGridContainer.visible = false
	%ShopInventoryGridContainer.visible = true

func _on_sale_menu_button_pressed() -> void:
	%BuyMenuButton.disabled = false
	%SaleMenuButton.disabled = true
	%PlayerInventoryGridContainer.visible = true
	%ShopInventoryGridContainer.visible = false

func _on_shop_inventory_item_list_item_selected(index: int) -> void:
	print("_on_shop_inventory_item_list_item_selected: ", index)
	selected_item = %ShopInventoryGridContainer.get_item(index)
	%CostValueLabel.text = "%d" % selected_item.value
	%ItemNameValueLabel.text = selected_item.name

func _on_continue_button_pressed() -> void:
	location.currentTimeOfDay = Location.TimeOfDay.END_OF_DAY
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
	location_simulation_done.emit()
	LocationEvents.end_of_day.emit()

func _on_player_inventory_grid_container_selected_indexes_updated() -> void:
	print("_on_player_inventory_grid_container_selected_indexes_updated: ", %PlayerInventoryGridContainer.selected_slots)
	var total_value = 0
	for each_selected in %PlayerInventoryGridContainer.selected_slots:
		total_value += %PlayerInventoryGridContainer.get_item(each_selected).value
	
	%CostValueLabel.text = "%d" % total_value

func _on_shop_inventory_grid_container_selected_indexes_updated() -> void:
	print("_on_shop_inventory_grid_container_selected_indexes_updated: ", %ShopInventoryGridContainer.selected_slots)
	var total_value = 0
	for each_selected in %ShopInventoryGridContainer.selected_slots:
		total_value += %ShopInventoryGridContainer.get_item(each_selected).value
	
	%CostValueLabel.text = "%d" % total_value
