class_name EffectComponentSystem extends Node2D ## EffectComponentSystem: Manages effects on parent
# Loops over child nodes and applies their effects (if possible) each frame to the parent

# Effects which should be constant (always on, no timer, no dispell)
@export var constantEffects : Array[PackedScene] = [] 

func _ready(): ClearEffects()
func _process(_delta): for E in get_children(): E.EffectTick()

func AddEffect(E: EffectBASE, constant:bool = false) -> void:
	if !E: return # null case
	
	# Check to see if theres already an existing effect of the same type
	for childE in get_children():
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
	if E in get_children(): # Only remove this ECS's child effects
		E.Destruct(skipEndEffect)

## Dispell all effects
# Called mainly from nexus or other portaling, also from priests & boss deaths
func ClearEffects() -> void: 
	for E in get_children(): E.Destruct(true) # Remove all effects, skipping any end effects
	for E in constantEffects: AddEffect(E.instantiate(), true) # re-add constant effects (if any)
