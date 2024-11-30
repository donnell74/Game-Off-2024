extends Control

var current_stats
var goal_stats

func update_ui(before: PartyMember, after: PartyMember) -> void:
	current_stats = before
	goal_stats = after

	%PlayerName.text = after.name
	%HealthValueLabel.text = "%d" % before.health
	%HealthChangeLabel.text = "%d" % (after.health - before.health)

	%StaminaValueLabel.text = "%d" % before.stamina
	%StaminaChangeLabel.text = "%d" % (after.stamina - before.stamina)

	%StrengthValueLabel.text = "%d" % before.strength
	%StrengthChangeLabel.text = "%d" % (after.strength - before.strength)

	%StartChangeAnimTimer.start()

func _on_change_apply_timer_timeout() -> void:
	if not current_stats or not goal_stats:
		return
	
	var health_left = current_stats.health - goal_stats.health
	var stamina_left = current_stats.stamina - goal_stats.stamina
	var strength_left = current_stats.strength - goal_stats.strength
	if (health_left + stamina_left + strength_left) != 0:
		current_stats.health -= health_left / (1.0 / %ChangeApplyTimer.wait_time)
		current_stats.stamina -= stamina_left / (1.0 / %ChangeApplyTimer.wait_time)
		current_stats.strength -= strength_left / (1.0 / %ChangeApplyTimer.wait_time)
		update_ui(current_stats, goal_stats)

func _on_start_change_anim_timer_timeout() -> void:
	%ChangeApplyTimer.start()
