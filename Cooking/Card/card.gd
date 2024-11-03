extends Control

signal card_clicked(action: Actions.Actions)

@export var image_texture : Texture = preload("res://Cooking/Assets/clock.png")
@export var description : String = "Wait"
@export var action: Actions.Actions = Actions.Actions.WAIT
@export var mouseOver : bool = false

func _ready() -> void:
	if image_texture:
		%ImageTexture.texture = image_texture
	
	%DescriptionText.text = description

func _input(event: InputEvent) -> void:
	if mouseOver and event is InputEventMouseButton and event.is_pressed():
		print("Clicked card with description: %s" % description)
		card_clicked.emit(action)

func _on_mouse_entered() -> void:
	mouseOver = true

func _on_mouse_exited() -> void:
	mouseOver = false
