extends Node2D

@export var startingScene = UiEvents.UiScene.CAMPFIRE

func _ready() -> void:
	UiEvents.active_ui_changed.emit(startingScene)
