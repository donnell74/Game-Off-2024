extends Resource
class_name InventoryItem

@export var name : String = "<Unknown>"
@export var texture : Texture2D
@export var modifiers : ItemModifier = ItemModifier.new()

func equals(other: InventoryItem, ignoreModifier: bool) -> bool:
	if name != other.name:
		return false
	
	if !ignoreModifier:
		if modifiers.health != other.modifiers.health:
			return false
		
		if modifiers.stamina != other.modifiers.stamina:
			return false
		
		if modifiers.strength != other.modifiers.strength:
			return false
	
	return true
