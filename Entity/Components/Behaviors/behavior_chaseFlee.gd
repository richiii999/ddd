extends behavior_BASE ## ChaseFlee: Goes directly towards / away from a target

@export var chaseOrFlee : bool = true # True: Chase towards False: Flee from
@export var TargetEntity : bool = false # If false, targets point, if true, targets Entity.targetEntity
@export var Target : Vector2 = Vector2(0,0)
@export var speed : float = 1.50

## Override funcs: behavior_BASE funcs overridden by ChaseFlee
func onEnter(): # Adjust movement for the Entity and begin orbiting
	Entity.behaviorMoveSpeed = speed
	Entity.targetPosStopRadius = 3.00 # Movement is rubberbanding if this is not close to zero
	Entity.set_collision_layer_value(9, false)
	Entity.StatusLabel.addStatusText("Chase" if chaseOrFlee else "Flee", "WHITE")

func onLeave(): # Stop timer, reset movement stuff
	Entity.behaviorMoveSpeed = 1.00
	Entity.targetPosStopRadius = 10.00
	Entity.set_collision_layer_value(9, true)

func BehaviorTick(): # every frame, set target pos farther along a circle with radius orbitRadius via timer
	if chaseOrFlee && Entity.targetEntity != Entity : Target = Entity.targetEntity.global_position # Chase target
	elif !chaseOrFlee && Entity.targetEntity != Entity : Target = Entity.targetEntity.global_position + Vector2(1000,0) # Flee from target
	
	# TODO Change flee to git the difference between this pos and target pos (= directional vector) then mult by alot to make it go far away
