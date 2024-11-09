extends Node

@export var master_volume : float = 0.5
@export var music_volume : float = 0.5
@export var sfx_volume : float = 0.5
@export var _seed : int = 123456

var _random : RandomNumberGenerator

func _ready() -> void:
	_random = RandomNumberGenerator.new()
	_random.randomize()

func set_master_volume(new_volume: float) -> void:
	master_volume = new_volume
	AudioServer.set_bus_volume_db(
		0, linear_to_db(master_volume)
	)

func set_music_volume(new_volume: float) -> void:
	music_volume = new_volume
	AudioServer.set_bus_volume_db(
		1, linear_to_db(music_volume)
	)

func set_sfx_volume(new_volume: float) -> void:
	sfx_volume = new_volume
	AudioServer.set_bus_volume_db(
		2, linear_to_db(sfx_volume)
	)

func set_seed(new_seed: int) -> void:
	_seed = new_seed
	_random.seed = _seed

func random() -> RandomNumberGenerator:
	return _random
