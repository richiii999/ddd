class_name GroundItem extends Node2D

@export var TTL : float = 15.00 # Time for an item to despawn (sec)
@export var item : Item = null 

func _ready(): 
	z_index = 10 # Render above floor
	
	# Despawn Timer
	$TTL.one_shot = true
	$TTL.connect("timeout", queue_free)
	$TTL.start(TTL)
	
	# Fade Timer (always relative to TTL value)
	$Fade.connect("timeout", fadeOut)
	$Fade.start(TTL / 3)
	
	if (item == null): # Item not set
		print_debug("Item not set for GroundItem, using TestItem")
		item = load("res://UI/Item/Items/TEST_ITEM.tscn").instantiate()
	
	$ItemSlot.add_child(item)

func fadeOut(): # Fade 20% every 1/5 of TTL
	print("fade")
	set_modulate(Color(get_modulate(), $TTL.time_left / TTL))
