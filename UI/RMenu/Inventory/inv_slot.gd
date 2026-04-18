extends Button ## Inventory (SLOT): Control whats displayed, Signals when the slot is clicked

var slotNumber : int = 0 # Keeping track of the slot (Set by the inventory)

# Changes the displayed sprite (Called by the inventory)
func UpdateSlot(newItem:Item = null) -> void: $Display_Sprite.texture = newItem.texture if (newItem) else null

signal Slot_Clicked

func _pressed(): 
	#print("[Signal T]: SlotN = " + str(slotNumber))
	Slot_Clicked.emit(slotNumber)
