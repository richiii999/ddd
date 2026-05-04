class_name WorldBASE extends TileMapLayer ## Base class for worlds, stores stats and lots of references to things
# Keeps track of world stats like cumulative kills, which boss is active, etc.
# NOTE: Worlds must have the following child nodes (all Node2D):
	# WorldEffects, Waygates, Spawners

@export var BGM : AudioStream = null # BGM to play when entering world

# Permanent effects given to players upon entering the world
@onready var WorldEffects : Array[Node] = $WorldEffects.get_children()

# NOTE: Need the update fn since the list can change as new waygates activate
@onready var ActiveWaygates : Array[Node] = $Waygates.get_children().filter(func(WG): return WG.active == true)
func updateWorldWaygateList(): ActiveWaygates = $Waygates.get_children().filter(func(WG): return WG.active == true)

# Spawns enemies according to each node's individual status (active/not) and params
@onready var EnemySpawnpointList : Array[Node] = $Spawners.get_children()
# Spawns bosses according to the node's conditions (e.g. world cumulative kills / bossOrder) and status (active/not)
# TODO 
@export var BossSpawnpointList   : Array[Node] = [] 

## World Stats
# TODO
@export var cumulativeKills : int = 0 # How many enemies have died in total (for summoning endboss)
@export var currBoss : int = 0 # Which is the current boss to spawn (Based on cumulative kills and other factors)

func _ready():
	z_index = -10
	# Hide effect particles behind world
	$WorldEffects.z_index -= 99
