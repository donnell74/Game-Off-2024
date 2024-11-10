extends Resource
class_name Recipe

@export var input: Array[InventoryItem]
@export var output: Array[InventoryItem]
@export var action: Actions.Actions
@export var times_cooked: int = 0
