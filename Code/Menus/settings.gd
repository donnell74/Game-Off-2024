extends Node

signal setting_vegan_changed(new: bool)

@export var master_volume : float = 0.5
@export var music_volume : float = 0.5
@export var sfx_volume : float = 0.5
@export var _seed : int = 123456
@export var skip_cutscenes : bool = false
@export var vegan : bool = false
@export var cheat_codes : Array[CHEAT_CODES] = []

var _random : RandomNumberGenerator

enum CHEAT_CODES {
	MASTERCHEF,
	SUPERMAN
}

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

func set_seed(new_seed: int, save_new_seed: bool = true) -> void:
	if save_new_seed:
		_seed = new_seed
	
	if new_seed == -1:
		_random.randomize()
	else:
		_random.seed = new_seed

func set_skip_cutscenes(new: bool) -> void:
	skip_cutscenes = new

func set_vegan(new: bool) -> void:
	vegan = new

func random() -> RandomNumberGenerator:
	return _random

func add_cheat_code(code : CHEAT_CODES) -> void:
	cheat_codes.append(code)
	match code:
		CHEAT_CODES.MASTERCHEF:
			RecipeBookController.cheat()
		_:
			pass

func has_cheat_code(code: CHEAT_CODES) -> bool:
	return cheat_codes.has(code)

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
