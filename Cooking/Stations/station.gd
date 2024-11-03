extends InventoryController
class_name Station

# @param item_index Index of the item we are performing on
# @param action Action is the enum value to perform on the item
# @param modifiers Modifiers is the attributes being changed by this perform, should follow the 
#   format of Dictionary<PartyController.Stats, float>
func perform_single(item_index: int, action: Actions.Actions, modifiers: Dictionary) -> void:
	if inventory.items.size() <= item_index:
		print("Item index is invalid: %d vs inventory size: %d" % [item_index, inventory.items.size()])
		return
	
	print("Performing action %s on item_array: %s with modifiers: %s" % [Actions.Actions.keys()[action], inventory.items[item_index].name, get_modifier_string(modifiers)])
	_perform([inventory.items[item_index]], action, modifiers)

func _perform(item_array: Array[InventoryItem], action: Actions.Actions, modifiers: Dictionary) -> void:	
	var matching_recipes = AllRecipeController.recipe_book.match(action, item_array)
	if matching_recipes.size() == 0:
		print("Unable to perform action, no recipe found")
		return
	elif matching_recipes.size() > 1:
		print("Unable to peform action, too many recipes found for action and station inventory")
		return

	clear_inventory()
	for each_output_item in matching_recipes[0].output:
		add_item(each_output_item)

func get_modifier_string(modifiers: Dictionary) -> String:
	var modifier_string = "["
	for each_stat in modifiers:
		modifier_string += "\n stat %s with modifier: %d" % [each_stat, modifiers[each_stat]]
	return modifier_string + "\n]"

# Combines all items into a recipe based on the action, setting the inventory to the output of the recipe
func perform_combination(action: Actions.Actions, modifiers: Dictionary) -> void:
	print("Performing action %s on item_array: %s with modifiers: %s" % [Actions.Actions.keys()[action], to_string(), get_modifier_string(modifiers)])
	_perform(inventory.items, action, modifiers)
