extends Control

signal recipe_selected(recipe: Recipe, neighbors: Array[Vector2], station: Station)

@export var station : Station
@export var neighbors : Array[Vector2] = []
@export var recipes : Array[Recipe] = []
@export var mouseOver = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !mouseOver:
		queue_free()

func _on_recipe_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if recipes.size() == 0:
		queue_free()
		return
	
	recipe_selected.emit(recipes[index], neighbors, station)

func _on_recipe_list_mouse_entered() -> void:
	mouseOver = true

func _on_recipe_list_mouse_exited() -> void:
	mouseOver = false
