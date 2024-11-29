extends Control

@export var location : Location
@export var left_position : Vector2
@export var right_position : Vector2
@export var on_right_side : bool = true
@export var full_star_threshold : float = 50
@export var half_star_threshold : float = 25
@export var stars_per_stat : int = 6
@export var health_cost : float = 0.0
@export var stamina_cost : float = 0.0
@export var strength_cost : float = 0.0
@export var reward_items : Array[InventoryItem] = []

func _ready() -> void:
	full_star_threshold = PartyController.get_total_party_health() / stars_per_stat
	if not has_node("/root/Main"): # for debugging
		updated_selected(preload("res://Locations/Dungeon/slime_king_dungeon.tres"))

func update() -> void:
	%LocationNameLabel.text = location.description
	set_stars(%HealthContainer, health_cost)
	set_stars(%StaminaContainer, stamina_cost)
	set_stars(%StrengthContainer, strength_cost)
	add_reward_items(%RewardItemsContainer)

func add_reward_items(container: Control) -> void:
	for each_child in container.get_children():
		if each_child is TextureRect:
			each_child.queue_free()

	for each_item in reward_items:
		var new_star = %RewardTextureRect.duplicate()
		new_star.texture = each_item.texture
		new_star.visible = true
		container.add_child(new_star)

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

func reset_values() -> void:
	health_cost = 0
	stamina_cost = 0
	strength_cost = 0
	reward_items = []

func set_details() -> void:
	var all_activity = []
	reset_values()
	all_activity.append_array(location.morningActivities)
	all_activity.append_array(location.afternoonActivities)
	all_activity.append_array(location.eveningActivities)
	for each_activity in all_activity:
		health_cost += each_activity.healthCost
		stamina_cost += each_activity.staminaCost
		strength_cost += each_activity.strengthCost
		for each_reward in each_activity.rewardItems:
			if not RecipeBook.array_contains_item(reward_items, each_reward, true):
				reward_items.append(each_reward)

func updated_selected(new: Location) -> void:	
	location = new
	set_details()
	update()
