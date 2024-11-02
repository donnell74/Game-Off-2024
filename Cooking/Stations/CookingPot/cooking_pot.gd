extends Station

func _ready() -> void:
	var potato = InventoryController.take_item(0)
	print("Potato: %s with quantity: %d" % [potato.name, potato.quantity])
	var butter = InventoryController.take_item(0, 2)
	print("Butter: %s with quantity: %d" % [butter.name, butter.quantity])
	
	perform(0, "cook", {PartyController.Stats.STRENGTH: 1.1})
