class_name GameManager extends Node ## Controls the game, opens and closes worlds / dungeons / etc.
# Moves players and other scenes around the tree

# "ParticleTrasher" Node is where a projectile GPUParticle2D's go while they are expiring, since they can't stay with their already free'd parent
# "ItemSpawner" Node gets signaled by various things to spawn items in the world (ex. when a mob dies)


@export var nexus_tscn: PackedScene ## Scenes
@export var world_tscn: PackedScene
@export var player_tscn: PackedScene # TODO: obv this is passed from somewhere else, but for now there isnt mp so just load the one player
@export var mainmenu_tscn: PackedScene

@onready var nexus: WorldBASE = nexus_tscn.instantiate() ## Refs
@onready var world: WorldBASE = world_tscn.instantiate()
@onready var player: Player = player_tscn.instantiate()
@onready var mainMenu: MainMenu = mainmenu_tscn.instantiate()

func _ready():
	add_child(nexus) # put the nexus, world, and player into the scene tree
	$WorldSlot.add_child(world)
	world.add_child(player)
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
	LoadData()
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
	# put the player in the nexus to start
	#print("Waygates: " + str(nexus.Waygates))
	if player.get_parent(): player.get_parent().remove_child(player)
	nexus.add_child(player)
	nexus.Waygates[0].setActive(true)
	player.global_position = nexus.Waygates[0].global_position
	player.find_child("PlayerCam").InstantMove(player.global_position)
	player.currWorld = nexus
	
	# quit game function that has a signal added during runtime for Mainmenu quit button handling
	nexus.Waygates[0].EffectTrigger()
	
	## Initial items
	# Some coins
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.Coin, Vector2(-300, 0))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.Coin, Vector2(-400, -100))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.Coin, Vector2(-400, 100))
	# HPots and MPots
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, Vector2(-200, 0))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, Vector2(-200, 50))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, Vector2(-200, 75))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.HPot, Vector2(-200, 100))
	
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, Vector2(-175, 0))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, Vector2(-175, 25))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, Vector2(-175, 50))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, Vector2(-175, 75))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, Vector2(-175, 100))
	$ItemSpawner.SpawnItemByID($ItemSpawner.specialID.MPot, Vector2(-175, 125))
	# 9 items to fill inventory
	$ItemSpawner.SpawnItemByID(1, Vector2(-600, 0))
	$ItemSpawner.SpawnItemByID(1, Vector2(-700, 0))
	$ItemSpawner.SpawnItemByID(1, Vector2(-800, 0))
	$ItemSpawner.SpawnItemByID(1, Vector2(-600, 100))
	$ItemSpawner.SpawnItemByID(1, Vector2(-700, 100))
	$ItemSpawner.SpawnItemByID(1, Vector2(-800, 100))
	$ItemSpawner.SpawnItemByID(1, Vector2(-600, 200))
	$ItemSpawner.SpawnItemByID(1, Vector2(-700, 200))
	$ItemSpawner.SpawnItemByID(1, Vector2(-800, 200))
	$ItemSpawner.SpawnItemByID(2, Vector2(-500, 200))
	
	
func quitGame():
	print("manager: quitting game")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) # Notify whole tree (so player can save and other stuff)
	await SavaData()
	
	get_tree().quit() # Actually quit the game

# Handles signal death from player which deletes player and adds a new player for perma death behavior
func DeathHandling():
	#pause the game
	get_tree().set_pause(false)
	#basically delete the player node and the information for the player
	if player.get_parent(): player.get_parent().remove_child(player)
	player.queue_free()
	#make a new instance of the player and add that to the world, then show the player to the world
	player = player_tscn.instantiate()
	nexus.add_child(player)
	player.death.connect(DeathHandling)
	player.show()
	player.InputStatus = true
	player.find_child("RMenu").show() #reconnect the main menu escape reference to new player
	mainMenu.escapeMenu = player.find_child("EscMenu")
	mainMenu.escapeMenu.mainMenuButton.connect(mainMenu.ActivateMainMenu)
	InitialSetup()
	SavaData()
	
# Main Save function, should save any variables we want
func SavaData():
	#Add data to custom resource file, GODOT resource
	print("DataSaved")
	var savedData:SavedData = SavedData.new()
	savedData.max_player_health = player.HPmax
	savedData.max_player_mp = player.MPmax
	#savedData.current_hp = player.HP irrelevant? maybe, should be max on load i think
	#savedData.current_mp = player.MP irrelevant? maybe, self regens soooo
	savedData.core_Stats = player.coreStats
	savedData.coins = player.coins
	savedData.fame = player.Fame
	savedData.hp_pot_current = player.HPotC
	savedData.hp_pot_max = player.HPotmax
	savedData.level = player.Level
	savedData.mp_pot_current = player.MPotC
	savedData.mp_pot_max = player.MPotmax
	savedData.skill_points = player.skillPoints
	savedData.xp_current = player.XP
	savedData.xp_max = player.XPmax
	
	ResourceSaver.save(savedData, "user://savegame.tres")
	
# Main load function that should
func LoadData():
	var savedData:SavedData = load("user://savegame.tres") as SavedData
	
	if savedData != null:
		print("DataLoaded")
		player.HPmax = savedData.max_player_health
		player.MPmax = savedData.max_player_mp
		player.coreStats = savedData.core_Stats
		player.coins = savedData.coins
		player.Fame = savedData.fame
		player.HPotC = savedData.hp_pot_current
		player.HPotmax = savedData.hp_pot_max
		player.Level = savedData.level
		player.MPotC = savedData.mp_pot_current
		player.MPotmax = savedData.mp_pot_max
		player.skillPoints = savedData.skill_points
		player.XP  = savedData.xp_current
		player.XPmax = savedData.xp_max
		pass
