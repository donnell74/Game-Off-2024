extends Resource
class_name Activity

@export var description : String = "Waiting..."
@export var rewardItems : Array[InventoryItem] = []
@export var minRewardItems : int = 1
@export var maxRewardItems : int = 3
@export var rewardCurrency : int = 0
@export var healthCost : float = 0.0
@export var staminaCost : float = 0.0
@export var strengthCost : float = 0.0

func save() -> Dictionary:
	var save_map = { 
		"description": description,
		"rewardItems": rewardItems.map(func(i): return i.save()),
		"rewardCurrency": rewardCurrency,
		"healthCost": healthCost,
		"staminaCost": staminaCost,
		"strengthCost": staminaCost
	}
	return save_map

static func from_values(from: Dictionary) -> Activity:
	var new_activity = Activity.new()
	for each_item in from["rewardItems"]:
		new_activity.rewardItems.append(InventoryItem.from_values(each_item))
	
	new_activity.description = from["description"]
	new_activity.rewardCurrency = from["rewardCurrency"]
	new_activity.healthCost = from["healthCost"]
	new_activity.staminaCost = from["staminaCost"]
	new_activity.strengthCost = from["strengthCost"]
	return new_activity
