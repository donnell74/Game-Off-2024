extends Control

@export var inventory : Inventory
@export var item : InventoryItem
@export var left_position : Vector2
@export var right_position : Vector2
@export var on_right_side : bool = true
@export var full_star_threshold : float = 0.5
@export var half_star_threshold : float = 0.25
@export var stars_per_stat : int = 6

func _ready() -> void:
	if not has_node("/root/Main"): # for debugging
		item = preload("res://Inventory/Items/maki_with_monster_masago.tres")
		item.modifiers = ItemModifier.from_values(2.5, 2.25, 1.75)
		update()

func update() -> void:
	%ItemTexture.texture = item.texture
	%ItemNameLabel.text = item.name
	set_stars(%HealthContainer, item.modifiers.health)
	set_stars(%StaminaContainer, item.modifiers.stamina)
	set_stars(%StrengthContainer, item.modifiers.strength)

func set_stars(container: Control, amount: float) -> void:
	for each_child in container.get_children():
		if each_child is TextureRect:
			each_child.queue_free()
	
	for each_star in range(1, stars_per_stat + 1):
		var new_star = %StarTextureRect.duplicate()
		new_star.texture = %StarTextureRect.texture.duplicate()
		new_star.visible = true
		if amount > (each_star * full_star_threshold):
			new_star.texture.region.position.x = 0
		elif amount - (each_star * full_star_threshold) >= half_star_threshold:
			new_star.texture.region.position.x = 16

		container.add_child(new_star)

func updated_selected(slot_index: Vector2) -> void:
	if not inventory or not inventory.items.has(slot_index):
		visible = false
		return
	
	visible = true
	item = inventory.items[slot_index].deref()
	update()
	on_right_side = slot_index.x > ceil(inventory.width / 2)
	if on_right_side:
		global_position = left_position
	else:
		global_position = right_position

func set_inventory(new: Inventory) -> void:
	inventory = new

func set_inventory_slot_clicked_signal(clicked_signal: Signal) -> void:
	clicked_signal.connect(updated_selected)

func set_inventory_slot_hovered_signal(hovered_signal: Signal) -> void:
	hovered_signal.connect(updated_selected)
