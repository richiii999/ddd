class_name ItemSpawner extends Node ## ItemSpawner: Recieves signals to spawn items in the world

var groundItemScene = load("res://UI/Item/ground_item.tscn") # GroundItem node to isntantiate whenever item spawned

var specialItems : Array[Resource] = [ # Negative item IDs
	load("res://UI/Item/Items/TEST_ITEM.tscn"), # -0, shouldnt be possible
	load("res://UI/Item/Items/TEST_ITEM.tscn"), # -1
	load("res://UI/Item/Items/Coin.tscn")       # -2
]

var items : Array[Resource] = [ # Index of this array == "itemID" used throughout the code
	load("res://UI/Item/Items/TEST_ITEM.tscn"), # NOTE: Present in both arrays index 0
	load("res://UI/Item/Items/test_chestplate.tscn")
]

func SpawnItemByID(itemID : int, pos : Vector2): # Spawns items[itemID] at Pos(X,Y)
	if itemID > len(items) - 1 or itemID < (len(specialItems) - 1) * -1:
		push_warning("IndexOOB ItemID") 
		return
	
	var newItem : Item = null # Create a new item
	if itemID < 0: newItem = specialItems[itemID * -1].instantiate()
	else: newItem = items[itemID].instantiate()
	
	SpawnItem(newItem, pos)


func SpawnItem(item : Item, pos : Vector2): # Spawns item at Pos(X,Y)
	
	# TODO: Coordinates check (has tilemap tile at that coord)
		# Not technically necessary but would catch some potential issues
		# such as mismatch between absolute/local position being very far away from intended position
	
	# Attempt 1
	var groundItem = groundItemScene.instantiate()
	groundItem.item = item
	
	add_child(groundItem) # Place the GroundItem in the world
	groundItem.global_position = pos
	
	# Attempt 2
	#var groundItem = groundItemScene.instantiate()
	#groundItem.item = newItem
	#call_deferred("add_child", groundItem) # Place the GroundItem in the world
	## TODO: still not working but atealst no more error
	#get_tree().process_frame.connect(groundItem.set_global_position.bind(pos), CONNECT_ONE_SHOT)
	
