extends Control

var timeForTimeOfDay : Dictionary = {
	Location.TimeOfDay.BREAKFAST: 6,
	Location.TimeOfDay.MORNING: 7,
	Location.TimeOfDay.LUNCH: 12,
	Location.TimeOfDay.AFTERNOON: 13,
	Location.TimeOfDay.DINNER: 19,
	Location.TimeOfDay.EVENING: 20,
	Location.TimeOfDay.END_OF_DAY: 23
}

@export var indicator_on_color : Color
@export var indicator_off_color : Color
@export var current_hour : float = 6.0
@export var goal_hour : int = 6
@export var hour_increment : float = 1.0

func _ready() -> void:
	%TimeForegroundLabel.text = "06:00"
	if not has_node("/root/Main"): # for debugging
		var location = preload("res://Locations/location.tscn").instantiate()
		get_tree().root.add_child.call_deferred(location)

func set_new_goal_hour() -> void:
	if has_node("/root/Location"):
		var locationNode = $"/root/Location"
		goal_hour = timeForTimeOfDay[locationNode.location.currentTimeOfDay]
		hour_increment = (goal_hour - current_hour) / (1.5 / %ClockTickTimer.wait_time)

func update_ui() -> void:
	%CanvasLayer.visible = visible
	if has_node("/root/Location"):
		var locationNode = $"/root/Location"
		var display_hour = current_hour if floor(current_hour) <= 12 else current_hour - 12
		%TimeForegroundLabel.text = "%02d:00" % floor(display_hour)
		if locationNode.location.currentTimeOfDay < Location.TimeOfDay.LUNCH:
			%AmIndicator.modulate = indicator_on_color
			%PmIndicator.modulate = indicator_off_color
		else:
			%AmIndicator.modulate = indicator_off_color
			%PmIndicator.modulate = indicator_on_color

func _on_clock_tick_timer_timeout() -> void:
	print("_on_clock_tick_timer_timeout", current_hour, " => ", goal_hour)
	if current_hour < goal_hour:
		current_hour += hour_increment
		update_ui()
