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
		UiEvents.UiScene.SETTINGS_OPEN, UiEvents.UiScene.INVENTORY_OPEN, UiEvents.UiScene.RECIPE_BOOK_OPEN:
			pass # don't hide if settings are opened on main menu
		_:
			%CanvasLayer.visible = false
