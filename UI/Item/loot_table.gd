class_name LootTable extends Node ## LootTable: Stores {itemID : weight} and Roll()
# This is a separate node so that it can be used as a component in multiple different things
# ex. both Enemies and DungeonRooms need a loot table, this reduces duplication

@export var numRolls : int = 1 # How many rolls to the table
@export var lootTable : Dictionary[int, int] = { 0 : 1 } # { itemID : weight}, 0 = no item
var sumWeights : int = 0 # Total weight in lootTable (set on ready)

signal SpawnItem # Signal to ItemSpawner global node, with the (itemID, pos)

func _ready(): for ID in lootTable: sumWeights += lootTable[ID] # Sum the weights

func DropItem(pos:Vector2 = Vector2.ZERO, itemID:int = -1): # Attempts to signal to ItemSpawner to drop an item
	var itemSpawner = get_node("/root/GameManager/ItemSpawner")
	if itemSpawner == null: 
		push_warning("ItemSpawner not found! Skipping DropItem()")
		return
	if itemID == -1: itemID = RollForItem() # Unspecified ID, use RNG to decide
	if itemID == 0: return # Drop nothing on a roll of ID 0
	if lootTable[itemID] == null: # Invalid itemID, return early
		push_warning("itemID not in lootTable")
		return
	
	SpawnItem.connect(itemSpawner.SpawnItemByID, CONNECT_ONE_SHOT) # Signal to ItemSpawner to spawn the item
	SpawnItem.emit(itemID, Tools.NudgeVec2(pos, 50)) # Slight nudge to pos to prevent stacking

func RollForItem() -> int: # Uses weighted RNG to pick an ID from the lootTable
	# Dumb way of doing it, there has to be a better way for sure.
	var RNG = randi() % sumWeights + 1 # Roll RNG out of the total weight
	print("LootTable rolled " + str(RNG) + " out of " + str(sumWeights))
	
	for ID in lootTable: 
		RNG -= lootTable[ID] # Decrement weight
		if RNG <= 0: # Once <= 0, stop and use the current ID
			print("LootTable chose itemID: " + str(ID))
			return ID
	
	push_error("LootTable roll failed! final RNG=" + str(RNG))
	return 0 # Drop nothing on fail
