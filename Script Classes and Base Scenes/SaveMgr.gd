class_name SaveMgr extends Node
## SaveMgr: Contains functions for saving and loading player & bank data from files
# [https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html]

# Linux: ~/.local/share/godot/app_userdata/DotDD/
# Winbloat: C:/Users/{User}/AppData/Roaming

var playerFilePath: String = "user://PlayerData.ddd"
var bankFilePath  : String = "user://BankData.ddd"
var skillFilePath : String = "user://SkillData.ddd"
var HOFFilePath  : String = "user://HallOfFame.ddd"

## Returns data from the passed player for saving
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
		"SkillPoints" : P.skillPoints
	}
	print("Saving PlayerData as: " + str(playerData))
	return playerData

func LoadSkills() -> Dictionary:
	return ReadFile(skillFilePath)

## Returns itemIDs for each bankslot
# Format: "Bank<slotN>": <itemID>
func BankData(B:Bank) -> Dictionary:
	var bankData = {} # Read each bank slot and put it in the dict
	for i in range(B.bankSlots): bankData["Bank"+str(i)] = B.ItemIDInSlot(i)
	
	print("Saving BankData as: " + str(bankData))
	return bankData

## Saves skill data
func SkillData(P:Player) -> Dictionary:
	#retrieve the skills unlocked already
	var skillsUI = P.find_child("SkillsUI")
	var data = { "chosen_class": skillsUI.chosen_class }
	
	for skill in skillsUI.get_skills():
		data[skill.name] = skill.active
	
	#use persistent data
	for skill_name in skillsUI.subtree_save:
		data["subtree_" + skill_name] = skillsUI.subtree_save[skill_name]
	
	#if subtree IS currently open, also grab live state (overrides saved)
	if skillsUI.has_node("ActiveSubtree"):
		var subtree = skillsUI.get_node("ActiveSubtree")
		for skill in subtree.get_children().filter(func(n): return n is skillButton):
			data["subtree_" + skill.name] = skill.active
	
	return data

## Enters the player into HOF
# Called on death, not exit game
func EnterHOF(P:Player) -> void:
	var date = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)
	var fame = P.Fame
	print("Potential HOF Entry: ", date, " ", fame)
	
	var HOF = LoadHOF()
	HOF[date] = fame # Add new entry
	
	if len(HOF.keys()) > 5:
		HOF.erase(HOF.find_key(HOF.values().min())) # Remove lowest
	
	SaveToFile(HOF, HOFFilePath)
	print("Saved HOF: ", HOF)

## Save data to filePath
func SaveToFile(data:Dictionary, filePath:String) -> void:
	FileAccess.open(filePath, FileAccess.WRITE).store_line(JSON.stringify(data))

## Saves the given player & bank information to separate files
func SaveGame(P:Player, B:Bank) -> void:
	print("Saving game to " + str(OS.get_data_dir()))
	print("Stats at save: ", P.coreStats)
	SaveToFile(PlayerData(P), playerFilePath)
	SaveToFile(BankData(B), bankFilePath)
	SaveToFile(SkillData(P), skillFilePath)

## Read bankData from a file, returns array of itemIDs
# Returns [] if nothing found
func LoadBank() -> Array[int]:
	print("Loading bank data from " + str(bankFilePath))
	if randi() % 10000 == 1: # RNG delete entire bank
		SaveToFile({}, bankFilePath)
		print("You got robbed LMAO")
	
	var bankFile = ReadFile(bankFilePath)
	
	var bankData : Array[int] = [] # Append IDs to bankData (including slots with ID=0, they are just empty)
	for slot in bankFile: bankData.append(bankFile[slot])
	
	return bankData

## Read playerData from a file, returns giant dict (See PlayerData())
func LoadPlayer() -> Dictionary:
	print("Loading player data from " + str(playerFilePath))
	return ReadFile(playerFilePath)

## Read HallOfFame from a file
func LoadHOF() -> Dictionary:
	return ReadFile(HOFFilePath)

## Read a json file into a Dict
# 90% copy-pasted from the godot docs
func ReadFile(filePath:String) -> Dictionary:
	if not FileAccess.file_exists(filePath):
		push_warning("File not found on disk: " + filePath)
		return {}
	
	# Open the file
	var file = FileAccess.open(filePath, FileAccess.READ)
	
	# Creates the helper class to interact with JSON.
	var json = JSON.new()
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		
		if not json.parse(json_string) == OK: # Error checking
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	
	return json.data
