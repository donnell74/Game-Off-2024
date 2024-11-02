extends Node2D

func _ready() -> void:
	# TODO: Remove this test code once we have UI
	print("Party Health: %d" % PartyController.get_total_party_health())
	print("Party Strength: %d" % PartyController.get_total_party_strength())
	print("Party Stamina: %d" % PartyController.get_total_party_stamina())
	PartyController.update_stat_multiplier(PartyController.Stats.STRENGTH, 1.1)
	PartyController.update_stat_multiplier(PartyController.Stats.STAMINA, 1.2)
	PartyController.update_stat_multiplier(PartyController.Stats.HEALTH, 1.5)
	print("Party Health: %d" % PartyController.get_total_party_health())
	print("Party Strength: %d" % PartyController.get_total_party_strength())
	print("Party Stamina: %d" % PartyController.get_total_party_stamina())
