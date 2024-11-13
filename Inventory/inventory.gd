extends Resource
class_name Inventory

@warning_ignore("unused_signal")
signal inventory_updated

@export var width : int = 10
@export var height : int = 4
@export var items : Dictionary = {}

func save() -> Dictionary:
	var save_map = { "items": {} }
	for item_key in items:
		save_map["items"][item_key] = items[item_key].save()
	
	return save_map

func load(load_data: Variant) -> void:
	for each_item_key in load_data["inventory"]["items"]:
		items[each_item_key] = InventoryItem.from_values(
			load_data["inventory"]["items"][each_item_key])
