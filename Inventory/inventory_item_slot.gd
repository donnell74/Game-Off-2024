extends Control

signal inventory_item_slot_clicked(index: int)

@export var mouseOver : bool = false
@export var index : int
@export var selected : bool = false
@export var selected_color : Color = Color.YELLOW
@export var unselected_color : Color = Color.LIGHT_GRAY

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		print("Clicked InventoryItemSlot with name: %s" % name)
		selected = !selected
		%Background.color = selected_color if selected else unselected_color
		inventory_item_slot_clicked.emit(index)

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false
