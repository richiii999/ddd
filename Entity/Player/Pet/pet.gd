class_name Pet extends CharacterBody2D

var player = null

# Movement variables, I mean duh just look at the names
var speed = 200.0
var follow_distance = 75.0
var maxDistance = 1000.0 # Teleports if above this distance

func _physics_process(_delta):
	if player == null: return
	
	# Calculate distance to player
	var distance = global_position.distance_to(player.global_position)
	
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
	
	move_and_slide()
