extends Control

@export var mapNodeScene : Control
@export var pathLineTemplateScene : Node
@export var possibleLocations : Array[Location] = []
@export var disabledLocations : Array[Location] = []
@export var possibleBosses : Array[Location] = []
@export var pathCount : int = 5
@export var pathLength : int = 10
@export var dungeonPercent : int = 50
@export var resourcePercent : int = 50
@export var pathHorizontalPadding = 250
@export var pathVerticalPadding = 150
@export var bottomLeftMapPosition : Vector2i
@export var cameraMovementSpeed = 1000.0
@export var locationScene = preload("res://Locations/location.tscn")
@export var shopScene = preload("res://Locations/shop.tscn")
@export var huntingScene = preload("res://MiniGames/Hunting/Hunting.tscn")
@export var currentlyLoadedMapNode : MapNode = null
@export var currentlyFocusedMapNode : Control
@export var selectedBoss : Location
@export var minMergedNodes : int = 3
@export var maxMergedNodes : int = 8
@export var rootNodes : Array[MapNode] = []
@export var mergeChance: float = 0.05
@export var zoom_change : Vector2 = Vector2(0.2, 0.2)
@export var enabled : bool = true
@export var topLeftBoundary : Vector2
@export var bottomRightBoundary : Vector2

const MAP_NODE_PATH = "/root/Main/Map/MapContainer/"

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	%MapCamera.enabled = false
	# Start centered on the middle path
	%MapCamera.global_position = bottomLeftMapPosition + Vector2i((pathCount / 2) * pathHorizontalPadding, pathVerticalPadding * 2)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	Settings.setting_vegan_changed.connect(_on_setting_vegan_changed)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.MAP:
			enabled = true
			show_map()
		UiEvents.UiScene.SETTINGS_CLOSED, UiEvents.UiScene.INVENTORY_CLOSED, UiEvents.UiScene.RECIPE_BOOK_CLOSED:
			if visible:
				enabled = true
				show_map()
			# overlay, don't hide
		UiEvents.UiScene.SETTINGS_OPEN, UiEvents.UiScene.INVENTORY_OPEN, UiEvents.UiScene.RECIPE_BOOK_OPEN, UiEvents.UiScene.DISABLE_HOTKEYS, UiEvents.UiScene.ENABLE_HOTKEYS:
			enabled = false
			# Overlay, don't hide
		_:
			hide_map()

func _on_focus_changed(control: Control) -> void:
	print("Focus changed to: %s" % control.name)
	if !visible:
		return
	
	if control and control.has_node("SelectedIndicator"):
		# Make the old one not selected
		if currentlyFocusedMapNode:
			currentlyFocusedMapNode.find_child("SelectedIndicator").visible = false

		%MapMovementSound.pitch_scale = Settings.random().randf_range(1.5, 4.0)
		%MapMovementSound.play()
		currentlyFocusedMapNode = control
		currentlyFocusedMapNode.find_child("SelectedIndicator").visible = true

func _on_setting_vegan_changed(new: bool) -> void:
	if new:
		var possibleCopy = possibleLocations.duplicate()
		for index in possibleCopy.size():
			if possibleCopy[index].type == Location.Type.HUNTING:
				var each_location = possibleLocations.pop_at(index)
				disabledLocations.append(each_location)
	else:
		possibleLocations.append_array(disabledLocations)
		disabledLocations = []
	
	generate_map()

func filter_by_visitable(node: MapNode) -> bool:
	return node.visitState == MapNode.VisitState.VISITABLE

func show_map() -> void:
	visible = true
	%MapCamera.enabled = true
	var pathLengthIndex = 0
	var mapNode = rootNodes[pathCount / 2]
	var nextNodes : Array[MapNode] = rootNodes.duplicate()
	while mapNode.visitState != MapNode.VisitState.VISITABLE:
		pathLengthIndex += 1
		nextNodes.append_array(mapNode.next_neighbors)
		if pathLengthIndex == pathLength:
			mapNode = %Boss
		else:
			mapNode = nextNodes.pop_front()

	mapNode.set_focus_mode(FocusMode.FOCUS_ALL)
	mapNode.grab_focus()

func hide_map() -> void:
	visible = false
	%MapCamera.enabled = false

func _input(event: InputEvent) -> void:
	if not visible or not enabled:
		return
	
	# is_action_released so it doesn't release on the campfire scene
	if event.is_action_released("ui_accept"):
		_on_map_node_clicked(currentlyFocusedMapNode)
	if event.is_action_pressed("Zoom In"):
		%MapCamera.zoom += zoom_change
	if event.is_action_pressed("Zoom Out"):
		if %MapCamera.zoom == 0:
			return

		%MapCamera.zoom -= zoom_change

func _process(delta: float) -> void:
	if not enabled:
		return
	
	var movement = Vector2.ZERO
	if Input.is_action_pressed("Pan Up"):
		if %MapCamera.position.y > topLeftBoundary.y:
			movement.y = -1
	if Input.is_action_pressed("Pan Down"):
		if %MapCamera.position.y < bottomRightBoundary.y:
			movement.y = 1
	if Input.is_action_pressed("Pan Left"):
		if %MapCamera.position.x > topLeftBoundary.x:
			movement.x = -1
	if Input.is_action_pressed("Pan Right"):
		if %MapCamera.position.x < bottomRightBoundary.x:
			movement.x = 1
	
	%MapCamera.position += movement.normalized() * cameraMovementSpeed * delta

func generate_map(map_node_data: Dictionary = {}) -> void:
	currentlyFocusedMapNode = null
	currentlyLoadedMapNode = null
	topLeftBoundary = Vector2(-100, -1 * (pathLength * pathVerticalPadding))
	bottomRightBoundary = Vector2(pathLength * pathHorizontalPadding, bottomLeftMapPosition.y)
	selectedBoss = possibleBosses[Settings.random().randi_range(0, possibleBosses.size() - 1)]
	%Boss.location = selectedBoss
	%Boss.find_child("Icon").texture = preload("res://Map/Assets/monster.png")
	%Boss.global_position = _get_map_node_positiion(pathCount / 2, pathLength + 2)
	add_map_to_ui(map_node_data)
	set_focus_neighbors()
	add_map_lines()

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
			if pathLengthIndex == pathLength - 1:
				rootMapNode.set_focus_neighbor(SIDE_TOP, %Boss.get_path())

func add_map_to_ui(map_node_data: Dictionary = {}) -> void:
	if !mapNodeScene:
		print("Unable to run add_map_to_ui")
		return
	
	# Delete all the previous nodes
	for child in %MapContainer.get_children():
		child.free()
	
	# loop through paths, horizontal padding based on index
	# Add map node for each location on path, vertical padded based on index
	# Create a line from last node to current node
	var lastMapNode = null
	rootNodes = []
	for pathIndex in range(pathCount):
		for pathLengthIndex in range(pathLength):
			var mapNode = create_map_node(pathIndex, pathLengthIndex)
			%MapContainer.add_child(mapNode)
			
			if map_node_data.size() == 0:
				if pathLengthIndex == 0:
					mapNode.change_visit_state(MapNode.VisitState.VISITABLE)
					rootNodes.append(mapNode)
				else:
					mapNode.change_visit_state(MapNode.VisitState.NOT_VISITABLE)
			else:
				if not map_node_data.has(_get_map_node_name(pathIndex, pathLengthIndex)):
					mapNode.queue_free()
					continue
				
				if pathLengthIndex == 0:
					rootNodes.append(mapNode)
				
				var node_data = map_node_data[_get_map_node_name(pathIndex, pathLengthIndex)]
				mapNode.global_position.x = node_data["global_position_x"]
				mapNode.global_position.y = node_data["global_position_y"]
				if node_data["visitState"]:
					mapNode.change_visit_state(node_data["visitState"])
				else:
					mapNode.change_visit_state(MapNode.VisitState.NOT_VISITABLE)
				
			if lastMapNode and lastMapNode.y_map_pos != pathLength - 1:
				lastMapNode.next_neighbors.append(mapNode)
	
			lastMapNode = mapNode
		
	# don't merge nodes if we are loading data
	if map_node_data.size() == 0:
		merge_random_nodes()

func merge_random_nodes() -> void:
	var nodes_to_merge = Settings.random().randi_range(minMergedNodes, maxMergedNodes)
	for merge_index in range(nodes_to_merge):
		var current_level = rootNodes.duplicate()
		var merged_node = false
		while !merged_node:
			if current_level.size() == 0:
				# restart at root if we haven't find a node to merge yet
				current_level = rootNodes.duplicate()

			# Calculate next level
			var next_level = []
			var next_level_keys = []
			for each_node in current_level:
				for each_neighbor in each_node.next_neighbors:
					if each_neighbor.name in next_level_keys:
						print("Duplicate neighbor, ignoring: ", each_neighbor.name)
						continue
					
					next_level.append(each_neighbor)
					next_level_keys.append(each_neighbor.name)
			
			if Settings.random().randf() <= mergeChance:
				merged_node = true
				# pick random node, it's next_neighbor will be merged
				# find node next to it and set next_neighbors to be the same
				var target_node_index = Settings.random().randi_range(1, current_level.size() - 1)
				var target_node = current_level[target_node_index - 1] # -1 so always works next line
				var neighbor_node = current_level[target_node_index]
				if target_node.x_map_pos == neighbor_node.x_map_pos:
					print("Merging (%d, %d) and (%d, %d) has same x_map_pos" % [target_node.x_map_pos,
					  target_node.y_map_pos, neighbor_node.x_map_pos, neighbor_node.y_map_pos])
				if same_neighbors(target_node, neighbor_node):
					print("We already merged (%d, %d) and (%d, %d).  Trying again" % [target_node.x_map_pos,
					  target_node.y_map_pos, neighbor_node.x_map_pos, neighbor_node.y_map_pos])
				else:
					print("Merging (%d, %d) and (%d, %d) to same next_neighbors" % [target_node.x_map_pos,
					  target_node.y_map_pos, neighbor_node.x_map_pos, neighbor_node.y_map_pos])
					# given a -> b -> c, and d -> e -> f make it
					# a/d -> b -> c/f (delete e)
					var later_path_neighbors : Array[MapNode] = []
					for each_neighbor in neighbor_node.next_neighbors:
						later_path_neighbors.append_array(each_neighbor.next_neighbors)
						each_neighbor.queue_free()
					
					neighbor_node.next_neighbors = target_node.next_neighbors
					for each_neighbor in target_node.next_neighbors:
						each_neighbor.next_neighbors.append_array(later_path_neighbors)
			
			# set next level
			current_level = next_level

func same_neighbors(left: MapNode, right: MapNode) -> bool:
	if left.next_neighbors.size() != right.next_neighbors.size():
		return false
	
	for left_neighbor in left.next_neighbors:
		var found = false
		for right_neighbor in right.next_neighbors:
			if left_neighbor == right_neighbor:
				found = true
				break
		
		if not found:
			return false
	
	return true

func add_map_lines() -> void:
	var nodes_to_visit = rootNodes.duplicate()
	while nodes_to_visit.size() > 0:
		var each_node = nodes_to_visit.pop_front()
		if not each_node:
			continue
		
		if each_node.y_map_pos == pathLength - 1:
			%MapContainer.add_child(create_line_node(each_node, %Boss))
		else:
			for each_neighbor in each_node.next_neighbors:
				%MapContainer.add_child(create_line_node(each_node, each_neighbor))
				nodes_to_visit.append(each_neighbor)


func create_map_node(pathIndex: int, pathLengthIndex: int) -> Control:
	var mapNode = mapNodeScene.duplicate()
	var location = possibleLocations[Settings.random().randi_range(0, possibleLocations.size() - 1)].duplicate()
	var icon = mapNode.find_child("Icon")
	icon.texture = get_map_node_texture(location.type)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	# We want the path to move up to give the since of building up to a boss so we multiple
	# y by negative
	mapNode.global_position = _get_map_node_positiion(pathIndex, pathLengthIndex)
	mapNode.visible = true
	mapNode.name = _get_map_node_name(pathIndex, pathLengthIndex)
	mapNode.location = location
	mapNode.x_map_pos = pathIndex
	mapNode.y_map_pos = pathLengthIndex
	mapNode.map_node_clicked.connect(_on_map_node_clicked)
	mapNode.set_focus_mode(FocusMode.FOCUS_ALL)
	return mapNode

func _get_map_node_positiion(pathIndex: int, pathLengthIndex: int) -> Vector2i:
	var y_pos = 100 - (pathLengthIndex * pathVerticalPadding)
	var x_pos = pathIndex * pathHorizontalPadding
	x_pos = x_pos + Settings.random().randi_range(x_pos - (pathHorizontalPadding / 2.0), x_pos + (pathHorizontalPadding / 2.0))
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
			return preload("res://Map/Assets/foraging_map_icon.jpeg")
		_:
			return preload("res://Map/Assets/monster.png")

func _on_map_node_clicked(mapNode: MapNode) -> void:
	
	print("_on_map_node_clicked for MapNode (%d, %d)" % [mapNode.x_map_pos, mapNode.y_map_pos])
	if currentlyFocusedMapNode.visitState != MapNode.VisitState.VISITABLE:
		print("MapNode is not visitable")
		return

	hide_map()
	
	currentlyLoadedMapNode = mapNode
	print("Location for MapNode (%d, %d): %s" % [mapNode.x_map_pos, mapNode.y_map_pos, mapNode.location.description])

	var scene_to_load
	match mapNode.location.type:
		Location.Type.TOWN:
			scene_to_load = shopScene.instantiate()
		Location.Type.HUNTING:
			scene_to_load = huntingScene.instantiate()
		_:
			scene_to_load = locationScene.instantiate()

	scene_to_load.location = mapNode.location
	scene_to_load.location_simulation_done.connect(_on_location_simulation_done)
	get_tree().root.add_child(scene_to_load)
	match mapNode.location.type:
		Location.Type.TOWN:
			UiEvents.active_ui_changed.emit(UiEvents.UiScene.SHOP)
		Location.Type.HUNTING:
			UiEvents.active_ui_changed.emit(UiEvents.UiScene.HUNTING)

func _get_map_node_name(x_map_pos: int, y_map_pos: int) -> String:
	return "MapNode%dx%d" % [x_map_pos, y_map_pos]

func _on_location_simulation_done() -> void:
	print("MapGenerator - _on_location_simulation_done")
	if has_node("/root/Location"):
		$"/root/Location".queue_free()
	if has_node("/root/Shop"):
		$"/root/Shop".queue_free()
	
	if currentlyLoadedMapNode.x_map_pos == -1 and currentlyFocusedMapNode.y_map_pos == -1:
		# Level complete
		rootNodes = []
		generate_map()
		PartyController.level_up()
		SaveLoad.save_game()
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
		return
	
	# The MapNode is not owned by the map /shrug
	currentlyLoadedMapNode.find_child("CompletedIndicator").visible = true
	currentlyLoadedMapNode.change_visit_state(MapNode.VisitState.VISTED)
	# Make the next MapNode on the path visitable
	if currentlyLoadedMapNode.y_map_pos == pathLength - 1:
		%Boss.change_visit_state(MapNode.VisitState.VISITABLE)
	else:
		for nextMapNode in currentlyLoadedMapNode.next_neighbors:
			nextMapNode.change_visit_state(MapNode.VisitState.VISITABLE)
		
		if currentlyLoadedMapNode.y_map_pos == 0:
			for rootMapNodes in rootNodes:
				if rootMapNodes.x_map_pos != currentlyLoadedMapNode.x_map_pos:
					rootMapNodes.change_visit_state(MapNode.VisitState.NOT_VISITABLE)

func save_map_node_data() -> Dictionary:
	var save_data: Dictionary = {}
	for child in %MapContainer.get_children():
		if not child.has_method("change_visit_state"):
			continue
		
		var child_data = {
			"name": child.name,
			"global_position_x": child.global_position.x,
			"global_position_y": child.global_position.y,
			"x_map_pos": child.x_map_pos,
			"y_map_pos": child.y_map_pos,
			"visitState": child.visitState
		}
		save_data[_get_map_node_name(child.x_map_pos, child.y_map_pos)] = child_data
	
	return save_data

func save() -> Dictionary:
	var save_dict = {
		SaveLoad.PATH_FROM_ROOT_KEY: get_path(),
		"map_node_data": save_map_node_data(),
		"boss": {
			"visitState": %Boss.visitState,
			"location": selectedBoss.save()
		}
	}
	
	return save_dict

func load(load_data: Dictionary) -> void:
	selectedBoss = Location.new()
	selectedBoss.load(load_data["boss"]["location"])
	%Boss.visitState = load_data["boss"]["visitState"]
	generate_map(load_data["map_node_data"])
