extends Node2D

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	PartyController.party_stats_changed.connect(populatePartyStats)
	Dialogic.timeline_started.connect(_on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_stopped)
	
	populatePartyStats()

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.CAMPFIRE:
			visible = true
			$ContinueDayButton.grab_focus()
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
		UiEvents.UiScene.SETTINGS, UiEvents.UiScene.INVENTORY, UiEvents.UiScene.RECIPE_BOOK:
			pass # overlay, do nothing
		_:
			%AmbienceSound.stop()
			visible = false

func _on_dialogic_timeline_started() -> void:
	%ContinueDayButton.disabled = true

func _on_dialogic_timeline_stopped() -> void:
	%ContinueDayButton.disabled = false

func _on_continue_day_button_pressed() -> void:
	print("Campfire - _on_continue_day_button_pressed")
	
	if has_node("/root/Location"):
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
	partyStatsLabel.text = PartyController.party_stats()
	%PartyStatsGrid.add_child(partyStatsLabel)
	for member in PartyController.party.members:
		var teamMemberLabel = Label.new()
		teamMemberLabel.text = member.to_string()
		%PartyStatsGrid.add_child(teamMemberLabel)
