extends Control ## Inventory (MAIN): Interfaces with the slots for gear, items, and the mouse


## TODO: Later, can change the UI layout to left, right, top, bottom, whatever
# which is just mirrored or setting the anchor to Top Left instead of Top Right
# Bottom layout: 1 row, many column: [Player Icon] [Playername] [HP] [Mana] [gear slots] [inventory slots] [minimap]

## I fuckin hate anchors. Why is it so hard to scale things to the screen? 
# I litterally just locked the resolution of the game to 1280x720 to fix it "temporarily" (forever)
# TODO: ^ probably should lock it to 2k res and use scaling or whatever.

# All items are stored in an array: [0 Mouse, 1-6 Gear, 7-15 Items]
# Items have a "Type" int, which restricts what slot the item can be placed in.
enum Slot {MOUSE, GROUND, HELM, CHEST, RING1, MAINHAND, OFFHAND, RING2, INV1, INV2, INV3, INV4, INV5, INV6, INV7, INV8, INV9}
@onready var Slots : Array = [%MouseSlot, %GroundSlot, %Gear_Slot0, %Gear_Slot1, %Gear_Slot2, %Gear_Slot3, %Gear_Slot4, %Gear_Slot5, %Inv_Slot0, %Inv_Slot1, %Inv_Slot2, %Inv_Slot3, %Inv_Slot4, %Inv_Slot5, %Inv_Slot6, %Inv_Slot7, %Inv_Slot8]
@export var Inv : Array[Item] = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]

signal UpdateInvStats(increase:bool, type:int, sourceStats:Array) # Emitted to player when changing items

func _ready(): 
	UpdateInvStats.connect(find_parent("Player").UpdateStats)
	
	# Default inventory, debug items
	Inv[Slot.INV1] = load("res://UI/Item/Items/TEST_ITEM.tscn").instantiate()
	Inv[Slot.INV5] = load("res://UI/Item/Items/TEST_ITEM.tscn").instantiate()
	Inv[Slot.INV9] = load("res://UI/Item/Items/TEST_ITEM.tscn").instantiate()
	
	for i in len(Slots):
		Slots[i].slotNumber = (i) # Assign slotNumber
		Slots[i].Slot_Clicked.connect(_on_Slot_Click) # Connect the slot's signal
		Slots[i].UpdateSlot(Inv[i]) # Updates all the slot nodes according to Inv[]
		
	print("First Empty SlotNum = " + str(firstEmptyInvSlot()))

# Position of the inventory's origin relative to game's origin
# Offset by a few extra pixels (ex. 12) to avoid overlapping the mouse
@export var MouseOffset : Vector2i = Vector2i(995 - 20, 295 - 20) 

func _process(_delta):
	$MouseSlot.position = Tools.VecSub(get_global_mouse_position(), MouseOffset)

# Inv management: When click on slot, swap with mouse slot. 
# TODO: If "Q" with item in mouse, drop in bag. 
# TODO: bag despawns with important item gets sent to mail

func ValidateSlot(SlotN : int, item : Item) -> bool:
	return ( 
	item == null || # Empty mouse
	item.type == -1 || # Unset type, any slot allowed
	SlotN in range(Slot.INV1,Slot.INV9 + 1) || # Inventory slots always allowed
	item.type == item.Types.HELM && SlotN == Slot.HELM || # Helmet
	item.type == item.Types.CHEST && SlotN == Slot.CHEST || # Chest
	item.type == item.Types.RING && (SlotN == Slot.RING1 || SlotN == Slot.RING2) || # Ring (either)
	item.type == item.Types.MAINHAND && SlotN == Slot.MAINHAND || # Mainhand
	item.type == item.Types.OFFHAND && SlotN == Slot.OFFHAND # Mainhand
	)

func _on_Slot_Click(SlotA:int, SlotB:int = Slot.MOUSE) -> void:
	print("[Signal R]: Slots: " + str(SlotA) + "<->" + str(SlotB) + "  " + str(Inv[SlotA]) + "<->" + str(Inv[SlotB]))
	
	if !ValidateSlot(SlotA, Inv[SlotB]): # Wrong slot, do not swap
		find_parent("Player").find_child("Status").addStatusText("Wrong Slot", "GREY")
		return
	
	# Swap the SlotA <-> B
	var tmp:Item = Inv[SlotA]
	Inv[SlotA] = Inv[SlotB]
	Inv[SlotB] = tmp
	
	# Update them with the swapped values
	Slots[SlotA].UpdateSlot(Inv[SlotA])
	Slots[SlotB].UpdateSlot(Inv[SlotB])
	
	# Adjust UI if needed
	%MouseSlot.visible = true if (Inv[Slot.MOUSE]) else false
	%GroundSlot.visible = false
	Inv[Slot.GROUND] = null # Remove ground items (e.g. after dropping an item)
	
	# Update player stats if changing a gear slot (0's if no item)
	if SlotA in range(Slot.HELM, Slot.INV1):
		if Inv[SlotB]: UpdateInvStats.emit(false, 2, Inv[SlotB].Stats)
		else: UpdateInvStats.emit(false, 2, [0,0,0,  0,0,0,  0,0,0]) # Remove curr item
		
		if Inv[SlotA]: UpdateInvStats.emit(true, 2, Inv[SlotA].Stats)
		else: UpdateInvStats.emit(true, 2, [0,0,0,  0,0,0,  0,0,0]) # Add new item

func firstEmptyInvSlot() -> int: # Returns first empty regular inv slot (index of Inv[] range 7-15) or -1 if full
	var first : int = Inv.slice(Slot.INV1).find(null) 
	return ( (-1) if (first == -1) else (first + Slot.INV1) ) # + because the slice's index 0 maps to original index 7
	
func mouseHasItem() -> bool: return true if Inv[Slot.MOUSE] else false # Does the mouse have an item in it?
