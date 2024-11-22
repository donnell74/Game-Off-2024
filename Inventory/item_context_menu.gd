extends Control

signal feed_selected
signal closed

@export var mouseOver = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !mouseOver:
		queue_free()
	
	if event.is_action_pressed("ui_cancel") and visible:
		_on_action_list_item_clicked(-1, Vector2(), 0)
	
	if event.is_action_pressed("ui_accept"):
		if %ActionList.get_selected_items().size() > 0:
			_on_action_list_item_clicked(%ActionList.get_selected_items()[0], Vector2(), 0)

func _on_action_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if index == -1:
		queue_free()
		closed.emit()

	if index == 0:
		queue_free()
		feed_selected.emit()

func _on_action_list_mouse_entered() -> void:
	mouseOver = true

func _on_action_list_mouse_exited() -> void:
	mouseOver = false
