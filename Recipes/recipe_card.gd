extends Control

func update_ui(recipe: Recipe) -> void:
	var ingredients: Array[InventoryItem] = recipe.input
	var output: InventoryItem = recipe.output[0]
	var action = recipe.action
	$AdditonalDetails/IngredientsList.clear()
	
	# Recipe Image
	if output.texture != null:
		%ImageTexture.texture = output.texture
	else:
		# Default
		%ImageTexture.texture = preload("res://addons/dialogic/Modules/Background/icon.png")
	if recipe.times_cooked == 0:
		%ImageTexture.modulate = Color(1, 1, 1, 0.05)
	else:
		# Ingredients, only show if they have unlocked the recipe
		if ingredients.size() > 0:
			var idx = 0
			for ingredient in ingredients:
				$AdditonalDetails/IngredientsList.add_item(ingredient.name, ingredient.texture)
				$AdditonalDetails/IngredientsList.set_item_selectable(idx, false)
				idx += 1
	
	# Recipe Name
	%DescriptionText.text = "{name}\n({action})(Cooked: {times_cooked})".format({
		"name": output.name,
		"action": Actions.Actions.keys()[recipe.action],
		"times_cooked": recipe.times_cooked
	})

func _on_area_2d_mouse_entered() -> void:
	if $AdditonalDetails/IngredientsList.get_item_count() > 0:
		$AdditonalDetails.visible = true

func _on_area_2d_mouse_exited() -> void:
	$AdditonalDetails.visible = false
