extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Inventory"):
		%InventoryCanvas.visible = !%InventoryCanvas.visible

func _ready() -> void:
	%ItemList.clear()
	for each_item in PlayerInventoryController.inventory.items:
		%ItemList.add_item(each_item.name)

func _on_close_button_pressed() -> void:
	print("Inventory close button clicked, hiding inventory ui")
	%InventoryCanvas.visible = false
