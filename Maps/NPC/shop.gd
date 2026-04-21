class_name Shop extends Node
## Shop: Opens a shop GUI that u can spend coins at for items / pots
# NOTE: Interaction signal comes with a ref to player, hence the _Player param (trashing since we dont use it)

func _ready():
	$InteractComponent.Interact.connect(ToggleShopGUI)

# Dialogue text is visible for a few seconds then goes away automatically
func ToggleShopGUI(_Player):
	$ShopGUI.visible = !$ShopGUI.visible
