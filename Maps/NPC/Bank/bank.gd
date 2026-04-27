class_name Bank extends Node ## Bank: Players can store items that persist through death.

var currPlayer = null # Ref to player (set when u open the bank)

@export var bankSlots : int = 8 # How many bankslots?

var invSlot = preload("res://UI/RMenu/Inventory/inv_slot.tscn")

func _ready():
	$InteractComponent.Interact.connect(ToggleBankGUI)
	
	for i in range(bankSlots): # Create bankslots
		var slot = invSlot.instantiate()
		$BankGUI/GridContainer.add_child(slot)
		
		slot.slotNumber = i
		slot.slotClicked.connect(BankSwap) # SlotN is emitted with this signal

## Open / close the bank GUI
func ToggleBankGUI(player):
	$BankGUI.visible = !$BankGUI.visible if player != null else false # Hide GUI if player leaves
	currPlayer = player

## Return Item or ID for a given slotN
func ItemInSlot(slotN:int) -> Item: return $BankGUI/GridContainer.get_child(slotN).item
func ItemIDInSlot(slotN:int) -> int: 
	if $BankGUI/GridContainer.get_child(slotN).item:
		return $BankGUI/GridContainer.get_child(slotN).item.ID
	else: return 0

## Put item in slotN
func PutItemInSlot(slotN:int, item:Item): 
	if $BankGUI/GridContainer.get_child(slotN) == null: 
		push_error("IndexOOB on BankSlot")
		return
	
	$BankGUI/GridContainer.get_child(slotN).UpdateSlot(item, true)

func BankSwap(bankSlotN:int):
	if bankSlotN > $BankGUI/GridContainer.get_child_count() - 1: push_error("IndexOOB on bank slot"); return
	if currPlayer == null: push_error("null player tried to BankSwap"); return
	
	var bankItem = ItemInSlot(bankSlotN)
	var playerItem = currPlayer.Inv.ItemInSlot(currPlayer.Inv.Slot.MOUSE)
	print("BankSwap " + str(bankSlotN) + ": " + str(bankItem) + "<->" + str(playerItem))
	
	# Swap bank <-> player items
	PutItemInSlot(bankSlotN, playerItem)
	currPlayer.Inv.PutItemInSlot(currPlayer.Inv.Slot.MOUSE, bankItem)
