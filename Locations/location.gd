extends Resource
class_name Location

enum TimeOfDay {
	BREAKFAST,
	MORNING,
	LUNCH,
	AFTERNOON,
	DINNER,
	EVENING
}

@export var description : String = "<Unknown>"
@export var background_texture : Texture2D
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
