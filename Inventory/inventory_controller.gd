extends Node
class_name InventoryController

signal inventory_updated

@export var inventory : Inventory = preload("res://Inventory/player_inventory.tres")
@export var inventory_item_resource : Resource

func add_item(item: InventoryItem) -> void:
	# TODO handle stacks
	inventory.items.append(item)
	inventory_updated.emit()

func take_item(item_index: int, quantity_needed: int = 1) -> InventoryItem:
	if item_index >= inventory.items.size():
		print("Invalid index of inventory: %d when size is %d" % [item_index, inventory.items.size()])
		return null

	# TODO: Implement item stacks for quantity
	#if inventory.items[item_index].quantity < quantity_needed:
		#print("Not enough quantity of the item to meet quantity_needed: %d vs %d" % [inventory.items[item_index].quantity, quantity_needed])
		#return null
	#elif inventory.items[item_index].quantity == quantity_needed:
	var item = inventory.items.pop_at(item_index)
	inventory_updated.emit()
	return item
	#else:
		#inventory.items[item_index].quantity -= quantity_needed
		#var item = inventory_item_resource.new()
		#item.name = inventory.items[item_index].name
		#item.quantity = quantity_needed
		#item.texture = inventory.items[item_index].texture
		#item.transistions = inventory.items[item_index].transistions
		#return item

func clear_inventory() -> void:
	inventory.items = []
	inventory_updated.emit()

func _to_string() -> String:
	var inventory_string = "["
	for each_item in inventory.items:
		inventory_string += "%s, " % each_item.name
	
	inventory_string = inventory_string.substr(0, inventory_string.length() - 2) + "]"
	return inventory_string
