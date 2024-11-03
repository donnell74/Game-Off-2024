extends Station

func _ready() -> void:
	perform_method_map[Actions.Actions.CHOP] = chop
	perform_method_map[Actions.Actions.DICE] = dice

func add_item(item: InventoryItem) -> void:
	print("Adding %s to cutting board" % item.name)
	super(item)
	print("CuttingBoard.add_item => New inventory: %s" % to_string())

func chop() -> void:
	perform_combination(Actions.Actions.CHOP, {PartyController.Stats.STAMINA: 1.1})
	print("CuttingBoard.chop => New inventory: %s" % to_string())

func dice() -> void:
	perform_combination(Actions.Actions.DICE, {PartyController.Stats.STAMINA: 1.1})
	print("CuttingBoard.dice => New inventory: %s" % to_string())
