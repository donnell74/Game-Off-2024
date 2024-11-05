extends Control

@export var active_station_index = 0

func _ready() -> void:
	PlayerInventoryController.inventory_updated.connect(_on_player_inventory_updated)
	update_player_item_list()

	var active_station = %Stations.get_child(active_station_index)
	if active_station and active_station.has_signal("inventory_updated"):
		update_station_item_list()
		active_station.inventory_updated.connect(_on_station_inventory_updated)
	
	for card in %CardContainer.get_children():
		card.card_clicked.connect(_on_card_clicked)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept"):
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
		visible = !visible
		
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
