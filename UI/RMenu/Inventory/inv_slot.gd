class_name ItemSlot extends Button ## Inventory (SLOT): Control whats displayed, Signals when the slot is clicked

var slotNumber : int = 0 # Keeping track of the slot (Set by Inventory/Shop on ready)
var item : Item = null # Current item in this slot

# Changes the item (Called by the inventory)
func UpdateSlot(newItem:Item = null) -> void: 
	item = newItem
	$Display_Sprite.texture = newItem.texture if (newItem) else null

signal Slot_Clicked

func _pressed(): 
	#print("SlotN = " + str(slotNumber))
	Slot_Clicked.emit(slotNumber)
