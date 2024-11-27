extends Control

@export var main_scene = preload("res://main.tscn")
@export var settings_scene = preload("res://Menus/settings_menu.tscn")

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func _on_focus_changed(control: Control) -> void:
	# Only play sound if the foucs is for one of MainMenu's children
	if control is Button and control.get_parent() == %GridContainer:
		%ButtonHoverSound.pitch_scale = Settings.random().randf_range(0.5, 1.0)
		%ButtonHoverSound.play()

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.MAIN_MENU:
			%CanvasLayer.visible = true
			%StartNewRunButton.grab_focus()
		UiEvents.UiScene.SETTINGS_CLOSED:
			var control_with_focus = get_viewport().gui_get_focus_owner()
			print("Inventory._on_active_ui_changed - control_with_focus: ", control_with_focus)
			if not control_with_focus and visible:
				%StartNewRunButton.grab_focus()
			else:
				release_focus()
			# don't hide if settings are opened on main menu
		UiEvents.UiScene.SETTINGS_OPEN, UiEvents.UiScene.DISABLE_HOTKEYS, UiEvents.UiScene.ENABLE_HOTKEYS:
			pass
		_:
			%CanvasLayer.visible = false
			visible = false

func _on_start_new_run_button_pressed() -> void:
	%ButtonSelectedSound.play()
	$"/root/Main/Map".generate_map()
	if not Settings.skip_cutscenes:
		Dialogic.start("introduction")

	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)

func _on_settings_button_pressed() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.SETTINGS_OPEN)

func _on_continue_button_pressed() -> void:
	if SaveLoad.save_file_exists():
		SaveLoad.load_game()

	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
