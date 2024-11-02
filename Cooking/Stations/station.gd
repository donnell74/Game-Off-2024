extends InventoryController
class_name Station

# @param item_index Index of the item we are performing on
# @param adjective Adjective is the string to add in front of the current food title
# @param modifiers Modifiers is the attributes being changed by this perform, should follow the 
#   format of Dictionary<PartyController.Stats, float>
func perform_single(item_index: int, adjective: String, modifiers: Dictionary) -> void:
	var modifier_string = "["
	for each_stat in modifiers:
		modifier_string += "\n stat %s with modifier: %d" % [each_stat, modifiers[each_stat]]
	
	modifier_string += "\n]"
	print("Performing action %s on item_index: %d with modifiers: %s" % [adjective, item_index, modifier_string])
	inventory.items[item_index].name = "%s %s" % [adjective, inventory.items[item_index].name]


# TODO write this
# Should combine all the items in the current_item into a single item at index 0
func perform_combination() -> void:
	pass
