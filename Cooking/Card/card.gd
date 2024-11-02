extends Control

@export var image_texture : Texture = preload("res://Cooking/Assets/clock.png")
@export var description : String = "Wait"

func _ready() -> void:
	if image_texture:
		%ImageTexture.texture = image_texture
	
	%DescriptionText.text = description
