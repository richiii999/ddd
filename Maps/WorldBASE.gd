class_name WorldBASE extends TileMapLayer ## Base class for worlds, stores stats and lots of references to things
# Keeps track of world stats like cumulative kills, which boss is active, etc.


# Permanent effects given to players upon entering the world
@onready var WorldEffects : Array[Node] = $WorldEffects.get_children()
# Scripted spawning locations: A world must have a Node2D "Waygates" and "EnemySpawns"
@onready var Waygates : Array[Node] = $Waygates.get_children()
# Need this func since the list can change
func updateWorldWaygateList():Waygates = $Waygates.get_children()

@onready var EnemySpawnpointList : Array[Node] = $Spawners.get_children() # Spawns enemies according to each node's individual status (active/not) and params
@export var BossSpawnpointList   : Array[Node] = [] # Spawns bosses according to the node's conditions (e.g. world cumulative kills / bossOrder) and status (active/not) 

## World Stats
@export var cumulativeKills : int = 0 # How many enemies have died in total (used for summoning endboss)
@export var currBoss : int = 0 # Which is the current boss to spawn (Based on cumulative kills and other factors)

func _ready():
	# Hide effect particles behind world
	$WorldEffects.z_index -= 99
