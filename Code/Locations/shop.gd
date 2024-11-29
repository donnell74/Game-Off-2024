extends Control

signal location_simulation_done

@export var location : Location

var selected_item : InventoryItem
var selected_item_index : Vector2 = Vector2(-1, -1)

func _ready() -> void:
	# For run single scene support
	if not get_tree().root.has_node("Main"):
		location = preload("res://Locations/Town/town_no_station.tres")
		show_ui()

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
	%ContinueButton.grab_focus()
	update_ui()
	%ItemDetailsOverlay.set_inventory(%ShopInventoryGridContainer.inventory)
	%ShopInventoryGridContainer.enabled = true

func update_ui() -> void:
	_on_party_currency_changed()
	var shopInventory = Inventory.new()
	# Shop expects items for sale to be in afternoon reward items
	var index = 0
	for each_item in location.afternoonActivities[0].rewardItems:
		shopInventory.items[Vector2(0, index)] = each_item # TODO: Handle more than 10 items
	
	%ShopInventoryGridContainer.set_inventory(shopInventory)

func _on_advance_day() -> void:
	print("Shop - _on_advance_day")
	show_ui()

func _on_buy_menu_button_pressed() -> void:
	%BuyMenuButton.disabled = true
	%SaleMenuButton.disabled = false
	%PlayerInventoryGridContainer.visible = false
	%ShopInventoryGridContainer.visible = true
	%PlayerInventoryGridContainer.enabled = false
	%ShopInventoryGridContainer.enabled = true
	%ContinueButton.focus_neighbor_top = %ShopInventoryGridContainer.get_path()
	%ItemDetailsOverlay.set_inventory(%ShopInventoryGridContainer.inventory)

func _on_sale_menu_button_pressed() -> void:
	%BuyMenuButton.disabled = false
	%SaleMenuButton.disabled = true
	%PlayerInventoryGridContainer.visible = true
	%ShopInventoryGridContainer.visible = false
	%PlayerInventoryGridContainer.enabled = true
	%ShopInventoryGridContainer.enabled = false
	%ContinueButton.focus_neighbor_top = %PlayerInventoryGridContainer.get_path()
	%ItemDetailsOverlay.set_inventory(%PlayerInventoryGridContainer.inventory)

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

func _on_player_inventory_grid_container_shop_mode_item_clicked(index: Vector2) -> void:
	selected_item_index = index
	selected_item = %PlayerInventoryGridContainer.get_item(index)
	if selected_item:
		%PlayerInventoryGridContainer.enabled = false
		%ItemDetailsOverlay.visible = false
		%BuySaleContextMenu.visible = true
		%BuySaleContextMenu.find_child("YesButton").grab_focus()
		%BuySaleContextMenu.get_node("Label").text = "Do you want to sell %s for %d gold?" % [selected_item.name, selected_item.value]

func _on_shop_inventory_grid_container_shop_mode_item_clicked(index: Vector2) -> void:
	selected_item_index = index
	selected_item = %ShopInventoryGridContainer.get_item(index)
	if selected_item:
		%ShopInventoryGridContainer.enabled = false
		%ItemDetailsOverlay.visible = false
		%BuySaleContextMenu.visible = true
		%BuySaleContextMenu.find_child("YesButton").grab_focus()
		%BuySaleContextMenu.get_node("Label").text = "Do you want to buy %s for %d gold?" % [selected_item.name, selected_item.value]

func _on_no_button_pressed() -> void:
	%BuySaleContextMenu.visible = false
	%ItemDetailsOverlay.visible = true
	if %PlayerInventoryGridContainer.visible:
		%PlayerInventoryGridContainer.grab_focus()
	else:
		%ShopInventoryGridContainer.grab_focus()

func _on_yes_button_pressed() -> void:
	%BuySaleContextMenu.visible = false
	%ItemDetailsOverlay.visible = true
	if %PlayerInventoryGridContainer.visible:
		var item_to_sell = %PlayerInventoryGridContainer.take_entire_item(selected_item_index)
		%PlayerInventoryGridContainer.enabled = true
		%ShopInventoryGridContainer.add_item(item_to_sell)
		%PlayerInventoryGridContainer.grab_focus()
		PartyController.increment_currency(item_to_sell.value)
	else:
		var item_to_buy = %ShopInventoryGridContainer.take_entire_item(selected_item_index)
		%ShopInventoryGridContainer.enabled = true
		%PlayerInventoryGridContainer.add_item(item_to_buy)
		%ShopInventoryGridContainer.grab_focus()
		PartyController.decrement_currency(item_to_buy.value)
