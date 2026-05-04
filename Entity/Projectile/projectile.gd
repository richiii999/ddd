class_name Projectile extends Area2D ## Projectile: Shooty shoot
# Travels in a straight line for a set time, on hit: emits Damage() and also can spawn an explosion (if there is one set)

var source  : Node = null  # What created this projectile?
var player  : bool = false # if player proj, dont hurt player (via different layer / mask)
var power   : int = 0      # How much base power the projectile has (~ damage)
var piercing: int = 1      # How many entities can it collide with before breaking? (Always expires on hitting a wall)
var knockback:float=150.00 # Knockback (in px/s) added to velocity of entity

var effect  : EffectBASE = null # What effect applies to hit entities?
var field   : Field = null # What field to spawn when the projectile destructs?

signal damage # emitted to the thing it hits with (source, power) params

var linear_velocity : Vector2 = Vector2(0,0) # Constant linear Velocity 
# NOTE: this is an area2D, not a physics object like RigidBody2D


## Constructor, this replaces the projectile manager signal translator thingy
func Spawn( Source : Node = null,
			Rotation : float = 0.00, # The direction of travel (radians)
			Speed : int = 10, # Speed of projectile in px/s
			Power : int = 0, 
			Piercing : int = 1,
			KnockbackAmt : float = 550.00,
			Effect : EffectBASE = null, 
			endField : Field = null
			# ScaleFactor : float = 1.00, # Scales the size
			) -> Projectile :
	
	## Set stuff from Params
	source = Source
	player = Source.is_in_group("Player") # Player proj or Enemy proj (determines collision masks)
	rotation = Rotation
	linear_velocity = Vector2.from_angle(rotation) * Speed # Make the proj go forwards towards the mouse click
	power = Power
	piercing = Piercing
	knockback = KnockbackAmt
	effect = Effect
	field = endField
	#$Sprite2D.apply_scale(Vector2(ScaleFactor, ScaleFactor)) # Scales the proj
	# TODO: WTF! can't just scale the root node? "Overriden by physics engine"
	var projLayer = 6 if (player) else 10
	var projMask = 7 if (!player) else 11
	var wallMask  = 8 if (player) else 12
	set_collision_layer_value(projLayer, true)
	set_collision_mask_value(projMask, true)
	set_collision_mask_value(wallMask, true)
	return self

func _physics_process(_delta): global_position += linear_velocity # Simple physics, dont need full Rigidbody2D calculations

## Use the projectile's properties to determine damage and stuff, then delete the projectile. 
# If these are called on the wrong thing, it's probably cause layers / masks


## Terrain collide
func BodyCollideRID(rid: RID, body: Node2D, _body_shape_idx: int, _local_shape_idx: int) -> void: 
	#print("projectile hit: " + str(body))
	if body is TileMapLayer:
		var tileCoords = body.get_coords_for_body_rid(rid)
		#print(tileCoords)
		var tile = body.get_cell_tile_data(tileCoords)
		if tile.get_custom_data("Destructible"):
			# TODO: change this to work for multiple different wall tiles
			# Tile switches to destroyed version which has no collision and a different texture
			if true: body.set_cell(tileCoords, 0, Vector2i(2,1)) 
			# Failsafe: If the tilemap atlas is messed up, just erase the tile
			else: body.erase_cell(tileCoords) 
		Destruct()
	#else: pass

func AreaCollide(area : Area2D) -> void: ## Entity collide
	if(area.get_collision_layer_value(7) || area.get_collision_layer_value(11)): # Player / Enemy projHitbox collide
		var entity = Tools.FindParentByType(area, ENTITY)
		damage.connect(entity.Damage, 4) # (<>, 4) = "Oneshot" connection (disconnects after emission)
		if source != null: # Special case: source deleted before proj hits. Have to specify (source != null) can't just do (source).
			damage.emit(power)
		else:
			damage.emit(power)
		damage.connect(entity.Knockback, 4)
		damage.emit(global_position, knockback)
		
		if effect and entity.ECS:
			if source and source is Player:
				effect.sourcePower = source.getStats(Stats.INT) if source else 0
			else: effect.sourcePower = 5
			entity.ECS.AddEffect(effect)
		
		piercing -= 1
		if(piercing): return # break early to prevent destruct
	# else: wall/gate collide or smth idk, just queue free
	Destruct()

## Knockback: Applies an impulse in px/s to velocity (modified by KBresistance) 
# NOTE: modifed from Entity.Knockback(): "LINEAR velocity" 
# NOTE: signaled from the colliding projectile
func Knockback(from : Vector2, strength : float) -> void: linear_velocity += Vector2.from_angle(from.angle_to_point(global_position)) * (strength / 50) # Reduced strength due to no drag

## Destructor, called instead of queue_free() so I can prepare stuff first
var QF : bool = false # Prevent destructing twice
func Destruct() -> void: 
	if QF: return
	QF = true
	
	Tools.ParticlePassOff($ProjParticles) # Let the particles expire separately
	
	if(field): # Spawn a field
		get_parent().call_deferred("add_child", field)
		field.global_position = global_position
	
	queue_free()
