extends InventoryController

signal item_selected(index: int)

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	%ItemList.focus_neighbor_left = "../%s" % focus_neighbor_left
	%ItemList.focus_neighbor_top = "../%s" % focus_neighbor_top
	%ItemList.focus_neighbor_right = "../%s" % focus_neighbor_right
	%ItemList.focus_neighbor_bottom = "../%s" % focus_neighbor_bottom
	%ItemList.focus_next = "../%s" % focus_next
	%ItemList.focus_previous = "../%s" % focus_previous
	if inventory:
		inventory.inventory_updated.connect(update_inventory_item_list)

func _on_focus_changed(control: Control) -> void:
	if control.has_method("pass_focus_to_child"):
		pass_focus_to_child(%ItemList)

func pass_focus_to_child(control: Control) -> void:
	control.grab_focus()

func get_item_count() -> int:
	return %ItemList.item_count

func get_item(index) -> InventoryItem:
	return inventory.items[index]

func clear() -> void:
	%ItemList.clear()

func get_selected_items() -> Array:
	return %ItemList.get_selected_items()

func get_item_text(index: int) -> String:
	return %ItemList.get_item_text(index)

func set_inventory(newInventory: Inventory) -> void:
	if inventory and inventory.inventory_updated.is_connected(update_inventory_item_list):
		inventory.inventory_updated.disconnect(update_inventory_item_list)

	inventory = newInventory
	if newInventory:
		newInventory.inventory_updated.connect(update_inventory_item_list)
		update_inventory_item_list()

func update_inventory_item_list() -> void:	
	print(name, " - update_inventory_item_list")
	clear()
	var counts : Dictionary = {}
	for each_item in inventory.items:
		if each_item.name in counts:
			counts[each_item.name] += 1
		else:
			counts[each_item.name] = 1

	for item_name in counts:
		%ItemList.add_item("%dx %s" % [counts[item_name], item_name])

func get_selected_item_name() -> String:
	var selected_index = %ItemList.get_selected_items()[0]
	var selected_text = %ItemList.get_item_text(selected_index)
	return selected_text.substr(selected_text.find("x") + 2)

func _on_item_list_item_selected(index: int) -> void:
	item_selected.emit(index)
