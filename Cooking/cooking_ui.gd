extends Control

func _ready() -> void:
	var potato = PlayerInventoryController.take_item(0)
	print("Potato: %s with quantity: %d" % [potato.name, potato.quantity])
	var butter = PlayerInventoryController.take_item(0, 2)
	print("Butter: %s with quantity: %d" % [butter.name, butter.quantity])
	
	%CuttingBoard.add_item(potato)
	%CuttingBoard.chop()
	
	%CookingPot.add_item(butter)
	%CookingPot.melt()
