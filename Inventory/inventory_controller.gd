extends Node
class_name InventoryController

signal inventory_updated

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource

func add_item(item: InventoryItem) -> void:
	print("Adding item to inventory: %s" % item.name)
	inventory.items.append(item)
	inventory_updated.emit()

func take_item(item_index: int) -> InventoryItem:
	if item_index >= inventory.items.size():
		print("Invalid index of inventory: %d when size is %d" % [item_index, inventory.items.size()])
		return null

	var item = inventory.items.pop_at(item_index)
	inventory_updated.emit()
	return item

func clear_inventory() -> void:
	inventory.items = []
	inventory_updated.emit()

func _to_string() -> String:
	var inventory_string = "["
	for each_item in inventory.items:
		inventory_string += "%s, " % each_item.name
	
	inventory_string = inventory_string.substr(0, inventory_string.length() - 2) + "]"
	return inventory_string
