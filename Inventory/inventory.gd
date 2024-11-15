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
	var regex = RegEx.new()
	var pattern = regex.compile("\\((?<pos_x>\\d+), (?<pos_y>\\d+)\\)")
	for each_item_key in load_data["inventory"]["items"]:
		var item_data = load_data["inventory"]["items"][each_item_key]
		var result = regex.search(each_item_key)
		if result:
			var index = Vector2(result.get_string("pos_x").to_int(), result.get_string("pos_y").to_int())
			if "root_node" in item_data:
				items[index] = InventoryItemSlotRef.from_values(item_data)
			else:
				items[index] = InventoryItem.from_values(item_data)
