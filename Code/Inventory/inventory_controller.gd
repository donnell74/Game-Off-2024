extends Control
class_name InventoryController

signal item_dropped_inventory_full(item: InventoryItem)

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource
@export var percentage_items_drop_on_death : float = 0.25

func _ready() -> void:
	PartyController.party_stat_depleted.connect(death_drop)
	fill_refs()

func fill_refs() -> void:
	for key in inventory.items:
		var item_slot = inventory.items[key] as InventoryItem
		if not item_slot:
			continue
		
		if item_slot.inventory_width == 1 and item_slot.inventory_height == 1:
			continue
		
		for pos_x in range(item_slot.inventory_width):
			for pos_y in range(item_slot.inventory_height):
				if pos_x == 0 and pos_y == 0:
					continue

				var ref_location = Vector2(pos_x, pos_y) + key
				var ref = InventoryItemSlotRef.new()
				ref.root_node = item_slot
				ref.root_node_index = key
				ref.root_node_type = item_slot.type
				if inventory.items.has(ref_location):
					print("fill_refs - Overwriting item at %s with other item" % ref_location)
					
				inventory.items[ref_location] = ref

func add_item(item: InventoryItem) -> void:
	var index = Vector2.ZERO
	for pos_y in inventory.height:
		if not inventory.items.has(index):
				break # so break below breaks both loops

		for pos_x in inventory.width:
			index = Vector2(pos_x, pos_y)
			if not inventory.items.has(index):
				break

	if index.is_equal_approx(Vector2(inventory.width - 1, inventory.height -1)):
		print("Unable to add item to inventory because it is full")
		item_dropped_inventory_full.emit(item)
		return

	add_item_at_index(item, index)


func add_item_at_index(item: InventoryItem, item_position: Vector2) -> void:
	print("Adding item to inventory: %s at index: %s" % [item.name, item_position])
	inventory.items[item_position] = item
	# add refs for spaces this item also takes up
	for pos_x in item.inventory_width:
		for pos_y in item.inventory_height:
			if pos_x == 0 and pos_y == 0:
				continue # don't overwrite the root node
			
			var item_ref = InventoryItemSlotRef.new()
			item_ref.root_node = item
			item_ref.root_node_index = item_position
			item_ref.root_node_type = item.type
			inventory.items[item_position + Vector2(pos_x, pos_y)] = item_ref

	inventory.inventory_updated.emit()

func can_place_item(index: Vector2, item: InventoryItem) -> bool:
	if not item:
		print("can_place_item with null item")
		return false

	for inv_x in item.inventory_width:
		for inv_y in item.inventory_height:
			var this_index = index + Vector2(inv_x, inv_y)
			if inventory.items.has(this_index):
				return false
			
			if this_index.x >= inventory.width:
				return false
			
			if this_index.y >= inventory.height:
				return false
	
	return true

func can_replace_item(index: Vector2, item: InventoryItem) -> bool:
	if not item:
		return false
	
	if item.inventory_height > 1 or item.inventory_width > 1:
		return false
	
	if not inventory.items.has(index):
		return false
	
	return true

func get_item(index: Vector2) -> Resource:
	if not inventory.items.has(index):
		return null

	return inventory.items[index]

func find_item(item_name: String) -> Vector2:
	for pos_x in inventory.width:
		for pos_y in inventory.height:
			var index = Vector2(pos_x, pos_y)
			var each_item = inventory.items.get(index, null)
			if each_item:
				if each_item is InventoryItemSlotRef:
					continue
				
				if item_name == each_item.name:
					return index
	
	return Vector2(-1, -1)

func take_item(search_name: String) -> Resource:
	for item_index in range(inventory.capacity):
		if inventory.items.has(item_index) and inventory.items[item_index].name == search_name:
			var item = inventory.items[item_index]
			inventory.items.erase(item_index)
			inventory.inventory_updated.emit()
			return item
	
	return null

# Almost the same code as get_surrounding_ingredients but returning the root node and deleting
# the refs
func take_entire_item(starting_index: Vector2) -> InventoryItem:
	var result : InventoryItem = null
	var neighbors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	var neighbors_already_visited : Array[Vector2] = []
	var nodes_left_to_vist : Array[Vector2] = []
	var current_item = get_item(starting_index)
	if current_item is InventoryItemSlotRef:
		starting_index = current_item.root_node_index

	current_item = take_item_index(starting_index)
	result = current_item
	var starting_name = current_item.name
	for neighbor in neighbors:
		nodes_left_to_vist.append(starting_index + neighbor)
	
	while nodes_left_to_vist.size() != 0:
		var current_index = nodes_left_to_vist.pop_front()
		if neighbors_already_visited.has(current_index):
			continue
		
		current_item = get_item(current_index)
		neighbors_already_visited.append(current_index)
		# Ignore empty slots and inventory items because we already know the root node
		if not current_item or current_item is InventoryItem:
			continue
		
		if starting_index == current_item.root_node_index:
			take_item_index(current_index)
			for neighbor in neighbors:
				nodes_left_to_vist.append(current_index + neighbor)
	
	print("take_entire_item for ", starting_index, " is: ", result, ".  Visited: ", neighbors_already_visited)
	return result


func take_item_index(item_index: Vector2) -> Resource:
	if not inventory.items.has(item_index):
		return null

	print(inventory.resource_name, " is called with take_item_index: ", item_index)
	var item = inventory.items[item_index]
	inventory.items.erase(item_index)
	inventory.inventory_updated.emit()
	return item

func count_items() -> int:
	var item_count = 0
	for index in inventory.items:
		var each_item = inventory.items[index]
		if each_item is InventoryItem:
			item_count += 1

	return item_count

func death_drop(_stat: PartyController.Stats) -> void:
	var item_count = count_items()
	var items_left_to_drop = floor(item_count * percentage_items_drop_on_death)
	var max_iterations = 100 # fall back in the case the inventory is only stations
	while items_left_to_drop > 0 and max_iterations > 0:
		var inventory_indexes = inventory.items.keys()
		var index_to_drop = Settings.random().randi_range(0, inventory_indexes.size() - 1)
		var item_to_drop = inventory.items[inventory_indexes[index_to_drop]]
		if item_to_drop is InventoryItem and item_to_drop.type == InventoryItem.ItemType.ITEM:
			take_entire_item(inventory_indexes[index_to_drop])
			items_left_to_drop -= 1
		
		max_iterations -= 1

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

func clear_inventory() -> void:
	inventory.items = {}
	inventory.inventory_updated.emit()

func _to_string() -> String:
	var inventory_string = "["
	for each_item in inventory.items:
		if inventory.items[each_item] is InventoryItemSlotRef:
			inventory_string += "%s, " % inventory.items[each_item].root_node.name
		else:
			inventory_string += "%s, " % inventory.items[each_item].name
	
	inventory_string = inventory_string.substr(0, inventory_string.length() - 2) + "]"
	return inventory_string

func save() -> Dictionary:
	var save_dict = {
		SaveLoad.PATH_FROM_ROOT_KEY: get_path(),
		"inventory": inventory.save()
	}
	
	return save_dict

func load(load_data: Dictionary) -> void:
	inventory.load(load_data)
	inventory.inventory_updated.emit()
