class_name Shop extends Node
## Shop: Opens a shop GUI that u can spend coins at for items / pots

var currPlayer = null # Ref to player (set when u open the shop)
@export var items : Array[PackedScene] # Put item scenes in editor

var invSlot = preload("res://UI/RMenu/Inventory/inv_slot.tscn")

func _ready():
	$InteractComponent.Interact.connect(ToggleShopGUI)
	
	var i : int = 0
	for item in items:
		var slot = invSlot.instantiate()
		$ShopGUI/GridContainer.add_child(slot)
		
		# TODO Price and label
		#var itemLabel = 
		#var priceLabel
		
		slot.slotNumber = i
		slot.slotClicked.connect(BuyItem) # SlotN is emitted with this signal
		slot.UpdateSlot(items[i].instantiate()) # Add item to slot
		i += 1

# Dialogue text is visible for a few seconds then goes away automatically
func ToggleShopGUI(player):
	$ShopGUI.visible = !$ShopGUI.visible if player != null else false # Hide GUI if player leaves
	currPlayer = player

func ItemInSlot(slotN:int) -> Item: return $ShopGUI/GridContainer.get_child(slotN).item

func BuyItem(slotN:int):
	if slotN > $ShopGUI/GridContainer.get_child_count() - 1: push_error("IndexOOB on shop slot"); return
	if currPlayer == null: push_error("null player tried to buy"); return
	
	var item = ItemInSlot(slotN)
	print("Player tried to buy " + str(item))
	if not currPlayer.Inv.FirstEmptyInvSlot():
		# BUG: Full inv is not triggering
		currPlayer.StatusLabel.addStatusText("Full Inv!", "RED")
	elif currPlayer.coins < item.price:
		currPlayer.StatusLabel.addStatusText("U R BROKE!", "RED")
	else:
		currPlayer.incCoins(item.price * -1)
		currPlayer.Inv.PutItemInSlot(currPlayer.Inv.FirstEmptyInvSlot(), item)
