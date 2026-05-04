class_name SlimeMinion extends Enemy

@onready var pattern = $ProjectilePattern

# Overrides abstract EnemyShoot function
func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	var dir_to_player = global_position.angle_to_point(pos)
	pattern.Emit(ProjectilePattern.PatternType.CIRCLE, 8, {"power" : P})
