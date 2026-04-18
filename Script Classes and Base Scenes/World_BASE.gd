class_name World_BASE extends TileMapLayer ## Base class for worlds, stores stats and lots of references to things
# Keeps track of world stats like cumulative kills, which boss is active, etc.

## Scripted spawning locations: A world must have a Node2D "Waygates" and "EnemySpawns" as immediate children (there is a better way of doing it but this *for now*)
@onready var Waygates : Array[Node] = get_tree().get_nodes_in_group("Waygate") # Waygates where players can spawn in / teleport
func updateWorldWaygateList(): Waygates = get_tree().get_nodes_in_group("Waygate")

@onready var EnemySpawnpointList : Array[Node] = find_child("EnemySpawns").get_children() # Spawns enemies according to each node's individual status (active/not) and params
@export var BossSpawnpointList   : Array[Node] = [] # Spawns bosses according to the node's conditions (e.g. world cumulative kills / bossOrder) and status (active/not) 

## World Stats
@export var cumulativeKills : int = 0 # How many enemies have died in total (used for summoning endboss)
@export var currBoss : int = 0 # Which is the current boss to spawn (Based on cumulative kills and other factors)

## Special world params
@export var ConstantWorldPlayerEffects : Array[EFFECT_BASE] = [] # perma effects given to players upon entering the world

func _ready(): pass
