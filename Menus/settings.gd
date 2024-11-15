extends Node

@export var master_volume : float = 0.5
@export var music_volume : float = 0.5
@export var sfx_volume : float = 0.5
@export var _seed : int = 123456
@export var skip_cutscenes : bool = false

var _random : RandomNumberGenerator

func _ready() -> void:
	_random = RandomNumberGenerator.new()
	_random.randomize()
	SaveLoad.load_settings()

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

func set_skip_cutscenes(new: bool) -> void:
	skip_cutscenes = new

func random() -> RandomNumberGenerator:
	return _random

func save() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"_seed": _seed,
		"skip_cutscenes": skip_cutscenes
	}

func load(load_data: Dictionary) -> void:
	set_master_volume(load_data["master_volume"])
	set_music_volume(load_data["music_volume"])
	set_sfx_volume(load_data["sfx_volume"])
	set_seed(load_data["_seed"])
	set_skip_cutscenes(load_data["skip_cutscenes"])
