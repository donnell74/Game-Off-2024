extends CharacterBody2D

@export var speed : float = 300.0
@export var direction : Vector2 = Vector2(1,1)

func _ready() -> void:
	velocity = speed * direction
	%DirectionChangeTimer.wait_time = Settings.random().randf_range(0.6, 1.0)
	%DirectionChangeTimer.start()

func _process(_delta: float) -> void:
	move_and_slide()

func _on_direction_change_timer_timeout() -> void:
	%DirectionChangeTimer.wait_time = Settings.random().randf_range(0.2, 1.0)
	%DirectionChangeTimer.start()
	direction = direction.rotated(Settings.random().randf_range(0.2, 3.0))
	velocity = speed * direction
