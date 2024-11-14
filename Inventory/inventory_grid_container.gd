extends InventoryController

signal selected_indexes_updated

@export var slot_scene : Resource = preload("res://Inventory/inventory_item_slot.tscn")
@export var recipe_context_menu = preload("res://Inventory/recipe_context_menu.tscn")
@export var selected_slot : Vector2 = Vector2(-1, -1)

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

func _on_inventory_item_slot_clicked(index: Vector2) -> void:
	selected_slot = index
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

func _on_slot_right_clicked(index: Vector2, node_postiion: Vector2) -> void:
	var selected_station_item = get_item(index)
	var station_type = selected_station_item.type if selected_station_item is InventoryItem else selected_station_item.root_node.type
	if station_type != InventoryItem.ItemType.STATION:
		return
	
	var station_name = selected_station_item.name if selected_station_item is InventoryItem else selected_station_item.root_node.name
	var surrounding_ingredients = get_surrounding_ingredients(index)
	var surrounding_inv_items : Array[InventoryItem] = []
	for each_ingred_pos in surrounding_ingredients:
		surrounding_inv_items.append(inventory.items[each_ingred_pos])
	
	var matching_recipes = StationController.get_all_matching_recipes(station_name, surrounding_inv_items)
	build_context_menu(matching_recipes, surrounding_ingredients, StationController.get_station(station_name), node_postiion)

func build_context_menu(
	recipes: Array[Recipe], 
	ingredients: Array[Vector2], 
	station: Station, 
	new_position: Vector2
) -> void:
	if has_node("../RecipeContextMenu"):
		$"../RecipeContextMenu".queue_free()
	
	var context_menu = recipe_context_menu.instantiate()
	var context_menu_item_list = context_menu.get_node("RecipeList")
	context_menu.recipes = recipes
	context_menu.neighbors = ingredients
	context_menu.station = station
	context_menu.recipe_selected.connect(_on_recipe_selected)

	if recipes.size() == 0:
		context_menu_item_list.add_item("No recipes possible")

	for each_recipe in recipes:
		context_menu_item_list.add_item(each_recipe.output[0].name)

	context_menu.global_position = new_position
	context_menu.z_index = 2
	get_parent().add_child(context_menu)

func _on_recipe_selected(recipe: Recipe, neighbors: Array[Vector2], station: Station):
	print("_on_recipe_selected ", recipe.output[0].name, " ", neighbors, " ", Actions.Actions.keys()[station.action])
	var recipe_items_to_find = recipe.input.duplicate()
	var items_removed : Array[InventoryItem] = []
	for each_neighbor in neighbors:
		var each_item = get_item(each_neighbor)
		var found = -1
		for index in range(recipe_items_to_find.size()):
			if recipe_items_to_find[index].equals(each_item, true):
				found = index

		if found != -1:
			var found_item = recipe_items_to_find.pop_at(found)
			items_removed.append(found_item)
			take_item_index(each_neighbor)
	
	for each_output in recipe.output:
		var each_item = each_output.duplicate()
		var combined = StationController.combine_multipliers(items_removed)
		each_item.modifiers.multiply(combined).multiply(station.modifier)
		add_item(each_item)
	
	if has_node("../RecipeContextMenu"):
		$"../RecipeContextMenu".queue_free()

func clear_inventory_grid() -> void:
	for child in get_children():
		if child.inventory_item_slot_clicked.is_connected(_on_inventory_item_slot_clicked):
			child.inventory_item_slot_clicked.disconnect(_on_inventory_item_slot_clicked)
		
		child.queue_free()

func get_selected_item() -> Vector2:
	return selected_slot
