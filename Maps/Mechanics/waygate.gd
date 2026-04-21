class_name Waygate extends GPUParticles2D ## Waygate: Node for teleporting players, can be one-way only
# Emits particles and changes sprite momentarily when triggered

@onready var currWorld : WorldBASE = Tools.FindParentByType(self, WorldBASE)
@export var active : bool = false # Players can only spawn here if active
@export var oneWayTarget : Waygate = null # if set, instantly sends players to oneWayTarget on interaction (no GUI) (ex. outside dungeon <-> inside dungeon)

func _ready():
	$InteractComponent.Interact.connect(WaygateInteract)
	$EffectTimer.timeout.connect(_on_EffectTimer_timeout)

func WaygateInteract(P:Player = null):
	#print("WaygateInteract called, active: " + str(active))
	if !active: setActive(true) # Inactive case: Activate with a short animation
	if oneWayTarget: oneWayTarget.UseWaygate(P) # One-way gates activate immediately 
	else: P.toggleWaygateGUI() # Regular waygates open the GUI to select a destination

func UseWaygate(P:Player = null): # Teleports player to this waygate
	if !P: print_debug("UseWaygate() called without arg 'Player', returning"); return
	if !active: setActive(true) # Inactive destination case: Activate it, then continue (ex. entering a dungeon)
	
	await P.LoadingScreenStart() # Show loading screen before moving player & camera
	# TODO: When going from nex to world, play a short transition screen showing the world name and some info, player in center (with party to side)
		# and some quest details, and any other stuff like stats idk
	
	P.global_position = global_position # Move player 
	P.find_child("PlayerCam").InstantMove(global_position) # Force move camera without smoothing
	P.currWorld = currWorld # Set the player's currWorld to this one (otherwise reading tilemap breaks)
	
	P.LoadingScreenEnd()

func setActive(state:bool): 
	if state && !active: # If activating from inactive
		$InteractComponent.set_collision_mask_value(5, false) # Disable interaction until animation is over
		# TODO: await play animation # Does this mess with WGinteract?? ^^^
		EffectTrigger(state)
		active = true
		$InteractComponent.set_collision_mask_value(5, true)

func EffectTrigger(state : bool = false): # Emits blue particles and changes sprite for a moment
	#print("EffectTrigger called, state: " + str(state))
	$Sprite2D_ON.visible = state; 
	$Sprite2D_OFF.visible = !state; 
	emitting = state; 
	if(state): $EffectTimer.start(1.5) # When this times out, stops emitting (calls this with state = false)

func _on_EffectTimer_timeout():
	#print("EffectTimer timeout, emitting: " + str(emitting))
	emitting = false #hopefully stops the particles but keeps the 2D sprite on?
