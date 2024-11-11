extends Control
class_name InventoryController

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource

func add_item(item: InventoryItem) -> void:
	var index = 0
	while index < inventory.capacity:
		if not inventory.items.has(index):
			break
		
		index += 1

	print("Adding item to inventory: %s at index: %d" % [item.name, index])
	inventory.items[index] = item
	inventory.inventory_updated.emit()

func get_item(index: int) -> InventoryItem:
	if not inventory.items.has(index):
		return null

	return inventory.items[index]

func take_item(search_name: String) -> InventoryItem:
	for item_index in range(inventory.capacity):
		if inventory.items.has(item_index) and inventory.items[item_index].name == search_name:
			var item = inventory.items[item_index]
			inventory.items.erase(item_index)
			inventory.inventory_updated.emit()
			return item
	
	return null

func take_item_index(item_index: int) -> InventoryItem:
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
