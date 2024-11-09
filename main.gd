extends Node2D

@export var startingScene = UiEvents.UiScene.CAMPFIRE
@export var useSavedGame = false

func _ready() -> void:
	UiEvents.active_ui_changed.emit(startingScene)
	LocationEvents.end_of_day.connect(SaveLoad.save_game)
	if useSavedGame and SaveLoad.save_file_exists():
		SaveLoad.load_game()
