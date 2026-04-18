class_name Field extends Area2D ## Field: applies an effect to entities inside the area
# Usually spawned as an effect from a projectile, but can exist alone (e.g. permanent part of map)

# BUG 0.13-153 (03-07-2024): couldnt get it to detect collisions as a smart area for some reason, so just made a normal area2D

# TODO: implement projectile interactions with this (like projectile repulsion / magnet field). For now, just doing entities

## Params
var source : ENTITY = null # What spawned this field? (passed by projectile)
@export var permanent : bool = false # If true, does not expire (deletes timer node)

@export var icon   : Resource = null  # What is the effect's icon? (displays in the top right)
@export var color  : String = "WHITE" # Color of status text / entity color change (as a string)

@export var effect : EffectBASE = null # What effect to apply?
@export var length : float = 0.00 # How long does the effect linger after leaving the field?

#@export var affectsProjectiles: bool = false # Does this field affect <X>? (sets masks in ready())
@export var affectsPlayers : bool = false # ^
@export var affectsEnemies : bool = false # ^

func _ready():
	$Sprite2D.self_modulate = Color(color)
	$GPUParticles2D.self_modulate = Color(color)
	
	print("Spawned field: " + str(effect.efname) + " (" + str(length) + "s)")
	$Timer.wait_time = length
	if permanent: $Timer.queue_free()
	
	set_collision_mask_value(5, affectsPlayers)
	set_collision_mask_value(9, affectsEnemies)
	#set_collision_mask_value(6, affectsPlayers && affectsProjectiles)
	#set_collision_mask_value(10, affectsEnemies && affectsProjectiles)
	
	$GPUParticles2D.process_material.set_emission_ring_inner_radius($CollisionShape2D.shape.radius / 2)
	$GPUParticles2D.process_material.set_emission_ring_radius($CollisionShape2D.shape.radius / 2)

## OVERRIDE FUNCS: SmartArea.gd funcs overridden by Field.gd
func onEnter(entity : Node2D): entity.AddEffect(effect, true) # Field effects are added with no timer
func onLeave(entity : Node2D): entity.RemoveEffect(effect) # Removing a field effect starts it's timer (via destructor)
