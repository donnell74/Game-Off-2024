extends Node

const SAVE_PATH = "user://savegame.save"
const SETTINGS_SAVE_PATH = "user://savesettings.save"
const PATH_FROM_ROOT_KEY = "path_from_root"

func save_settings() -> void:
	print("Saving settings - Starting")
	var save_file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(Settings.save())
	save_file.store_line(json_string)
	print("Saving settings - finished")

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		print("No save file, starting fresh settings save")
		return

	var save_file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("Loading Save JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		Settings.load(json.data)

func save_game() -> void:
	print("Saving game - Starting")
	var save_nodes = get_tree().get_nodes_in_group("persist")	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	for node in save_nodes:
		print("Saving node: %s" % node.name)
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file, starting fresh game")
		return

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("Loading Save JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.data
		if PATH_FROM_ROOT_KEY not in node_data:
			print("Unable to find path_from_root in: ", node_data)
			continue
		
		print("Loading node: ", node_data[PATH_FROM_ROOT_KEY])
		if not get_tree().root.has_node(node_data[PATH_FROM_ROOT_KEY]):
			print("Unable to find node in tree for: ", node_data)
			return
		
		var node = get_node(node_data[PATH_FROM_ROOT_KEY])
		node.load(node_data)

func save_file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
