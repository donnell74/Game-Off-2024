extends Node

enum UiScene {
	COOKING,
	MAP,
	CAMPFIRE,
	INVENTORY,
	LOCATION,
	MAIN_MENU,
	SETTINGS,
	SHOP,
	RECIPE_BOOK,
	GAME_WON
}


@warning_ignore("unused_signal")
signal active_ui_changed(newActive: UiScene)
