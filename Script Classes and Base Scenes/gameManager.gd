class_name GameManager extends Node ## Controls the game, opens and closes worlds / dungeons / etc.
# Moves players and other scenes around the tree

# "ParticleTrasher" Node is where a projectile GPUParticle2D's go while they are expiring, since they can't stay with their already free'd parent
# "ItemSpawner" Node gets signaled by various things to spawn items in the world (ex. when a mob dies)


@export var nexus_tscn: PackedScene ## Scenes
@export var world_tscn: PackedScene
@export var player_tscn: PackedScene # TODO: obv this is passed from somewhere else, but for now there isnt mp so just load the one player

@onready var nexus: WorldBASE = nexus_tscn.instantiate() ## Refs
@onready var world: WorldBASE = world_tscn.instantiate()
@onready var player: Player = player_tscn.instantiate()

func _ready():
	add_child(nexus) # put the nexus, world, and player into the scene tree
	$WorldSlot.add_child(world)
	world.add_child(player)
	
	# put the player in the nexus to start
	nexus.Waygates[0].setActive(true)
	player.global_position = nexus.Waygates[0].global_position
	player.find_child("PlayerCam").InstantMove(player.global_position)
	player.currWorld = nexus
	nexus.Waygates[0].EffectTrigger()
	
	## Initial items
	# Some coins
	$ItemSpawner.SpawnItemByID(-2, Vector2(-300, 0))
	$ItemSpawner.SpawnItemByID(-2, Vector2(-400, -100))
	$ItemSpawner.SpawnItemByID(-2, Vector2(-400, 100))

func quitGame():
	print("manager: quitting game")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) # Notify whole tree (so player can save and other stuff)
	get_tree().quit() # Actually quit the game
