class_name EffectBASE extends GPUParticles2D ## BASE class for effects, effects inherit this
# Contains the effect params, as well as virtual fn for Initial(), Tick(), and End()

@onready var entity:ENTITY = Tools.FindParentByType(self, ENTITY) # Which Entity to apply effects?

@export var color    : String = "WHITE" # Color of status text / entity color change (as a string)
@export var efname   : String = "BASE"  # Reapplications of the same effect adds to timer 
# NOTE: "efname" since "name" is a reserved word

@export var tier     : int = 1          # Tier affects how strong the effect is
@export var length   : float = 4.00     # How long does the effect last?

## Setup the timer, send a status text, particles (if any), and apply initial effect
func _ready():
	if not entity: return
	if(entity.StatusLabel): entity.StatusLabel.addStatusText(efname, color)
	
	## Set the particle effect amount and radius by size of the entity
	var HitboxSize = entity.find_child("Projectile_Hitbox").get_child(0).shape.size.x
	if HitboxSize:
		amount = (int)(HitboxSize / 10)
		process_material.set_emission_ring_radius(HitboxSize * 0.5)
		process_material.set_emission_ring_inner_radius(HitboxSize * 0.25)
	
	InitialEffect()

## NOT "_exit_tree()" because this has a param & reparents itself before freeing
func Destruct() -> void:
	# BUG: stored effects are being added to tree
	if !is_inside_tree(): 
		queue_free()
		return # free effect if it isnt even in the tree (e.g. effects stored in fields) 
	
	EndEffect()
	Tools.ParticlePassOff(self) # Safely reparent particles to let them expire
	queue_free()

## OVERRIDE FUNCS: Inherited effects will override these and supply the functions they wish to perform
func InitialEffect() -> void: pass # What to do when the effect first applies
func EffectTick() -> void:    pass # What to do each physics tick
func EndEffect() -> void:     pass # What to do when the effect ends
