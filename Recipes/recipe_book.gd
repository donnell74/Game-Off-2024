extends Resource
class_name RecipeBook

# TODO: Figure out if we can make a loader
@export var recipes : Array[Recipe] = []

func match(action: Actions.Actions, item_array: Array[InventoryItem] = []) -> Array[Recipe]:
	var matches: Array[Recipe] = []
	for each_recipe in recipes:
		if each_recipe.action != action:
			continue
		
		if !item_arrays_match(each_recipe.input, item_array):
			continue
		
		matches.append(each_recipe)
	
	return matches

func item_arrays_match(left: Array[InventoryItem], right: Array[InventoryItem], ignoreModifiers: bool = true) -> bool:
	if left.size() != right.size(): 
		return false
	
	for item in left:
		if !array_contains_item(left, item, ignoreModifiers):
			return false
		
		if array_count_item(left, item, ignoreModifiers) != array_count_item(right, item, ignoreModifiers): 
			return false
	
	return true

func array_count_item(left: Array[InventoryItem], item: InventoryItem, ignoreModifiers: bool) -> bool:
	var count = 0
	for each_left in left:
		if each_left.equals(item, ignoreModifiers):
			count += 1
	
	return count

func array_contains_item(left: Array[InventoryItem], item: InventoryItem, ignoreModifiers: bool) -> bool:
	for each_left in left:
		if each_left.equals(item, ignoreModifiers):
			return true
	
	return false
