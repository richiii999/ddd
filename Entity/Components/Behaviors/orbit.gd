extends behaviorBASE ## Orbit: Orbits around a point by a radius

@export var orbitsTargetEntity : bool = false # If false, orbits point, if true, orbits Entity.targetEntity
@export var orbitRadius : float = 300.0
@export var orbitTarget : Vector2 = Vector2(0,0)

func setOrbit(V2 : Vector2 = Entity.targetEntity.global_position, R : float = orbitRadius): orbitTarget = V2; orbitRadius = R

## Override funcs: behaviorBASE funcs overridden by Wander
func onEnter(): # Adjust movement for the Entity and begin orbiting
	Entity.behaviorMoveSpeed = 1.50
	Entity.targetPosStopRadius = 3.00 # Orbit movement is rubberbanding if this is not close to zero
	Entity.set_collision_layer_value(9, false)
	Entity.StatusLabel.addStatusText("Orbit", "WHITE")
	
	setOrbit(Entity.global_position)
	start(randf_range(0.00, wait_time)) # Start the timer with a random value up to wait_time, then reset wait_time (starting changes wait_time)
	wait_time = 4.00 # This is needed otherwise all orbiting entities will orbit at the same point and stack up rather than spread out
func onLeave(): # Stop timer, reset movement stuff
	Entity.behaviorMoveSpeed = 1.00
	Entity.targetPosStopRadius = 10.00
	Entity.set_collision_layer_value(9, true)
	stop()
func BehaviorTick(): # every frame, set target pos farther along a circle with radius orbitRadius via timer
	if orbitsTargetEntity && Entity.targetEntity != Entity : setOrbit(Entity.targetEntity.global_position) # Follow targetEntity's position
	Entity.setTargetPos(orbitTarget + (Vector2.RIGHT.rotated( (time_left/wait_time) * 6.00 ) * orbitRadius)) # set Entity.targetPos to a position along a circle of radius orbitRadius
