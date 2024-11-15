extends Control

@export var main_scene = preload("res://main.tscn")
@export var settings_scene = preload("res://Menus/settings_menu.tscn")

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.MAIN_MENU:
			%CanvasLayer.visible = true
		UiEvents.UiScene.SETTINGS, UiEvents.UiScene.INVENTORY, UiEvents.UiScene.RECIPE_BOOK:
			pass # don't hide if settings are opened on main menu
		_:
			%CanvasLayer.visible = false
			visible = false

func _on_start_new_run_button_pressed() -> void:
	if not Settings.skip_cutscenes:
		Dialogic.start("introduction")

	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)

func _on_settings_button_pressed() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS)

func _on_continue_button_pressed() -> void:
	if SaveLoad.save_file_exists():
		SaveLoad.load_game()

	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
