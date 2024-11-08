extends Resource
class_name MapPath

@export var locations : Array[Location] = []

func save() -> Dictionary:
	var save_map = { "locations": [] }
	for each_location in locations:
		save_map["locations"].append(each_location.save())
	
	return save_map

func load(load_data: Variant) -> void:
	for each_location_data in load_data["locations"]:
		var new_location = Location.new()
		new_location.load(each_location_data)
		locations.append(new_location)
