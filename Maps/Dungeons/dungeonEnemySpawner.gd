class_name EnemyDungeonSpawner extends AnimatedSprite2D ## Plays an animation then spawns enemy

@export var enemyScene : PackedScene # Which enemy to spawn
var spawnedEnemy: Enemy = null # Enemy instance once spawned

# Apply effects to the spawned enemy
@export var effects : Array[PackedScene]

# Adjust these to change enemy difficulty
@export var statScale : Dictionary[String, float] = {"HP":1.00, "DMG":1.00, "SIZE":1.00, "SPD":1.00}

# Set by a parent higher in the tree that wants to listen to the enemy death 
# (e.g. dungeon room for counting deaths)
var deathSignalConnection : Node = null 

func _ready():
	if enemyScene == null: 
		push_error("Enemy not set on spawner!")
		queue_free()
		return
	
	animation_finished.connect(SpawnEnemy)
	
	setEnabled(false) # Spawners start disabled and are enabled by some parent (eg nextWave() in dungeonRoom)

## Instantiates enemy, then plays anim
func setEnabled(state:bool):
	visible = state
	speed_scale = float(state) * randf_range(0.5, 1.5) # Play/Pause anim (rng length looks better)
	
	SetupEnemy()
	scale = spawnedEnemy.scale # Scale sprite to enemy size

## Prepares enemy to be spawned
func SetupEnemy():
	if spawnedEnemy != null: return # Enemy already setup
	
	spawnedEnemy = enemyScene.instantiate()
	
	# Scale stats
	@warning_ignore_start("narrowing_conversion") # Enemy stats are ints, scale is floats
	spawnedEnemy.HPmax *= statScale["HP"]
	spawnedEnemy.HP *= statScale["HP"]
	spawnedEnemy.mainStat *= statScale["DMG"]
	spawnedEnemy.scale *= statScale["SIZE"]
	spawnedEnemy.accel *= statScale["SPD"]

## Spawns the enemy then frees
func SpawnEnemy(): 
	# TODO
	# Particle instantiate
	# particle pass off
	
	# play sound
	
	SetupEnemy()
	get_parent().add_child(spawnedEnemy)
	spawnedEnemy.global_position = global_position
	# Workaround for awkward signal connection
	if deathSignalConnection: spawnedEnemy.death.connect(deathSignalConnection.onEnemyDeath) 
	
	if spawnedEnemy.ECS != null:
		for E in effects: spawnedEnemy.ECS.AddEffect(E.instantiate())
	
	queue_free()
