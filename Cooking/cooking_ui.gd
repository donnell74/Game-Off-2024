extends Control

func _ready() -> void:
	var potato = PlayerInventoryController.take_item(0)
	print("Potato: %s" % [potato.name])
	var butter = PlayerInventoryController.take_item(0)
	print("Butter: %s" % [butter.name])
	
	%CuttingBoard.add_item(potato)
	%CuttingBoard.dice()
	var diced_potatoes = %CuttingBoard.take_item(0)
	
	%CookingPot.add_item(butter)
	%CookingPot.melt()
	var melted_butter = %CookingPot.take_item(0)
	
	%CookingPot.add_item(diced_potatoes)
	%CookingPot.boil()
	%CookingPot.add_item(melted_butter)
	%CookingPot.mash()
