extends Control

@export var active_station_index = 0
@export var actions_starting_index = Actions.Actions.keys().size() / 2
@export var cards_to_show = 4

func _ready() -> void:
	PlayerInventoryController.inventory_updated.connect(_on_player_inventory_updated)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

	update_player_item_list()

	var active_station = %Stations.get_child(active_station_index)
	if active_station and active_station.has_signal("inventory_updated"):
		update_station_item_list()
		active_station.inventory_updated.connect(_on_station_inventory_updated)
	
	for card in %CardContainer.get_children():
		card.card_clicked.connect(_on_card_clicked)
	
	update_cards()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if %PlayerInventoryList.get_selected_items().size() == 1:
			var inventory_item = PlayerInventoryController.take_item(%PlayerInventoryList.get_selected_items()[0])
			%Stations.get_child(active_station_index).add_item(inventory_item)
		elif %StationInventoryList.get_selected_items().size() == 1:
			var station_item = %Stations.get_child(active_station_index)\
					.take_item(%StationInventoryList.get_selected_items()[0])
			PlayerInventoryController.add_item(station_item)
	elif event.is_action_pressed("Navigate To Next Page"):
		switch_active_station(1)
	elif event.is_action_pressed("Navigate to Last Page"):
		switch_active_station(-1)
	elif event.is_action_pressed("Toggle Cooking"):
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.COOKING)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	if newActive == UiEvents.UiScene.COOKING:
		visible = true
		%PlayerInventoryList.grab_focus()
	else:
		visible = false

func switch_active_station(increment: int) -> void:
	var new_active_index = (active_station_index + increment) % %Stations.get_child_count()
	print("Switching active station from %d to %d" % [active_station_index, new_active_index])
	
	var active_station = %Stations.get_child(active_station_index)
	if active_station and active_station.has_signal("inventory_updated") \
			and active_station.inventory_updated.is_connected(_on_station_inventory_updated):
		active_station.inventory_updated.disconnect(_on_station_inventory_updated)
		active_station.visible = false

	active_station_index = new_active_index
	var new_active_station = %Stations.get_child(active_station_index)
	new_active_station.visible = true
	if new_active_station and new_active_station.has_signal("inventory_updated"):
		new_active_station.inventory_updated.connect(_on_station_inventory_updated)

	update_station_item_list()

func update_station_item_list() -> void:
	%StationInventoryList.clear()
	for each_item in %Stations.get_child(active_station_index).inventory.items:
		%StationInventoryList.add_item(each_item.name)

func update_player_item_list() -> void:
	%PlayerInventoryList.clear()
	for each_item in PlayerInventoryController.inventory.items:
		%PlayerInventoryList.add_item(each_item.name)

func _on_player_inventory_updated() -> void:
	print("_on_player_inventory_updated")
	update_player_item_list()

func _on_station_inventory_updated() -> void:
	print("_on_station_inventory_updated")
	update_station_item_list()

func _on_card_clicked(action: Actions.Actions) -> void:
	print("_on_card_clicked with action: %s" % Actions.Actions.keys()[action])
	var active_station = %Stations.get_child(active_station_index)
	active_station.get_perform_method(action).call()

func update_cards() -> void:
	for card_index in range(actions_starting_index, actions_starting_index + cards_to_show):
		var card = %CardContainer.get_child(card_index - actions_starting_index)
		card.update_ui(card_index as Actions.Actions, Actions.Actions.keys()[card_index])

func _on_left_card_nav_button_pressed() -> void:
	actions_starting_index -= 1
	update_cards()
	if actions_starting_index == 0:
		print("Hit far left of action cards, disabling left card nav button")
		%LeftCardNavButton.disabled = true
	
	%RightCardNavButton.disabled = false

func _on_right_card_nav_button_pressed() -> void:
	actions_starting_index += 1
	update_cards()
	if actions_starting_index + cards_to_show == Actions.Actions.size():
		print("Hit far right of action cards, disabling right card nav button")
		%RightCardNavButton.disabled = true
	
	%LeftCardNavButton.disabled = false

func _on_player_inventory_list_focus_exited() -> void:
	%PlayerInventoryList.deselect_all()

func _on_station_inventory_list_focus_exited() -> void:
	%StationInventoryList.deselect_all()
