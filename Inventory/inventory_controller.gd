extends Control
class_name InventoryController

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource

func add_item(item: InventoryItem) -> void:
	print("Adding item to inventory: %s" % item.name)
	inventory.items.append(item)
	inventory.inventory_updated.emit()

func take_item(search_name: String) -> InventoryItem:
	for item_index in range(inventory.items.size()):
		if inventory.items[item_index].name == search_name:
			var item = inventory.items.pop_at(item_index)
			inventory.inventory_updated.emit()
			return item

	return null

func take_item_index(item_index: int) -> InventoryItem:
	if item_index >= inventory.items.size():
		print("Invalid index of inventory: %d when size is %d" % [item_index, inventory.items.size()])
		return null

	var item = inventory.items.pop_at(item_index)
	inventory.inventory_updated.emit()
	return item

func clear_inventory() -> void:
	inventory.items = []
	inventory.inventory_updated.emit()
	
func sort_by_name():
	inventory.items.sort_custom(_by_name)
	
func _by_name(a: InventoryItem, b: InventoryItem):
	if a.name > b.name:
		return false
	return true

func _to_string() -> String:
	var inventory_string = "["
	for each_item in inventory.items:
		inventory_string += "%s, " % each_item.name
	
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
