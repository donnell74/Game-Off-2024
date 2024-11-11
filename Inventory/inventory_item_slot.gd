extends Control

signal inventory_item_slot_clicked(index: int)
signal slot_right_clicked(index: int)

@export var mouseOver : bool = false
@export var index : int
@export var selected : bool = false
@export var selected_color : Color = Color.YELLOW
@export var unselected_color : Color = Color.LIGHT_GRAY

func _input(event: InputEvent) -> void:
	# TODO: Handle right mouse click if item is station
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		print("Clicked InventoryItemSlot with name: %s" % name)
		print((event as InputEventMouseButton).button_index)
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				selected = !selected
				%Background.color = selected_color if selected else unselected_color
				inventory_item_slot_clicked.emit(index)
			MOUSE_BUTTON_RIGHT:
				slot_right_clicked.emit(index)

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false
