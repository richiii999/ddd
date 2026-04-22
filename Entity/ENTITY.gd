class_name ENTITY extends CharacterBody2D ## Provides much useful functionality that is common across entities
# Used for players / enemies / neutrals

## References to nodes
@onready var Manager : GameManager = get_node_or_null("/root/GameManager") # Reference to the WorldNode (so I dont have to call it every time)
@onready var currWorld : WorldBASE = Tools.FindParentByType(self, WorldBASE)
@onready var Sight : SmartArea = find_child("Sight") # Ref to this entity's sight smartarea (if any)
@onready var ECS : EffectComponentSystem = find_child("EffectsComponentSystem") # This entity's EffectComponentSystem node, if null, no effects will be applied to this.
@onready var Behavior: BehaviorFSM = find_child("BehaviorFSM") # This entity's Behavior Finite State Machine node, if null, will not have any ai behavior (players dont have this)
@onready var StatusLabel : Status = find_child("Status") # This entity's Status component
@onready var HPBar : Node = find_child("HP_Bar") # This entity's HP and MP bars
@onready var MPBar : Node = find_child("MP_Bar")
var SpawnNode : Node = null # Link to the entity's spawn node (if any) (ex. player = which waygate, enemy = their spawnnode). Set by the spawnnode

## Scenes to spawn
@export var projs : Array[PackedScene] = [null, null, null]
@export var effects : Array[PackedScene] = [null, null, null]
@export var fields : Array[PackedScene] = [null, null, null]
@export var fieldEffects : Array[PackedScene] = [null, null, null]
#@export var proj1  : PackedScene = null # Main attack projectile
#@export var proj2  : PackedScene = null # Spell projectile
#@export var proj3 : PackedScene = null # Opus projectile
#@export var effect1: PackedScene = null # proj<X>'s effect and field (if any)
#@export var effect2: PackedScene = null
#@export var effect3: PackedScene = null
#@export var field1 : PackedScene = null
#@export var field2 : PackedScene = null
#@export var field3 : PackedScene = null
#@export var fieldEffect1: PackedScene = null # If there is a field, there has to be a corresponding field effect
#@export var fieldEffect2: PackedScene = null
#@export var fieldEffect3: PackedScene = null

## Entity Stats
@export var mainStat     : int = 10      # Main stat, less specific then the Player's 'core stats' since monsters dont care
@export var accel        : float = 30.00 # Multiplied by a bunch of modifiers
@export var projSpeed    : int = 10      # Projectile speed (px/s)
@export var piercing     : int = 2       # How many enemies will your projectiles pass through?
@export var aimSpread    : float = 30.0  # (Degrees) Range defining how tight the aim spread is
@export var atkSpeed     : float = 1.00  # (sec) time between shots (shoot2 is this * 5)
@export var kBResistance : float = 0.50  # Knockback resistance (0 - 1.00), inverse of this multiplies Knockback()
@export var kBstrength1  : float = 250.0 # Knockback strength (of projX) as an impulse of px/s
@export var kBstrength2  : float = 500.0
@export var elementResist: Dictionary = {} # Elemental resistiance, key = elem (string), val = tier resist (int). If applied elem < elemResist - 2, then immune, else reduced

## Terrain
var currTile  : TileData = null # Current tile under player (can be null, ex. leave edge of map)
var tileSpeed : float = 1.00    # multiplier to velocity (ex. water slows u down)
var tilePain  : int = 0         # Every physics tick, minus health (ex. poison = 1, lava = 2)

## Modifiers
@export var invulnerable : bool = false # If true, Damage() passes
func setInvulnerable(state:bool): invulnerable = state
@export var behaviorMoveSpeed : float = 1.00 # Multiplier to accel
@export var effectMoveSpeed   : float = 1.00 # Multiplier to accel

## HP / MP
@export var HPmax : int = 150 # Max HP / MP
@export var MPmax : int = 100
var HP    : int = 0 # Current HP / MP (gets set on ready)
var MP    : int = 0

# NOT A SETTER, it's an "incrementor" that also updates UI. Arguments passed will add, not assign
func incHP(inc:int): HP += inc; if (HPBar): HPBar.value = HP; if HPBar: HPBar.visible = (HPmax - HP)
func incMP(inc:int): MP += inc; if (MPBar): MPBar.value = MP

## Entity AI stuff
@onready var targetEntity : ENTITY = self # What entity is this entity targeting? (ex. player targeted by enemy)

@onready var targetPos : Vector2 = global_position # movement target (global position) for pathfinding to (players dont use this)

func setTargetEntity(T : ENTITY = self): targetEntity = T if T is ENTITY else self # Failsafe
func setTargetPos(T : Vector2 = Vector2(0,0)): targetPos = T # TODO: Pathfinding

# Workaround for double signal binding (enemy Sight.onFirst sets target entity to whatever was seen)
func setTargetFirstSight(): setTargetEntity(Sight.smartArea.front())

signal death # Emitted when ded

func initEntityUI(): ## initializes UI stuff (instead of having all these in each entity's script)
	if HPBar: HPBar.max_value = HPmax
	if HPBar: HPBar.value = HP
	if StatusLabel: StatusLabel.addStatusText("Status", "GRAY")

## ShootProj: Shoots one of the projectiles based on input and constructs them according to this entity's stats, effects, and fields
func ShootProj(input : int, Aim : Vector2) -> void:
	var index := input - 1 #literally just var assignment
	if index < 0 or index >= projs.size(): #check to see if the index that we pass in is even in the bounds of the projectiles we have set
		push_error("Invalid projectile index: " + str(input))
		return
	
	var F : Field = null       # Prepare nodes of their respective types to be filled in
	var FE: EffectBASE = null
	var E : EffectBASE = null
	var P : Projectile  = null
	
	if index < fields.size() and fields[index]: #if the index is in the range, instantiate the objects
		F = fields[index].instantiate()
	if index < fieldEffects.size() and fieldEffects[index]:
		FE = fieldEffects[index].instantiate()
		
	if index < effects.size() and effects[index]:
		E = effects[index].instantiate()
	if projs[index]: #if the index exists in the projectiles array, instantiate our projectile
		P = projs[index].instantiate().Spawn(self, Tools.NudgeFloat(global_position.angle_to_point(Aim), deg_to_rad(aimSpread)), projSpeed, mainStat, piercing, kBstrength1, E, F)
		
	#match input: # TODO this is kinda a retarded way of doing it, has to be a better way with less duplication
		#1: 
			#if field1: F = field1.instantiate()
			#if fieldEffect1: FE = fieldEffect1.instantiate()
			#if effect1: E = effect1.instantiate()
			#if proj1: P = proj1.instantiate().Spawn(self, Tools.NudgeFloat(global_position.angle_to_point(Aim), deg_to_rad(aimSpread)), projSpeed, mainStat, piercing, kBstrength1, E, F)
		#2:
			#if field2: F = field2.instantiate()
			#if fieldEffect2: FE = fieldEffect2.instantiate()
			#if effect2: E = effect2.instantiate()
			#if proj2: P = proj2.instantiate().Spawn(self, Tools.NudgeFloat(global_position.angle_to_point(Aim), deg_to_rad(aimSpread)), projSpeed, mainStat, piercing, kBstrength2, E, F)
		#3: 
			# <field 3>
			#if field3: F = field3.instantiate()
			# <FE 3>
			#if fieldEffect3: FE = fieldEffect3.instantiate()
			# <effect3>
			#if effect3: E = effect3.instantiate() 
			# <proj 3>
			#if proj3: P = proj3.instantiate().Spawn(self, Tools.NudgeFloat(global_position.angle_to_point(Aim), deg_to_rad(aimSpread)), projSpeed, mainStat, piercing, kBstrength2, E, F)
	
	#need to add a check to make sure if P and manager are null, push an error to not break the game 
	if P == null:
		push_error("Shit broke")
		return
	if Manager == null: 
		push_error("Shit broke")
		return
	Manager.add_child(P) # Reparent projectile to the world
	P.global_position = global_position # Have to do this from here, not from p.Spawn()
	if F and FE: FE.field = F; F.effect = FE; F.color = FE.color; F.source = self # Set field & effects (if any, check to see both exists first)
	if E: P.effect = E # Set effect (if any)

func ShootSmart(input : int): ShootProj(input, targetEntity.global_position + targetEntity.velocity * 20) ## Shoots at where targetEntity will be, instead of where it is now

## Damage / Heal: Called by signals, the incrementors handle UI
# TODO: do stuff with sources idk, like for tracking stats
func Damage(power : int):
	if invulnerable: return
	if !power: return # zero case
	if (HPBar && !HPBar.visible): HPBar.visible = true
	incHP(-power)
	$Status.setStatusFlash("RED", 0.25)
	if(HP <= 0 ): Death(); return # Return early on death
	
	if(HP < HPmax >> 2 && StatusLabel && !StatusLabel.textQueue.find("Low HP")): StatusLabel.setStatusText("Low HP", "RED") # Under 1/4 health, warn

func Heal(power : int):
	if !power: return # zero case
	incHP(power)
	StatusLabel.setStatusFlash("GREEN", 0.25)

func ReadTerrain(): ## Read tile under the entity, assign tile's data to variables
	if currWorld:
		currTile = currWorld.get_cell_tile_data(currWorld.local_to_map(currWorld.to_local(global_position)))
		tileSpeed = currTile.get_custom_data("Speed") if currTile else 1.00
		tilePain  = currTile.get_custom_data("Pain")  if currTile else 0

## Knockback (signaled from the colliding projectile): Applies an impluse to velocity in px/s (modified by KBresistance)
func Knockback(from : Vector2, strength : float): if !invulnerable: velocity += Vector2.from_angle(from.angle_to_point(global_position)) * (1.00 - kBResistance) * strength

## Entity.AddEffect(): This is used to add effects to entities rather than calling AddEffect on the entity's effect component system
# This way, it allows for things like immunities and stuff to be handled by the entity and just pass along a modified effect to the ECS
func AddEffect(E : EffectBASE = null, _field : bool = false) -> void:
	if (!E || !ECS): return # null case (shouldn't happen), or no ECS to apply effect to, so just return
	
	if elementResist.has(E.element): 
		return
		# TODO:
		# if res > tier + 2
			# immune, return and print immune status text
		# else, res > 0
			# resistance, lower strength of effect or soemthing, print "resist"
	
	# TODO: can have both regular and field effects at once. Field effects with timer started are reset in timer and puased,
	#if 
	
	ECS.AddEffect(E)

func RemoveEffect(E: EffectBASE = null) -> void:
	if (!E || !ECS || E not in ECS.get_children()): return # null case (shouldn't happen), or no ECS to apply effect to, or effect not found, just return
	else: ECS.RemoveEffect(E)

## OVERRIDE funcs: Player and Enemy scripts override these and provide additional functionality
func _ready(): 
	incHP(HPmax)
	incMP(MPmax)

func Death(): death.emit(self) ## Death: Default func for entities just emits the signal
