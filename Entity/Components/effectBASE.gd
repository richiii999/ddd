class_name EffectBASE extends GPUParticles2D ## BASE class for effects, effects should inherit from this
# Contains the effect params, as well as a virtual fn for InitialEffect(), EffectTick(), and EndEffect()

@onready var entity : Node = Tools.FindParentByType(self, ENTITY) # Which Entity to apply effects to?

@export var icon     : Resource = null  # TODO: What is the effect's icon? (displays in the top right)
@export var color    : String = "WHITE" # Color of status text / entity color change (as a string)

@export var efname   : String = "BASE"  # Reapplications of the same effect adds to timer ("efname" instead of "name" cause reserved word)
@export var tier     : int = 1          # Effects of a higher tier override lower tiers (resets time)
@export var strength : int = 1          # Effects of a higher strength override lower strengths (& adds time)
@export var length   : float = 4.00     # How long does the effect last?
@export var element  : String = ""      # Element
@export var field    : Node = null     # Reference to the field node

func _ready(): ## Setup the timer, send a status text, particles (if any), and apply any initial effect
	$Timer.timeout.connect(Destruct.bind(false,true)) # timeout -> Destruct(false, true). This works for field effects too
	
	## NOTE: Currently unimplemented
	if (field): 
		$Timer.stop() # effect timer is autostart, field timers however start on destructor call
		print(efname + " field effect added, timer stopped. Timer time_left: " + str($Timer.time_left))
	
	if(entity.find_child("Status")): entity.find_child("Status").addStatusText(efname, color)
	
	var HitboxSize = entity.find_child("Projectile_Hitbox").get_child(0).shape.size.x
	if HitboxSize: # Set the particle effect amount and radius (by size of the entity)
		amount = (int)(HitboxSize / 10)
		process_material.set_emission_ring_radius(HitboxSize * 0.5)
		process_material.set_emission_ring_inner_radius(HitboxSize * 0.25)
	
	InitialEffect()

func Destruct(skipEndEffect : bool = false, Timeout : bool = false) -> void: ## NOT "_exit_tree()" because this has a param & reparents itself before freeing\
	print(efname + " Destruct called | field: " + str(field) + " | Timeout: " + str(Timeout) + " | time_left: " + str($Timer.time_left))
	if !is_inside_tree(): queue_free(); return # free effect if it isnt even in the tree (e.g. effects stored in fields) # BUG: stored effects are being added to tree
	
	## NOTE: Currently unimplemented
	if(is_instance_valid(field) && !Timeout): # removing field effects first starts timer, only on timeout -> free
		$Timer.start(length)
		field = null
		return
	if !skipEndEffect: EndEffect()
	Tools.ParticlePassOff(self) # Safely reparent particles to let them expire

## OVERRIDE FUNCS: Inherited effects will override these and supply the functions they wish to perform
func InitialEffect() -> void: pass # What to do when the effect first applies
func EffectTick() -> void:    pass # What to do each physics tick
func EndEffect() -> void:     pass # What to do when the effect ends
