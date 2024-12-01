extends Control

signal inventory_item_slot_clicked(index: Vector2)
signal inventory_item_slot_hovered(index: Vector2)
signal slot_right_clicked(index: Vector2, node_postiion: Vector2)

@export var mouseOver : bool = false
@export var index : Vector2
@export var selected : bool = false
@export var selected_color : Color = Color.YELLOW
@export var root_selected_color : Color = Color.LIGHT_YELLOW
@export var unselected_color : Color = Color.WHITE
@export var hover_color : Color = Color.LIGHT_BLUE
@export var shop_mode : bool = false
@export var neighbor_tool_hover : bool = false
@export var root_selected : bool = false

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var parent = get_parent()
				if not shop_mode && parent.get_selected_item().is_equal_approx(Vector2(-1, -1)):
					%Icon.texture = null
				inventory_item_slot_clicked.emit(index)
			MOUSE_BUTTON_RIGHT:
				slot_right_clicked.emit(index, global_position)

func updated_neighbor_tool_hover(new: bool) -> void:
	neighbor_tool_hover = new
	if neighbor_tool_hover:
		%Background.modulate = hover_color
	else:
		%Background.modulate = unselected_color

func updated_selected(slot_index: Vector2) -> void:
	if neighbor_tool_hover:
		return

	selected = slot_index.is_equal_approx(index)
	if selected:
		%Background.modulate = selected_color
	elif root_selected:
		%Background.modulate = root_selected_color
	else:
		%Background.modulate = unselected_color

func set_inventory_slot_clicked_signal(clicked_signal: Signal) -> void:
	clicked_signal.connect(updated_selected)

func _on_mouse_entered() -> void:
	mouseOver = true
	inventory_item_slot_hovered.emit(index)

func _on_mouse_exited() -> void:
	mouseOver = false
	inventory_item_slot_hovered.emit(Vector2(-1, -1))
