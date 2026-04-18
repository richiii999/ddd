extends behaviorBASE ## Boss1: Stands still and shoots slowly

@export var healthThreshold = 0.33 # What % health remaining to switch phases?

# Copied from Orbit
@export var orbitRadius : float = 300.0
@onready var orbitTarget : Vector2 = Entity.global_position
func setOrbit(V2 : Vector2 = Entity.targetEntity.global_position, R : float = orbitRadius): orbitTarget = V2; orbitRadius = R

## Override funcs: behaviorBASE funcs overridden by ChaseFlee
func onEnter(): # Adjust movement for the Entity and begin orbiting
	Entity.behaviorMoveSpeed = 1.00
	Entity.set_collision_layer_value(9, false)
	Entity.StatusLabel.addStatusText("Boss2", "WHITE")
	
	# Copied from Orbit
	setOrbit(Entity.global_position)
	start(randf_range(0.00, wait_time)) # Start the timer with a random value up to wait_time, then reset wait_time (starting changes wait_time)
	wait_time = 4.00 # This is needed otherwise all orbiting entities will orbit at the same point and stack up rather than spread out

func BehaviorTick(): # Copied from Orbit
	Entity.setTargetPos(orbitTarget + (Vector2.RIGHT.rotated( (time_left/wait_time) * 6.00 ) * orbitRadius)) # set Entity.targetPos to a position along a circle of radius orbitRadius

func checkConditions(): 
	if ( Entity.HPBar.ratio <= healthThreshold): 
		changeStateByIdx.connect(get_parent().ChangeStateByIdx)
		changeStateByIdx.emit(self.get_index() + 1 ) # Go to next phase
