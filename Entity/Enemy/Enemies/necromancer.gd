class_name Necromancer extends Enemy #using this script to test projectile patterns to see if it even works

@onready var pattern = $ProjectilePattern

func EnemyShoot(P: int, pos: Vector2 = targetEntity.global_position):
	var dir_to_player = global_position.angle_to_point(pos)
	#pattern.Emit(ProjectilePattern.PatternType.ARC, 5, {
	#	"power": P,
	#	"spread": PI / 2.0,
	#	"offset_angle": dir_to_player
	#})
	#pattern.Emit(ProjectilePattern.PatternType.CIRCLE, 8, {"power" : P})
	#pattern.Emit(ProjectilePattern.PatternType.BOWTIE, 6, {
	#	"power": P,
	#	"spread": PI / 2.0,
	#	"safe_angle": PI / 4.0,
	#	"offset_angle": dir_to_player
	#})
	#pattern.Emit(ProjectilePattern.PatternType.GRID, 0, {
	#"power": P,
	#"cols": 2,
	#"rows": 2,
	#"cell_size": 100.0,
	#"offset_angle": dir_to_player
	#})
	#pattern.Emit(ProjectilePattern.PatternType.CHAIN, 0, {
	#	"power": P,
	#	"offset_angle": dir_to_player,
	#	"reps": 3,           # how many times to repeat
	#	"interval": 0.5,     # seconds between each repeat
	#	"sub_type": ProjectilePattern.PatternType.CIRCLE,  # what pattern to repeat
	#	"sub_count": 8,      # count passed to the sub pattern
	#	"sub_opts": {        # opts forwarded to the sub pattern
	#		"power": P,
	#		"offset_angle": dir_to_player
	#	}
	#})
	pattern.Emit(ProjectilePattern.PatternType.WING_RINGS, 8, {
		"power": P,
		"ring_count": 3,
		"sine_amp": 0.5,
		"sine_freq": 1.5,
		"time_offset": Time.get_ticks_msec() / 1000.0
	})
