extends Resource
class_name Inventory

@warning_ignore("unused_signal")
signal inventory_updated

@export var items : Array[InventoryItem] = []

func save() -> Dictionary:
	var save_map = { "items": items.map(func(i): return i.save()) }
	return save_map

func load(load_data: Variant) -> void:
	var new_items: Array[InventoryItem] = []
	for each_item_data in load_data["inventory"]["items"]:
		new_items.append(InventoryItem.from_values(each_item_data))
	
	items = new_items
