extends InventoryController
class_name Station

@export var perform_method_map = {
	Actions.Actions.WAIT: func wait():
		print("Waiting...")
}

func get_perform_method(action: Actions.Actions) -> Callable:
	if not action in perform_method_map:
		print("%s not in perform_method_map" % Actions.Actions.keys()[action])
		return perform_method_map[Actions.Actions.WAIT]
	
	return perform_method_map[action]

# @param item_index Index of the item we are performing on
# @param action Action is the enum value to perform on the item
# @param modifiers Modifiers is the attributes being changed by this perform
func perform_single(item_index: int, action: Actions.Actions, modifiers: ItemModifier) -> void:
	if inventory.items.size() <= item_index:
		print("Item index is invalid: %d vs inventory size: %d" % [item_index, inventory.items.size()])
		return
	
	print("Performing action %s on item_array: %s with modifiers: %s" % [Actions.Actions.keys()[action], inventory.items[item_index].name, modifiers])
	_perform([inventory.items[item_index]], action, modifiers)

func _perform(item_array: Array[InventoryItem], action: Actions.Actions, modifiers: ItemModifier) -> void:
	var matching_recipes = RecipeBookController.recipe_book.match(action, item_array)
	if matching_recipes.size() == 0:
		print("Unable to perform action, no recipe found")
		return
	elif matching_recipes.size() > 1:
		print("Unable to peform action, too many recipes found for action and station inventory")
		return

	clear_inventory()
	
	# Increment count of recipe cooked
	var recipe: Recipe = matching_recipes[0]
	RecipeBookController.recipe_cooked.emit(recipe)
	
	for each_output_item in matching_recipes[0].output:
		var local_output_item = each_output_item.duplicate()
		var combined = combine_multipliers(item_array)
		local_output_item.modifiers.multiply(combined).multiply(modifiers)
		add_item(local_output_item)

func combine_multipliers(item_array: Array[InventoryItem]) -> ItemModifier:
	var item_modifier = ItemModifier.new()
	for each_item in item_array:
		print("%s => %s" % [each_item.name, each_item.modifiers])
		item_modifier.multiply(each_item.modifiers)

	return item_modifier

# Combines all items into a recipe based on the action, setting the inventory to the output of the recipe
func perform_combination(action: Actions.Actions, modifiers: ItemModifier) -> void:
	print("Performing action %s on item_array: %s with modifiers: %s" % [Actions.Actions.keys()[action], to_string(), modifiers])
	#_perform(inventory.items, action, modifiers)
