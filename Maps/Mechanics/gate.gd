extends StaticBody2D ## Gate: Membrane that can open / close on a trigger
# Certain things can go through while others are blocked (player/enemy)

# TODO: test this out

# What is this connected to?
@export var Connection : Node = null

# Inspector bools to set the layer automatically
@export var blockPlayer: bool = false
@export var blockEnemy : bool = false

func _ready():
	if(Connection): Connection.Triggered.connect(Trigger) # Activate any connection
	
	# Set collision layers:
	set_collision_layer_value(8, blockPlayer)
	set_collision_layer_value(12, blockEnemy)

func Trigger(state : bool):
	print("[SIGNAL R] Pressure_Plate: " + str(state))
	$State_ON.visible  = !state; $State_OFF.visible = state
	$CollisionShape2D.set_deferred("disabled", state)
