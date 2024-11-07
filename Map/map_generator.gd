extends Control

@export var mapPathResource : Resource = preload("res://Map/map_path.gd")
@export var mapNodeScene : Control
@export var pathLineTemplateScene : Node
@export var possibleLocations : Array[Location] = []
@export var pathCount : int = 5
@export var pathLength : int = 10
@export var dungeonPercent : int = 50
@export var resourcePercent : int = 50
@export var map : Map = preload("res://Map/map.gd").new()
@export var pathHorizontalPadding = 200
@export var pathVerticalPadding = 150
@export var bottomLeftMapPosition : Vector2i
@export var cameraMovementSpeed = 1000.0
@export var locationScene = preload("res://Locations/location.tscn")
@export var currentlyLoadedMapNode = Vector2.ZERO
@export var currentlyFocusedMapNode : Control

var RAND_NUM_GEN = RandomNumberGenerator.new()
const MAP_NODE_PATH = "/root/Main/Map/"

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	%MapCamera.enabled = false
	generate_map()
	# Start centered on the middle path
	%MapCamera.global_position = bottomLeftMapPosition + Vector2i((pathCount / 2) * pathHorizontalPadding, pathVerticalPadding * 2)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.MAP:
			show_map()
		UiEvents.UiScene.INVENTORY:
			pass
		_:
			hide_map()

func _on_focus_changed(control: Control) -> void:
	print("Focus changed to: %s" % control.name)
	if !visible:
		return
	
	if control:
		# Make the old one not selected
		if currentlyFocusedMapNode:
			currentlyFocusedMapNode.find_child("SelectedIndicator").visible = false
		currentlyFocusedMapNode = control
		currentlyFocusedMapNode.find_child("SelectedIndicator").visible = true

func show_map() -> void:
	visible = true
	%MapCamera.enabled = true
	var pathLengthIndex = 0
	var mapNode = find_child(_get_map_node_name(pathCount / 2, pathLengthIndex), true, false)
	while !mapNode.visitable:
		pathLengthIndex += 1
		mapNode = find_child(_get_map_node_name(pathCount / 2, pathLengthIndex), true, false)

	mapNode.set_focus_mode(FocusMode.FOCUS_ALL)
	mapNode.grab_focus()
	#currentlyFocusedMapNode = mapNode
	#mapNode.find_child("SelectedIndicator").visible = true

func hide_map() -> void:
	visible = false
	%MapCamera.enabled = false

func _input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		_on_map_node_clicked(currentlyFocusedMapNode.x_map_pos, currentlyFocusedMapNode.y_map_pos)

func _process(delta: float) -> void:
	var movement = Vector2.ZERO
	if Input.is_action_pressed("Pan Up"):
		movement.y = -1
	if Input.is_action_pressed("Pan Down"):
		movement.y = 1
	if Input.is_action_pressed("Pan Left"):
		movement.x = -1
	if Input.is_action_pressed("Pan Right"):
		movement.x = 1
	
	%MapCamera.position += movement.normalized() * cameraMovementSpeed * delta

func generate_map() -> void:
	for pathIndex in range(pathCount):
		map.paths.append(create_map_path())

	add_map_to_ui()
	set_focus_neighbors()

func set_focus_neighbors() -> void:
	for pathIndex in range(pathCount):
		for pathLengthIndex in range(pathLength):
			#                        (pathIndex, pathLengthIndex - 1)
			#                                   ^
			# (pathIndex - 1, pathLengthIndex) < > (pathIndex + 1, pathLengthIndex)
			#                                   V
			#                        (pathIndex, pathLengthIndex + 1)
			var rootMapNode = find_child(_get_map_node_name(pathIndex, pathLengthIndex), true, false)
			if pathIndex != 0:
				rootMapNode.set_focus_neighbor(SIDE_LEFT, MAP_NODE_PATH + _get_map_node_name(pathIndex - 1, pathLengthIndex))
			if pathIndex != pathCount - 1:
				rootMapNode.set_focus_neighbor(SIDE_RIGHT, MAP_NODE_PATH + _get_map_node_name(pathIndex + 1, pathLengthIndex))
			if pathLengthIndex != pathLengthIndex - 1:
				rootMapNode.set_focus_neighbor(SIDE_TOP, MAP_NODE_PATH + _get_map_node_name(pathIndex, pathLengthIndex + 1))
			if pathLengthIndex != 0:
				rootMapNode.set_focus_neighbor(SIDE_BOTTOM, MAP_NODE_PATH + _get_map_node_name(pathIndex, pathLengthIndex - 1))

func create_map_path() -> MapPath:
	var mapPath = mapPathResource.new()
	for lengthIndex in range(pathLength):
		var each_location = possibleLocations[
			RAND_NUM_GEN.randi_range(0, possibleLocations.size() - 1)].duplicate()
		mapPath.locations.append(each_location)
	
	return mapPath

func add_map_to_ui() -> void:
	if !mapNodeScene:
		print("Unable to run add_map_to_ui")
		return
	
	# loop through paths, horizontal padding based on index
	# Add map node for each location on path, vertical padded based on index
	# Create a line from last node to current node
	var lastMapNode
	for pathIndex in range(pathCount):
		for pathLengthIndex in range(pathLength):
			var mapNode = create_map_node(pathIndex, pathLengthIndex)
			add_child(mapNode)
			if pathLengthIndex == 0:
				mapNode.make_visitable()
			else:
				mapNode.make_not_visitable()
				add_child(create_line_node(lastMapNode, mapNode))
			
			lastMapNode = mapNode

func create_map_node(pathIndex: int, pathLengthIndex: int) -> Control:
	var mapNode = mapNodeScene.duplicate()
	var location = map.paths[pathIndex].locations[pathLengthIndex]
	mapNode.find_child("Icon").texture = get_map_node_texture(location.type)
	# We want the path to move up to give the since of building up to a boss so we multiple
	# y by negative
	mapNode.global_position = _get_map_node_positiion(pathIndex, pathLengthIndex)
	mapNode.visible = true
	mapNode.name = _get_map_node_name(pathIndex, pathLengthIndex)
	mapNode.x_map_pos = pathIndex
	mapNode.y_map_pos = pathLengthIndex
	mapNode.map_node_clicked.connect(_on_map_node_clicked)
	mapNode.set_focus_mode(FocusMode.FOCUS_ALL)
	return mapNode

func _get_map_node_positiion(pathIndex: int, pathLengthIndex: int) -> Vector2i:
	var y_pos = 100 - (pathLengthIndex * pathVerticalPadding)
	var x_pos = pathIndex * pathHorizontalPadding
	x_pos = x_pos + RAND_NUM_GEN.randi_range(x_pos - pathHorizontalPadding, x_pos + pathHorizontalPadding)
	return bottomLeftMapPosition + Vector2i(x_pos, y_pos)

func create_line_node(from: Node, to: Node) -> Line2D:
	var line = pathLineTemplateScene.duplicate()
	line.add_point(from.global_position)
	line.add_point(to.global_position)
	line.visible = true
	line.z_index = -1
	line.name = "Line2D (%s => %s)" % [from.name, to.name] # for debugging
	return line

func get_map_node_texture(type: Location.Type) -> Texture2D:
	match type:
		Location.Type.TOWN:
			return preload("res://Map/Assets/town.png")
		Location.Type.FISHING:
			return preload("res://Map/Assets/fishing.png")
		Location.Type.HUNTING:
			return preload("res://Map/Assets/hunting.png")
		Location.Type.FORAGING:
			return preload("res://Cooking/Assets/clock.png")
		_:
			return preload("res://Map/Assets/monster.png")

func _on_map_node_clicked(x_map_pos: int, y_map_pos: int) -> void:
	print("_on_map_node_clicked for MapNode (%d, %d)" % [x_map_pos, y_map_pos])
	if !currentlyFocusedMapNode.visitable:
		print("MapNode is not visitable")
		return

	hide_map()
	
	var location = map.paths[x_map_pos].locations[y_map_pos]
	currentlyLoadedMapNode = Vector2(x_map_pos, y_map_pos)
	print("Location for MapNode (%d, %d): %s" % [x_map_pos, y_map_pos, location.description])
	
	var scene_to_load = locationScene.instantiate()
	scene_to_load.location = location
	scene_to_load.location_simulation_done.connect(_on_location_simulation_done)
	get_tree().root.add_child(scene_to_load)

func _get_map_node_name(x_map_pos: int, y_map_pos: int) -> String:
	return "MapNode%dx%d" % [x_map_pos, y_map_pos]

func _on_location_simulation_done() -> void:
	print("MapGenerator - _on_location_simulation_done")
	$"/root/Location".queue_free()
	# The MapNode is not owned by the map /shrug
	#var mapScene = get_root().find_child("Map", true, false)
	var mapNode = find_child(_get_map_node_name(currentlyLoadedMapNode.x, currentlyLoadedMapNode.y), true, false)
	mapNode.find_child("CompletedIndicator").visible = true
	mapNode.make_not_visitable()
	# TODO: Handle end of map!
	# Make the next MapNode on the path visitable
	var nextMapNode = find_child(_get_map_node_name(currentlyLoadedMapNode.x, currentlyLoadedMapNode.y + 1), true, false)
	nextMapNode.make_visitable()
