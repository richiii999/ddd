class_name SaveMgr extends Node
## SaveMgr: Contains functions for saving and loading player & bank data from files
# [https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html]

var playerFilePath : String = "user://PlayerData.ddd"
var bankFilePath : String = "user://BankData.ddd"

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

## Returns itemIDs for each bankslot
# Format: "Bank<slotN>": <itemID>
func BankData(B:Bank) -> Dictionary:
	var bankData = {} # Read each bank slot and put it in the dict
	for i in range(B.bankSlots): bankData["Bank"+str(i)] = B.ItemIDInSlot(i)
	
	print("Saving BankData as: " + str(bankData))
	return bankData

## Save data to filePath
func SaveToFile(data:Dictionary, filePath:String) -> void:
	FileAccess.open(filePath, FileAccess.WRITE).store_line(JSON.stringify(data))

## Saves the given player & bank information to separate files
# Linux: ~/.local/share/godot/app_userdata/DotDD/
# Windows: TODO: somebody put the windows location here
func SaveGame(P:Player, B:Bank) -> void:
	print("Saving game to " + str(OS.get_data_dir()))
	SaveToFile(PlayerData(P), playerFilePath)
	SaveToFile(BankData(B), bankFilePath)

## NOTE: Load functions split in two, to make it easier

## Read bankData from a file, returns array of itemIDs
# 90% copy-pasted from the godot docs
# Returns [] if nothing found
func LoadBank() -> Array[int]:
	print("Loading bank data from " + str(bankFilePath))
	if randi() % 10000 == 1: # RNG delete entire bank
		SaveToFile({}, bankFilePath)
		print("You got robbed LMAO")
	
	if not FileAccess.file_exists(bankFilePath):
		push_warning("BankData not found on disk")
		return []
	
	# Open the file
	var bankFile = FileAccess.open(bankFilePath, FileAccess.READ)
	
	# Creates the helper class to interact with JSON.
	var json = JSON.new()
	while bankFile.get_position() < bankFile.get_length():
		var json_string = bankFile.get_line()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		if not json.parse(json_string) == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
	
	var bankData : Array[int] = [] # Append IDs to bankData (including slots with ID=0, they are just empty)
	for slot in json.data: bankData.append(json.data[slot])
	
	return bankData
