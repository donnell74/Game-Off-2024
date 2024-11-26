extends CharacterBody2D

@export var speed : float = 100.0
@export var direction : Vector2 = Vector2(1,1)

func _ready() -> void:
	velocity = speed * direction

func _process(_delta: float) -> void:
	move_and_slide()
