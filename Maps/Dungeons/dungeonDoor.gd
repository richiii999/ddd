class_name DungeonDoor extends AnimatedSprite2D ## Opens on trigger from parent (the room)

# TODO: # DungeonRoomDoor also gets put on the main island boss arenas when boss is attacked

func SetOpen(state:bool): 
	# TODO: opening/closing animation
	$Front/CollisionShape2D.set_deferred("disabled", state)
	$Back/CollisionShape2D.set_deferred("disabled", state)
	$PlayerDetector/CollisionShape2D.set_deferred("disabled", state)
	visible = !state
