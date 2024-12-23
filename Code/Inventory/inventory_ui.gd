extends Control

@export var enabled : bool = true
@export var first_scene_visit : bool = true

func _input(event: InputEvent) -> void:
	if get_tree().root.has_node("/root/Main/MainMenu") and get_tree().root.get_node("/root/Main/MainMenu").visible:
		return
	
	if event.is_action_pressed("Toggle Inventory"):
		_toggle_inventory()
	
func _toggle_inventory() -> void:
	%InventoryCanvas.visible = !%InventoryCanvas.visible
	if %InventoryCanvas.visible:
		%InventoryOpenSound.play()
		%CloseButton.grab_focus()
		%InventoryGridContainer.enabled = true
		if first_scene_visit and not Settings.skip_tutorial:
			enabled = false
			%InventoryGridContainer.enabled = false
			first_scene_visit = false
			%CloseButton.release_focus()
			Dialogic.start("inventory_tutorial")
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY_OPEN)
	else:
		%InventoryGridContainer.enabled = false
		%InventoryClosedSound.play()
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.INVENTORY_CLOSED)
	

func _ready() -> void:
	if not get_tree().root.has_node("/root/Main"):
		# Debugging set ups
		pass
		#%InventoryCanvas.visible = true
	
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	%InventoryGridContainer.set_inventory(PlayerInventoryController.inventory)
	%CloseButton.grab_focus()
	PlayerInventoryController.item_dropped_inventory_full.connect(_on_item_dropped_inventory_full)
	Dialogic.signal_event.connect(_on_dialogic_signal_event)

func _on_dialogic_signal_event(event: String) -> void:
	match event:
		"inventory_tutorial_focus_fish":
			pass # handled in inventory_grid#_on_dialogic_signal_event

func _on_item_dropped_inventory_full(_item: InventoryItem) -> void:
	print("InventoryUi - _on_item_dropped_inventory_full")
	Dialogic.start("inventory_full")

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.INVENTORY_OPEN, UiEvents.UiScene.INVENTORY_CLOSED:
			%CloseButton.grab_focus()
		_:
			%InventoryCanvas.visible = false

func _on_close_button_pressed() -> void:
	print("Inventory close button clicked, hiding inventory ui")
	%CloseButton.release_focus()
	_toggle_inventory()

func _on_recipe_book_button_pressed() -> void:
	print("Recipe button, clicked, showing recipe book")
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.RECIPE_BOOK_OPEN)

func _on_recipe_created_animation_animation_finished(anim_name: StringName) -> void:
	%InventoryGridContainer.enabled = true
	if %InventoryGridContainer.awaiting_feed_cliced and not Settings.skip_tutorial:
		Dialogic.start("inventory_tutorial_feed")
