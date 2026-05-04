class_name BehaviorFSM extends Timer ## BehaviorFSM: Manages Entity behaviors via a FSM pattern
# Extends Timer, since this uses a timer anyways to check for changing states every 0.5s

var initState : BehaviorBASE = null
@onready var currState : BehaviorBASE = initState

func _ready():
	if !(get_parent() is ENTITY): 
		push_error("BehaviorFSM is child of a non-Entity")
		queue_free()
		return
	
	if !get_child_count(): print_debug("BehaviorFSM has no children")
	
	if !initState:
		initState = get_child(0)
		currState = initState
	
	currState.call_deferred("onEnter")
	timeout.connect(BehaviorTick)

func BehaviorTick(): 
	if currState: 
		currState.BehaviorTick() # Tick current behavior each frame
		
		# On timeout (0.5s rather than every frame): check if behavior should change from currState
		if currState.checkConditions():
			ChangeStateByIdx(currState.get_index() + 1) # Go to next phase

## Change state: currState -> newState, calling their respective onLeave/onEnter functions
func ChangeState(newState : BehaviorBASE = null) -> void: 
	if currState.isFinal: return
	if !newState: print_debug("newState == null, keeping current state for Entity")
	if newState == currState: print_debug("newState == currState, keeping current state for Entity")
	else: # Valid newState
		currState.onLeave()
		currState = newState
		currState.onEnter()

func ChangeStateByIdx(newStateChildIdx : int = -1) -> void:
	if currState.isFinal: return
	if newStateChildIdx < 0: 
		print_debug("newStateChildIdx < 0, keeping current state for Entity")
		return
	if newStateChildIdx >= self.get_child_count(): 
		print_debug("newStateChildIdx == outOfRange, keeping current state for Entity")
		print(newStateChildIdx)
		return
		
	# Non-final state, loop back to idx 0
	if newStateChildIdx == self.get_child_count(): newStateChildIdx = 0
	
	currState.onLeave()
	currState = get_child(newStateChildIdx)
	currState.onEnter()
