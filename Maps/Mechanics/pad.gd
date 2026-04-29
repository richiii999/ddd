extends Area2D ## Pressure Plate: Sprite when stepped on, sends a signal
# NOTE: Connections are made from the reciever node, not from this!

# TODO: Test this out

# Inspector bools to set the masks automatically
@export var detectPlayer: bool = false
@export var detectEnemy : bool = false

# Count num of detections (to make sure only trigger(false) if plate is completely empty)
@export var count : int = 0
signal Triggered

# Is the pressure plate held down or only triggered once?
@export var hold : bool = false
var triggered_once : bool = false

func _ready():
	# Set collision masks
	set_collision_mask_value(5, detectPlayer)
	set_collision_mask_value(9, detectEnemy)

func Trigger(state : bool):
	#print("[SIGNAL T] Pressure_Plate: " + str(state))
	$State_ON.visible = state; $State_OFF.visible = !state
	Triggered.emit(state)
	triggered_once = true

func UpdateCount(_body, i : int = 1): # Ignore the body, only count enter/exits
	count += i
	if ( (count == 1 && hold) || (!triggered_once) ): Trigger(true)
	elif (hold && !count): Trigger(false)
