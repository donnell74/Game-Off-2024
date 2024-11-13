extends InventoryController

signal selected_indexes_updated

@export var slot_scene : Resource = preload("res://Inventory/inventory_item_slot.tscn")
@export var selected_slots : Array[int] = []

func _ready() -> void:
	generate_inventory_grid()

func set_inventory(newInventory: Inventory) -> void:
	if inventory and inventory.inventory_updated.is_connected(generate_inventory_grid):
		inventory.inventory_updated.disconnect(generate_inventory_grid)

	inventory = newInventory
	if newInventory:
		newInventory.inventory_updated.connect(generate_inventory_grid)
		generate_inventory_grid()

func generate_inventory_grid() -> void:
	print("generate_inventory_grid with inventory: ", inventory.items)
	clear_inventory_grid()
	if not inventory:
		return

	$".".columns = inventory.width
	for pos_y in range(inventory.height):
		for pos_x in range(inventory.width):
			var index = Vector2(pos_x, pos_y)
			var slot = slot_scene.instantiate()
			slot.name = "InventoryItemSlot - %s" % index
			slot.index = index
			var item_for_slot = get_item(index)
			if not item_for_slot is InventoryItemSlotRef:
				if item_for_slot and item_for_slot.texture:
					var icon = slot.get_node("Icon")
					icon.texture = item_for_slot.texture
					icon.scale = Vector2(item_for_slot.inventory_width, item_for_slot.inventory_height)
					icon.z_index = 1
			
			slot.inventory_item_slot_clicked.connect(_on_inventory_item_slot_clicked)
			slot.slot_right_clicked.connect(_on_slot_right_clicked)
			add_child(slot)

func _on_inventory_item_slot_clicked(index: int) -> void:
	var selected_position = selected_slots.find(index)
	if selected_position == -1:
		selected_slots.append(index)
	else:
		selected_slots.remove_at(selected_position)
	
	selected_indexes_updated.emit()

# This algorithm is sorta a reverse a-star search.
# Starting with node clicked, go to all neighbors
# if neighbor is a station, recursively call this function, appending all ingredients from the call
# if neighbor is an ingredient, add to result
func get_surrounding_ingredients(starting_index: Vector2, neighbors_already_visited: Array[Vector2] = []) -> Array[Vector2]:
	var result : Array[Vector2] = []
	var neighbors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	
	for each_neighbor in neighbors:
		var each_neighbor_pos = starting_index + each_neighbor
		if neighbors_already_visited.has(each_neighbor_pos):
			continue
		
		neighbors_already_visited.append(each_neighbor_pos)
		var inventory_slot = get_item(each_neighbor_pos)
		if not inventory_slot:
			continue
		
		if inventory_slot is InventoryItemSlotRef and inventory_slot.root_node_type == InventoryItem.ItemType.STATION:
			var starting_index_item = get_item(starting_index)
			if starting_index_item is InventoryItemSlotRef and starting_index_item.root_node.name != inventory_slot.root_node.name:
				continue
			
			if starting_index_item is InventoryItem and starting_index_item.name != inventory_slot.root_node.name:
				continue
			
			result.append_array(get_surrounding_ingredients(each_neighbor_pos, neighbors_already_visited))
		
		if inventory_slot is InventoryItem and inventory_slot.type == InventoryItem.ItemType.ITEM:
			result.append(starting_index + each_neighbor)
	
	print("get_surrounding_ingredients for ", starting_index, " is: ", result)
	return result

func _on_slot_right_clicked(index: Vector2) -> void:
	var selected_station_item = get_item(index)
	var selected_indexes = get_selected_items()
	var surrounding_ingredients = get_surrounding_ingredients(index)
	#for each_selected in selected_indexes:
		#var each_item = get_item(each_selected)
		#print("Selected items[%d]: %s" % [each_selected, each_item.name])
		#selected_items.append(each_item)
	#
	#var output = StationController.perform(selected_station_item.name, selected_items)
	#if output.size() != 0:
		#for each_selected in selected_indexes:
			#take_item_index(each_selected)
		#
		#for each_output in output:
			#add_item(each_output)

func clear_inventory_grid() -> void:
	for child in get_children():
		if child.inventory_item_slot_clicked.is_connected(_on_inventory_item_slot_clicked):
			child.inventory_item_slot_clicked.disconnect(_on_inventory_item_slot_clicked)
		
		child.queue_free()

func get_selected_items() -> Array[int]:
	var selected_index : Array[int] = []
	for index in range(inventory.width * inventory.height):
		var slot = get_child(index)
		if slot.selected:
			selected_index.append(index)
	
	print("get_selected_items: ", selected_index)
	return selected_index
