class_name Enemy extends ENTITY ## ENEMY: Base class for enemies, who are instantiated with params for their behavior and appearance
# Controls enemy behavior, shooting, health, and death

# Refs to nodes
@onready var HurtTimer = find_child("HurtTimer") # May not exist (ex. training dummy)

@export var XP : int = 10 # How much XP does the mob give on death? (Emitted with entity.death)
@export var targetOnSight:bool = true # Target player when spotted?

var following:Enemy = null # Set by parent enemy's spawner (ex. NecroSkull Orbiters)

func _ready():
	super._ready() # call ENTITY._ready() (sets HP and MP)
	EntityUI()
	z_index = 2
	$ShootTimer1.set_paused(true) # The shoot timers activate only when SightList has something in it
	$ShootTimer2.set_paused(true) # ^ via onFirst() turning them on & onEmpty() turning them off
	
	if following: setTargetEntity(following)
	
	if targetOnSight:
		if following: $Sight.onEmpty.connect(setTargetEntity.bind(following))
		else: $Sight.onEmpty.connect(setTargetEntity.bind(self))
		$Sight.onFirst.connect(setTargetFirstSight)
	
	if HurtTimer: HurtTimer.timeout.connect(SightIncrease.bind(false))

func _physics_process(_delta):
	ReadTerrain()
	if Behavior: Behavior.BehaviorTick()
	MoveTowardTarget()
	EntityMovement()
	var facingDir : Vector2 = velocity if velocity.length() > 10.0 else (get_global_mouse_position() - global_position)
	# Flip the sprite horizontally when facing the left 
	if find_child("AnimatedSprite2D"):
		if facingDir.x != 0: $AnimatedSprite2D.flip_h = facingDir.x < 0
	else: 
		if facingDir.x != 0: $Sprite2D.flip_h = facingDir.x < 0

func EnemyShoot(P : int, pos : Vector2 = targetEntity.global_position): ShootProj(P, pos) # Workaround for signal binds keeping one value and not updating each call

## End of Combat, revert to init behavior and heal
func CheckEndOfCombat():
	var Timeout:bool = (not HurtTimer or not HurtTimer.time_left) # Combat timeout
	var NoPlayerInSight:bool = (not Sight or Sight.smartArea.is_empty()) # Sight empty
	
	if Behavior and Timeout and NoPlayerInSight:
		Behavior.ChangeStateByIdx(0) # Revert to initial behavior
		Heal(HPmax - HP)

# Called by $Sight onFirst() & onEmpty(), also during hurtTimer duration
func SightIncrease(enterOrExit:bool): 
	if enterOrExit:
		$Sight/CollisionShape2D.shape.radius += 300
	else:
		$Sight/CollisionShape2D.shape.radius -= 300
		CheckEndOfCombat()

## OVERRIDE FUNCS: Entity Funcs overridden by Enemy.gd
func Damage(power:int, crit:bool=false):
	super.Damage(power, crit)
	
	if HurtTimer: # Increase enemy sight when starting combat
		if not HurtTimer.time_left:
			SightIncrease(true)
		HurtTimer.start(5.00)

func Death():
	for E in $Sight.smartArea: # For each Player in Sight
		if E is Player: death.connect(E.GainXP.bind(XP))
	
	var LT = find_child("LootTable") # Setup LootTable signal connections
	if LT: # Roll off loot (harder enemies may have more than 1 loot drop)
		for i in range(LT.numRolls): LT.DropItem(global_position)
	
	death.emit() # If has a parent spawner, this is already connected with bind(self)
	queue_free()
func EntityUI():
	super.EntityUI()
	if HPBar: HPBar.visible = (HPmax - HP)
