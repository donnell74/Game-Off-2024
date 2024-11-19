extends Control

signal recipe_selected(recipe: Recipe, neighbors: Array[Vector2], station: Station)

@export var station : Station
@export var neighbors : Array[Vector2] = []
@export var recipes : Array[Recipe] = []
@export var mouseOver = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !mouseOver:
		queue_free()
	
	if event.is_action_pressed("ui_accept"):
		if %RecipeList.get_selected_items().size() > 0:
			_on_recipe_list_item_clicked(%RecipeList.get_selected_items()[0], Vector2(), 0)
		else:
			_on_recipe_list_item_clicked(-1, Vector2(), 0)

func _on_recipe_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if recipes.size() == 0:
		recipe_selected.emit(null, neighbors, station)
		queue_free()
		return
	
	recipe_selected.emit(recipes[index], neighbors, station)

func _on_recipe_list_mouse_entered() -> void:
	mouseOver = true

func _on_recipe_list_mouse_exited() -> void:
	mouseOver = false
