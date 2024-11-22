extends Resource
class_name Recipe

enum Tiers {
	BASIC,
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	GOLDEN
}

@export var input: Array[InventoryItem]
@export var output: Array[InventoryItem]
@export var action: Actions.Actions
@export var times_cooked: int = 0
@export var tier: Tiers = Tiers.BASIC

func save() -> Dictionary:
	var input_list = []
	var output_list = []
	for i in input:
		input_list.append(i.save())
	for i in output:
		output_list.append(i.save())
	return {
		"input": input_list,
		"output": output_list,
		"action": action,
		"times_cooked": times_cooked
	}
	
func load(load_data: Dictionary) -> void:
	var input_list: Array[InventoryItem] = []
	var output_list: Array[InventoryItem] = []
	for i in load_data["input"]:
		input_list.append(InventoryItem.from_values(i))
	for i in load_data["output"]:
		output_list.append(InventoryItem.from_values(i))
	input = input_list
	output = output_list
	action = load_data["action"]
	times_cooked = load_data["times_cooked"]
