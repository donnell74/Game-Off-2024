extends Node

enum UiScene {
	COOKING,
	MAP,
	CAMPFIRE,
	INVENTORY,
	LOCATION,
	MAIN_MENU,
	SETTINGS,
	RECIPE_BOOK
}


@warning_ignore("unused_signal")
signal active_ui_changed(newActive: UiScene)
