extends Control ## Inventory: Stores the slots for gear, items, and the mouse. Handles pick/drop 'Q'

# Refs to parts of the Player
@onready var player : Player = Tools.FindParentByType(self, Player)
@onready var itemPickupRange : SmartArea = player.find_child("ItemPickupRange")
@onready var itemSpawner = get_node("/root/GameManager/ItemSpawner")
@onready var pickup: AudioStreamPlayer = $pickup

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
INV0, INV1, INV2, 
INV3, INV4, INV5, 
INV6, INV7, INV8
}

@onready var Slots : Array = [
%MouseSlot, %GroundSlot, 
%Gear_Slot0, %Gear_Slot1, %Gear_Slot2, 
%Gear_Slot3, %Gear_Slot4, %Gear_Slot5, 
%Inv_Slot0, %Inv_Slot1, %Inv_Slot2, 
%Inv_Slot3, %Inv_Slot4, %Inv_Slot5, 
%Inv_Slot6, %Inv_Slot7, %Inv_Slot8
]

# Emitted to Player when equipping gear
signal UpdateInvStats(increase:bool, stats : Dictionary) 
# Emitted to itemSpawner when dropping an item
signal dropItem(item:Item, pos:Vector2)

func _ready(): 
	UpdateInvStats.connect(player.UpdateStats)
	dropItem.connect(itemSpawner.SpawnItemByID)
	
	for i in len(Slots):
		Slots[i].slotNumber = i # Assign slotNumber
		Slots[i].slotClicked.connect(SlotClick) # Connect the slot's signal

func _process(_delta): 
	if ItemInSlot(Slot.MOUSE): # Move the mouse slot to the mouse
		$MouseSlot.position = Tools.VecSub(get_global_mouse_position(), MouseOffset)

## Initialize stats from a fresh inventory
# NOTE: This should only be called after loading inventory from a save, otherwise it may dupe stats
func InitStats() -> void:
	for slotN in range(Slot.HELM, Slot.INV0): # Gear slots
		if ItemInSlot(slotN) != null:
			UpdateInvStats.emit(true, ItemInSlot(slotN).stats)

func ValidateSlot(SlotN : int, item : Item) -> bool:
	return ( 
	item == null || # Empty mouse
	item.type == -1 || # Unset type, any slot allowed
	SlotN == 0 || # Mouse slot always allowed
	SlotN in range(Slot.INV0,Slot.INV8 + 1) || # Inventory slots always allowed
	item.type == item.Types.HELM && SlotN == Slot.HELM || # Helmet
	item.type == item.Types.CHEST && SlotN == Slot.CHEST || # Chest
	item.type == item.Types.RING && (SlotN == Slot.RING1 || SlotN == Slot.RING2) || # Ring (either)
	item.type == item.Types.MAINHAND && SlotN == Slot.MAINHAND || # Mainhand
	item.type == item.Types.OFFHAND && SlotN == Slot.OFFHAND # Offhand
	)

## Swap the items in SlotA <-> SlotB, usually B = mouse and A = inventory
func SlotClick(SlotA:Slot, SlotB:Slot = Slot.MOUSE) -> void:
	print("Inv: " + str(SlotA) + "<->" + str(SlotB) + "  " + str(ItemInSlot(SlotA)) + "<->" + str(ItemInSlot(SlotB)))
	
	if !ValidateSlot(SlotA, ItemInSlot(SlotB)): # Wrong slot, do not swap
		player.StatusLabel.addStatusText("Wrong Slot!", "GREY")
		return
	
	# Swap the items A <-> B
	var tmp:Item = ItemInSlot(SlotA)
	PutItemInSlot(SlotA, ItemInSlot(SlotB))
	PutItemInSlot(SlotB, tmp)
	
	# Remove ground items (e.g. after dropping an item), prevent duplication
	PutItemInSlot(Slot.GROUND, null) 
	
	# Update player stats if changing a gear slot
	if SlotA in range(Slot.HELM, Slot.INV0):
	# REMOVE old item
		if ItemInSlot(SlotB) != null:
			UpdateInvStats.emit(false, ItemInSlot(SlotB).stats)
	# ADD new item
		if ItemInSlot(SlotA) != null:
			UpdateInvStats.emit(true, ItemInSlot(SlotA).stats)

## Returns first empty inventory slot [8-16] or -1 if full
func FirstEmptyInvSlot() -> int: 
	for slotN in range(Slot.INV0, Slot.INV8 + 1):
		if ItemInSlot(slotN) == null: return slotN
	return -1

## 'Q' to pickup / drop items on ground
func Loot() -> void: 
	if ItemInSlot(Slot.MOUSE): DropItem()
	else: 
		PickItem()

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
						pickup.play()
				-4: # MPot
					if player.MPotC == player.MPotmax:
						player.StatusLabel.addStatusText("Full Mana pots!", "GOLD")
						continue # Prevent blocking
					else: 
						player.incMPot(1)
						pickup.play()
			
			groundItem.queue_free()
			return # Only pick up 1 item per press
		
		# No open slot
		elif (openSlot == -1):
			player.StatusLabel.addStatusText("Full inv!", "Gray")
			return
		
		else:
			PutItemInSlot(openSlot, item)
			groundItem.queue_free() # Delete grounditem after
			pickup.play()
			return # Only pick up 1 item per press

## Drop the item in mouse on the ground
func DropItem():
	var mouseItem = ItemInSlot(Slot.MOUSE)
	if mouseItem: 
		if mouseItem.tier == 4: # Quest Item
			player.StatusLabel.addStatusText("Cant drop Quest Item!")
			return
		dropItem.emit(mouseItem.ID, player.global_position)
	else: push_warning("Tried to drop null item") # Null case: shouldnt happen, see Loot()
	
	SlotClick(Slot.MOUSE, Slot.GROUND) # Delete item in MOUSE

## Check for a specific item in inv, returning the slotN it's in (-1 if not found)
func HasItem(item:Item) -> int: return HasItemID(item.ID)
func HasItemName(itemName:String) -> int:
	for i in range(len(Slots)):
		if ItemInSlot(i) != null and ItemInSlot(i).name == itemName: return i
	return -1
func HasItemID(id:int) -> int:
	if id == 0: push_warning("Searching for ItemID:0")
	
	for i in range(len(Slots)):
		if ItemInSlot(i) != null and ItemInSlot(i).ID == id: return i
	return -1

## Return the item (or ID) in slotN (null or 0 if none)
func ItemInSlot(slotN:Slot) -> Item: 
	return Slots[slotN].item
func ItemIDInSlot(slotN:Slot) -> int: 
	var item = ItemInSlot(slotN)
	if item != null: return Slots[slotN].item.ID 
	else: return 0

## Put an item in inv slot
# NOTE: Item may not be a valid type for the slot
# NOTE: This will overwrite any existing item in the slot
func PutItemInSlot(slotN:int, item:Item): 
	Slots[slotN].UpdateSlot(item)
	%MouseSlot.visible = (ItemInSlot(Slot.MOUSE) != null) # Adjust Mouse UI visibility
