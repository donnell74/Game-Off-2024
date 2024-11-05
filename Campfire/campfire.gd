extends Node2D

func _ready() -> void:
	# TODO: Remove this test code once we have UI
	print("Party Health: %d" % PartyController.get_total_party_health())
	print("Party Strength: %d" % PartyController.get_total_party_strength())
	print("Party Stamina: %d" % PartyController.get_total_party_stamina())

func _on_continue_day_button_pressed() -> void:
	print("Campfire - _on_continue_day_button_pressed")
	if has_node("/root/Location"):
		LocationEvents.advance_day.emit()
	else:
		# show map
		var map = $"/root/Main/Map"
		if map and map.has_method("show_map"):
			map.show_map()
		else:
			print("Unable to show map.")
		
		var campfire = $"/root/Main/Campfire"
		campfire.visible = false
