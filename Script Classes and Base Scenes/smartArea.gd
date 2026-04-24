class_name SmartArea extends Area2D ## Keeps an array of the nodes inside of an area 
# Supports additional logic via signals

@export var area : bool = true # Detect areas?
@export var body : bool = true # Detect bodies?

@export var smartArea : Array[Node] = [] # Array which stores all nodes inside the area
@export var threshold : int = 0 # When the array reaches a certain size, emit onThreshold

signal onFirst     # When array.size() goes from 0 -> 1 
signal onEmpty     # When array.size() goes from 1 -> 0
signal onThreshold # When array.size() = threshold with true (++) or false (--)

func _ready():
	if area:
		area_entered.connect(UpdateArray.bind(true))
		area_exited.connect(UpdateArray.bind(false))
	if body:
		body_entered.connect(UpdateArray.bind(true))
		body_exited.connect(UpdateArray.bind(false)) 

## Add/remove entities to array when they enter/exit the Area2D
func UpdateArray(N : Node2D, enter : bool): 
	print("------" +str(N))
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
