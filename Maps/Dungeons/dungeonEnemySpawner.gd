class_name EnemyDungeonSpawner extends AnimatedSprite2D ## Plays a short animation then spawns an enemy on top

@export var EnemyToSpawn : PackedScene = null
@export var randomizeSpawnLocation : bool = false # If true, ignores editor placement and randomly places this spawner somewhere in the room
@export var Effects : Array[EFFECT_BASE] = [] # if set, applies effects to the spawned enemy

var deathSignalConnection : Node = null # Set by a parent higher in the tree that wants to listen to the enemy death (e.g. dungeon room for counting deaths)

func _ready():
	setEnabled(false) # Spawners start disabled and are enabled by some parent (eg nextWave() in dungeonRoom)
	# TODO: scale size to enemy sprite size

func setEnabled(state:bool): # workaround since cant do just set_process(false) for some reason idk
	visible = state
	speed_scale = float(state)
	# perhaps if state: slightly randomize times from 1-3s to add slight rng in spawns

func SpawnEnemy(): ## Signaled by 'animation_finished'
	# Particle instantiate
	# particle pass off
	
	# play sound
	# Depending on how big it is, play different sounds
	
	var enemy = EnemyToSpawn.instantiate()
	get_parent().add_child(enemy)
	if deathSignalConnection: enemy.death.connect(deathSignalConnection.onEnemyDeath) # Workaround for awkward signal connection
	enemy.global_position = global_position
	#for effect in Effects: enemy.applyEffect(effect)
	queue_free()
