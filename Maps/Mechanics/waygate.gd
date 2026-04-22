class_name Waygate extends GPUParticles2D ## Waygate: Node for teleporting players
# Emits particles and changes sprite momentarily when triggered

@onready var currWorld : WorldBASE = Tools.FindParentByType(self, WorldBASE)
@export var active : bool = false # Players can only spawn here if active
@export var oneWayTarget : Waygate = null # Instantly tp to oneWayTarget, no GUI (ex. dung exit)

# TODO: Change this to require (one or more) itemIDs
@export var price : int = 0 # What does it cost to activate this waygate?

func _ready():
	$InteractComponent.Interact.connect(WaygateInteract)
	$EffectTimer.timeout.connect(EffectTrigger.bind(false)) # Timer controls particle burst

func WaygateInteract(P:Player = null):
	if !active:
		# TODO: check for cost
		setActive(true)
	
	if oneWayTarget: oneWayTarget.UseWaygate(P) # One-way gates activate immediately
	else: P.toggleWaygateGUI() # Regular waygates open the GUI to select a destination

func UseWaygate(P:Player): # Teleports player to this waygate
	await P.LoadingScreenStart() # Show loading screen before moving player & camera
	# TODO: When going from nex to world, play a short transition screen showing the world name and some info, player in center (with party to side)
		# and some quest details, and any other stuff like stats idk
	
	P.global_position = global_position # Move player 
	P.find_child("PlayerCam").InstantMove(global_position) # Force move camera without smoothing
	P.currWorld = currWorld # Set the player's currWorld to this one (otherwise reading tilemap breaks)
	
	P.LoadingScreenEnd()
	
	EffectTrigger()

# BUG: The nexus waygate gets set twice when the game is started, something in gameManager
func setActive(state:bool):
	EffectTrigger(state)
	$Sprite2D_ON.visible = state;
	$Sprite2D_OFF.visible = !state;
	active = state

func EffectTrigger(state:bool=true): # Emits blue particles and changes sprite for a moment
	print("EffectTrigger called, state: " + str(state) + "WG= " + str(self))
	emitting = state; 
	if(state): $EffectTimer.start(1.5) # Ttops emitting (calls this with state = false)
