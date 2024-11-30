extends Node2D

signal location_simulation_done

@export var location : Location

func _ready() -> void:
	if !location:
		print("No location data found, showing blank screen...")
		return
	
	print("Starting location: %s" % location.description )
	print("Party stats at beginning of day: %s" % location.description)
	print(PartyController)
	
	%Background.texture = location.backgroundTexture
	var animation = $AnimationPlayer.get_animation("background")
	animation.loop = true

	# Play the animation
	if not Settings.skip_cutscenes:
		$AnimationPlayer.play("background")

	LocationEvents.advance_day.connect(_on_advance_day)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.LOCATION:
			show_ui()
		_:
			hide_ui()

func hide_ui() -> void:
	visible = false
	%CanvasLayer.visible = false
	%Clock.visible = false
	%Clock.update_ui()

func show_ui() -> void:
	visible = true
	%CanvasLayer.visible = true

func _on_advance_day() -> void:
	print("LocationController - _on_advance_day")
	show_ui()
	location.advance_time_of_day()
	location.simulate()
	print("Party stats at end of activity: %s" % location.description)
	print(PartyController)
	if Settings.skip_cutscenes:
		_on_timer_timeout()
	else:
		$Timer.start(2)
		%Clock.visible = true
		%Clock.set_new_goal_hour()
		%Clock.update_ui()

func _on_timer_timeout() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
	print("Location TimeOfDay: %s" % Location.TimeOfDay.keys()[location.currentTimeOfDay])
	LocationEvents.advance_day_done.emit()
	if location.currentTimeOfDay == Location.TimeOfDay.END_OF_DAY:
		location_simulation_done.emit()
		LocationEvents.end_of_day.emit()
