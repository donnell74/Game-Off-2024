extends Control

@export var can_show_settings : bool = true
@export var node_to_give_focus_on_close : Node
@export var cheat_code_row : PackedScene = preload("res://Menus/cheat_code_row.tscn")

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	%MasterHSlider.value = Settings.master_volume
	%MusicHSlider.value = Settings.music_volume
	%SfxHSlider.value = Settings.sfx_volume
	%SeedTextEdit.text = "%d" % Settings._seed
	%SkipCutscenesCheckBox.button_pressed = Settings.skip_cutscenes
	%SkipTutorialCheckbox.button_pressed = Settings.skip_tutorial
	%VeganCheckBox.button_pressed = Settings.vegan
	%SettingsControl.visible = true
	%CheatCodesControl.visible = false

func _input(event: InputEvent) -> void:
	if can_show_settings and event.is_action_pressed("Toggle Settings"):
		_toggle_settings_menu()

func _toggle_settings_menu() -> void:
	%CanvasLayer.visible = not %CanvasLayer.visible
	if %CanvasLayer.visible:
		print("SettingsMenu - Toggling ON")
		%CloseButton.grab_focus()
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS_OPEN)
	else:
		print("SettingsMenu - Toggling OFF")
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS_CLOSED)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	can_show_settings = false
	match newActive:
		UiEvents.UiScene.SETTINGS_OPEN:
			can_show_settings = true
			if not %CanvasLayer.visible:
				_toggle_settings_menu()
		UiEvents.UiScene.CAMPFIRE, UiEvents.UiScene.MAP:
			can_show_settings = true
			%CanvasLayer.visible = false
		UiEvents.UiScene.INVENTORY_OPEN, UiEvents.UiScene.RECIPE_BOOK_OPEN:
			# Overlays
			can_show_settings = false
		UiEvents.UiScene.INVENTORY_CLOSED, UiEvents.UiScene.RECIPE_BOOK_CLOSED, UiEvents.UiScene.SETTINGS_CLOSED:
			can_show_settings = true
		UiEvents.UiScene.DISABLE_HOTKEYS, UiEvents.UiScene.ENABLE_HOTKEYS:
			can_show_settings = true
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

func _on_skip_tutorial_checkbox_toggled(toggled_on: bool) -> void:
	Settings.set_skip_tutorial(toggled_on)

func _on_close_button_pressed() -> void:
	_toggle_settings_menu()
	SaveLoad.save_settings()

func _on_quit_to_main_menu_button_pressed() -> void:
	%QuitToMainMenuButton.release_focus()
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.MAIN_MENU)
	SaveLoad.save_settings()

func _on_cheat_code_button_pressed() -> void:
	%SettingsControl.visible = false
	%CheatCodesControl.visible = true

func _on_enter_cheat_code_button_pressed() -> void:
	if Settings.CHEAT_CODES.keys().has(%CheatCodeTextEdit.text):
		var cheatCodeIndex = Settings.CHEAT_CODES[%CheatCodeTextEdit.text]
		var cheatCodeRow = cheat_code_row.instantiate()
		cheatCodeRow.get_node("Label").text = %CheatCodeTextEdit.text
		%CheatCodesGridContainer.add_child(cheatCodeRow)
		Settings.add_cheat_code(cheatCodeIndex)
	else:
		%InvalidLabel.visible = true
		%InvalidLabelTimer.start()

func _on_back_to_settings_button_pressed() -> void:
	%SettingsControl.visible = true
	%CheatCodesControl.visible = false

func _on_invalid_label_timer_timeout() -> void:
	%InvalidLabel.visible = false

func _on_cheat_code_text_edit_focus_entered() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.DISABLE_HOTKEYS)

func _on_cheat_code_text_edit_focus_exited() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.ENABLE_HOTKEYS)

func _on_vegan_check_box_toggled(toggled_on: bool) -> void:
	Settings.set_vegan(toggled_on)
