extends InventoryController

signal shop_mode_item_clicked(index: Vector2)
signal inventory_slot_selected(index: Vector2)
signal inventory_slot_hovered(index: Vector2)

@export var slot_scene : Resource = preload("res://Inventory/inventory_item_slot.tscn")
@export var recipe_context_menu = preload("res://Inventory/recipe_context_menu.tscn")
@export var item_context_menu = preload("res://Inventory/item_context_menu.tscn")
@export var selected_slot : Vector2 = Vector2(-1, -1)
@export var selected_slot_position : Vector2
@export var shop_mode : bool = false
@export var last_right_clicked_slot : Control
@export var last_feed_time_of_of_day : Location.TimeOfDay = Location.TimeOfDay.BREAKFAST
@export var current_time_of_day : Location.TimeOfDay = -1
@export var enabled : bool = false

const SLOT_PATH = "InventoryCanvas/InventoryGridContainer/"
var generate_semaphor : bool = false
var inventory_dictionary : Dictionary = {}

# Tutorial states
var awaiting_fish_place : bool = false
var awaiting_open_recipe_context : bool = false
var awaiting_recipe_clicked : bool = false
var awaiting_feed_cliced : bool = false

func _ready() -> void:
	LocationEvents.advance_day.connect(_on_advance_day)
	LocationEvents.end_of_day.connect(_on_end_of_day)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	_do_generate_inventory_grid()
	Dialogic.signal_event.connect(_on_dialogic_signal_event)
	%ItemDetailsOverlay.set_inventory(inventory)	
	%ItemDetailsOverlay.set_inventory_slot_clicked_signal(self.inventory_slot_selected)
	%ItemDetailsOverlay.set_inventory_slot_hovered_signal(self.inventory_slot_hovered)

func _on_dialogic_signal_event(event: String) -> void:
	match event:
		"inventory_tutorial_focus_fish":
			var fish_index = find_item("Fish")
			var slot = find_child(_get_slot_name(fish_index.x, fish_index.y), true, false)
			slot.grab_focus()
		"inventory_tutorial_awaiting_fish_place":
			awaiting_fish_place = true
			enabled = true
		"inventory_tutorial_focus_knife":
			var knife_index = find_item("Knife")
			var slot = find_child(_get_slot_name(knife_index.x, knife_index.y), true, false)
			slot.grab_focus()
			enabled = true
			awaiting_open_recipe_context = true
		"inventory_tutorial_focus_recipe_context":
			var recipe_context_menu = get_node("../RecipeContextMenu")
			recipe_context_menu.grab_focus()
			recipe_context_menu.enabled = true
			awaiting_recipe_clicked = true
		"inventory_tutorial_focus_sashimi":
			var sashimi_index = find_item("Sashimi")
			var slot = find_child(_get_slot_name(sashimi_index.x, sashimi_index.y), true, false)
			slot.grab_focus()
			enabled = true

func _on_focus_changed(control: Control) -> void:
	print("InventoryGridContainer - Focus changed to: ", control.name)
	if control == self:
		print("InventoryGridContainer - Focus changed to me! ")
		find_child(_get_slot_name(0, 0), true, false).grab_focus()
	else:
		if control.has_method("updated_selected"):
			_update_station_neighbors(selected_slot, false) # unset old
			_update_item_refs_to_selected(selected_slot, false)

			selected_slot = control.index
			selected_slot_position = control.global_position
			_update_item_refs_to_selected(selected_slot, true)
			_update_station_neighbors(selected_slot, true)
		else:
			# make sure we unselect when leaving the inventory grid
			selected_slot = Vector2(-1, -1)
			selected_slot_position = Vector2(0, 0)
		
		inventory_slot_selected.emit(selected_slot)

func _update_item_refs_to_selected(selected_slot: Vector2, newSelected: bool) -> void:
	var selected_item : Resource = null
	var root_node_index = selected_slot
	if inventory.items.has(selected_slot):
		selected_item = get_item(selected_slot)
		if selected_item is InventoryItemSlotRef:
			root_node_index = selected_item.root_node_index
			selected_item = selected_item.root_node

		if selected_item.inventory_height == 1 and selected_item.inventory_width == 1:
			return

		for pos_x in selected_item.inventory_width:
			for pos_y in selected_item.inventory_height:
				var large_item_index = root_node_index + Vector2(pos_x, pos_y)
				var large_item_refs = find_child(_get_slot_name(large_item_index.x, large_item_index.y), true, false)
				large_item_refs.root_selected = newSelected

func _update_station_neighbors(index: Vector2, newHover: bool) -> void:
	var item_at_index = get_item_deref(index)
	if not item_at_index:
		return
		
	if item_at_index.type != InventoryItem.ItemType.STATION:
		return

	var surrounding_ingredients = get_surrounding_ingredients(index)
	for each_neighbor in surrounding_ingredients:
		var neighbor_node = find_child(_get_slot_name(each_neighbor.x, each_neighbor.y), true, false)
		neighbor_node.updated_neighbor_tool_hover(newHover)
		var neighbor_item = get_item(each_neighbor)
		if neighbor_item.inventory_height > 1 or neighbor_item.inventory_width > 1:
			for pos_x in neighbor_item.inventory_width:
				for pos_y in neighbor_item.inventory_height:
					var large_item_index = each_neighbor + Vector2(pos_x, pos_y)
					var large_item_refs = find_child(_get_slot_name(large_item_index.x, large_item_index.y), true, false)
					large_item_refs.updated_neighbor_tool_hover(newHover)

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	
	if event.is_action_released("ui_cancel"):
		if not selected_slot.is_equal_approx(Vector2(-1, -1)):
			add_item_at_index(%InventoryItemDraggable.item, %InventoryItemDraggable.original_index)
			selected_slot = Vector2(-1, -1)
			%InventoryItemDraggable.visible = false
			generate_inventory_grid()
	
	if event.is_action_released("ui_accept"):
		_on_inventory_item_slot_clicked(selected_slot)
	
	if event.is_action_released("Action Selected"):
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
			slot.inventory_item_slot_hovered.connect(_on_inventory_item_slot_hovered)
			slot.inventory_item_slot_clicked.connect(_on_inventory_item_slot_clicked)
			slot.slot_right_clicked.connect(_on_slot_right_clicked)
			add_child(slot)
			inventory_dictionary[index] = slot
			
	set_focus_neighbors()

func _on_inventory_item_slot_hovered(index: Vector2) -> void:
	inventory_slot_hovered.emit(index)

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
			if pos_y == 0:
				if shop_mode:
					rootSlot.set_focus_neighbor(SIDE_TOP, get_node(focus_neighbor_top).get_path())

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
	if has_node("../ItemContextMenu") or has_node("../RecipeContextMenu"):
		return

	if not shop_mode:
		if %InventoryItemDraggable.visible:
			var drag_item = %InventoryItemDraggable.item.deref()
			
			if can_place_item(index, drag_item):
				add_item_at_index(drag_item, index)				
				%InventoryItemDraggable.visible = false
				if awaiting_fish_place:
					awaiting_fish_place = false
					enabled = false
					Dialogic.start("inventory_tutorial_knife")
				return
			elif can_replace_item(index, drag_item):
				%InventoryItemDraggable.original_index = index
				if get_item(index) is InventoryItemSlotRef:
					%InventoryItemDraggable.original_index = get_item(index).root_node_index

				var item_at_index = take_entire_item(index)
				%InventoryItemDraggable.item = item_at_index
				%InventoryItemDraggable.update()
				add_item_at_index(drag_item, index)
				return
			else:
				# TODO: Add animation to indicate failure
				print("Unable to place at index: ", index, " Item: ", drag_item)
				return
		
		%InventoryItemDraggable.original_index = index
		var item_at_index = get_item(index)
		if item_at_index is InventoryItemSlotRef:
			%InventoryItemDraggable.original_index = item_at_index.root_node_index

		_update_item_refs_to_selected(%InventoryItemDraggable.original_index, false)		
		item_at_index = take_entire_item(index)
		if not item_at_index:
			return

		selected_slot = index
		%InventoryItemDraggable.visible = true
		%InventoryItemDraggable.item = item_at_index
		%InventoryItemDraggable.update()
	else:
		shop_mode_item_clicked.emit(index)

func _on_slot_right_clicked(index: Vector2, node_position: Vector2) -> void:
	if shop_mode or %InventoryItemDraggable.visible:
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

func _handle_station_right_clicked(selected_station_item: Resource, index: Vector2, node_position: Vector2) -> void:
	var station_name = selected_station_item.name if selected_station_item is InventoryItem else selected_station_item.root_node.name
	var surrounding_ingredients = get_surrounding_ingredients(index)
	var surrounding_inv_items : Array[InventoryItem] = []
	for each_ingred_pos in surrounding_ingredients:
		surrounding_inv_items.append(inventory.items[each_ingred_pos])
	
	var matching_recipes = StationController.get_all_matching_recipes(station_name, surrounding_inv_items)
	var context_menu = build_recipe_context_menu(matching_recipes, surrounding_ingredients, StationController.get_station(station_name), node_position)
	if awaiting_open_recipe_context:
		Dialogic.start("inventory_tutorial_recipe_context")
		enabled = false
		context_menu.enabled = false
		awaiting_open_recipe_context = false

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
) -> Node:
	if has_node("../RecipeContextMenu"):
		$"../RecipeContextMenu".queue_free()
	
	var context_menu = recipe_context_menu.instantiate()
	var context_menu_item_list = context_menu.get_node("RecipeList")
	context_menu.recipes = recipes
	context_menu.neighbors = ingredients
	context_menu.station = station
	context_menu.enabled = true
	context_menu.recipe_selected.connect(_on_recipe_selected)

	if recipes.size() == 0:
		context_menu_item_list.add_item("No recipes possible")

	for each_recipe in recipes:
		if each_recipe.times_cooked == 0:
			context_menu_item_list.add_item("New Recipe")
		else:
			context_menu_item_list.add_item(each_recipe.output[0].name)

	context_menu.global_position = new_position
	context_menu.z_index = 2
	get_parent().add_child(context_menu)
	context_menu_item_list.grab_focus()
	context_menu_item_list.select(0)
	return context_menu

func _on_recipe_selected(recipe: Recipe, neighbors: Array[Vector2], station: Station):	
	if last_right_clicked_slot:
		# call deferred so it is after we regenerate ui
		last_right_clicked_slot.grab_focus()
		
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
	
	var last_item_made
	for each_output in recipe.output:
		var each_item = each_output.duplicate()
		if not each_item.modifiers:
			each_item.modifiers = ItemModifier.new()
		
		var combined = StationController.combine_multipliers(items_removed)
		each_item.modifiers.multiply(combined).multiply(station.modifier)
		last_item_made = each_item
		add_item(each_item)
		
	if has_node("../RecipeContextMenu"):
		$"../RecipeContextMenu".queue_free()
	
	if awaiting_recipe_clicked:
		enabled = false
		awaiting_recipe_clicked = false
		awaiting_feed_cliced = true
	
	if recipe.times_cooked == 0:
		var last_item_made_location = find_item(last_item_made.name)
		var last_item_made_control_name = _get_slot_name(last_item_made_location.x, last_item_made_location.y)
		var last_item_made_control = find_child(last_item_made_control_name, true, false)
		last_item_made_control.grab_focus()
		enabled = false
		%RecipeCreatedSound.play()
		if %ItemDetailsOverlay.on_right_side:
			%RecipeCreatedAnimation.play("recipe_created_left")
		else:
			%RecipeCreatedAnimation.play("recipe_created_right")
	
	RecipeBookController.recipe_cooked.emit(recipe)


func _on_item_context_menu_closed() -> void:
	if last_right_clicked_slot:
		last_right_clicked_slot.grab_focus()

func _on_feed_selected() -> void:
	print("_on_feed_selected")
	awaiting_feed_cliced = false
	if last_feed_time_of_of_day == current_time_of_day:
		Dialogic.start("full_bellies")
		Dialogic.timeline_ended.connect(_on_full_bellies_timeline_ended)
		return
	
	last_feed_time_of_of_day = current_time_of_day
	if last_right_clicked_slot:
		var item = PlayerInventoryController.take_item_index(last_right_clicked_slot.index)
		print("Feeding selected item to party: %s" % item.name)
		%ActivitySummaryOverlay.reset()
		PartyController.feed_party_item(item)
		%ActivitySummaryOverlay.update_ui(UiEvents.UiScene.INVENTORY_OPEN)
	else:
		print("Skipping feeding since no selected item")

func _on_full_bellies_timeline_ended() -> void:
	last_right_clicked_slot.grab_focus()
	Dialogic.timeline_ended.disconnect(_on_full_bellies_timeline_ended)

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
