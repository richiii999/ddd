extends Camera2D ## Camera script: Typically follows player, maybe add cutscene or jump or something idk.
## Inspector:
# Position Smoothing: 5px/s
# Position.x = 160, offset to account for RMenu

## TODO: confusion debuff makes camera spin around player in circle or something 
	# trace a circle of radius R around player, where R is the strenght of the debuff

@onready var Follow : Node = get_parent() # link to what the camera is following (just parent for now)
var Res : Vector2 = Vector2(1280, 720) # Game resolution # TODO: there has to be a way to get this easily

var lookAtCursor : bool = false # Camera does/not move towards cursor
var lookRate: float = 7.00 # How much the camera moves with the mouse
var lookMax : Vector2 = Vector2(400,400) # +/- clamps for how far camera looks with cursor
var lookMin : Vector2 = Vector2.ZERO - lookMax

var zoomRate: Vector2 = Vector2(0.01, 0.01) # How fast the cam zooms in/out
var zoomMax : Vector2 = Vector2(1.25, 1.25) # Max / Min zoom amount
var zoomMin : Vector2 = Vector2(0.40, 0.40)

func _ready(): 
	Follow.find_child("CamReset_Button").pressed.connect(camReset)
	Follow.find_child("RMenu").visibility_changed.connect(RMenuOffset)

func _process(_delta): 
	if Input.is_action_pressed("camReset"): camReset()
	if Input.get_axis("minus", "plus"): Zoom(Input.get_axis("minus", "plus"))
	
	if lookAtCursor: offset = (get_viewport().get_mouse_position() / lookRate).clamp(lookMin, lookMax)

func camReset() -> void : zoom = Vector2(1.00,1.00)

func Zoom(input : float = 0.00) -> void : zoom = (zoom + (zoomRate * input) ).clamp(zoomMin, zoomMax)

func RMenuOffset() -> void: position.x = 160 if !position.x else 0 # Toggling RMenu recenters cam

# Instantly move the camera's global pos without smooth scrolling (ex. when teleporting)
func InstantMove(pos: Vector2) -> void: 
	position_smoothing_enabled = false
	var tmp = position # preserve localpos offset (from RMenu toggle)
	global_position = pos
	position = tmp
	align()
	position_smoothing_enabled = true
