extends Control

signal inventory_item_slot_clicked(index: Vector2)
signal slot_right_clicked(index: Vector2, node_postiion: Vector2)

@export var mouseOver : bool = false
@export var index : Vector2
@export var selected : bool = false
@export var selected_color : Color = Color.YELLOW
@export var unselected_color : Color = Color.WHITE

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if get_parent().get_selected_item().is_equal_approx(Vector2(-1, -1)):
					%Icon.texture = null
				inventory_item_slot_clicked.emit(index)
			MOUSE_BUTTON_RIGHT:
				slot_right_clicked.emit(index, global_position)
	

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false