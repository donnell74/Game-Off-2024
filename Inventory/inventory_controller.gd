extends Node
class_name InventoryController

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource

func add_item(item: InventoryItem) -> void:
	# TODO handle stacks
	inventory.items.append(item)

func take_item(item_index: int, quantity_needed: int = 1) -> InventoryItem:
	if item_index >= inventory.items.size():
		print("Invalid index of inventory: %d when size is %d" % [item_index, inventory.items.size()])
		return null

	if inventory.items[item_index].quantity < quantity_needed:
		print("Not enough quantity of the item to meet quantity_needed: %d vs %d" % [inventory.items[item_index].quantity, quantity_needed])
		return null
	elif inventory.items[item_index].quantity == quantity_needed:
		return inventory.items.pop_at(item_index)
	else:
		inventory.items[item_index].quantity -= quantity_needed
		var item = inventory_item_resource.new()
		item.name = inventory.items[item_index].name
		item.quantity = quantity_needed
		item.texture = inventory.items[item_index].texture
		return item


func _to_string() -> String:
	var inventory_string = "["
	for each_item in inventory.items:
		inventory_string += "%s, " % each_item.name
	
	inventory_string = inventory_string.substr(0, inventory_string.length() - 2) + "]"
	return inventory_string
