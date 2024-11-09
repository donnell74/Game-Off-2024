extends Resource
class_name Location

enum TimeOfDay {
	BREAKFAST,
	MORNING,
	LUNCH,
	AFTERNOON,
	DINNER,
	EVENING,
	END_OF_DAY
}

enum Type {
	DUNGEON,
	TOWN,
	FISHING,
	HUNTING,
	FORAGING
}

@export var description : String = "<Unknown>"
@export var backgroundTexture : Texture2D
@export var type : Type = Type.DUNGEON
@export var morningActivities : Array[Activity] = []
@export var afternoonActivities : Array[Activity] = []
@export var eveningActivities : Array[Activity] = []
@export var currentTimeOfDay : TimeOfDay = TimeOfDay.BREAKFAST

func simulate() -> void:
	print("Simulating next part of day: %s" % TimeOfDay.keys()[currentTimeOfDay])
	var activitiesToSimulate : Array[Activity] = []
	match currentTimeOfDay:
		TimeOfDay.MORNING:
			activitiesToSimulate = morningActivities
		TimeOfDay.AFTERNOON:
			activitiesToSimulate = afternoonActivities
		TimeOfDay.EVENING:
			activitiesToSimulate = eveningActivities
		_: #default
			print("Unknown time of day: %d" % currentTimeOfDay)

	for each_activity in activitiesToSimulate:
		print("Simulating activity: %s" % each_activity.description)
		simulate_activity(each_activity)

	advance_time_of_day()

func simulate_activity(activity: Activity) -> void:
	print("Simulating")
	if activity.rewardItems.size() > 0:
		print("Activity potential rewards: ", activity.rewardItems)
		for reward in select_random_items(activity.rewardItems, 1, 2):
			PlayerInventoryController.add_item(reward)
		
		# handle decrementing 
		PartyController.apply_party_damage(PartyController.Stats.STRENGTH, activity.strengthCost)
		PartyController.apply_party_damage(PartyController.Stats.STAMINA, activity.staminaCost)
		PartyController.apply_party_damage(PartyController.Stats.HEALTH, activity.healthCost)
		
func select_random_items(items: Array[InventoryItem], min_num_items: int, max_num_items: int) -> Array[InventoryItem]:
	# Total sum of rarity items
	var total_rarity = 0.0
	for item in items:
		total_rarity += item.rarity
	
	# Determine how many items this activity will return
	var num_items = randi_range(min_num_items, max_num_items)
	var selected_items: Array[InventoryItem] = []
	
	for i in range(num_items):
		var rand_value = randf_range(0.0, total_rarity)
		var cumulative_rarity = 0.0
		
		for item in items:
			cumulative_rarity += item.rarity
			if rand_value <= cumulative_rarity:
				selected_items.append(item)
				break
	return selected_items
	
func advance_time_of_day() -> void:
	currentTimeOfDay = (currentTimeOfDay + 1) as TimeOfDay

func save() -> Dictionary:	
	var save_map = { 
		"description": description,
		"backgroundTexture": backgroundTexture.resource_path if backgroundTexture else "",
		"type": type,
		"morningActivities": { "activities" : morningActivities.map(func(a): return a.save()) }, 
		"afternoonActivities": { "activities" : afternoonActivities.map(func(a): return a.save()) }, 
		"eveningActivities": { "activities" : eveningActivities.map(func(a): return a.save()) }, 
	}
	return save_map

func load(load_data: Variant) -> void:
	description = load_data["description"]
	if load_data["backgroundTexture"]:
		backgroundTexture = load(load_data["backgroundTexture"])
	
	type = load_data["type"]
	for each_activity in load_data["morningActivities"]["activities"]:
		morningActivities.append(Activity.from_values(each_activity))
