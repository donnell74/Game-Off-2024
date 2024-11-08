extends Resource
class_name Map

@export var paths : Array[MapPath] = []

func save() -> Dictionary:
	var save_map = { "paths": [] }
	for each_path in paths:
		save_map["paths"].append(each_path.save())
	
	return save_map

func load(load_data: Dictionary) -> void:
	for each_path_data in load_data["paths"]:
		var new_path = MapPath.new()
		new_path.load(each_path_data)
		paths.append(new_path)
