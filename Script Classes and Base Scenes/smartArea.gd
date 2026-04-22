class_name SmartArea extends Area2D ## Keeps an array of the nodes inside of an area (& supports additional logic via signals)

@export var AreaOrBody : bool = false # Detect area or bodies? default body

@export var smartArea : Array[Node] = [] # Array which stores all nodes inside the area
@export var threshold : int = 0 # When the array reaches a certain size, emit onThreshold

signal onFirst     # When array.size() goes from 0 -> 1 
signal onEmpty     # When array.size() goes from 1 -> 0
signal onThreshold # When array.size() reaches (nonzero) threshold with true (reached threshold) or false (went below threshold)

func _ready(): # NOTE: have to connect signals from this script since they dont save from editor when you instantiate the scene
	if AreaOrBody:
		area_entered.connect(UpdateArray.bind(true))
		area_exited.connect(UpdateArray.bind(false))
	else: 
		body_entered.connect(UpdateArray.bind(true))
		body_exited.connect(UpdateArray.bind(false)) 

func UpdateArray(N : Node2D, enter : bool): ## Add/remove entities to array when they enter/exit the Area2D
	if enter:
		onEnter(N)
		smartArea.append(N)
		if smartArea.size() == 1: onFirst.emit()
		if (threshold && (smartArea.size() == threshold)): onThreshold.emit(true)
	else:
		onLeave(N)
		smartArea.erase(N)
		if smartArea.size() == 0: onEmpty.emit() 
		if (threshold && (smartArea.size() == threshold)): onThreshold.emit(false)

## OVERRIDE FUNCS: Funcs to be overridden by inherited things
func onEnter(_N: Node2D): pass # Do something to the entering node
func onLeave(_N: Node2D): pass # Do something to the leaving node
