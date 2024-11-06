extends Control

signal card_clicked(action: Actions.Actions)

@export var image_texture : Texture = preload("res://Cooking/Assets/clock.png")
@export var description : String = "Wait"
@export var action: Actions.Actions = Actions.Actions.WAIT
@export var mouseOver : bool = false

const ACTION_TO_TEXTURE = {
	Actions.Actions.DICE: preload("res://Cooking/Assets/knife.png"),
	Actions.Actions.WAIT: preload("res://Cooking/Assets/clock.png"),
}

func update_ui(_action: Actions.Actions, _description: String) -> void:
	action = _action
	%DescriptionText.text = _description
	if ACTION_TO_TEXTURE.has(action):
		%ImageTexture.texture = ACTION_TO_TEXTURE[action]
	else:
		%ImageTexture.texture = null

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		print("Clicked card with description: %s" % description)
		card_clicked.emit(action)
	elif event.is_action_pressed("ui_accept") and has_focus():
		card_clicked.emit(action)

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false
