class_name ItemSpawner extends Node ## ItemSpawner: Recieves signals to spawn items in the world

var groundItemScene = load("res://UI/Item/ground_item.tscn") # GroundItem to put items in bags

# Dedicated Enum for special item IDs, since they are so common
enum specialID {TEST_ITEM=-1, Coin=-2, HPot=-3, MPot=-4}

var specialItems : Array[Resource] = [ # Negative item IDs
	load("res://UI/Item/Items/Special/TEST_ITEM.tscn"), # -0, Just to pad index
	load("res://UI/Item/Items/Special/TEST_ITEM.tscn"),
	load("res://UI/Item/Items/Special/Coin.tscn"),
	load("res://UI/Item/Items/Special/HPot.tscn"),
	load("res://UI/Item/Items/Special/MPot.tscn")
]

var items : Array[Resource] = [ # Index of this array == "itemID" used throughout the code
	load("res://UI/Item/Items/Special/TEST_ITEM.tscn"), # NOTE: Present in both arrays at index 0
	load("res://UI/Item/Items/test_chestplate.tscn"),
	load("res://UI/Item/Items/TEST_ITEM2.tscn")
]

func SpawnItemByID(itemID : int, pos : Vector2): # Spawns items[itemID] at Pos(X,Y)
	if itemID > len(items) - 1 or itemID < (len(specialItems) - 1) * -1:
		push_error("IndexOOB ItemID")
		return
	
	var newItem : Item = null # Create a new item
	if itemID < 0: newItem = specialItems[itemID * -1].instantiate() # Negative ID
	else: newItem = items[itemID].instantiate() # Positive ID
	newItem.ID = itemID
	
	SpawnItem(newItem, pos)


func SpawnItem(item : Item, pos : Vector2): # Spawns given item at Pos(X,Y)
	if item.ID == 0: push_warning("Spawned item without ID")
	
	var groundItem = groundItemScene.instantiate()
	groundItem.item = item
	
	call_deferred("add_child", groundItem) # Place the GroundItem in the world
	get_tree().process_frame.connect(groundItem.set_global_position.bind(pos), CONNECT_ONE_SHOT)
