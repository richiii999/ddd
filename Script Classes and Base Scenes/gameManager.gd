class_name GameManager extends Node ## Controls the game. The "Main" scene of the game

# "ParticleTrasher" Node is where a projectile GPUParticle2D's go while they are expiring
	# Needed since if you just free() a particle, they immediately dissapear instead of expiring.
# "ItemSpawner" Node gets signaled by various things to spawn items in the world (ex. when a mob dies)

@export var nexus_tscn: PackedScene
@export var world_tscn: PackedScene
@export var dungeons: Array[PackedScene]
var mapOffset : Vector2 = Vector2(99999,0) # Offset each added map by this much
func AddMap(map): $Maps.add_child(map); map.global_position += mapOffset; mapOffset += mapOffset

## Player
@export var player_tscn: PackedScene 
@export var mainmenu_tscn: PackedScene

## Refs to Stuff
@onready var nexus: WorldBASE = nexus_tscn.instantiate()
@onready var world: WorldBASE = world_tscn.instantiate()
@onready var player: Player = player_tscn.instantiate()
@onready var mainMenu: MainMenu = mainmenu_tscn.instantiate()

## Save Manager instance
var Save = SaveMgr.new() # Create a SaveMgr instance to allow for saving

func _ready():
	# Put the Nexus, OpenWorld, and Player into the scene tree
	AddMap(nexus)
	AddMap(world)
	for DG in dungeons: AddMap(DG.instantiate())
	$Players.add_child(player)
	
	# Setup player, but disable controls for now
	player.death.connect(DeathHandling)
	player.hide()
	player.find_child("RMenu").hide()
	player.InputStatus = false

	
	#Main Menu Handling
	#canvas allows us to keep the main menu seperate from all the other assets in the game (TLDR)
	var canvas = CanvasLayer.new() 
	add_child(canvas)
	canvas.add_child(mainMenu)
	
	mainMenu.escapeMenu = player.find_child("EscMenu") #pass in the child directly rather than us just hardcoding this shit in
	mainMenu.escapeMenu.mainMenuButton.connect(mainMenu.ActivateMainMenu)
	mainMenu.show()
	mainMenu.quitPressed.connect(quitGame)
	mainMenu.playPressed.connect(Play)
	mainMenu.escHandling.connect(ActivatingMainMenu)
	player.find_child("PlayerCam").InstantMove(mainMenu.global_position)

# signal function when play is pressed that starts player movement
func Play():
	LoadData(player, nexus.find_child("Bank"))
	InitialSetup()
	player.show()
	player.InputStatus = true
	player.find_child("RMenu").show()
	#update player UI
	player.UpdateUIBars()

func ActivatingMainMenu():
	#print("ActivatingMainMenu called")
	player.InputStatus = false
	player.velocity = Vector2.ZERO
	#mainMenu.set_position(player.position)
	#print("player pos: " + str(player.position) + " | mainMenu pos: " + str(mainMenu.position))
	player.hide()
	player.find_child("RMenu").hide()
	player.find_child("EscMenu").hide()
	mainMenu.show()
	#print("mainMenu visible: " + str(mainMenu.visible))
	#player.find_child("PlayerCam").InstantMove(mainMenu.global_position)


# Reused initial setup for player
func InitialSetup():
	# Put the player in the Nexus to start
	if not player.get_parent(): $Players.add_child(player)
	nexus.ActiveWaygates[0].UseWaygate(player)
	
	#setup the player so that anytime you die or respawn, it resets everything in terms of skills 
	player.find_child("SkillsUI").setup(player)
	## Initial items
	var nexOffset = nexus.global_position
	# Some coins
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.Coin, nexOffset + Vector2(-300, 0))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.Coin, nexOffset + Vector2(-400, -100))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.Coin, nexOffset + Vector2(-400, 100))
	# HPots
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, nexOffset + Vector2(-200, 0))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, nexOffset + Vector2(-200, 50))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, nexOffset + Vector2(-200, 75))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, nexOffset + Vector2(-200, 100))
	# MPots
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, nexOffset + Vector2(-175, 0))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, nexOffset + Vector2(-175, 25))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, nexOffset + Vector2(-175, 50))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, nexOffset + Vector2(-175, 75))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, nexOffset + Vector2(-175, 100))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, nexOffset + Vector2(-175, 125))
	# MC Items test
	$ItemSpawner.SpawnItemByID(4, nexOffset + Vector2(-600, 0))
	$ItemSpawner.SpawnItemByID(5, nexOffset + Vector2(-700, 0))
	$ItemSpawner.SpawnItemByID(6, nexOffset + Vector2(-800, 0))
	$ItemSpawner.SpawnItemByID(7, nexOffset + Vector2(-600, 100))
	$ItemSpawner.SpawnItemByID(8, nexOffset + Vector2(-700, 100))
	$ItemSpawner.SpawnItemByID(9, nexOffset + Vector2(-800, 100))
	$ItemSpawner.SpawnItemByID(10, nexOffset + Vector2(-600, 200))
	$ItemSpawner.SpawnItemByID(11, nexOffset + Vector2(-700, 200))
	$ItemSpawner.SpawnItemByID(12, nexOffset + Vector2(-800, 200))
	$ItemSpawner.SpawnItemByID(13, nexOffset + Vector2(-600, 300))
	$ItemSpawner.SpawnItemByID(14, nexOffset + Vector2(-700, 300))
	$ItemSpawner.SpawnItemByID(15, nexOffset + Vector2(-800, 300))
	$ItemSpawner.SpawnItemByID(16, nexOffset + Vector2(-600, 400))
	$ItemSpawner.SpawnItemByID(17, nexOffset + Vector2(-700, 400))
	$ItemSpawner.SpawnItemByID(18, nexOffset + Vector2(-800, 400))
	$ItemSpawner.SpawnItemByID(19, nexOffset + Vector2(-600, 500))
	$ItemSpawner.SpawnItemByID(20, nexOffset + Vector2(-700, 500))
	
func quitGame():
	print("manager: quitting game")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) # Notify whole tree (so player can save and other stuff)
	#await SavaData() # Old saving interface
	
	Save.SaveGame(player, nexus.find_child("Bank")) # Player and bank saved separately
	
	get_tree().quit() # Actually quit the game

# Handles signal death from player which deletes player and adds a new player for perma death behavior
func DeathHandling():
	#pause the game
	get_tree().set_pause(false)
	#basically delete the player node and the information for the player
	player.queue_free()
	#make a new instance of the player and add that to the world, then show the player to the world
	player = player_tscn.instantiate()
	player.death.connect(DeathHandling)
	player.show()
	player.InputStatus = true
	player.find_child("RMenu").show() #reconnect the main menu escape reference to new player
	mainMenu.escapeMenu = player.find_child("EscMenu")
	mainMenu.escapeMenu.mainMenuButton.connect(mainMenu.ActivateMainMenu)
	InitialSetup()

## Load player and bank data
func LoadData(P:Player, B:Bank):
	var bankData = Save.LoadBank()
	print("Loaded bankdata: " +str(bankData))
	for i in range(len(bankData)): 
		if bankData[i] == 0: continue
		B.PutItemInSlot(i, $ItemSpawner.ItemByID(bankData[i]))
		
	var playerData = Save.LoadPlayer()
	print("Loaded playerData: " + str(playerData))
	if playerData != {}:
		# Progress
		while playerData.Level > 1: # Level starts from 1
			P.LevelUp()
			playerData.Level -= 1
		while playerData.Fame > 0: # Fame starts from 0
			P.LevelUp()
			playerData.Fame -= 1
		P.XP = playerData.XP
		# Consumables
		P.HPotC = playerData.HPotC
		P.MPotC = playerData.MPotC
		P.coins = playerData.Coins
		# Items: Store the ID only, when loading the ID can be used to spawn them in again
		# Gear
		if playerData.Helm  > 0: P.Inv.PutItemInSlot(P.Inv.Slot.HELM,     $ItemSpawner.ItemByID(playerData.Helm))
		if playerData.Chest > 0: P.Inv.PutItemInSlot(P.Inv.Slot.CHEST,    $ItemSpawner.ItemByID(playerData.Chest))
		if playerData.Main  > 0: P.Inv.PutItemInSlot(P.Inv.Slot.MAINHAND, $ItemSpawner.ItemByID(playerData.Main))
		if playerData.Off   > 0: P.Inv.PutItemInSlot(P.Inv.Slot.OFFHAND,  $ItemSpawner.ItemByID(playerData.Off))
		if playerData.Ring1 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.RING1,    $ItemSpawner.ItemByID(playerData.Ring1))
		if playerData.Ring2 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.RING2,    $ItemSpawner.ItemByID(playerData.Ring2))
		# Inventory
		if playerData.Inv0 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV0, $ItemSpawner.ItemByID(playerData.Inv0))
		if playerData.Inv1 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV1, $ItemSpawner.ItemByID(playerData.Inv1))
		if playerData.Inv2 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV2, $ItemSpawner.ItemByID(playerData.Inv2))
		if playerData.Inv3 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV3, $ItemSpawner.ItemByID(playerData.Inv3))
		if playerData.Inv4 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV4, $ItemSpawner.ItemByID(playerData.Inv4))
		if playerData.Inv5 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV5, $ItemSpawner.ItemByID(playerData.Inv5))
		if playerData.Inv6 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV6, $ItemSpawner.ItemByID(playerData.Inv6))
		if playerData.Inv7 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV7, $ItemSpawner.ItemByID(playerData.Inv7))
		if playerData.Inv8 > 0: P.Inv.PutItemInSlot(P.Inv.Slot.INV8, $ItemSpawner.ItemByID(playerData.Inv8))

## Get all active waygates in all worlds
func GetActiveWaygates() -> Array[Waygate]:
	var gates : Array[Waygate] = []
	for map in $Maps.get_children():
		for wg in map.ActiveWaygates:
			gates.append(wg)
	gates.erase(nexus.ActiveWaygates[0]) # Not including the Nexus Waygate
	return gates
