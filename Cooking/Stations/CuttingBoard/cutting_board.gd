extends Station

func add_item(item: InventoryItem) -> void:
	print("Adding %s to cutting board" % item.name)
	super(item)
	print("CuttingBoard.add_item => New inventory: %s" % to_string())

func chop() -> void:
	perform_single(0, "Chopped", {PartyController.Stats.STAMINA: 1.1})
	print("CuttingBoard.chop => New inventory: %s" % to_string())
