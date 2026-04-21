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
	$WorldSlot.add_child(mainMenu)
	mainMenu.show()
	mainMenu.quitPressed.connect(quitGame)
	mainMenu.playPressed.connect(Play)
	mainMenu.escHandling.connect(ActivatingMainMenu)
	player.find_child("PlayerCam").InstantMove(mainMenu.global_position)
	
# signal function when play is pressed that starts player movement
func Play():
	InitialSetup()
	player.show()
	player.InputStatus = true
	player.find_child("RMenu").show()

func ActivatingMainMenu():
	player.InputStatus = false
	player.velocity = Vector2.ZERO
	mainMenu.set_position(player.position)
	player.hide()
	player.find_child("RMenu").hide()
	player.find_child("EscMenu").hide()
	mainMenu.show()
	player.find_child("PlayerCam").InstantMove(mainMenu.global_position)


# Reused initial setup for player
func InitialSetup():
	# put the player in the nexus to start
	nexus.Waygates[0].setActive(true)
	player.global_position = nexus.Waygates[0].global_position
	player.find_child("PlayerCam").InstantMove(player.global_position)
	player.currWorld = nexus
	nexus.Waygates[0].EffectTrigger()

# quit game function that has a signal added during runtime for Mainmenu quit button handling
func quitGame():
	print("manager: quitting game")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) # Notify whole tree (so player can save and other stuff)
	get_tree().quit() # Actually quit the game

# Handles signal death from player which deletes player and adds a new player for perma death behavior
func DeathHandling():
	world.remove_child(player)
	player = player_tscn.instantiate()
	world.add_child(player)
	player.death.connect(DeathHandling)
	InitialSetup()
	pass
