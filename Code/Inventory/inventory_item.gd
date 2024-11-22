extends Resource
class_name InventoryItem

enum ItemType {
	ITEM,
	STATION
}

@export var name : String = "<Unknown>"
@export var texture : Texture2D
@export var modifiers : ItemModifier = ItemModifier.new()
# Lower rarity means smaller change of being selected
@export var rarity: float = 1.0
@export var value: int = 10
@export var type: ItemType = ItemType.ITEM
@export var inventory_width : int = 1
@export var inventory_height : int = 1

func equals(other: InventoryItem, ignoreModifier: bool) -> bool:
	if not other:
		return false
	
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

func save() -> Dictionary:
	var save_map = {
		"name": name,
		"texture": texture.resource_path if texture else "",
		"rarity": rarity,
		"type": type,
		"value": value,
		"inventory_height": inventory_height,
		"inventory_width": inventory_width,
		"modifiers": modifiers.save()
	}
	return save_map

static func from_values(from: Dictionary) -> InventoryItem:
	var each_item = InventoryItem.new()
	each_item.name = from["name"]
	each_item.rarity = from["rarity"]
	each_item.type = from["type"]
	each_item.value = from["value"]
	each_item.inventory_height = from["inventory_height"]
	each_item.inventory_width = from["inventory_width"]
	if from["texture"]:
		each_item.texture = load(from["texture"])

	var mod_data = from["modifiers"]
	each_item.modifiers = ItemModifier.from_values(mod_data["health"], mod_data["stamina"], mod_data["strength"])
	return each_item
