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
	return "Health: %f, Stamina: %f, Strength: %f" % [health, stamina, strength]

func multiply(other: ItemModifier) -> ItemModifier:
	if !other:
		return self
	
	health *= other.health
	stamina *= other.stamina
	strength *= other.strength
	return self
