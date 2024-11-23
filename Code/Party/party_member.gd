extends Resource
class_name PartyMember

@export var name : String = "<Unknown>"
@export var base_health : float = 100.0
@export var base_stamina : float = 100.0
@export var base_strength : float = 100.0
@export var health : float = 100.0
@export var stamina : float = 100.0
@export var strength : float = 100.0
@export var level : int = 1

func decrement_health(amount: float) -> float:
	health -= amount
	var extra = 0
	if health < 0:
		extra = health * -1 # -3 health means we have 3 extra or multiply by -1
		health = 0
	
	return extra

func decrement_stamina(amount: float) -> float:
	stamina -= amount
	var extra = 0
	if stamina < 0:
		extra = stamina * -1 # -3 health means we have 3 extra or multiply by -1
		stamina = 0
	
	return extra

func decrement_strength(amount: float) -> float:
	strength -= amount
	var extra = 0
	if strength < 0:
		extra = strength * -1 # -3 health means we have 3 extra or multiply by -1
		strength = 0
	
	return extra

func apply_strength_modifier(amount: float) -> void:
	strength += amount * base_strength

func apply_stamina_modifier(amount: float) -> void:
	stamina += amount * base_stamina

func apply_health_modifier(amount: float) -> void:
	health += amount * base_health

func _to_string() -> String:
	return "%s: Level: %d, Health: %d, Stamina: %d, Strength: %d" % \
			[name, level, health, stamina, strength]