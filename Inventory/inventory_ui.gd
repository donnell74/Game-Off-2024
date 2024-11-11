extends Control

func _input(event: InputEvent) -> void:
	if get_tree().root.has_node("/root/Main/MainMenu") and get_tree().root.get_node("/root/Main/MainMenu").visible:
		return
	
	if event.is_action_pressed("Toggle Inventory"):
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY)

func switch_focus_to_feed_button() -> void:
	%FeedButton.grab_focus()

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	%InventoryGridContainer.set_inventory(PlayerInventoryController.inventory)
	switch_focus_to_feed_button()

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
	var selected_indexes = %InventoryGridContainer.get_selected_items()
	if selected_indexes.size() > 0:
		for each_selected in selected_indexes:
			var item = PlayerInventoryController.take_item_index(each_selected)
			print("Feeding selected item to party: %s" % item.name)
			PartyController.feed_party_item(item)
	else:
		print("Skipping feeding since no selected item")

func _on_recipe_book_button_pressed() -> void:
	print("Recipe button, clicked, showing recipe book")
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.RECIPE_BOOK)
