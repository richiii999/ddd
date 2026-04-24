class_name EffectBASE extends GPUParticles2D ## BASE class for effects, effects inherit this
# Contains the effect params, as well as virtual fn for Initial(), Tick(), and End()

@onready var entity : Node = Tools.FindParentByType(self, ENTITY) # Which Entity to apply effects?

@export var icon     : Resource = null  # What is the effect's icon?
@export var color    : String = "WHITE" # Color of status text / entity color change (as a string)

# NOTE: "efname" since "name" is a reserved word
@export var efname   : String = "BASE"  # Reapplications of the same effect adds to timer 
@export var tier     : int = 1          # Effects of a higher tier override lower tiers

@export var length   : float = 4.00     # How long does the effect last?
@export var field    : Node = null      # (optional) reference to the field node

var lingering : bool = false 

func _ready(): ## Setup the timer, send a status text, particles (if any), and apply initial effect
	$Timer.timeout.connect(Destruct.bind(false,true))
	
	if (field): 
		$Timer.stop() # effect timer is autostart, field timers however start on destructor call
		#print(efname + " field effect added, timer stopped. time_left: " + str($Timer.time_left))
	
	if(entity.find_child("Status")): entity.find_child("Status").addStatusText(efname, color)
	
	## Set the particle effect amount and radius by size of the entity
	var HitboxSize = entity.find_child("Projectile_Hitbox").get_child(0).shape.size.x
	if HitboxSize:
		amount = (int)(HitboxSize / 10)
		process_material.set_emission_ring_radius(HitboxSize * 0.5)
		process_material.set_emission_ring_inner_radius(HitboxSize * 0.25)
	
	InitialEffect()

## NOT "_exit_tree()" because this has a param & reparents itself before freeing
func Destruct(skipEndEffect : bool = false, Timeout : bool = false) -> void: 
	#print(efname + " Destruct called | field: " + str(field) + " | Timeout: " + str(Timeout) + " | time_left: " + str($Timer.time_left) + " | stack: " + str(get_stack()))
	if !is_inside_tree(): 
		queue_free()
		# BUG: stored effects are being added to tree
		return # free effect if it isnt even in the tree (e.g. effects stored in fields) 
	
	if(field != null && !Timeout): # removing field effects first starts timer, only on timeout -> free
		lingering = true
		$Timer.one_shot = true
		$Timer.start(length)
		#print("Linger timer started, one_shot: " + str($Timer.one_shot) + " | time_left: " + str($Timer.time_left))
		field = null
		return
	#if(is_instance_valid(field) && !Timeout): # removing field effects first starts timer, only on timeout -> free
		
	if !skipEndEffect: EndEffect()
	Tools.ParticlePassOff(self) # Safely reparent particles to let them expire
	queue_free()

func ResetTimer(): $Timer.start(length)

## OVERRIDE FUNCS: Inherited effects will override these and supply the functions they wish to perform
func InitialEffect() -> void: pass # What to do when the effect first applies
func EffectTick() -> void:    pass # What to do each physics tick
func EndEffect() -> void:     pass # What to do when the effect ends
