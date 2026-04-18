extends behavior_BASE ## Wander: Wanders around slowly

var wanderPoint : Vector2 = Vector2(0,0) # Wander about this point
var wanderRadius : float = 0.00 # Wander within this radius

func setWanderRange(P : Vector2 = Entity.global_position, R : float = wanderRadius): wanderPoint = P; wanderRadius = R

func Wander(): # Every 3-6s, pick a new point to walk slowly towards
	Entity.setTargetPos(Tools.NudgeVec2(wanderPoint, wanderRadius))
	wait_time = randf_range(3, 6)

## Override funcs: behavior_BASE funcs overridden by Wander
func onEnter(): # Begin wandering about spawnpoint (if any) or current position, with slower movespeed and no collision
	var ESN = find_parent("EnemySpawnNode")
	if ESN: setWanderRange(ESN.global_position, 1000)
	else  : setWanderRange(Entity.global_position, 1000)
	
	Entity.behaviorMoveSpeed = 0.20
	Entity.set_collision_mask_value(9, false)
	Entity.StatusLabel.addStatusText("Wander", "WHITE")
	Wander()
	start()

func onLeave(): # Reset movespeed and collision
	Entity.behaviorMoveSpeed = 1.00 
	Entity.set_collision_mask_value(9, true)
	stop()
