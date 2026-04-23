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
		slot.Slot_Clicked.connect(BuyItem) # SlotN is emitted with this signal
		if i < len(items) - 1: slot.UpdateSlot(items[i].instantiate()) # Add item to slot (if present)

# Dialogue text is visible for a few seconds then goes away automatically
func ToggleBankGUI(player):
	$BankGUI.visible = !$BankGUI.visible
	currPlayer = player

func ItemInSlot(slotN:int) -> Item: 
	return $BankGUI/GridContainer.get_child(slotN).item

func BankSwap(bankSlotN:int, playerSlotN:int):
	if bankSlotN > $BankGUI/GridContainer.get_child_count(): push_error("IndexOOB on shop slot"); return
	if currPlayer == null: push_error("null player tried to buy"); return
	
	var item = ItemInSlot(bankSlotN)
	print("BankSwap: " + str(item))
	if item == null: return # Skip empty slot
	
	if not currPlayer.Inv.FirstEmptyInvSlot():
		# BUG: Full inv is not triggering
		currPlayer.StatusLabel.addStatusText("Full Inv!", "RED")
	elif currPlayer.coins < item.price:
		currPlayer.StatusLabel.addStatusText("U R BROKE!", "RED")
	else:
		currPlayer.incCoins(item.price * -1)
		currPlayer.Inv.PutItemInSlot(currPlayer.Inv.FirstEmptyInvSlot(), item)
