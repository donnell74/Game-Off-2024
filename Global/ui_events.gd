extends Node

enum UiScene {
	COOKING,
	MAP,
	CAMPFIRE,
	INVENTORY,
	LOCATION
}


signal active_ui_changed(newActive: UiScene)
