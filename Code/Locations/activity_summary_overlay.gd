extends Control

var starting_party_stats : Party
var reward_items : Array[InventoryItem] = []

func _ready() -> void:
	%CanvasLayer.visible = visible
	LocationEvents.reward_item_added.connect(_on_reward_item_added)

func reset() -> void:
	starting_party_stats = PartyController.duplicate_party()
	reward_items = []

func _on_reward_item_added(item: InventoryItem) -> void:
	reward_items.append(item)

func update_ui() -> void:
	visible = true
	%CanvasLayer.visible = true
	%ContinueButton.grab_focus()
	update_reward_items()
	for index in starting_party_stats.members.size():
		var before = starting_party_stats.members[index]
		var after = PartyController.party.members[index]
		%PlayerCardGrid.get_child(index).update_ui(before, after)

func update_reward_items() -> void:
	for each_child in %RewardItemsGrid.get_children():
		each_child.queue_free()

	for each_item in reward_items:
		var item_control = %RewardTextureRect.duplicate()
		item_control.texture = each_item.texture
		item_control.visible = true
		%RewardItemsGrid.add_child(item_control)

func _on_continue_button_pressed() -> void:
	visible = false
	%CanvasLayer.visible = false
	UiEvents.active_ui_changed.emit(UiEvents.UiScene.CAMPFIRE)
