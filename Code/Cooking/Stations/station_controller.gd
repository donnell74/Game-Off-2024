extends Node

@export var all_stations : Array[Station] = []

func get_station(station_name: String) -> Station:
	for station in all_stations:
		if station.inventory_item.name == station_name:
			return station
	
	return null

func perform(station_name: String, input_items: Array[InventoryItem]) -> Array[InventoryItem]:
	var selected_station = StationController.get_station(station_name)
	if not selected_station:
		print("Right click inventory slot that was not a station")
		return []
	
	var matching_recipes = RecipeBookController.recipe_book.match(selected_station.action, input_items)
	print("Right clicked station: ", Actions.Actions.keys()[selected_station.action], " with items: ", input_items, " resulting in recipe: ", matching_recipes)
	if not matching_recipes:
		return []
	
	var recipe : Recipe = matching_recipes[0]
	var result_output_item : Array[InventoryItem] = []
	for each_output_item in recipe.output:
		var local_output_item = each_output_item.duplicate()
		var combined = combine_multipliers(input_items)
		local_output_item.modifiers.multiply(combined).multiply(selected_station.modifier)
		result_output_item.append(local_output_item)

	RecipeBookController.recipe_cooked.emit(recipe)
	return result_output_item

func get_all_matching_recipes(station_name: String, ingredients: Array[InventoryItem]) -> Array[Recipe]:
	var selected_station = StationController.get_station(station_name)
	if not selected_station:
		print("Right click inventory slot that was not a station")
		return []
	
	var permutations : Array = get_permutations(ingredients)
	var result : Array[Recipe] = []
	for each_permutation in permutations:
		var typed_permutation : Array[InventoryItem] = []
		for each_item in each_permutation:
			typed_permutation.append(each_item)

		var matching_recipes = RecipeBookController.recipe_book.match(selected_station.action, typed_permutation)
		for each_recipe in matching_recipes:
			result.append(each_recipe)

	return result

func get_permutations(input: Array[InventoryItem]) -> Array:
	if input.size() == 0:
		return []
	if input.size() == 1:
		return [[input[0]]]
	if input.size() == 2:
		return [[input[0]], [input[1]], [input[0], input[1]]]
	
	var first_element = input.pop_front()
	var result = [[first_element]]
	for each_perm in get_permutations(input):
		result.append(each_perm)
		var dup = each_perm.duplicate()
		dup.append(first_element)
		result.append(dup)

	return result

func combine_multipliers(item_array: Array[InventoryItem]) -> ItemModifier:
	var item_modifier = ItemModifier.from_values(0.0, 0.0, 0.0)
	var count = 0
	for each_item in item_array:
		print("%s => %s" % [each_item.name, each_item.modifiers])
		item_modifier.add(each_item.modifiers)
		count += 1

	return item_modifier.divide(count)
