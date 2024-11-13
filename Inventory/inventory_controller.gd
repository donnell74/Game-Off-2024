extends Control
class_name InventoryController

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource

func _ready() -> void:
	fill_refs()

func fill_refs() -> void:
	for key in inventory.items:
		var item_slot = inventory.items[key] as InventoryItem
		if not item_slot:
			continue
		
		if item_slot.inventory_width == 1 and item_slot.inventory_height == 1:
			continue
		
		for pos_x in range(item_slot.inventory_width):
			for pos_y in range(item_slot.inventory_height):
				if pos_x == 0 and pos_y == 0:
					continue

				var ref_location = Vector2(pos_x, pos_y) + key				
				var ref = InventoryItemSlotRef.new()
				ref.root_node = item_slot
				ref.root_node_type = item_slot.type
				if inventory.items.has(ref_location):
					print("fill_refs - Overwriting item at %s with other item" % ref_location)
					
				inventory.items[ref_location] = ref

func add_item(item: InventoryItem) -> void:
	var index = Vector2.ZERO
	for pos_x in inventory.width:
		for pos_y in inventory.height:
			index = Vector2(pos_x, pos_y)
			if not inventory.items.has(index):
				break
			
			index += 1

	print("Adding item to inventory: %s at index: %s" % [item.name, index.to_string()])
	inventory.items[index] = item
	inventory.inventory_updated.emit()

func can_place_item(index: int, item: InventoryItem) -> bool:
	for inv_x in item.inventory_width:
		for inv_y in item.inventory_height:
			# if index + inv_x + inv_y in space is not free
			return false
	
	return true

func get_item(index: Vector2) -> Resource:
	if not inventory.items.has(index):
		return null

	return inventory.items[index]

func take_item(search_name: String) -> Resource:
	for item_index in range(inventory.capacity):
		if inventory.items.has(item_index) and inventory.items[item_index].name == search_name:
			var item = inventory.items[item_index]
			inventory.items.erase(item_index)
			inventory.inventory_updated.emit()
			return item
	
	return null

func take_item_index(item_index: int) -> Resource:
	if not inventory.items.has(item_index):
		return null

	print(inventory.resource_name, " is called with take_item_index: ", item_index)
	var item = inventory.items[item_index]
	inventory.items.erase(item_index)
	inventory.inventory_updated.emit()
	return item

func clear_inventory() -> void:
	inventory.items = {}
	inventory.inventory_updated.emit()

func _to_string() -> String:
	var inventory_string = "["
	for each_item in inventory.items:
		inventory_string += "%s, " % inventory.items[each_item].name
	
	inventory_string = inventory_string.substr(0, inventory_string.length() - 2) + "]"
	return inventory_string

func save() -> Dictionary:
	var save_dict = {
		SaveLoad.PATH_FROM_ROOT_KEY: get_path(),
		"inventory": inventory.save()
	}
	
	return save_dict

func load(load_data: Dictionary) -> void:
	inventory.load(load_data)
	inventory.inventory_updated.emit()
