extends Resource
class_name Party

@export var strength_multiplier : float = 1.0 # Strength == Protein
@export var stamina_multiplier : float = 1.0 # Stamina == Carbs
@export var health_multiplier : float = 1.0 # Health == Fat
@export var members: Array[PartyMember] = []
