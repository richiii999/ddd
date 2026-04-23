class_name Bank extends Node ## Bank: Players can store items that persist through death.

var currPlayer = null # Ref to player (set when u open the bank)
@export var items : Array[PackedScene] # Put item scenes in editor

@export var bankSlots : int = 8 # How many bankslots?

var invSlot = preload("res://UI/RMenu/Inventory/inv_slot.tscn")

func _ready():
	$InteractComponent.Interact.connect(ToggleBankGUI)
	
	for i in range(bankSlots): # Create bankslots
		var slot = invSlot.instantiate()
		$BankGUI/GridContainer.add_child(slot)
		
		slot.slotNumber = i
		slot.slotClicked.connect(BankSwap) # SlotN is emitted with this signal
		if i < len(items) - 1: slot.UpdateSlot(items[i].instantiate()) # Add item to slot (if present)

# Dialogue text is visible for a few seconds then goes away automatically
func ToggleBankGUI(player):
	$BankGUI.visible = !$BankGUI.visible
	currPlayer = player

func GetItemSlot(slotN:int) -> Item: return $BankGUI/GridContainer.get_child(slotN).item
func SetItemSlot(slotN:int, item:Item): $BankGUI/GridContainer.get_child(slotN).UpdateSlot(item)

func BankSwap(bankSlotN:int):
	if bankSlotN > $BankGUI/GridContainer.get_child_count() - 1: push_error("IndexOOB on bank slot"); return
	if currPlayer == null: push_error("null player tried to BankSwap"); return
	
	var bankItem = GetItemSlot(bankSlotN)
	var playerItem = currPlayer.Inv.Inv[currPlayer.Inv.Slot.MOUSE]
	print("BankSwap " + str(bankSlotN) + ": " + str(bankItem) + "<->" + str(playerItem))
	
	# Swap bank <-> player items
	SetItemSlot(bankSlotN, playerItem)
	currPlayer.Inv.PutItemInSlot(currPlayer.Inv.Slot.MOUSE, bankItem)
