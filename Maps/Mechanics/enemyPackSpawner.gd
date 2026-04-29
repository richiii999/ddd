class_name EnemyPackSpawner extends Node2D ## EnemySpawnNode: Spawns mobs in packs, also can include a pack boss
# If this node is not seen by anyone, not already full of mobs, etc. spawns a pack of mobs

@export var Mob : PackedScene      # The mob of this node
@export var PackBoss : PackedScene # The pack boss of this node 

@export var maxMobs   : int = 8      # How many mobs can be spawned at most?
@export var immediate : bool = false # If toggled, spawns a FULL pack immediately, otherwise starts empty and waits for timer (used for dungeons)
@export var respawn   : bool = true  # Do mobs respawn or no? (Mostly used for dungeons)
@export var spawnRadius: int = 150   # Within what radius to spawn mobs?
@export var onlyWhenOffScreen : bool = true # Only spawn when player can't see?

var mobList : Array[Node] = []  # Links to the pack's mobs
var packBoss: Node = null       # Link to the pack's boss (if any)
var visibility: int = 0 # Is the node visible to any player (via count)? If so, pause timer (to prevent spawning immediately after you leave and come back)

signal screen_entered
signal screen_exited

func _ready():
	if respawn: $RespawnTimer.timeout.connect(SpawnMobs)
	if immediate: SpawnMobs(maxMobs) # Spawn a full pack based on setting
	if onlyWhenOffScreen: 
		screen_entered.connect(Visible.bind(1))
		screen_exited.connect(Visible.bind(-1))

## Function which actually spawns mobs, only spawns about (quarter + 1) at a time to prevent farming too fast
func SpawnMobs( n : int = (maxMobs >> 2) + 1 ):
	if(Mob && mobList.size() < maxMobs): # If there is a mob set, and the node is not yet full, spawn mobs
		for i in range(n):
			if(mobList.size() < maxMobs): 
				var newMob:Enemy = Mob.instantiate()
				newMob.position = Tools.NudgeVec2(newMob.position, spawnRadius)
				newMob.death.connect(MobDeath.bind(newMob))
				newMob.SpawnNode = self
				mobList.append(newMob)
				
				# Some mobs spawn other mobs, the new mob should follow parent
				# Ex. NecroSkull orbiters
				if get_parent() is Enemy: 
					newMob.following = get_parent()
				
				add_child(newMob)
				print(newMob.targetEntity)
				#print("Mob Spawned")
	elif(PackBoss && !packBoss): # If already full of mobs (or max = 0), spawn the pack boss
		var newBoss = packBoss.instantiate()
		# <set params on the new spawn>
		add_child(newBoss)
	
	$RespawnTimer.start()

# Count how many players can see this node. If any can, the timer is paused (only respawn enemies when offscreen)
func Visible(i : int = 0) : visibility += i; $RespawnTimer.set_paused(visibility)

# Called by signal from the mob when it dies
func MobDeath(mob : Node): mobList.erase(mob)
