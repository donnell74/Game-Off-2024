extends Node2D

enum Stats {
	STRENGTH,
	STAMINA,
	HEALTH
}

@export var party: Party = preload("res://Party/First Party/first_party.tres")

func get_total_party_health() -> float:
	var total_health = 0.0
	for each_member in party.members:
		total_health += each_member.health
	
	return total_health

func get_total_party_strength() -> float:
	var total_strength = 0.0
	for each_member in party.members:
		total_strength += each_member.strength
	
	return total_strength

func get_total_party_stamina() -> float:
	var total_stamina = 0.0
	for each_member in party.members:
		total_stamina += each_member.stamina
	
	return total_stamina

func get_max_party_level() -> int:
	var max_level = 1
	for each_member in party.members:
		max_level = max(max_level, each_member.level)
	
	return max_level

func feed_party_item(item: InventoryItem) -> void:
	print("PartyController - feed-party-item with: %s" % item.name)
	print("PartyController - Modifiers: %s" % item.modifiers)
	if !item.modifiers:
		item.modifiers = ItemModifier.new()
	
	apply_to_each_member(Stats.HEALTH, item.modifiers.health)
	apply_to_each_member(Stats.STRENGTH, item.modifiers.strength)
	apply_to_each_member(Stats.STAMINA, item.modifiers.stamina)
	print(self)

func apply_to_each_member(stat: Stats, amount: float) -> void:
	for member in party.members:
		match stat:
			Stats.STRENGTH:
				member.multiply_strength(amount)
			Stats.STAMINA:
				member.multiply_stamina(amount)
			Stats.HEALTH:
				member.multiply_health(amount)

func apply_party_damage(stat: Stats, amount: float) -> void:
	var damagePerIteration = get_max_party_level() # so we spread out the damage but don't iterate 1 by 1
	while amount > 0.0:
		damagePerIteration = min(damagePerIteration, amount)
		var rng = RandomNumberGenerator.new()
		var damagedMember = party.members[rng.randi_range(0, party.members.size() - 1)]
		print("Damaging member: %s for stat: %s for ammount: %d" % [damagedMember.name, Stats.keys()[stat], amount])
		match stat:
			Stats.STRENGTH:
				damagedMember.decrement_strength(damagePerIteration)
			Stats.STAMINA:
				damagedMember.decrement_stamina(damagePerIteration)
			Stats.HEALTH:
				damagedMember.decrement_health(damagePerIteration)
		
		amount -= damagePerIteration

func _to_string() -> String:
	var result = "Team: Level: %d, Health: %d, Strength: %d, Stamina: %d\n" % \
		[get_max_party_level(), get_total_party_health(), get_total_party_strength(), get_total_party_stamina()]
	for each_member in party.members:
		result += each_member.to_string() + "\n"
	
	return result
