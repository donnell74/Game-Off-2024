extends Station

func add_item(item: InventoryItem) -> void:
	print("Adding %s to cooking pot" % item.name)
	super(item)
	print("CookingPot.add_item => New inventory: %s" % to_string())

func melt() -> void:
	perform_combination(Actions.Actions.MELT, {PartyController.Stats.HEALTH: 1.1})
	print("CookingPot.melt => New inventory: %s" % to_string())

func boil() -> void:
	perform_combination(Actions.Actions.BOIL, {PartyController.Stats.STRENGTH: 1.1})
	print("CookingPot.boil => New inventory: %s" % to_string())

func mash() -> void:
	perform_combination(Actions.Actions.MASH, {PartyController.Stats.STAMINA: 1.1})
	print("CookingPot.mash => New inventory: %s" % to_string())
