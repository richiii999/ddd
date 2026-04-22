extends Control
signal deathButtonPressed
signal DebugDeath

# Signal for when button is pressed
func _on_button_pressed() -> void:
	deathButtonPressed.emit()

# Signal for debug revive
func _on_debug_restart_pressed() -> void:
	DebugDeath.emit()
