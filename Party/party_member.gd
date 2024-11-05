extends Resource
class_name PartyMember

@export var name : String = "<Unknown>"
@export var health : float = 100.0
@export var stamina : float = 100.0
@export var strength : float = 100.0
@export var level : int = 1

func decrement_health(amount: float) -> void:
	health -= amount

func decrement_stamina(amount: float) -> void:
	stamina -= amount

func decrement_strength(amount: float) -> void:
	strength -= amount

func multiply_strength(amount: float) -> void:
	strength *= amount

func multiply_stamina(amount: float) -> void:
	stamina *= amount

func multiply_health(amount: float) -> void:
	health *= amount

func _to_string() -> String:
	return "%s: Level: %d, Health: %d, Stamina: %d, Strength: %d" % \
			[name, level, health, stamina, strength]
