class_name Immobile_Turret extends Enemy

@onready var pattern = $ProjectilePattern
func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	var dir_to_player = global_position.angle_to_point(pos)
	pattern.Emit(ProjectilePattern.PatternType.GRID, 0, {
	"power": P,
	"cols": 2,
	"rows": 4,
	"cell_size": 100.0,
	"offset_angle": dir_to_player
	})
