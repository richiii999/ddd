extends Camera2D ## Camera script: Typically follows player, maybe add cutscene or jump or something idk.
## Inspector:
# Position Smoothing: 5px/s
# Position.x = 160, offset to account for RMenu

@export var confused : bool = false # If set, camera zooms in / out

@onready var Follow : Node = get_parent() # link to what the camera is following (just parent for now)
var Res : Vector2 = Vector2(1280, 720) # Game resolution

var lookAtCursor : bool = false # Camera does/not move towards cursor
var lookRate: float = 7.00 # How much the camera moves with the mouse
var lookMax : Vector2 = Vector2(400,400) # +/- clamps for how far camera looks with cursor
var lookMin : Vector2 = Vector2.ZERO - lookMax

var zoomRate: Vector2 = Vector2(0.01, 0.01) # How fast the cam zooms in/out
var zoomMax : Vector2 = Vector2(1.25, 1.25) # Max / Min zoom amount
var zoomMin : Vector2 = Vector2(0.60, 0.60)

var rMenuOffset : bool = true # Applies an offset to account for the game's UI
func setOffset(state:bool):
	rMenuOffset = state
	RMenuOffset()

func _ready(): 
	Follow.find_child("CamReset_Button").pressed.connect(camReset)
	Follow.find_child("RMenu").visibility_changed.connect(RMenuOffset)
	camReset()

func _process(_delta): 
	if Input.is_action_pressed("camReset"): camReset()
	if Input.get_axis("minus", "plus"): Zoom(Input.get_axis("minus", "plus"))
	
	if lookAtCursor: offset = (get_viewport().get_mouse_position() / lookRate).clamp(lookMin, lookMax)
	if confused: Zoom(0.1 * sin(Time.get_ticks_msec() / 1000.0))

func camReset() -> void : zoom = Vector2(0.8, 0.8) # 0.8 is the new default

func Zoom(input : float = 0.00) -> void : zoom = (zoom + (zoomRate * input) ).clamp(zoomMin, zoomMax)

func RMenuOffset() -> void: position.x = 160 if rMenuOffset else 0 # Toggling RMenu recenters cam

# Instantly move the camera's global pos without smooth scrolling (ex. when teleporting)
func InstantMove(pos: Vector2) -> void: 
	position_smoothing_enabled = false
	
	var tmp = position # preserve localpos offset (from RMenu toggle)
	global_position = pos
	position = tmp
	align()
	position_smoothing_enabled = true
	
	RMenuOffset() # offset if needed 
