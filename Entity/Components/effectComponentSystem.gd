class_name EffectComponentSystem extends Node2D ## EffectComponentSystem: Manages effects on parent
# Loops over child nodes and applies their effects (if possible) each frame to the parent

# Effects which should be constant (always on, no timer, no dispell)
@export var constantEffects : Array[PackedScene] = [] 

func _ready(): 
	ClearEffects()
	$Timer.timeout.connect(Tick)
	$Timer.start()

## Apply effect ticks
func Tick(): for E in GetEffects(): E.EffectTick()

## Return an array of all child effects
func GetEffects() -> Array[Node]:
	return get_children().filter(func(child): return child is not Timer)

func AddEffect(E: EffectBASE, constant:bool = false) -> void:
	if !E: return # null case
	
	# Check to see if theres already an existing effect of the same type
	for childE in GetEffects():
		if E.get_script() == childE.get_script(): # Effects are the same type
			# Skip Fields, otherwise reset timer for duplicates
			
			if is_instance_valid(childE.field) or childE.lingering: return
			elif not constant: childE.ResetTimer()
			
			E.queue_free(); return # Discard the new E, since we dont need it
	
	# Effect is new, so add it
	add_child(E); print("Added " + E.efname + " (" + str(E.length) + "s)" + " const=" + str(constant))
	if not constant: E.ResetTimer()

## Remove an effect
# Can optionally skip the EndEffect()
func RemoveEffect(E : EffectBASE, skipEndEffect : bool = false) -> void: 
	if !E: return # null case
	if E in GetEffects(): # Only remove this ECS's child effects
		E.Destruct(skipEndEffect)

## Dispell all effects
# Called mainly from nexus or other portaling, also from priests & boss deaths
func ClearEffects() -> void: 
	for E in GetEffects(): E.Destruct(true) # Remove all effects, skipping any end effects
	for E in constantEffects: AddEffect(E.instantiate(), true) # re-add constant effects (if any)
