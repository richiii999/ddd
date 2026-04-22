class_name BehaviorFSM extends Timer ## BehaviorFSM: Manages Entity behaviors via a finite state machine pattern
# Extends Timer, since this uses a timer anyways to check for changing states every 0.5s
# Learned about FSMs from this great YT vid: [TODO yt link]

@export var Sight : SmartArea = null # Refereance to the entity's sight node (if any). Used for many enemy behaviors

@export  var initState : BehaviorBASE = null
@onready var currState : BehaviorBASE = initState

func _ready():
	if !(get_parent() is ENTITY): print_debug("BehaviorFSM is child of a non-Entity")
	if !get_child_count(): print_debug("BehaviorFSM has no children")
	
	if !initState:
		initState = get_child(0)
		currState = initState
	
	currState.call_deferred("onEnter")

func _process(_delta): if currState: currState.BehaviorTick() # Tick current behavior each frame

func CheckConditions(): if currState: currState.checkConditions() # On timeout (0.5s rather than every frame): check if behavior should change from currState

func ChangeState(newState : BehaviorBASE = null) -> void: # Change state: currState -> newState, calling their respective onLeave/onEnter functions
	if !newState: print_debug("newState == null, keeping current state for Entity")
	if newState == currState: print_debug("newState == currState, keeping current state for Entity")
	else: # Valid newState
		currState.onLeave()
		currState = newState
		currState.onEnter()

func ChangeStateByIdx(newStateChildIdx : int = -1) -> void:
	#return rather than else statmenet, since its not going to change anything and leave it as is
	if newStateChildIdx < 0: print_debug("newStateChildIdx < 0, keeping current state for Entity"); return
	if newStateChildIdx > self.get_child_count() - 1: print_debug("newStateChildIdx == outOfRange, keeping current state for Entity"); return
	currState.onLeave()
	currState = get_child(newStateChildIdx)
	currState.onEnter()
