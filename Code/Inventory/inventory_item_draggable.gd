extends Control

@export var item : InventoryItem
@export var original_index : Vector2 
@export var offset : Vector2 = Vector2(2,2) # small offset needed for onclick to work

func update() -> void:
	if item:
		%Icon.texture = item.texture

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos:
		global_position = mouse_pos + offset
