extends Station

func _ready() -> void:
	perform_method_map[Actions.Actions.CHOP] = chop
	perform_method_map[Actions.Actions.DICE] = dice
	perform_method_map[Actions.Actions.WAIT] = wait

func add_item(item: InventoryItem) -> void:
	print("Adding %s to cutting board" % item.name)
	super(item)
	print("CuttingBoard.add_item => New inventory: %s" % to_string())

func chop() -> void:
	perform_combination(Actions.Actions.CHOP, ItemModifier.from_values(1.0, 1.1, 1.0))
	print("CuttingBoard.chop => New inventory: %s" % to_string())

func dice() -> void:
	perform_combination(Actions.Actions.DICE, ItemModifier.from_values(1.0, 1.1, 1.0))
	print("CuttingBoard.dice => New inventory: %s" % to_string())
	

func wait() -> void:
	perform_combination(Actions.Actions.WAIT, ItemModifier.from_values(1.0, 1.1, 1.0))
	print("CuttingBoard.wait => New inventory: %s" % to_string())
