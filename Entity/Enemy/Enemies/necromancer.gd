class_name Necromancer extends Enemy #using this script to test projectile patterns to see if it even works

@onready var pattern = $ProjectilePattern

func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	#var dir_to_player = global_position.angle_to_point(pos)
	#pattern.Emit(ProjectilePattern.PatternType.ARC, 5, {
	#	"power": P,
	#	"spread": PI / 2.0,
	#	"offset_angle": dir_to_player
	#})
	pattern.Emit(ProjectilePattern.PatternType.CIRCLE, 8, {"power" : P})
