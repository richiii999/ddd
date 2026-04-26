class_name Necromancer extends Enemy #using this script to test projectile patterns to see if it even works

@onready var pattern = $ProjectilePattern

func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	pattern.Emit(ProjectilePattern.PatternType.CIRCLE, 8, {"power": P})
