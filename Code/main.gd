extends Node2D

@export var startingScene = UiEvents.UiScene.CAMPFIRE
@export var useSavedGame = false
@export var gameWon = false

func _ready() -> void:
	UiEvents.active_ui_changed.emit(startingScene)
	UiEvents.active_ui_changed.connect(_on_active_ui_changed)
	LocationEvents.end_of_day.connect(SaveLoad.save_game)
	PartyController.party_stat_depleted.connect(_on_party_stat_depleted)
	RecipeBookController.recipe_cooked.connect(_on_recipe_cooked)

func _on_active_ui_changed(newActive: UiEvents.UiScene) -> void:
	match newActive:
		UiEvents.UiScene.DISABLE_HOTKEYS:
			for each_child in get_children():
				each_child.set_process_input(false)
		UiEvents.UiScene.ENABLE_HOTKEYS:
			for each_child in get_children():
				each_child.set_process_input(true)
		_:
			pass

func _on_recipe_cooked(recipe: Recipe) -> void:
	print("Main - _on_recipe_cooked: ", Recipe.Tiers.keys()[recipe.tier])
	if recipe.tier == Recipe.Tiers.GOLDEN:
		gameWon = true
		Dialogic.start("game_won")
		UiEvents.active_ui_changed.emit(UiEvents.UiScene.GAME_WON)

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
