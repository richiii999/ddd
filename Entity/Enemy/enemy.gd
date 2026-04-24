class_name Enemy extends ENTITY ## ENEMY: Base class for enemies, who are instantiated with params for their behavior and appearance
# Controls enemy behavior, shooting, health, and death

@export var XP : int = 10 # How much XP does the mob give on death? (Emitted with entity.death)

var targetPosStopRadius : float = 50 # How close to targetPos will this enemy stop (values closer to 0 make movement rubberband when reach targetPos)

func _ready():
	super._ready() # call ENTITY._ready() (sets HP and MP)
	EntityUI()
	z_index = 2 # TODO: should probably write down what order things should be layers in
	
	$ShootTimer1.set_paused(true) # The shoot timers activate only when SightList has something in it
	$ShootTimer2.set_paused(true) # ^ via onFirst() turning them on & onEmpty() turning them off
	$Sight.onEmpty.connect(setTargetEntity.bind(self))
	$Sight.onFirst.connect(setTargetFirstSight)
	
	setTargetPos()

func _physics_process(_delta):
	ReadTerrain()
	if(abs(global_position.x - targetPos.x) + abs(global_position.y - targetPos.y) > targetPosStopRadius ): velocity += (Vector2.from_angle(get_angle_to(targetPos))) * (accel * behaviorMoveSpeed * effectMoveSpeed * tileSpeed)
	
	EntityMovement()

func EnemyShoot(P : int, pos : Vector2 = targetEntity.global_position): ShootProj(P, pos) # Workaround for signal binds keeping one value and not updating each call

func SightIncrease(enterOrExit:bool): # Called by $Sight onFirst() & onEmpty()
	if enterOrExit: $Sight/CollisionShape2D.shape.radius += 250
	else:           $Sight/CollisionShape2D.shape.radius -= 250
	# TODO: if an enemy is hit from outside sight range, should increase also

## OVERRIDE FUNCS: Entity Funcs overridden by Enemy.gd
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
