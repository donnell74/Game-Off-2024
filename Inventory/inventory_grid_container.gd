extends InventoryController

signal selected_indexes_updated

@export var slot_scene : Resource = preload("res://Inventory/inventory_item_slot.tscn")
@export var width : int = 20
@export var height : int = 8
@export var selected_slots : Array[int] = []

func _ready() -> void:
	generate_inventory_grid()

func set_inventory(newInventory: Inventory) -> void:
	if inventory and inventory.inventory_updated.is_connected(generate_inventory_grid):
		inventory.inventory_updated.disconnect(generate_inventory_grid)

	inventory = newInventory
	if newInventory:
		newInventory.inventory_updated.connect(generate_inventory_grid)
		generate_inventory_grid()

func generate_inventory_grid() -> void:
	print("generate_inventory_grid with inventory: ", inventory.items)
	clear_inventory_grid()
	$".".columns = width
	if not inventory:
		return

	for index in range(width * height):
		var slot = slot_scene.instantiate()
		slot.name = "InventoryItemSlot - %d" % index
		slot.index = index
		var item_for_slot = get_item(index)
		if item_for_slot and item_for_slot.texture:
			slot.get_node("Icon").texture = item_for_slot.texture
	
		slot.inventory_item_slot_clicked.connect(_on_inventory_item_slot_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		add_child(slot)

func _on_inventory_item_slot_clicked(index: int) -> void:
	var selected_position = selected_slots.find(index)
	if selected_position == -1:
		selected_slots.append(index)
	else:
		selected_slots.remove_at(selected_position)
	
	selected_indexes_updated.emit()

func _on_slot_right_clicked(index: int) -> void:
	var selected_station_item = get_item(index)
	var selected_indexes = get_selected_items()
	var selected_items : Array[InventoryItem] = []
	for each_selected in selected_indexes:
		var each_item = get_item(each_selected)
		print("Selected items[%d]: %s" % [each_selected, each_item.name])
		selected_items.append(each_item)
	
	var output = StationController.perform(selected_station_item.name, selected_items)
	if output.size() != 0:
		for each_selected in selected_indexes:
			take_item_index(each_selected)
		
		for each_output in output:
			add_item(each_output)

func clear_inventory_grid() -> void:
	for child in get_children():
		if child.inventory_item_slot_clicked.is_connected(_on_inventory_item_slot_clicked):
			child.inventory_item_slot_clicked.disconnect(_on_inventory_item_slot_clicked)
		
		child.queue_free()

func get_selected_items() -> Array[int]:
	var selected_index : Array[int] = []
	for index in range(width * height):
		var slot = get_child(index)
		if slot.selected:
			selected_index.append(index)
	
	print("get_selected_items: ", selected_index)
	return selected_index
