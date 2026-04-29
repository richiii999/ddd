class_name Field extends SmartArea ## Field: applies an effect to entities inside the area
# Fields are spawned from projectiles

@export var fieldColor  : String = "WHITE"
@export var particleColor : String = "WHITE"

@export var effect : EffectBASE = null # What effect to apply?
@export var length : float = 5.00 # How long does the field last?
@export var lingering : float = 2.00 # How long does the effect last after leaving the field?

# Does this field affect <X>? (sets masks in ready())
@export var affectsPlayers : bool = true
@export var affectsEnemies : bool = true

func _ready():
	super._ready()
	#print("Spawned Field: " + str(effect.efname) + " (" + str(length) + "s)")
	
	$Sprite2D.self_modulate = Color(fieldColor)
	$GPUParticles2D.self_modulate = Color(particleColor)
	$GPUParticles2D.process_material.set_emission_ring_inner_radius($CollisionShape2D.shape.radius / 2)
	$GPUParticles2D.process_material.set_emission_ring_radius($CollisionShape2D.shape.radius / 2)
	
	if length: get_tree().create_timer(length).timeout.connect(queue_free)
	
	set_collision_mask_value(5, affectsPlayers)
	set_collision_mask_value(11, affectsEnemies)

## OVERRIDE FUNCS: SmartArea.gd funcs overridden by Field.gd

## Add a constant effect while in the field
func onEnter(entity : Node2D):
	#print("Enter field: " + str(entity))
	if entity is not ENTITY: # Try to find parent Entity
		entity = Tools.FindParentByType(entity, ENTITY)
	if entity is ENTITY:
		entity.ECS.RemoveEffectByName(effect.efname)
		entity.ECS.AddEffect(effect.duplicate(), true)
	else: push_error("Non entity entered field, wtf")

## Replace the constant field effect with a lingering effect
# NOTE: This is also called when field expires
func onLeave(entity : Node2D):
	#print("Exited field: " + str(entity))
	if entity is not ENTITY: # Try to find parent Entity
		entity = Tools.FindParentByType(entity, ENTITY)
	if entity is ENTITY:
		entity.ECS.RemoveEffectByName(effect.efname)
		if lingering > 0.0: entity.ECS.AddEffect(effect.duplicate(), false, lingering)
	else: push_error("Non entity exited field, wtf")
