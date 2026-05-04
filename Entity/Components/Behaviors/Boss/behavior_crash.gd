extends BehaviorBASE ## Crash: When boss crashes into wall

## Override funcs: behaviorBASE funcs overridden by behavior_crash
func onEnter(): # Adjust movement for the Entity and begin orbiting
	Entity.immovable = true
	Entity.velocity = Vector2.ZERO
	Entity.set_collision_layer_value(9, false)
	
	#TODO: Enemy should shoot multiple waves of projectiles
	Entity.EnemyShoot(1)
	start()

func onLeave(): # Stop timer, reset movement stuff
	stop()
	Entity.immovable = false
	Entity.behaviorMoveSpeed = 1.00
	Entity.targetPosStopRadius = 10.00
	Entity.set_collision_layer_value(9, true)

func BehaviorTick(): 
	pass

func _on_timeout() -> void:
	emit_signal("changeStateByIdx", 0)
