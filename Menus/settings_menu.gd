extends Control

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	%MasterHSlider.value = Settings.master_volume
	%MusicHSlider.value = Settings.music_volume
	%SfxHSlider.value = Settings.sfx_volume
	%SeedTextEdit.text = "%d" % Settings._seed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Settings"):
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	if newActive == UiEvents.UiScene.SETTINGS:
		%CanvasLayer.visible = !%CanvasLayer.visible
	else:
		%CanvasLayer.visible = false

func _on_master_h_slider_value_changed(value: float) -> void:
	Settings.set_master_volume(value)

func _on_music_h_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(value)

func _on_sfx_h_slider_value_changed(value: float) -> void:
	Settings.set_sfx_volume(value)

func _on_seed_text_edit_text_changed() -> void:
	if %SeedTextEdit.text.is_valid_int():
		Settings.set_seed(%SeedTextEdit.text.to_int())

func _on_close_button_pressed() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS)

func _on_quit_to_main_menu_button_pressed() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.MAIN_MENU)
