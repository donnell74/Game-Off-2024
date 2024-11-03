extends Node2D

@export var location : Location

func _ready() -> void:
	if !location:
		print("No location data found, showing blank screen...")
		return
	
	print("Starting location: %s" % location.description )
	print("Party stats at beginning of day: %s" % location.description)
	print(PartyController)
	
	location.advance_time_of_day()
	location.simulate() 
	location.advance_time_of_day() 
	location.simulate() 
	location.advance_time_of_day() 
	location.simulate()
	
	print("Party stats at end of day: %s" % location.description)
	print(PartyController)
