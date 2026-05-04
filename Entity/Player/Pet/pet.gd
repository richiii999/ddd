class_name Pet extends CharacterBody2D

var player : Player = null # Player to follow
var doingTrick : bool = false # Currently doing trick (spin in circle)

# Movement variables, I mean duh just look at the names
var speed = 200.0
var follow_distance = 75.0
var maxDistance = 1000.0 # Teleports if above this distance

func _physics_process(_delta):
	if player == null: return
	
	# Calculate distance to player
	var distance = global_position.distance_to(player.global_position)
	$AnimatedSprite2D.flip_h = (global_position.x - player.global_position.x < 0)
	
	# Follow player, may have to teleport to them
	if distance > maxDistance: global_position = player.global_position
	elif distance > follow_distance:
		# Get normalized direction so movement speed stays constant regardless of distance
		var direction = (player.global_position - global_position).normalized()
		
		# Use player speed and enforce a minimum speed of 50 so the pet can catch up
		var base_speed = player.velocity.length()
		speed = max(base_speed, 50.0)
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	if doingTrick: rotate(deg_to_rad(6)) # Spin around
	
	move_and_slide()

## Trick: Pet spins around in a circle
func Trick():
	if doingTrick: return # Wait for trick to finish before doing another
	doingTrick = true
	
	# Timer to stop trick
	var T = get_tree().create_timer(1)
	T.timeout.connect(set_rotation.bind(0))
	T.timeout.connect(set_deferred.bind("doingTrick", false))
