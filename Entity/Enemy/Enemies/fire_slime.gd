class_name FireSlime extends Enemy 

var exploded = false


#If player is close to enemy, explodes and does damage, only happens once with a bool check
func _physics_process(_delta: float) -> void:
	if exploded:
		return
	
	super._physics_process(_delta)
	for play in $ExplosionArea.smartArea:
		if play is Player:
			exploded = true
			explode(play)
			return

#Actual explosing damage handling and animation
func explode(play):
	play.Damage(50)
	death.emit()

	$AnimatedSprite2D.play("Explode")
	await $AnimatedSprite2D.animation_finished

	queue_free()
