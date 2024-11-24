extends Node

enum UiScene {
	MAP,
	CAMPFIRE,
	INVENTORY_OPEN,
	INVENTORY_CLOSED,
	LOCATION,
	MAIN_MENU,
	SETTINGS_OPEN,
	SETTINGS_CLOSED,
	SHOP,
	RECIPE_BOOK_OPEN,
	RECIPE_BOOK_CLOSED,
	GAME_WON,
	DISABLE_HOTKEYS,
	ENABLE_HOTKEYS
}


@warning_ignore("unused_signal")
signal active_ui_changed(newActive: UiScene)
