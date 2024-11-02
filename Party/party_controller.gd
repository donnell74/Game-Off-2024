extends Node2D

enum Stats {
	STRENGTH,
	STAMINA,
	HEALTH
}

@export var party: Party = preload("res://Party/First Party/first_party.tres")

func update_stat_multiplier(stats: Stats, new_multiplier: float) -> void:
	match stats:
		Stats.STRENGTH:
			party.strength_multiplier = new_multiplier
		Stats.STAMINA:
			party.stamina_multiplier = new_multiplier
		Stats.HEALTH:
			party.health_multiplier = new_multiplier

func get_total_party_health() -> float:
	var total_health = 0.0
	for each_member in party.members:
		total_health += each_member.health
	
	return total_health * party.health_multiplier

func get_total_party_strength() -> float:
	var total_strength = 0.0
	for each_member in party.members:
		total_strength += each_member.strength
	
	return total_strength * party.strength_multiplier

func get_total_party_stamina() -> float:
	var total_stamina = 0.0
	for each_member in party.members:
		total_stamina += each_member.stamina
	
	return total_stamina * party.stamina_multiplier
