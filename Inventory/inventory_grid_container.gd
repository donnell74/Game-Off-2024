extends InventoryController

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
	if %InventoryItemDraggable.visible:
		var drag_item = get_item(%InventoryItemDraggable.original_index)
		if drag_item is InventoryItemSlotRef:
			drag_item = drag_item.root_node
		
		if can_place_item(index, drag_item):
			take_entire_item(%InventoryItemDraggable.original_index)
			add_item_at_index(drag_item, index)
			%InventoryItemDraggable.visible = false
			selected_slot = Vector2(-1, -1)
		else:
			# TODO: Add animation to indicate failure
			print("Unable to place at index: ", index, " Item: ", drag_item)
		return
		
	selected_slot = index
	var item_at_index = get_item(index)
	if item_at_index is InventoryItemSlotRef:
		item_at_index = item_at_index.root_node
	
	%InventoryItemDraggable.visible = true
	%InventoryItemDraggable.original_index = index
	%InventoryItemDraggable.item = item_at_index
	
	%InventoryItemDraggable.update()

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
