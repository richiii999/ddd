extends BehaviorBASE ## Charge: Charges in the player's direction

@export var TargetEntity : bool = false # If false, targets point, if true, targets Entity.targetEntity

# Movement variables
var dir : Vector2 # direction of the player
var startPos : Vector2 # start position of the entity
@export var speed : float = 5

# Crash cooldown variables to prevent immediate crash when pushing off the wall
var crash_cooldown : float = 0.0
@export var crash_buffer_time : float = 0.2

## Override funcs: behaviorBASE funcs overridden by behavior_charge
func onEnter():
	Entity.override_movement = true
	Entity.behaviorMoveSpeed = speed
	Entity.targetPosStopRadius = 3.00 # Movement is rubberbanding if this is not close to zero
	Entity.set_collision_layer_value(9, false)
	
	# Lock direction
	dir = Vector2.ZERO
	startPos = Entity.global_position

func onLeave(): # Stop timer, reset movement stuff
	Entity.override_movement = false
	Entity.behaviorMoveSpeed = 1.00
	Entity.targetPosStopRadius = 10.00
	Entity.set_collision_layer_value(9, true)

func BehaviorTick(): # every frame, set target pos farther along a circle with radius orbitRadius via timer
	# If target entity is null or the current entity return
	if Entity.targetEntity == null or Entity.targetEntity == Entity:
		return
		
	# Lock direction
	if dir == Vector2.ZERO:
		var delta = Entity.targetEntity.global_position - Entity.global_position
		
		if delta.length() < 5:
			return
		
		dir = delta.normalized()
		startPos = Entity.global_position
		
	# apply movement
	Entity.velocity = dir * speed * 200
		
	# Crash_cooldown is a buffer to prevent sticking to the wall
	crash_cooldown = max(crash_cooldown - get_process_delta_time(), 0.0) 
	if crash_cooldown > 0.0: return
	
	# Enters crash state when Entity collides with tilemap colliders
	if Entity.is_on_wall_only():
		crash_cooldown = crash_buffer_time
		emit_signal("changeStateByIdx", 1)
