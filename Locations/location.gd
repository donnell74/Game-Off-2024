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
	if activity.rewardItems.size() > 0:
		for each_reward in activity.rewardItems:
			PlayerInventoryController.add_item(each_reward)
		
		# handle decrementing 
		PartyController.apply_party_damage(PartyController.Stats.STRENGTH, activity.strengthCost)
		PartyController.apply_party_damage(PartyController.Stats.STAMINA, activity.staminaCost)
		PartyController.apply_party_damage(PartyController.Stats.HEALTH, activity.healthCost)
	
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
