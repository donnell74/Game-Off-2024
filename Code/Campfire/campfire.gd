extends Node2D

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	LocationEvents.advance_day_done.connect(_on_advance_day_done)
	PartyController.party_stats_changed.connect(populatePartyStats)
	Dialogic.timeline_started.connect(_on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_stopped)
	Dialogic.signal_event.connect(_on_dialogic_signal_event)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	%CampfireAnimationSprite.play("campfire_animation")
	
	populatePartyStats()

func _on_focus_changed(control: Control) -> void:
	print("Campfire - _on_focus_changed - ", control)
	if not control and visible:
		print("Campfire - I am visible and no one has focus, taking focus")
		%ContinueDayButton.grab_focus()

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.CAMPFIRE:
			visible = true
			%ContinueDayButton.grab_focus()
			%ContinueDayButton.text = _get_continue_day_text()
			%AmbienceSound.play()
			if has_node("/root/Location"):
				var locationNode = $"/root/Location"
				if locationNode:
					%LocationInfo.text = locationNode.location.description
					%TimeOfDayInfo.text = Location.TimeOfDay.keys()[locationNode.location.currentTimeOfDay]
				else:
					%TimeOfDayInfo.text = Location.TimeOfDay.keys()[Location.TimeOfDay.BREAKFAST]
			else:
				%LocationInfo.text = "Campfire"
				%TimeOfDayInfo.text = Location.TimeOfDay.keys()[0]
		UiEvents.UiScene.SETTINGS_CLOSED, UiEvents.UiScene.INVENTORY_CLOSED, UiEvents.UiScene.RECIPE_BOOK_CLOSED:
			var control_with_focus = get_viewport().gui_get_focus_owner()
			print("Campfire - control_with_focus: ", control_with_focus)
			if not control_with_focus and visible:
				%ContinueDayButton.grab_focus()
			# overlay, do nothing
		UiEvents.UiScene.SETTINGS_OPEN, UiEvents.UiScene.INVENTORY_OPEN, UiEvents.UiScene.RECIPE_BOOK_OPEN, UiEvents.UiScene.DISABLE_HOTKEYS, UiEvents.UiScene.ENABLE_HOTKEYS:
			pass # keep the music going and let the overlay show on top of the campfire scene
		_:
			%AmbienceSound.stop()
			visible = false

func _get_continue_day_text() -> String:
	if not has_node("/root/Location"):
		return "Start My Day"
	
	var location_node = get_node("/root/Location")
	if location_node.location.currentTimeOfDay == Location.TimeOfDay.END_OF_DAY:
		return "End My Day"
	
	return "Continue Day"

func _on_dialogic_signal_event(event: String) -> void:
	match event:
		"introduction_done":
			if not Settings.skip_tutorial:
				Dialogic.start("campfire_tutorial")
		"tutorial_location_details_open":
			%LocationStatsHighlight.visible = true
		"tutorial_location_details_done":
			%LocationStatsHighlight.visible = false
			%PartyStatsHighlight.visible = true
		"tutorial_party_details_close":
			%PartyStatsHighlight.visible = false


func _on_dialogic_timeline_started() -> void:
	%ContinueDayButton.disabled = true

func _on_dialogic_timeline_stopped() -> void:
	%ContinueDayButton.disabled = false

func _on_continue_day_button_pressed() -> void:
	print("Campfire - _on_continue_day_button_pressed")
	%ButtonClickedSound.play()
	
	if has_node("/root/Location"):
		%ActivitySummaryOverlay.reset()
		LocationEvents.advance_day.emit()
	else:
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.MAP)

func populatePartyStats():
	# Clean up the grid
	for label in %PartyStatsGrid.get_children():
		%PartyStatsGrid.remove_child(label)
		label.queue_free()

	# Re-populate the party stats
	var partyStatsLabel = Label.new()
	partyStatsLabel.theme = preload("res://Themes/overall_theme.tres")
	partyStatsLabel.text = PartyController.party_stats()
	%PartyStatsGrid.add_child(partyStatsLabel)
	for member in PartyController.party.members:
		var teamMemberLabel = Label.new()
		teamMemberLabel.theme = preload("res://Themes/overall_theme.tres")
		teamMemberLabel.text = member.to_string()
		%PartyStatsGrid.add_child(teamMemberLabel)

func _on_advance_day_done() -> void:
	if has_node("/root/Location"):
		var location_node = get_node("/root/Location")
		%ActivitySummaryOverlay.update_ui(UiEvents.UiScene.CAMPFIRE)

func _on_inventory_button_pressed() -> void:
	var inv_input = InputEventAction.new()
	inv_input.action = "Toggle Inventory"
	inv_input.pressed = true
	Input.parse_input_event(inv_input)
