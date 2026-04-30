class_name BehaviorBASE extends Timer ## Base class for behaviors, provides functions for behaviors to inherit and override
# Extends Timer, since I need timers for a bunch of behaviors anyways

@export var isFinal: bool = false # true: FSM wont switch off this behavior

@onready var FSM : BehaviorFSM = get_parent() # The FSM this behavior is a part of
@onready var Entity : ENTITY = get_parent().get_parent() # The entity this behavior affects

signal changeState # Emitted by checkConditions() with the state to change to, to the parent FSM
signal changeStateByIdx # Emitted by checkConditions() with the idx of the sibling state to change to, to the parent FSM

func _ready():
	#connect our signals once, since they were bouncing around between states
	changeStateByIdx.connect(get_parent().ChangeStateByIdx)
	changeState.connect(get_parent().ChangeState)
func onEnter(): pass # What to do when this behavior is triggered
func onLeave(): pass # What to do when this behavior is ended
func BehaviorTick(): pass # What to do each frame during this behavior
func checkConditions() -> bool: return true # Checks conditions, if met, signals the parent FSM to change to the passed state
