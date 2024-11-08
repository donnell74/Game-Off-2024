extends Station

func _ready() -> void:
	perform_method_map[Actions.Actions.MELT] = melt
	perform_method_map[Actions.Actions.BOIL] = boil
	perform_method_map[Actions.Actions.MASH] = mash
	perform_method_map[Actions.Actions.MIX] = mix

func add_item(item: InventoryItem) -> void:
	print("Adding %s to cooking pot" % item.name)
	super(item)
	print("CookingPot.add_item => New inventory: %s" % to_string())

func melt() -> void:
	perform_combination(Actions.Actions.MELT, ItemModifier.from_values(1.1, 1.0, 1.0))
	print("CookingPot.melt => New inventory: %s" % to_string())

func boil() -> void:
	perform_combination(Actions.Actions.BOIL, ItemModifier.from_values(1.0, 1.0, 1.1))
	print("CookingPot.boil => New inventory: %s" % to_string())

func mash() -> void:
	perform_combination(Actions.Actions.MASH, ItemModifier.from_values(1.0, 1.1, 1.0))
	print("CookingPot.mash => New inventory: %s" % to_string())
	
func mix() -> void:
	perform_combination(Actions.Actions.MIX, ItemModifier.from_values(1.0, 1.05, 1.05))
	print("CookingPot.mix => New inventory: %s" % to_string())
