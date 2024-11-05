extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Inventory"):
		%InventoryCanvas.visible = !%InventoryCanvas.visible

func _ready() -> void:
	PlayerInventoryController.inventory_updated.connect(update_inventory_item_list)
	update_inventory_item_list()

func update_inventory_item_list() -> void:
	%ItemList.clear()
	for each_item in PlayerInventoryController.inventory.items:
		%ItemList.add_item(each_item.name)

func _on_close_button_pressed() -> void:
	print("Inventory close button clicked, hiding inventory ui")
	%InventoryCanvas.visible = false

func _on_feed_button_pressed() -> void:
	if %ItemList.get_selected_items().size() > 0:
		var item = PlayerInventoryController.take_item(%ItemList.get_selected_items()[0])
		print("Feeding selected item to party: %s" % item.name)
		PartyController.feed_party_item(item)
	else:
		print("Skipping feeding since no selected item")
