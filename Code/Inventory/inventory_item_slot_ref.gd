extends Resource
class_name InventoryItemSlotRef

@export var root_node : InventoryItem = null
@export var root_node_type : InventoryItem.ItemType

func save() -> Dictionary:
	var save_map = {
		"root_node": root_node.save(),
		"root_node_type": root_node_type
	}
	return save_map

static func from_values(from: Dictionary) -> InventoryItemSlotRef:
	var each_ref = InventoryItemSlotRef.new()
	each_ref.root_node = InventoryItem.from_values(from["root_node"])
	each_ref.root_node_type = from["root_node_type"]
	
	return each_ref
