extends Control

func _input(event: InputEvent) -> void:
	if get_tree().root.has_node("/root/Main/MainMenu") and get_tree().root.get_node("/root/Main/MainMenu").visible:
		return
	
	if event.is_action_pressed("Toggle Inventory"):
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY)

func switch_focus_to_feed_button() -> void:
	%FeedButton.grab_focus()

func _ready() -> void:
	if not get_tree().root.has_node("/root/Main"):
		# Debugging set ups
		%InventoryCanvas.visible = true
	
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	%InventoryGridContainer.set_inventory(PlayerInventoryController.inventory)
	switch_focus_to_feed_button()
	PlayerInventoryController.item_dropped_inventory_full.connect(_on_item_dropped_inventory_full)

func _on_item_dropped_inventory_full(item: InventoryItem) -> void:
	print("InventoryUi - _on_item_dropped_inventory_full")
	Dialogic.start("inventory_full")

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	if newActive == UiEvents.UiScene.INVENTORY:
		%InventoryCanvas.visible = !%InventoryCanvas.visible
		#if %InventoryCanvas.visible:
			#%InventoryItemList.grab_focus()
	if newActive == UiEvents.UiScene.RECIPE_BOOK:
		%InventoryCanvas.visible = false

func _on_close_button_pressed() -> void:
	print("Inventory close button clicked, hiding inventory ui")
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY)

func _on_feed_button_pressed() -> void:
	var selected_index = %InventoryGridContainer.get_selected_item()
	if selected_index != Vector2(-1, -1):
		var item = PlayerInventoryController.take_item_index(selected_index)
		print("Feeding selected item to party: %s" % item.name)
		PartyController.feed_party_item(item)
	else:
		print("Skipping feeding since no selected item")

func _on_recipe_book_button_pressed() -> void:
	print("Recipe button, clicked, showing recipe book")
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.RECIPE_BOOK)
