extends Node2D

@export var startingScene = UiEvents.UiScene.CAMPFIRE
@export var useSavedGame = false

func _ready() -> void:
	UiEvents.active_ui_changed.emit(startingScene)
	LocationEvents.end_of_day.connect(SaveLoad.save_game)
	PartyController.party_stat_depleted.connect(_on_party_stat_depleted)

func _on_party_stat_depleted(stat: PartyController.Stats) -> void:
	print("Campfire - _on_party_stat_depleted: ", PartyController.Stats.keys()[stat])
	Dialogic.start("party_stat_depleted")
	Settings.set_seed(-1, false)
	get_node("Map").generate_map()
	if has_node("/root/Location"):
		var location_node = get_node("/root/Location")
		# need to remove as well as free so campfire doesn't see the node before the next frame
		get_tree().root.remove_child(location_node)
		location_node.queue_free()

	PartyController.reset_party_stats()
	call_deferred("switch_to_campfire")

func switch_to_campfire() -> void:
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
