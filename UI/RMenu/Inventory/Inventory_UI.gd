extends Control ## Inventory: Stores the slots for gear, items, and the mouse
# Interfaces with root/ItemSpawner to drop items on ground

# Refs to parts of the Player
@onready var player : Player = Tools.FindParentByType(self, Player)
@onready var itemPickupRange : SmartArea = player.find_child("ItemPickupRange")
@onready var itemSpawner = get_node("/root/GameManager/ItemSpawner")

# Position of the inventory's origin relative to game's origin
# NOTE: Offset by a few extra pixels (20) to avoid overlapping the mouse
@export var MouseOffset : Vector2i = Vector2i(995 - 20, 295 - 20)

# All items are stored in an array: [0 Mouse, 1 Ground, 2-7 Gear, 8-16 Items]
# NOTE: Mouse and Ground slots are special
# Gear has a "Type", which restricts what slot the item can be placed in.
enum Slot {
MOUSE, GROUND, 
HELM, CHEST, RING1, 
MAINHAND, OFFHAND, RING2, 
INV1, INV2, INV3, 
INV4, INV5, INV6, 
INV7, INV8, INV9
}

@onready var Slots : Array = [
%MouseSlot, %GroundSlot, 
%Gear_Slot0, %Gear_Slot1, %Gear_Slot2, 
%Gear_Slot3, %Gear_Slot4, %Gear_Slot5, 
%Inv_Slot0, %Inv_Slot1, %Inv_Slot2, 
%Inv_Slot3, %Inv_Slot4, %Inv_Slot5, 
%Inv_Slot6, %Inv_Slot7, %Inv_Slot8
]

@export var Inv : Array[Item] = [
null, null, 
null, null, null, 
null, null, null, 
null, null, null, 
null, null, null, 
null, null, null
]

# Emitted to player when changing items
signal UpdateInvStats(increase:bool, stats : Dictionary) 

# Emitted when dropping an item, with the dropped item and position
signal dropItem

func _ready(): 
	UpdateInvStats.connect(player.UpdateStats)
	dropItem.connect(itemSpawner.SpawnItem)
	
	
	for i in len(Slots):
		Slots[i].slotNumber = i # Assign slotNumber
		Slots[i].slotClicked.connect(SlotClick) # Connect the slot's signal
	
	# Default inventory, debug items
	var testItem = load("res://UI/Item/Items/Special/TEST_ITEM.tscn").instantiate()
	# Deferred since player isnt ready() yet
	call_deferred("PutItemInSlot", 8, testItem)
	call_deferred("PutItemInSlot", 12, testItem)
	call_deferred("PutItemInSlot", 16, testItem)


func _process(_delta): 
	if Inv[Slot.MOUSE]: # Move the mouse slot to the mouse
		$MouseSlot.position = Tools.VecSub(get_global_mouse_position(), MouseOffset)

func ValidateSlot(SlotN : int, item : Item) -> bool:
	return ( 
	item == null || # Empty mouse
	item.type == -1 || # Unset type, any slot allowed
	SlotN == 0 || # Mouse slot always allowed
	SlotN in range(Slot.INV1,Slot.INV9 + 1) || # Inventory slots always allowed
	item.type == item.Types.HELM && SlotN == Slot.HELM || # Helmet
	item.type == item.Types.CHEST && SlotN == Slot.CHEST || # Chest
	item.type == item.Types.RING && (SlotN == Slot.RING1 || SlotN == Slot.RING2) || # Ring (either)
	item.type == item.Types.MAINHAND && SlotN == Slot.MAINHAND || # Mainhand
	item.type == item.Types.OFFHAND && SlotN == Slot.OFFHAND # Offhand
	)

func SlotClick(SlotA:int, SlotB:int = Slot.MOUSE) -> void:
	print("Inv: " + str(SlotA) + "<->" + str(SlotB) + "  " + str(Inv[SlotA]) + "<->" + str(Inv[SlotB]))
	
	if !ValidateSlot(SlotA, Inv[SlotB]): # Wrong slot, do not swap
		player.StatusLabel.addStatusText("Wrong Slot!", "GREY")
		return
	
	# Swap the SlotA <-> B
	var tmp:Item = Inv[SlotA]
	Inv[SlotA] = Inv[SlotB]
	Inv[SlotB] = tmp
	
	# Update them with the swapped values
	Slots[SlotA].UpdateSlot(Inv[SlotA])
	Slots[SlotB].UpdateSlot(Inv[SlotB])
	
	# Adjust UI if needed
	%MouseSlot.visible = MouseHasItem()
	Inv[Slot.GROUND] = null # Remove ground items (e.g. after dropping an item), prevent duplication
	
	# Update player stats if changing a gear slot (0's if no item)
	if SlotA in range(Slot.HELM, Slot.INV1):
	# REMOVE old item
		if Inv[SlotB]:
			UpdateInvStats.emit(false, Inv[SlotB].stats)
	# ADD new item
		if Inv[SlotA]:
			UpdateInvStats.emit(true, Inv[SlotA].stats)

## Returns first empty slot [8-16] or -1 if full
func FirstEmptyInvSlot() -> int: 
	var first : int = Inv.slice(Slot.INV1).find(null) 
	# + because the slice's index 0 maps to original index 7
	return ( -1 if (first == -1) else first + Slot.INV1 ) 

## Does the mouse have an item in it?
func MouseHasItem() -> bool: return true if Inv[Slot.MOUSE] else false 

## Put an item in inv slot
# NOTE: Item must be a valid type for the slot
# NOTE: This will overwrite any existing item in the slot
func PutItemInSlot(slotN:int, item:Item): 
	Inv[Slot.GROUND] = item.duplicate() if item else null # Put item in 'Ground' slot
	SlotClick(slotN, Slot.GROUND) # Then perform update on inv (moves into inv, deleted ground item)

## 'Q' to pickup / drop items on ground
func Loot() -> void: 
	if MouseHasItem(): DropItem()
	else: PickItem()

## Pickup a nearby item from the ground
func PickItem() -> void:
	if (itemPickupRange.smartArea.is_empty()): 
		player.StatusLabel.addStatusText("No Item on ground", "Gray")
		return
		
	var openSlot : int = FirstEmptyInvSlot()
	# First groundItem has priority, but can still pick up other items if it fails
	# ex. full on HPots, try to pickup HPot but fail -> go to next item (prevent blocking)
	for groundItem in itemPickupRange.smartArea.filter(func(node): return node is GroundItem):
		var item:Item = groundItem.item # Get the item from the GroundItem
		
		# null shouldnt break inv, but still shouldnt happen (problem with the item usually)
		if (item == null): push_warning("Null item looted, skipping"); continue
		
		# Special items
		if item.ID < 0:
			match item.ID:
				-2: # Coin
					player.incCoins(1) 
				-3: # HPot
					if player.HPotC == player.HPotmax:
						player.StatusLabel.addStatusText("Full Health pots!", "GOLD")
						continue # Prevent blocking
					else: 
						player.incHPot(1)
				-4: # MPot
					if player.MPotC == player.MPotmax:
						player.StatusLabel.addStatusText("Full Mana pots!", "GOLD")
						continue # Prevent blocking
					else: 
						player.incMPot(1)
			
			groundItem.queue_free()
			return # Only pick up 1 item per press
		
		# No open slot
		elif (openSlot == -1):
			player.StatusLabel.addStatusText("Full inv!", "Gray")
			return
		
		else:
			PutItemInSlot(openSlot, item)
			groundItem.queue_free() # Delete grounditem after
			return # Only pick up 1 item per press

## Drop the item in mouse on the ground
func DropItem():
	if MouseHasItem(): dropItem.emit(Inv[Slot.MOUSE], player.global_position)
	else: push_warning("Tried to drop null item") # Null case: shouldnt happen, see Loot()
	
	SlotClick(Slot.MOUSE, Slot.GROUND) # Delete item in MOUSE

## Check for a specific item in inv, returning the slotN it's in (-1 if not found)
func HasItem(item:Item) -> int: return HasItemID(item.ID)
func HasItemName(itemName:String) -> int:
	for i in range(len(Inv)):
		if Inv[i] and Inv[i].itemName == itemName: return i
	return -1
func HasItemID(id:int) -> int:
	if id == 0: push_warning("Searching for ItemID:0")
	
	for i in range(len(Inv)):
		if Inv[i] and Inv[i].ID == id: return i
	return -1
