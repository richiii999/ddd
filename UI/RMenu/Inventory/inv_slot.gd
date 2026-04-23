class_name ItemSlot extends Button ## Item Slot: Stores and displayed an item, signals on click

var slotNumber : int = 0 # Used by parent GUI to keep track of the slot
var item : Item = null # Current item in this slot

# Correspond to item.tier 0-5
var rarityColors : Array[Color] = [Color.WHITE, Color.GREEN, Color.BLUE, Color.PURPLE, Color.GOLD]

func _ready(): UpdateSlot()

# Changes the item (Called by the inventory)
func UpdateSlot(newItem:Item = null) -> void: 
	item = newItem
	if newItem:
		$Display_Sprite.texture = newItem.texture
		$BorderSprite.self_modulate = rarityColors[newItem.tier]
	else:
		$Display_Sprite.texture = null
		$BorderSprite.self_modulate = Color.TRANSPARENT
	

signal slotClicked

func _pressed(): slotClicked.emit(slotNumber)
