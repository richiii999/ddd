extends Enemy

@export var minion_scene: PackedScene
@export var max_minions := 4
@export var spawn_interval := 3.0

var current_minions := 0
var spawning_active := false


func _ready():
	super._ready()
	
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	$SpawnTimer.start()
	
	$Sight.onFirst.connect(_on_player_detected)

func _on_player_detected(_entity):
	start_spawning()

func start_spawning():
	if spawning_active:
		return
		
	spawning_active = true
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	print("bruh")
	if current_minions >= max_minions:
		return
	
	var minion = minion_scene.instantiate()
	var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
	minion.global_position = global_position + offset
	
	get_tree().current_scene.add_child(minion)
	
	current_minions += 1
	minion.death.connect(_on_minion_died)
	
func _on_minion_died():
	current_minions -= 1
