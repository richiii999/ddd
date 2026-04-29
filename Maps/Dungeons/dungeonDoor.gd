class_name DungeonDoor extends AnimatedSprite2D ## Opens on trigger from parent (the room)
# DungeonRoomDoors also get put on the world arenas when the boss is attacked

# TODO: arenas

func SetOpen(state:bool): 
	# TODO: opening/closing animation
	$Front/CollisionShape2D.set_deferred("disabled", state)
	$Back/CollisionShape2D.set_deferred("disabled", state)
	$PlayerDetector/CollisionShape2D.set_deferred("disabled", state)
	visible = !state
