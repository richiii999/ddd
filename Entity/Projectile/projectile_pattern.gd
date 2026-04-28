class_name ProjectilePattern extends Node2D #all this file is gonna do is spawn a group of projectiles in shapes
#basically, the idea is to attach this to like a shooter node and call emit() to fire the pattern
#the starting patterns should be CIRCLE and ARC, as they are the base for any other pattern
#CHAIN should be set on a timer to repeat any pattern like N times
enum PatternType {
	CIRCLE,
	ARC, 
	BOWTIE, 
	#GRID, 
	#CHAIN,
	#WING_RINGS
}

#TODO: this is our projectile scene to instantiate, we have to set this on the node in the editor or before calling Emit()
@export var projectile_scene : PackedScene

#chain settings - don't know if this is correct so will change this later
#var _chain_timer : Timer = null
#var _chain_config : Dictionary = {}
#var _chain_rep_left : int = 0

#main emit function that needs to be called

func Emit(type: PatternType, count: int, opts: Dictionary = {}) -> void:
	match type:
		PatternType.CIRCLE: emit_circle(count, opts)
		PatternType.ARC: emit_arc(count, opts)
		PatternType.BOWTIE: emit_bowtie(count, opts)

#this will basically do a circle that does N projectles in a 360 (aka a circle)
#so if you pass in say (circle, 3), then you get a triangle
#(circle, 6) gives you a hexagon, and (circle, 1000) gives you an aneurysm
func emit_circle(count: int, opts: Dictionary) -> void:
	var offset: float = opts.get("offset_angle", 0.0) #we are grabbing the rotation offset from the opts dictionary (which is defaulted to 0)
	var step: float = TAU / count #this basically generates our first step in the circle (think of the unit circle, TAU is 2pi... so 2pi / count)
	for i in count: #loop through the count and repeat until you get a projectile that's a circle
		spawn_proj(step * i + offset, opts)

#creates an arc that has some projectiles
# so like (arc, 5) gives you a cone like consistency
func emit_arc(count: int, opts: Dictionary) -> void:
	var spread: float = opts.get("spread", PI / 4.0) #how wide our arc is gonna be 
	var offset: float = opts.get("offset_angle", 0.0) #same as circle offset
	var base: float = offset #center direction of the arc
	
	if count == 1: #if its one projectile, just send it
		spawn_proj(base, opts)
		return
	
	var step: float = spread / (count - 1) #angle between each projectile
	var start: float = base - spread / 2.0 #angle for our first projectile
	for i in count: #same thing as circle, generates the arc
		spawn_proj(start + step * i, opts)

#bowtie is like two opposing arcs which make a bow like shape (based off what google said)
func emit_bowtie(count: int, opts: Dictionary) -> void:
	var half: int = count / 2 #one half of the arc
	var safe: float =  opts.get("safe_angle", PI / 4.0) #the total gap in the bowtie
	var lobe_spread: float = opts.get("spread", PI - safe) #how much each lobe is filled
	var offset: float = opts.get("offset_angle", 0.0) #basically rotates our entire pattern
	
	#create the forward lobe by defining the spread and offset angle, then passing it into our arc function
	var opts_fwd:= opts.duplicate()
	opts_fwd["spread"] = lobe_spread
	opts_fwd["offset_angle"] = opts.get("offset_angle", 0.0) 
	emit_arc(half, opts_fwd)
	
	#create the rear lobe, which is just 180 degrees in the opposite direction
	var opts_back:= opts.duplicate()
	opts_back["spread"] = lobe_spread
	opts_back["offset_angle"] = opts.get("offset_angle", 0.0) + PI #the opposite direction
	emit_arc(count - half, opts_back) #need to do count - half to deal with the odd counts
	
func make_proj(dir: float, opts: Dictionary) -> Projectile:
	#check to see if the projectile scene even exists 
	if projectile_scene == null: return null
	
	#instantiate a projectile and then spawn it
	var proj : Projectile = projectile_scene.instantiate()
	proj.Spawn(
		get_parent(),# source
		dir,# rotation / direction
		opts.get("speed", 10), #modifiers (can comment this out for now)
		opts.get("power", 1),
		opts.get("piercing", 1),
		opts.get("knockback", 150.0),
		opts.get("effect", null),
		opts.get("field", null)
	)
	return proj

#use this to actually spawn the projectile on the screen
func spawn_proj(dir: float, opts: Dictionary) -> void:
	var proj := make_proj(dir, opts)
	if proj == null: return
	get_node("/root/GameManager/Projectiles").add_child(proj)
	proj.global_position = global_position
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
