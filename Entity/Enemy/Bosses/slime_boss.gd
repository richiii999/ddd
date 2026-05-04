class_name SlimeBoss extends Enemy

@onready var pattern = $ProjectilePattern

@export var maxMobs : int = 4 # Amount of mobs spawned after death
@export var Mob : PackedScene # The mob to be spawned after death
@export var spawnRadius: int = 150   # Within what radius to spawn mobs?

# Overrides abstract EnemyShoot function
func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	var dir_to_player = global_position.angle_to_point(pos)
	pattern.Emit(ProjectilePattern.PatternType.WING_RINGS, 8, {
		"power": P,
		"ring_count": 3,
		"sine_amp": 0.5,
		"sine_freq": 1.5,
		"time_offset": Time.get_ticks_msec() / 1000.0
	})
	
# Override enemy death function to spawn minions after death
func Death():
	var spawn_pos = global_position
	var parent_node = get_parent()
	
	call_deferred("SpawnMinions", spawn_pos, parent_node, maxMobs)
	super.Death()

func SpawnMinions(pos, parent_node, n):
	for i in range(n):
		var newMob:Enemy = Mob.instantiate()
		
		#Spawn where boss was and use NudgeVec2 to randomize
		var base_pos = pos
		var offset = Tools.NudgeVec2(Vector2.ZERO, spawnRadius)

		parent_node.add_child(newMob)
		newMob.global_position = base_pos + offset
