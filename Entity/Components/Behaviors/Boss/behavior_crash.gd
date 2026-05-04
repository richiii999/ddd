extends BehaviorBASE ## Crash: When boss crashes into wall

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"

## Override funcs: behaviorBASE funcs overridden by behavior_crash
func onEnter(): # Adjust movement for the Entity and begin orbiting
	Entity.immovable = true
	Entity.velocity = Vector2.ZERO
	Entity.set_collision_layer_value(9, false)
	animated_sprite_2d.pause()
	
	#TODO: Enemy should shoot multiple waves of projectiles
	Entity.EnemyShoot(1)
	start()

func onLeave(): # Stop timer, reset movement stuff
	stop()
	Entity.immovable = false
	Entity.behaviorMoveSpeed = 1.00
	Entity.targetPosStopRadius = 10.00
	Entity.set_collision_layer_value(9, true)
	animated_sprite_2d.play()

func BehaviorTick(): 
	pass

func _on_timeout() -> void:
	emit_signal("changeStateByIdx", 0)
