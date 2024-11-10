extends Control

@export var active_station_index = 0
@export var actions_starting_index = 0
@export var cards_to_show = 4

var active_station: Station
var actions


func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

	active_station = %Stations.get_child(active_station_index)
	actions = get_actions_for_station(active_station)

	%PlayerInventoryList.set_inventory(PlayerInventoryController.inventory)
	if active_station:
		%StationInventoryList.set_inventory(active_station.inventory)
	
	for card in %CardContainer.get_children():
		card.card_clicked.connect(_on_card_clicked)
	
	update_cards()

func _input(event: InputEvent) -> void:
	var main_menu = $"/root/Main/MainMenu"
	if main_menu and main_menu.visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		if %PlayerInventoryList.get_selected_items().size() == 1:
			var selected_item_name = %PlayerInventoryList.get_selected_item_name()
			var inventory_item = PlayerInventoryController.take_item(selected_item_name)
			%Stations.get_child(active_station_index).add_item(inventory_item)
			%Stations.get_child(active_station_index).sort_by_name()
		elif %StationInventoryList.get_selected_items().size() == 1:
			var station_item = %Stations.get_child(active_station_index)\
					.take_item(%StationInventoryList.get_selected_item_name())
			PlayerInventoryController.add_item(station_item)
			PlayerInventoryController.sort_by_name()
		if %StationInventoryList.size() == 0:
			$MoveAllItemsBackButton.visible = false
		else:
			$MoveAllItemsBackButton.visible = true
	elif event.is_action_pressed("Navigate To Next Page"):
		switch_active_station(1)
	elif event.is_action_pressed("Navigate to Last Page"):
		switch_active_station(-1)
	elif event.is_action_pressed("Toggle Cooking"):
		if visible:
			move_items_from_station_to_player(active_station)
			UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
		else:
			UiEvents.active_ui_changed.emit(UiEvents.UiScene.COOKING)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.COOKING:
			visible = true
			%PlayerInventoryList.grab_focus()
		UiEvents.UiScene.SETTINGS, UiEvents.UiScene.RECIPE_BOOK:
			pass # overlay, don't hide
		_:
			visible = false

func switch_active_station(increment: int) -> void:
	var new_active_index = (active_station_index + increment) % %Stations.get_child_count()
	var new_active_station = %Stations.get_child(new_active_index)
	print("Switching active station from %d to %d" % [active_station_index, new_active_index])
	
	active_station = %Stations.get_child(active_station_index)
	if active_station:
		move_items_from_station_to_station(active_station, new_active_station)
		active_station.visible = false

	active_station_index = new_active_index
	active_station = new_active_station
	actions = get_actions_for_station(active_station)
	actions_starting_index = 0
	
	active_station.visible = true
	if active_station:
		%StationInventoryList.set_inventory(active_station.inventory)

	update_cards()
	
func move_items_from_station_to_station(from_station: Station, to_station: Station):
	if %StationInventoryList.get_item_count() > 0:
		while %StationInventoryList.get_item_count() > 0:
			var station_item = from_station.take_item_index(0)
			to_station.add_item(station_item)
		to_station.sort_by_name()
		
func move_items_from_station_to_player(from_station: Station):
	if %StationInventoryList.get_item_count() > 0:
		while %StationInventoryList.get_item_count() > 0:
			var station_item = from_station.take_item_index(0)
			PlayerInventoryController.add_item(station_item)
		PlayerInventoryController.sort_by_name()
	$MoveAllItemsBackButton.visible = false

func _on_card_clicked(action: Actions.Actions) -> void:
	print("_on_card_clicked with action: %s" % Actions.Actions.keys()[action])
	active_station = %Stations.get_child(active_station_index)
	active_station.get_perform_method(action).call()
	
func get_actions_for_station(station: Station):
	return station.perform_method_map.keys()

func update_cards() -> void:
	if actions_starting_index == 0:
		print("Hit far left of action cards, disabling left card nav button")
		%LeftCardNavButton.disabled = true
	
	print("actions for station", actions)
	for card_index in range(actions_starting_index,actions_starting_index + cards_to_show):
		var card = %CardContainer.get_child(card_index - actions_starting_index)
		if card_index > actions.size() - 1:
			card.visible = false
			continue
		else:
			card.visible = true
		
		var action = actions[card_index]
		card.update_ui(actions[card_index], Actions.Actions.keys()[actions[card_index]])
	
	if actions.size() <= cards_to_show:
		%LeftCardNavButton.disabled = true
		%RightCardNavButton.disabled = true
	elif actions_starting_index == 0:
		print("Hit far left of action cards, disabling left card nav button")
		%LeftCardNavButton.disabled = true
		if actions.size() > cards_to_show:
			%RightCardNavButton.disabled = false
	elif actions_starting_index + cards_to_show == actions.size():
		print("Hit far right of action cards, disabling right card nav button")
		%RightCardNavButton.disabled = true
		if actions.size() > cards_to_show:
			%LeftCardNavButton.disabled = false
		

func _on_left_card_nav_button_pressed() -> void:
	actions_starting_index -= 1
	update_cards()

func _on_right_card_nav_button_pressed() -> void:
	actions_starting_index += 1
	update_cards()

func _on_player_inventory_list_focus_exited() -> void:
	%PlayerInventoryList.deselect_all()

func _on_station_inventory_list_focus_exited() -> void:
	%StationInventoryList.deselect_all()

func _on_move_items_button_pressed() -> void:
	move_items_from_station_to_player(active_station)
