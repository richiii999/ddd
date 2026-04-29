class_name GameManager extends Node ## Controls the game. The "Main" scene of the game

## Child node descriptions:
# Maps: Game maps like Nexus, World, and many dungeons are children of this. 
	# Use AddMap() to put a map into the world
# ParticleTrasher: is where a projectile GPUParticle2D's go while they are expiring
	# Tools.ParticlePassOff() sends them here automatically
# ItemSpawner: gets signaled by various things to spawn items in the world
# Projectiles: Projectiles are reparented to here, prevents inheriting entity velocity
# CanvasLayer: Shows the Main menu for the game

@export var dungeons: Array[PackedScene]
var mapOffset : Vector2 = Vector2(99999,0) # Offset each added map by this much
func AddMap(map): $Maps.add_child(map); map.global_position += mapOffset; mapOffset += mapOffset

## Player
@export var player_tscn: PackedScene 
var player: Player = null # Set by the loading funcs

## Refs to Stuff
@onready var nexus: WorldBASE = load("res://Maps/Nexus.tscn").instantiate()
@onready var world: WorldBASE = load("res://Maps/TestWorld.tscn").instantiate()

## Save Manager instance
var Save = SaveMgr.new() # Create a SaveMgr instance to allow for saving

func _ready():
	# Load all maps into the game
	AddMap(nexus)
	NexusSetup() # Spawn items in the nexus
	AddMap(world)
	for DG in dungeons: AddMap(DG.instantiate())
	
	# Main Menu Handling
	%MainMenu.show()
	%MainMenu.quitPressed.connect(Quit)
	%MainMenu.playPressed.connect(MainMenuPlay)
	%MainMenu.escHandling.connect(ActivatingMainMenu)

## Main Menu Play: Load any saves, then put player in the world
func MainMenuPlay():
	PlayerSetup() # Create a new player
	
	LoadPlayer(player) # Load the player and bank saves
	LoadBank(nexus.find_child("Bank"))

func ActivatingMainMenu():
	if player: # Player may be null if never started the game
		Save.SaveGame(player, nexus.find_child("Bank")) # Player and bank saved separately
		player.queue_free()
	%MainMenu.show()


## NexusSetup: Spawn items on the ground in the nexus
func NexusSetup():
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

## PlayerSetup: Places a new player into the game
# NOTE: Any existing player should be freed before calling this func on the next frame.
func PlayerSetup():
	if player != null: push_error("Player already setup!")
	player = player_tscn.instantiate()
	
	# Put player in nexus via waygate
	$Players.add_child(player)
	nexus.ActiveWaygates[0].UseWaygate(player)
	
	# Show player, setup UI, and enable input
	player.show()
	player.InputStatus = true
	player.death.connect(DeathHandling)
	player.find_child("RMenu").show()
	player.UpdateUIBars()
	player.find_child("SkillsUI").setup(player) # On death, reset skills 
	
	# Main Menu connection
	%MainMenu.escapeMenu = player.find_child("EscMenu")
	%MainMenu.escapeMenu.mainMenuButton.connect(%MainMenu.ActivateMainMenu)

func Quit():
	print("Quitting game...")
	if player: # Player may be null if never started the game
		Save.SaveGame(player, nexus.find_child("Bank")) # Player and bank saved separately
	
	get_tree().quit() # Actually quit the game

## Permadeath: Reset the player
func DeathHandling():
	get_tree().set_pause(false) # Player.Death() paused the game, need to unpause
	player.queue_free()
	
	# NOTE: process_frame basically means do this on the next frame
	get_tree().process_frame.connect(PlayerSetup, CONNECT_ONE_SHOT)

## Load BankData from bankData.ddd
func LoadBank(B:Bank):
	var bankData = Save.LoadBank()
	print("Loaded bankdata: " +str(bankData))
	for i in range(len(bankData)): 
		if bankData[i] == 0: continue
		B.PutItemInSlot(i, $ItemSpawner.ItemByID(bankData[i]))

## Load PlayerData from playerData.ddd
func LoadPlayer(P:Player):
	var playerData = Save.LoadPlayer()
	print("Loaded playerData: " + str(playerData))
	if playerData == {}: return # Save doesnt exist: Just skip
	
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
	
	# Prevent "Level X!" spam
	print(player.StatusLabel.textQueue)
	player.StatusLabel.textQueue = [] # Prevent "Level X!" spam
	player.StatusLabel.addStatusText("Spawned in!", "BLUE")


## Get all active waygates in all worlds
func GetActiveWaygates() -> Array[Waygate]:
	var gates : Array[Waygate] = []
	for map in $Maps.get_children():
		for wg in map.ActiveWaygates:
			gates.append(wg)
	gates.erase(nexus.ActiveWaygates[0]) # Not including the Nexus Waygate
	return gates
