extends Node

@export var recipe_book: RecipeBook
@warning_ignore("unused_signal")
signal recipe_cooked(recipe: Recipe)

func cheat() -> void:
	for each_recipe in recipe_book.recipes:
		each_recipe.times_cooked = 1

func save() -> Dictionary:
	return {
		SaveLoad.PATH_FROM_ROOT_KEY: get_path(),
		"recipe_book": recipe_book.save()
	}
	
func load(load_data: Dictionary) -> void:
	recipe_book = RecipeBook.new()
	recipe_book.load(load_data["recipe_book"])
