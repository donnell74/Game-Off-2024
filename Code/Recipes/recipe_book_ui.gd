extends Node2D

@export var recipes_per_row : int = 5
@export var scroll_step : float = 0.01

var recipe_tier_containers : Dictionary = {}

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	RecipeBookController.recipe_cooked.connect(_on_recipe_cooked)
	update_recipes()

func _toggle_recipe_book() -> void:
	%RecipeBookCanvas.visible = !%RecipeBookCanvas.visible
	if %RecipeBookCanvas.visible:
		update_recipes()
		%CloseButton.grab_focus()
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.RECIPE_BOOK_OPEN)
	else:
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.RECIPE_BOOK_CLOSED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Recipe Book"):
		_toggle_recipe_book()
	if event.is_action_pressed("Pan Down"):
		%ScrollContainer.get_v_scroll_bar().ratio += scroll_step
	if event.is_action_pressed("Pan Up"):
		%ScrollContainer.get_v_scroll_bar().ratio -= scroll_step

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.RECIPE_BOOK_OPEN:
			if not %RecipeBookCanvas.visible:
				_toggle_recipe_book()
		_:
			%RecipeBookCanvas.visible = false

func update_recipes(type: String = "ALL"):
	var recipe_card_scene: PackedScene = preload("res://Recipes/recipe_card.tscn")
	print("Updating recipes")
	# Clear it first
	recipe_tier_containers = {}
	for child in %RecipeGridContainer.get_children():
		child.queue_free()

	for each_tier in Recipe.Tiers.values():
		var tier_label = Label.new()
		tier_label.text = Recipe.Tiers.keys()[each_tier]
		%RecipeGridContainer.add_child(tier_label)
		
		var new_tier_container = GridContainer.new()
		new_tier_container.columns = recipes_per_row
		recipe_tier_containers[each_tier] = new_tier_container
		%RecipeGridContainer.add_child(new_tier_container)

	var recipes = RecipeBookController.recipe_book.recipes
	recipes.sort_custom(_by_name)
	for recipe in RecipeBookController.recipe_book.recipes:
		if (type == "UNLOCKED" and recipe.times_cooked > 0) or (type == "ALL"):
			var recipe_card = recipe_card_scene.instantiate()
			recipe_card.update_ui(recipe)
			recipe_tier_containers[recipe.tier].add_child(recipe_card)
		
func _by_name(a: Recipe, b: Recipe):
	if a.output[0].name > b.output[0].name:
		return false
	return true

func _on_recipe_cooked(recipe: Recipe):
	var idx = 0
	for r in RecipeBookController.recipe_book.recipes:
		if r.output[0].name == recipe.output[0].name:
			RecipeBookController.recipe_book.recipes[idx].times_cooked += 1
			break
		idx += 1
	update_recipes()


func _on_close_button_pressed() -> void:
	_toggle_recipe_book()

func _on_show_unlocked_button_pressed() -> void:
	update_recipes("UNLOCKED")

func _on_show_all_button_button_down() -> void:
	update_recipes()
