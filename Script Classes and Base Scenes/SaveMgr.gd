class_name SaveMgr extends Node
## Contains functions for saving and loading from a file

## Returns data from the passed player for saving
# TODO: For now, dont save their stats or skills, must re-pick skills when reloading a save
func PlayerData(P:Player) -> Dictionary:
	var playerData = {
		# Progress
		"Fame" : P.Fame,
		"Level": P.Level,
		"XP"   : P.XP,
		# Consumables
		"HPotC": P.HPotC,
		"MPotC": P.MPotC,
		"Coins": P.coins,
		# Items: Store the ID only, when loading the ID can be used to spawn them in again
		"Helm" : P.Inv.ItemIDInSlot(P.Inv.Slot.HELM),
		"Chest": P.Inv.ItemIDInSlot(P.Inv.Slot.CHEST),
		"Main" : P.Inv.ItemIDInSlot(P.Inv.Slot.MAINHAND),
		"Off"  : P.Inv.ItemIDInSlot(P.Inv.Slot.OFFHAND),
		"Ring1": P.Inv.ItemIDInSlot(P.Inv.Slot.RING1),
		"Ring2": P.Inv.ItemIDInSlot(P.Inv.Slot.RING2),
		"Inv0" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV0),
		"Inv1" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV1),
		"Inv2" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV2),
		"Inv3" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV3),
		"Inv4" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV4),
		"Inv5" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV5),
		"Inv6" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV6),
		"Inv7" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV7),
		"Inv8" : P.Inv.ItemIDInSlot(P.Inv.Slot.INV8),
	}
	print("Saving PlayerData as: " + str(playerData))
	return playerData
