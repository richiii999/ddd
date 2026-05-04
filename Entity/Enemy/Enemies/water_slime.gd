class_name WaterSlime extends Enemy 

var Waterexploded = false
@onready var pattern = $ProjectilePattern

#If player is close to enemy, explodes and shoots projectiles, only happens once with a bool check
func _physics_process(_delta: float) -> void:
	if Waterexploded:
		return
	
	super._physics_process(_delta)
	for play in $ExplosionArea.smartArea:
		if play is Player:
			Waterexploded = true
			Waterexplode()
			return

#Actual explosing damage handling and animation
func Waterexplode():
	#TODO: Circular spray of water bullets, 
	
	$AnimatedSprite2D.play("Explode")
	await $AnimatedSprite2D.animation_finished
	
	pattern.Emit(ProjectilePattern.PatternType.CIRCLE, 8, {"power": 10})	
	queue_free()

func Death():
	await Waterexplode()
	super.Death()
