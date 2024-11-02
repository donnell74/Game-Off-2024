extends Station

func add_item(item: InventoryItem) -> void:
	print("Adding %s to cooking pot" % item.name)
	super(item)
	print("CookingPot.add_item => New inventory: %s" % to_string())

func melt() -> void:
	perform_single(0, "Melted", {PartyController.Stats.HEALTH: 1.1})
	print("CookingPot.melt => New inventory: %s" % to_string())

func cook() -> void:
	perform_single(0, "Cooked", {PartyController.Stats.STRENGTH: 1.1})
	print("CookingPot.chop => New inventory: %s" % to_string())
