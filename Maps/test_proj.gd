extends Node2D

@onready var pattern = $ProjectilePattern

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_QUOTELEFT:  # tilde key
			pattern.Emit(ProjectilePattern.PatternType.CIRCLE, 8)
