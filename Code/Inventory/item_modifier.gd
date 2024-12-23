extends Resource
class_name ItemModifier

@export var health : float = 1.0
@export var stamina : float = 1.0
@export var strength : float = 1.0

static func from_values(_health: float, _stamina: float, _strength: float) -> ItemModifier:
	var result = ItemModifier.new()
	result.health = _health
	result.stamina = _stamina
	result.strength = _strength
	return result

func _to_string() -> String:
	return "Health: %f\nStamina: %f\nStrength: %f" % [health, stamina, strength]

func add(other: ItemModifier) -> ItemModifier:
	if !other:
		return self
	
	health += other.health
	stamina += other.stamina
	strength += other.strength
	return self
	
func divide(value: int) -> ItemModifier:
	health /= value
	stamina /= value
	strength /= value
	return self

func multiply(other: ItemModifier) -> ItemModifier:
	if !other:
		return self
	
	health *= other.health
	stamina *= other.stamina
	strength *= other.strength
	return self

func save() -> Dictionary:
	var save_map = {
		"health": health,
		"stamina": stamina,
		"strength": strength
	}
	return save_map
