class_name EffectComponentSystem extends Node2D ## EffectComponentSystem: Manages effects on parent
# Loops over child nodes and applies their effects each tick to the parent entity

# Effects which should be constant (always on, no timer, no dispell)
@export var constantEffects : Array[PackedScene] = [] 
@export var immuneToEffects : bool = false

func _ready(): 
	ClearEffects()
	$Timer.timeout.connect(Tick)
	$Timer.start()

## Apply effect ticks
func Tick(): for E in GetEffects(): E.EffectTick()

## Return an array of all child effects
func GetEffects() -> Array[Node]:
	return get_children().filter(func(child): return child is not Timer) # Dont include the timer

## Adds an effect to the entity
# Constant: Effect is permanent, usually from fields or worlds
# Timeoverride: Effect's time is changed to this (if set), usually from fields with lingering set
func AddEffect(E: EffectBASE, constant:bool = false, length:float = E.length) -> void:
	if immuneToEffects: return
	if E == null: 
		push_error("Tried to add null effect")
		return
	
	# Effect already exists
	if E in GetEffects():
		#print("E already exists, re-applying")
		RemoveEffect(E)
	
	#print("Added " + E.efname + " (" + str(length) + "s)" + " const=" + str(constant))
	add_child(E)
	
	if not constant: 
		var T = Timer.new() # NOTE: Cant use SceneTreeTimer since the effect may expire before timer
		T.timeout.connect(RemoveEffect.bind(E))
		E.add_child(T)
		T.start(length)

## Remove an effect
func RemoveEffect(E : EffectBASE) -> void: 
	if !E: return # null case
	if E in GetEffects(): # Only remove this ECS's child effects
		#print("removed effect " +str(E))
		E.Destruct()

## Workaround to different instances not being equal
func RemoveEffectByName(efname:String) -> void:
	for E in GetEffects(): # Only remove this ECS's child effects
		if E.efname == efname:
			#print("removed effect " +str(E))
			E.Destruct()

## Dispell all effects
# Called mainly from nexus or other portaling, also from priests & boss deaths
func ClearEffects() -> void: 
	for E in GetEffects(): E.Destruct() # Remove all effects
	for E in constantEffects: AddEffect(E.instantiate(), true) # re-apply constant effects
	
	# BUG: Instantly spawned enemies from packSpaners do not recieve worldeffects
		# This may be a good thing actually, since we can burn incoming players but not enemies
	if get_parent().currWorld: # Re-apply world effecfs
		for E in get_parent().currWorld.WorldEffects: AddEffect(E.duplicate(), true)
