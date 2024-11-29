extends Control

signal location_simulation_done

@export var location : Location
@export var mobScene : PackedScene = preload("res://MiniGames/Hunting/mob.tscn")
@export var animals_killed : int = 0
@export var conversion_to_inventory_rate : int = 5
@export var rabbit_item : InventoryItem 
@export var top_left_boundary : Control = Control.new()
@export var bottom_right_boundary : Control = Control.new()
@export var cursorMovementSpeed : float = 500.0
@export var input_type_button : bool = false
@export var last_mouse_pos : Control = Control.new()

var is_mouse_pressed : bool = false
var cursor_enabled : bool = true
var starting_mouse_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	# For run single scene support
	if not get_tree().root.has_node("Main"):
		location = preload("res://Locations/Resources/hunting.tres")
		show_ui()
	
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.HUNTING:
			show_ui()
		_:
			hide_ui()

func hide_ui() -> void:
	visible = false
	cursor_enabled = false

func show_ui() -> void:
	visible = true
	cursor_enabled = true
	%SpawnTimer.start()
	%GameTimer.start()
	%Cursor.global_position = last_mouse_pos.global_position

func _process(_delta: float) -> void:
	%GameTimeLabel.text = "%d" % %GameTimer.time_left

func _physics_process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if starting_mouse_pos.is_equal_approx(Vector2.ZERO):
		starting_mouse_pos = mouse_pos
	
	if mouse_position_has_changed(mouse_pos):
		input_type_button = false
		last_mouse_pos.global_position = mouse_pos
	
	var movement = Vector2.ZERO
	if Input.is_action_pressed("Pan Up"):
		input_type_button = true
		if %Cursor.position.y > top_left_boundary.global_position.y:
			movement.y = -1
	if Input.is_action_pressed("Pan Down"):
		input_type_button = true
		if %Cursor.position.y < bottom_right_boundary.global_position.y:
			movement.y = 1
	if Input.is_action_pressed("Pan Left"):
		input_type_button = true
		if %Cursor.position.x > top_left_boundary.global_position.x:
			movement.x = -1
	if Input.is_action_pressed("Pan Right"):
		input_type_button = true
		if %Cursor.position.x < bottom_right_boundary.global_position.x:
			movement.x = 1
	
	if input_type_button and not movement.is_equal_approx(Vector2.ZERO):
		%Cursor.global_position += movement.normalized() * cursorMovementSpeed * delta
	elif mouse_position_has_changed(mouse_pos):
		%Cursor.global_position = mouse_pos

func mouse_position_has_changed(new_mouse_pos: Vector2) -> bool:
	return not new_mouse_pos.is_equal_approx(last_mouse_pos.global_position) and not new_mouse_pos.is_equal_approx(starting_mouse_pos)

func _input(event: InputEvent) -> void:
	if cursor_enabled and not is_mouse_pressed and event.is_action_pressed("Left Click"):
		is_mouse_pressed = true
		print("Mouse click at position: ", %Cursor.global_position)
		var objects_under_cursor = %Cursor.get_overlapping_bodies()
		print("objects_under_cursor: ", objects_under_cursor)
		if objects_under_cursor:
			_update_score_label(objects_under_cursor.size())
			for each_object in objects_under_cursor:
				each_object.queue_free()
	
	# So players can drag while holding the shoot button down
	if event.is_action_released("Left Click"):
		is_mouse_pressed = false

func _update_score_label(increment: int) -> void:
	animals_killed += increment
	%ScoreLabel.text = "%d" % animals_killed

func _on_spawn_timer_timeout() -> void:
	%PathFollow2D.progress_ratio = Settings.random().randf()
	%SpawnTimer.wait_time = Settings.random().randf_range(2.0, 5.0)
	var mob = mobScene.instantiate()
	var mouse_pos = get_viewport().get_mouse_position()
	mob.global_position = %PathFollow2D.global_position
	mob.direction = mob.global_position.direction_to(mouse_pos)
	mob.velocity = mob.direction * mob.speed
	add_child(mob)

func _on_game_timer_timeout() -> void:
	%TimesUpScreen.visible = true
	%ContinueDayButton.grab_focus()
	%RabbitsCollectedValueLabel.text = "%d" % ceil(animals_killed % conversion_to_inventory_rate)
	%Cursor.visible = false
	cursor_enabled = false
	for items_to_add in ceil(animals_killed % conversion_to_inventory_rate):
		PlayerInventoryController.add_item(rabbit_item)

func _on_continue_day_button_pressed() -> void:
	location.currentTimeOfDay = Location.TimeOfDay.END_OF_DAY
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
	location_simulation_done.emit()
	LocationEvents.end_of_day.emit()
