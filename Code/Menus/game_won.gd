extends Control

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

func _on_quit_to_main_menu_button_pressed() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.MAIN_MENU)

func _on_continue_button_pressed() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.GAME_WON:
			%CanvasLayer.visible = true
		UiEvents.UiScene.SETTINGS, UiEvents.UiScene.INVENTORY, UiEvents.UiScene.RECIPE_BOOK:
			pass # don't hide if settings are opened on main menu
		_:
			%CanvasLayer.visible = false
