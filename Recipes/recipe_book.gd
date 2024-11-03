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

func item_arrays_match(left, right) -> bool:
	if left.size() != right.size(): 
		return false
	
	for item in left:
		if !right.has(item): 
			return false
		
		if left.count(item) != right.count(item): 
			return false
	
	return true
