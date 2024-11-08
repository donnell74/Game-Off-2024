extends Node2D

@export var startingScene = UiEvents.UiScene.CAMPFIRE

func _ready() -> void:
	UiEvents.active_ui_changed.emit(startingScene)
	if SaveLoad.save_file_exists():
		SaveLoad.load_game()
