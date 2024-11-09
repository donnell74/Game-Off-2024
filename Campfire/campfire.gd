extends Node2D

func _ready() -> void:
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	PartyController.party_stats_changed.connect(populatePartyStats)
	
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
		UiEvents.UiScene.SETTINGS, UiEvents.UiScene.INVENTORY:
			pass # overlay, do nothing
		_:
			%AmbienceSound.stop()
			visible = false

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
