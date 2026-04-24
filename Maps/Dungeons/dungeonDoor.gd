class_name DungeonDoor extends StaticBody2D ## Opens on trigger from parent (the room)

# TODO: # DungeonRoomDoor also gets put on the main island boss arenas when boss is attacked

func SetOpen(state:bool): 
	# TODO: opening/closing animation
	$CollisionShape2D.disabled = state
	$Veil.visible = !state
