extends Node2D

const ITEM_STACK_FORMAT = "%s x%d"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Inventory"):
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY)
	if event.is_action_pressed("ui_accept") and %InventoryItemList.has_focus():
		call_deferred("switch_focus_to_feed_button")

func switch_focus_to_feed_button() -> void:
	%FeedButton.grab_focus()

func _ready() -> void:
	%InventoryItemList.set_inventory(PlayerInventoryController.inventory)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	switch_focus_to_feed_button()

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	if newActive == UiEvents.UiScene.INVENTORY:
		%InventoryCanvas.visible = !%InventoryCanvas.visible
		if %InventoryCanvas.visible:
			%InventoryItemList.grab_focus()
	if newActive == UiEvents.UiScene.RECIPE_BOOK:
		%InventoryCanvas.visible = false

func update_inventory_item_list() -> void:
	%ItemList.clear()
	var counts : Dictionary = {}
	for each_item in PlayerInventoryController.inventory.items:
		if each_item.name in counts:
			counts[each_item.name] += 1
		else:
			counts[each_item.name] = 1

	for item_name in counts:
		%ItemList.add_item(ITEM_STACK_FORMAT % [item_name, counts[item_name]])

func _on_close_button_pressed() -> void:
	print("Inventory close button clicked, hiding inventory ui")
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY)

func _on_feed_button_pressed() -> void:
	if %InventoryItemList.get_selected_items().size() > 0:
		var item = PlayerInventoryController.take_item(%InventoryItemList.get_selected_item_name())
		print("Feeding selected item to party: %s" % item.name)
		PartyController.feed_party_item(item)
	else:
		print("Skipping feeding since no selected item")


func _on_recipe_book_button_pressed() -> void:
	print("Recipe button, clicked, showing recipe book")
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.RECIPE_BOOK)
