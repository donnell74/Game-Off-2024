extends InventoryController

signal shop_mode_item_clicked(index: Vector2)
signal inventory_slot_selected(index: Vector2)

@export var slot_scene : Resource = preload("res://Inventory/inventory_item_slot.tscn")
@export var recipe_context_menu = preload("res://Inventory/recipe_context_menu.tscn")
@export var item_context_menu = preload("res://Inventory/item_context_menu.tscn")
@export var selected_slot : Vector2 = Vector2(-1, -1)
@export var selected_slot_position : Vector2
@export var shop_mode : bool = false
@export var last_right_clicked_slot : Control
@export var last_feed_time_of_of_day : Location.TimeOfDay = Location.TimeOfDay.BREAKFAST
@export var current_time_of_day : Location.TimeOfDay = -1

const SLOT_PATH = "InventoryCanvas/InventoryGridContainer/"
var generate_semaphor : bool = false
var inventory_dictionary : Dictionary = {}

func _ready() -> void:
	LocationEvents.advance_day.connect(_on_advance_day)
	LocationEvents.end_of_day.connect(_on_end_of_day)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	_do_generate_inventory_grid()

func _on_focus_changed(control: Control) -> void:
	print("InventoryGridContainer - Focus changed to: ", control.name)
	if control == self:
		print("InventoryGridContainer - Focus changed to me! ")
		find_child(_get_slot_name(0, 0), true, false).grab_focus()
	else:
		if control.has_method("updated_selected"):
			selected_slot = control.index
			selected_slot_position = control.global_position
		else:
			# make sure we unselect when leaving the inventory grid
			selected_slot = Vector2(-1, -1)
			selected_slot_position = Vector2(0, 0)
		
		inventory_slot_selected.emit(selected_slot)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not selected_slot.is_equal_approx(Vector2(-1, -1)):
			selected_slot = Vector2(-1, -1)
			%InventoryItemDraggable.visible = false
			generate_inventory_grid()
	
	if event.is_action_pressed("ui_accept"):
		_on_inventory_item_slot_clicked(selected_slot)
	
	if event.is_action_pressed("Action Selected"):
		if not selected_slot.is_equal_approx(Vector2(-1, -1)):
			_on_slot_right_clicked(selected_slot, selected_slot_position)


func set_inventory(newInventory: Inventory) -> void:
	if inventory and inventory.inventory_updated.is_connected(generate_inventory_grid):
		inventory.inventory_updated.disconnect(generate_inventory_grid)

	inventory = newInventory
	if newInventory:
		newInventory.inventory_updated.connect(generate_inventory_grid)
		generate_inventory_grid()

func generate_inventory_grid() -> void:
	print("generate_inventory_grid with inventory: ", inventory.items)
	clear_inventory_slots()
	update_inventory_slots()

func update_inventory_slots() -> void:
	for pos_y in range(inventory.height):
		for pos_x in range(inventory.width):
			var index = Vector2(pos_x, pos_y)
			var item_for_slot = get_item(index)
			var slot = inventory_dictionary[index]
			if not item_for_slot is InventoryItemSlotRef:
				if item_for_slot and item_for_slot.texture:
					var icon = slot.get_node("Icon")
					icon.texture = item_for_slot.texture
					icon.scale = Vector2(item_for_slot.inventory_width, item_for_slot.inventory_height)
					icon.z_index = 1

func _do_generate_inventory_grid() -> void:
	if not inventory:
		return

	generate_semaphor = false
	$".".columns = inventory.width
	for pos_y in range(inventory.height):
		for pos_x in range(inventory.width):
			var index = Vector2(pos_x, pos_y)
			var slot = slot_scene.instantiate()
			slot.shop_mode = shop_mode
			slot.name = _get_slot_name(pos_x, pos_y)
			slot.index = index
			slot.set_focus_mode(FocusMode.FOCUS_ALL)
			slot.set_inventory_slot_clicked_signal(self.inventory_slot_selected)
			slot.inventory_item_slot_clicked.connect(_on_inventory_item_slot_clicked)
			slot.slot_right_clicked.connect(_on_slot_right_clicked)
			add_child(slot)
			inventory_dictionary[index] = slot
			
	set_focus_neighbors()

func _get_slot_name(pos_x: int, pos_y: int) -> String:
	return "InventorySlot%dx%d" % [pos_x, pos_y]

func set_focus_neighbors() -> void:
	for pos_y in range(inventory.height):
		for pos_x in range(inventory.width):
			#              (pos_x, pos_y - 1)
			#                     ^
			# (pos_x - 1, pos_y) < > (pos_x + 1, pos_y)
			#                     V
			#              (pos_x, pos_y + 1)
			var rootSlot = find_child(_get_slot_name(pos_x, pos_y), true, false)
			if pos_x != 0:
				var neighbor = find_child(_get_slot_name(pos_x - 1, pos_y), true, false)
				rootSlot.set_focus_neighbor(SIDE_LEFT, neighbor.get_path())
			if pos_x != inventory.width - 1:
				var neighbor = find_child(_get_slot_name(pos_x + 1, pos_y), true, false)
				rootSlot.set_focus_neighbor(SIDE_RIGHT, neighbor.get_path())
			if pos_y != inventory.height - 1:
				var neighbor = find_child(_get_slot_name(pos_x, pos_y + 1), true, false)
				rootSlot.set_focus_neighbor(SIDE_BOTTOM, neighbor.get_path())
			if pos_y != 0:
				var neighbor = find_child(_get_slot_name(pos_x, pos_y - 1), true, false)
				rootSlot.set_focus_neighbor(SIDE_TOP, neighbor.get_path())
			if pos_y == inventory.height - 1:
				if shop_mode:
					rootSlot.set_focus_neighbor(SIDE_BOTTOM, %ContinueButton.get_path())
				else:
					rootSlot.set_focus_neighbor(SIDE_BOTTOM, %CloseButton.get_path())

func _on_inventory_item_slot_clicked(index: Vector2) -> void:
	if not shop_mode:
		if %InventoryItemDraggable.visible:
			var drag_item = get_item(%InventoryItemDraggable.original_index)
			if drag_item is InventoryItemSlotRef:
				drag_item = drag_item.root_node
			
			if can_place_item(index, drag_item):
				take_entire_item(%InventoryItemDraggable.original_index)
				add_item_at_index(drag_item, index)
				%InventoryItemDraggable.visible = false
				selected_slot = Vector2(-1, -1)
				return
			else:
				# TODO: Add animation to indicate failure
				print("Unable to place at index: ", index, " Item: ", drag_item)
				return
		
		var item_at_index = get_item(index)
		if not item_at_index:
			return

		selected_slot = index
		if item_at_index is InventoryItemSlotRef:
			item_at_index = item_at_index.root_node
		
		%InventoryItemDraggable.visible = true
		%InventoryItemDraggable.original_index = index
		%InventoryItemDraggable.item = item_at_index
		
		%InventoryItemDraggable.update()
	else:
		shop_mode_item_clicked.emit(index)

func _on_slot_right_clicked(index: Vector2, node_position: Vector2) -> void:
	if shop_mode:
		return

	var item = get_item(index)
	if not item:
		return
	
	var station_type = item.type if item is InventoryItem else item.root_node.type
	last_right_clicked_slot = find_child(_get_slot_name(index.x, index.y), true, false)
	match station_type:
		InventoryItem.ItemType.STATION:
			_handle_station_right_clicked(item, index, node_position)
		InventoryItem.ItemType.ITEM:
			_handle_item_right_clicked(node_position)

func _handle_item_right_clicked(node_position: Vector2) -> void:
	build_item_context_menu(node_position)

func _handle_station_right_clicked(selected_station_item: InventoryItem, index: Vector2, node_position: Vector2) -> void:
	var station_name = selected_station_item.name if selected_station_item is InventoryItem else selected_station_item.root_node.name
	var surrounding_ingredients = get_surrounding_ingredients(index)
	var surrounding_inv_items : Array[InventoryItem] = []
	for each_ingred_pos in surrounding_ingredients:
		surrounding_inv_items.append(inventory.items[each_ingred_pos])
	
	var matching_recipes = StationController.get_all_matching_recipes(station_name, surrounding_inv_items)
	build_recipe_context_menu(matching_recipes, surrounding_ingredients, StationController.get_station(station_name), node_position)

func build_item_context_menu(new_position: Vector2) -> void:
	if has_node("../ItemContextMenu"):
		$"../ItemContextMenu".queue_free()
	
	var context_menu = item_context_menu.instantiate()
	var context_menu_item_list = context_menu.get_node("ActionList")
	context_menu.feed_selected.connect(_on_feed_selected)
	context_menu.closed.connect(_on_item_context_menu_closed)

	context_menu.global_position = new_position
	context_menu.z_index = 2
	get_parent().add_child(context_menu)
	context_menu_item_list.grab_focus()
	context_menu_item_list.select(0)

func build_recipe_context_menu(
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
		if each_recipe.times_cooked == 0:
			context_menu_item_list.add_item("?")
		else:
			context_menu_item_list.add_item(each_recipe.output[0].name)

	context_menu.global_position = new_position
	context_menu.z_index = 2
	get_parent().add_child(context_menu)
	context_menu_item_list.grab_focus()
	context_menu_item_list.select(0)

func _on_recipe_selected(recipe: Recipe, neighbors: Array[Vector2], station: Station):
	if last_right_clicked_slot:
		# call deferred so it is after we regenerate ui
		last_right_clicked_slot.grab_focus()
		
	selected_slot = Vector2(-1, -1)
	%InventoryItemDraggable.visible = false
	if not recipe:
		if has_node("../RecipeContextMenu"):
			$"../RecipeContextMenu".queue_free()
		
		return

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
		
	RecipeBookController.recipe_cooked.emit(recipe)
	if has_node("../RecipeContextMenu"):
		$"../RecipeContextMenu".queue_free()

func _on_item_context_menu_closed() -> void:
	if last_right_clicked_slot:
		last_right_clicked_slot.grab_focus()

func _on_feed_selected() -> void:
	print("_on_feed_selected")
	if last_feed_time_of_of_day == current_time_of_day:
		Dialogic.start("full_bellies")
		return
	
	last_feed_time_of_of_day = current_time_of_day
	if last_right_clicked_slot:
		var item = PlayerInventoryController.take_item_index(last_right_clicked_slot.index)
		print("Feeding selected item to party: %s" % item.name)
		PartyController.feed_party_item(item)
		last_right_clicked_slot.grab_focus()
	else:
		print("Skipping feeding since no selected item")


func clear_inventory_slots() -> void:
	for slot in get_children():
		var icon = slot.get_node("Icon")
		icon.texture = null
		icon.scale = Vector2(1,1)

func get_selected_item() -> Vector2:
	return selected_slot

func _on_advance_day() -> void:
	current_time_of_day = (current_time_of_day + 1) as Location.TimeOfDay

func _on_end_of_day() -> void:
	last_feed_time_of_of_day = Location.TimeOfDay.BREAKFAST
