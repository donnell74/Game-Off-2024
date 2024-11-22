extends Control

@export var can_show_settings : bool = true
@export var node_to_give_focus_on_close : Node

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	%MasterHSlider.value = Settings.master_volume
	%MusicHSlider.value = Settings.music_volume
	%SfxHSlider.value = Settings.sfx_volume
	%SeedTextEdit.text = "%d" % Settings._seed
	%SkipCutscenesCheckBox.button_pressed = Settings.skip_cutscenes

func _input(event: InputEvent) -> void:
	if can_show_settings and event.is_action_pressed("Toggle Settings"):
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	can_show_settings = false
	match newActive:
		UiEvents.UiScene.SETTINGS:
			%CanvasLayer.visible = not %CanvasLayer.visible
			if %CanvasLayer.visible:
				%CloseButton.grab_focus()

			can_show_settings = true
		UiEvents.UiScene.CAMPFIRE, UiEvents.UiScene.MAP:
			can_show_settings = true
			%CanvasLayer.visible = false
		UiEvents.UiScene.INVENTORY, UiEvents.UiScene.RECIPE_BOOK:
			# Overlays
			can_show_settings = !can_show_settings
		_:
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

func _on_skip_cutscenes_check_box_toggled(toggled_on: bool) -> void:
	Settings.set_skip_cutscenes(toggled_on)

func _on_close_button_pressed() -> void:
	%CloseButton.release_focus()
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS)
	SaveLoad.save_settings()

func _on_quit_to_main_menu_button_pressed() -> void:
	%QuitToMainMenuButton.release_focus()
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.MAIN_MENU)
	SaveLoad.save_settings()
