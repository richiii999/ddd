class_name DamageNumber extends Label ## DamageNumber: Displays fading text for a moment

func setup(pos:Vector2, num:int, crit:bool=false, heal:bool=false) -> DamageNumber: # Set the number and color
	global_position = Tools.NudgeVec2(pos, 50)
	text = str(num)
	if heal: self_modulate = Color.GREEN # Heals are green
	elif crit: self_modulate = Color.ORANGE # Crits are orange
	
	return self # Simplifies builder pattern when this is constructed

func _ready():
	get_tree().create_timer(0.67).timeout.connect(queue_free)
	z_index += 999 # Nums always on top

func _process(_d):
	global_position.y -= 2 # Float upwards
