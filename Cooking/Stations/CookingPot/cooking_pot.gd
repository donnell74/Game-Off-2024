extends Station

func _ready() -> void:
	perform(0, "cook", {PartyController.Stats.STRENGTH: 1.1})
