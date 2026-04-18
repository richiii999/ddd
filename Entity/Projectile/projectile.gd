class_name Projectile extends Area2D ## Projectile: Shooty shoot
# Travels in a straight line for a set time, on hit: emits Damage() and also can spawn an explosion (if there is one set)

var source  : Node = null  # What created this projectile?
var player  : bool = false # if player proj, dont hurt player (via different layer / mask)
var power   : int = 0      # How much base power the projectile has (~ damage)
var piercing: int = 1      # How many entities can it collide with before breaking? (Always expires on hitting a wall)
var knockback:float=150.00 # Knockback (in px/s) added to velocity of entity
#var element : int = 0     # What element does the proj have (0 = none)

var effect  : EffectBASE = null # What effect applies to hit entities?
var field   : Field = null # What field to spawn when the projectile destructs?

signal damage # emitted to the thing it hits with (source, power) params

var linear_velocity : Vector2 = Vector2(0,0) # CONSTANT linear Velocity NOTE: this is an area2D, not a physics object like RigidBody2D

## Constructor, this replaces the projectile manager signal translator thingy
func Spawn( Source : Node = null,
			Rotation : float = 0.00, # The direction of travel (radians)
			Speed : int = 10, # Speed of projectile in px/s
			Power : int = 0, 
			Piercing : int = 1,
			KnockbackAmt : float = 550.00,
			Effect : EffectBASE = null, 
			endField : Field = null
			# Element : int = 0
			# ScaleFactor : float = 1.00, # Scales the size
			# Location : Vector2 = Vector2(0,0) # Where to spawn it relative to source (Usually spawn at the center of source)
			# Trail : PackedScene = null # What happens when the projectile is shot? (e.g. special travel path)
			# Pattern # Spawn a pattern of bullets (e.g. in a circle, three in a row)
			) -> Projectile :
	#print("Direction: " + str(Direction) + "  " + "Shot by: " + str(Source))
	
	## Set stuff from Params
	source = Source
	player = Source.is_in_group("Player") # is it a player proj or enemy proj (determines collision masks)
	rotation = Rotation
	linear_velocity = Vector2.from_angle(rotation) * Speed # "LINEAR" velocity for rigidbody2d type to make the proj go forwards towards the mouse click
	# TODO: ^^ inherit source's velocity (not just source.velocity + other, bug: goes too fast) 
		# but you have to dampen it otherwise it's too OP, so maybe only like 25% for players and 50% for mobs
	power = Power
	piercing = Piercing
	knockback = KnockbackAmt
	effect = Effect
	field = endField
	#element = Element
	#$Sprite2D.apply_scale(Vector2(ScaleFactor, ScaleFactor)) # Scales the proj TODO: WTF! can't just scale the root node? "Overriden by physics engine"
	#$CollisionBox2D.apply_scale(Vector2(ScaleFactor, ScaleFactor))
	#position = Location
	#add_child(Trail.instantiate())
	#add_child(Explosion.instantiate())
	
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
func BodyCollideRID(rid: RID, body: Node2D, _body_shape_idx: int, _local_shape_idx: int) -> void: ## Terrain collide
	#print("projectile hit: " + str(body))
	if body is TileMapLayer:
		var tileCoords = body.get_coords_for_body_rid(rid)
		var tile = body.get_cell_tile_data(tileCoords)
		if tile.get_custom_data("Destructible"): # TODO: "if true" vvv change condition to check if destroyed tile exists based on current tile coords + 1 row or whatever
			if true: body.set_cell(tileCoords, 0, Vector2i(2,1)) # Tile switches to destroyed version which has no collision and a different texture
			else: body.erase_cell(tileCoords) # Failsafe: If the tilemap atlas is messed up, just erase the tile	
		Destruct()
	#else: pass

func AreaCollide(area : Area2D) -> void: ## Entity collide
	if(area.get_collision_layer_value(7) || area.get_collision_layer_value(11)): # Player / Enemy projHitbox collide
		var entity = area.get_parent()
		damage.connect(entity.Damage, 4) # (<>, 4) = "Oneshot" connection (disconnects after emission)
		if source != null: # Special case: source deleted before proj hits. Have to specify (source != null) can't just do (source).
			damage.emit(power, source)
		else:
			damage.emit(power) 
		damage.connect(entity.Knockback, 4)
		damage.emit(global_position, knockback)
		
		if effect: entity.AddEffect(effect)
		
		piercing -= 1
		if(piercing): return # break early to prevent destruct
	# else: wall/gate collide or smth idk, just queue free
	Destruct()

## Knockback (signaled from the colliding projectile): Applies an impulse in px/s to velocity (modified by KBresistance) # modifed from Entity.Knockback(): "LINEAR velocity" 
func Knockback(from : Vector2, strength : float) -> void: linear_velocity += Vector2.from_angle(from.angle_to_point(global_position)) * (strength / 50) # Reduced strength due to no drag

var QF : bool = false # Used as a temp to mark when queue_free() is called, to prevent destructing twice
func Destruct(skipEndEffect : bool = false) -> void: ## "Destructor", called instead of queue_free() or exit_tree() so I can do certain stuff and call it directly
	if !QF:
		QF = true
		Tools.ParticlePassOff($ProjParticles) # Let the particles expire rather than instantly disappearing
		
		if(field && !skipEndEffect): # Spawn an effect (if any) on destruct
			get_parent().call_deferred("add_child", field) # BUG: On double hit, destructs twice or something and this is called twice. happens right before free
			field.position = position # Have to do this, it doesnt just inherit
		
		queue_free()
