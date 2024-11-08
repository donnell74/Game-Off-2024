extends Control
class_name MapNode

signal map_node_clicked(x_map_pos: int, y_map_pos: int)

enum VisitState {
	NOT_VISITABLE,
	VISITABLE,
	VISTED
}

@export var x_map_pos : int
@export var y_map_pos : int
@export var mouseOver : bool = false
@export var visitState : VisitState = VisitState.VISITABLE
@export var notVisitableColor : Color = Color.DARK_GRAY

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		print("Clicked card with name: %s" % name)
		if visitState == VisitState.VISTED:
			print("Already completed location, not emitting")
			return
		elif visitState == VisitState.NOT_VISITABLE:
			print("Location Not Visitable yet, not emitting")
			return

		map_node_clicked.emit(x_map_pos, y_map_pos)

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false

func change_visit_state(state: VisitState) -> void:
	visitState = state
	match state:
		VisitState.NOT_VISITABLE:
			%Icon.modulate = notVisitableColor
			%Background.modulate = notVisitableColor
		VisitState.VISITABLE:
			%Icon.modulate = Color.WHITE
			%Background.modulate = Color.WHITE
		VisitState.VISTED:
			%CompletedIndicator.visible = true
			%Icon.modulate = notVisitableColor
			%Background.modulate = notVisitableColor
