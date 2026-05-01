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
	load("res://UI/Item/Items/TEST_ITEM2.tscn"),
	load("res://UI/Item/Items/TEST_ITEM3.tscn"), # 3
	
	# MC Test items
	load("res://UI/Item/Items/MCTest/T1_Chest.tscn"),
	load("res://UI/Item/Items/MCTest/T1_Helm.tscn"), # 5
	load("res://UI/Item/Items/MCTest/T1_Offhand.tscn"),
	load("res://UI/Item/Items/MCTest/T1_Sword.tscn"),
	load("res://UI/Item/Items/MCTest/T2_Chest.tscn"),
	load("res://UI/Item/Items/MCTest/T2_Helm.tscn"),
	load("res://UI/Item/Items/MCTest/T2_Offhand.tscn"), # 10
	load("res://UI/Item/Items/MCTest/T2_Sword.tscn"),
	load("res://UI/Item/Items/MCTest/T3_Chest.tscn"),
	load("res://UI/Item/Items/MCTest/T3_Helm.tscn"),
	load("res://UI/Item/Items/MCTest/T3_Offhand.tscn"),
	load("res://UI/Item/Items/MCTest/T3_Sword.tscn"), # 15
	load("res://UI/Item/Items/MCTest/T4_Chest.tscn"),
	load("res://UI/Item/Items/MCTest/T4_Helm.tscn"),
	load("res://UI/Item/Items/MCTest/T4_Offhand.tscn"),
	load("res://UI/Item/Items/MCTest/T4_Sword.tscn"),
	load("res://UI/Item/Items/MCTest/TX_Diamond.tscn"), # 20
	
	# Jackson's weapons
	load("res://UI/Item/Weapon/WEAPON-ONE.tscn"),
	load("res://UI/Item/Weapon/WEAPON-TWO.tscn"),
	load("res://UI/Item/Weapon/WEAPON-THREE.tscn")
	
]

## Creates a new item with an ID
# NOTE: Does not place it into the world
func ItemByID(itemID:int) -> Item:
	var newItem : Item = null # Create a new item
	
	if itemID < 0: # Negative ID
		newItem = specialItems[itemID * -1].instantiate() 
	else: # Positive ID
		newItem = items[itemID].instantiate() 
	
	newItem.ID = itemID
	return newItem

## Spawns an item via ID
func SpawnItemByID(itemID : int, pos : Vector2): # Spawns items[itemID] at Pos(X,Y)
	if itemID > len(items) - 1 or itemID < (len(specialItems) - 1) * -1:
		push_error("IndexOOB ItemID")
		return
	
	SpawnItem(ItemByID(itemID), pos)

## Places an item into the world
func SpawnItem(item : Item, pos : Vector2): # Spawns given item at Pos(X,Y)
	if item.ID == 0: push_warning("Spawned item without ID")
	
	var groundItem = groundItemScene.instantiate()
	groundItem.item = item
	
	# BUG: Have to manually scale pots (they dont autoscale Idk why), coins work tho
	if item.ID in [specialID.HPot, specialID.MPot]: 
		groundItem.find_child("ItemSlot").scale = Vector2(6,6)
	
	call_deferred("add_child", groundItem) # Place the GroundItem in the world
	get_tree().process_frame.connect(groundItem.set_global_position.bind(pos), CONNECT_ONE_SHOT)
