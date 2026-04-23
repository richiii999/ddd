class_name ItemSlot extends Button ## Item Slot: Stores and displayed an item, signals on click

var slotNumber : int = 0 # Used by parent GUI to keep track of the slot
var item : Item = null # Current item in this slot

# Changes the item (Called by the inventory)
func UpdateSlot(newItem:Item = null) -> void: 
	item = newItem
	$Display_Sprite.texture = newItem.texture if (newItem) else null

signal slotClicked

func _pressed(): slotClicked.emit(slotNumber)
