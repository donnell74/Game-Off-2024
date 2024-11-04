extends Control

signal map_node_clicked(x_map_pos: int, y_map_pos: int)

@export var x_map_pos : int
@export var y_map_pos : int
@export var mouseOver : bool = false
@export var visitable : bool = false
@export var notVisitableColor : Color = Color.DARK_GRAY

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		print("Clicked card with name: %s" % name)
		if !visitable:
			print("Already completed location, not emitting")
			return

		map_node_clicked.emit(x_map_pos, y_map_pos)

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false

func make_not_visitable() -> void:
	%Icon.modulate = notVisitableColor
	%Background.modulate = notVisitableColor
	visitable = false

func make_visitable() -> void:
	%Icon.modulate = Color.WHITE
	%Background.modulate = Color.WHITE
	visitable = true
