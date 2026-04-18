class_name ItemSpawner extends Node ## ItemSpawner: Recieves signals to spawn items in the world

var groundItemScene = load("res://UI/Item/ground_item.tscn") # GroundItem node to isntantiate whenever item spawned
var items : Array[Resource] = [ # Index of this array == "itemID" used throughout the code
	load("res://UI/Item/Items/TEST_ITEM.tscn"),
	load("res://UI/Item/Items/test_chestplate.tscn")
]

func SpawnItemByID( itemID : int = 0, pos = Vector2(0,0) ): # Spawns items[itemID] @ Pos
	if itemID > len(items) or itemID < 0: # Bounds check
		push_warning("ItemID out of bounds for Items[]") 
		return
	
	# TODO: Coordinates check (has tilemap tile at that coord)
		# Not technically necessary but would catch some potential issues
		# such as mismatch between absolute/local position being very far away from intended position
	
	var item = items[itemID].instantiate() # Create Item and place it in a GroundItem
	var groundItem = groundItemScene.instantiate() 
	groundItem.item = item
	
	call_deferred("add_child", groundItem) # Place the GroundItem in the world (defferred cause of some error idk)
	get_tree().process_frame.connect(groundItem.set_global_position.bind(pos), CONNECT_ONE_SHOT)
	# TODO: still not working but atealst no more error


func SpawnItem( item : Item = null, pos = Vector2(0,0) ): # Spawns item @ Pos
	if item == null: # null case
		push_warning("Invalid item") 
		return
	
	# TODO: Coordinates check (has tilemap tile at that coord)
		# Not technically necessary but would catch some potential issues
		# such as mismatch between absolute/local position being very far away from intended position
	
	var groundItem = groundItemScene.instantiate() 
	groundItem.item = item
	
	add_child(groundItem) # Place the GroundItem in the world
	groundItem.global_position = pos
