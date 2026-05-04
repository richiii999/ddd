class_name SlimeMinion extends Enemy

@onready var pattern = $ProjectilePattern

# Overrides abstract EnemyShoot function
func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	var dir_to_player = global_position.angle_to_point(pos)
	pattern.Emit(ProjectilePattern.PatternType.WING_RINGS, 8, {
		"power": P,
		"ring_count": 3,
		"sine_amp": 0.5,
		"sine_freq": 1.5,
		"time_offset": Time.get_ticks_msec() / 1000.0
	})

func Death():
	
