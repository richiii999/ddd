class_name Enemy extends ENTITY ## ENEMY: Base class for enemies, who are instantiated with params for their behavior and appearance
# Controls enemy behavior, shooting, health, and death

@export var XP : int = 10 # How much XP does the mob give on death? (Emitted with entity.death)

var targetPosStopRadius : float = 50 # How close to targetPos will this enemy stop (values closer to 0 make movement rubberband when reach targetPos)

func _ready():
	super._ready() # call ENTITY._ready() (sets HP and MP)
	initEntityUI()
	z_index = 2 # TODO: should probably write down what order things should be layers in
	
	$ShootTimer1.set_paused(true) # The shoot timers activate only when SightList has something in it
	$ShootTimer2.set_paused(true) # ^ via onFirst() turning them on & onEmpty() turning them off
	$Sight.onEmpty.connect(setTargetEntity.bind(self))
	$Sight.onFirst.connect(setTargetFirstSight)
	
	setTargetPos()

func _physics_process(_delta):
	ReadTerrain()
	
	if(abs(global_position.x - targetPos.x) + abs(global_position.y - targetPos.y) > targetPosStopRadius ): velocity += (Vector2.from_angle(get_angle_to(targetPos))) * (accel * behaviorMoveSpeed * effectMoveSpeed * tileSpeed)
	velocity *= Vector2(0.95, 0.95)
	
	move_and_slide()

func EnemyShoot(P : int, pos : Vector2 = targetEntity.global_position): ShootProj(P, pos) # Workaround for signal binds keeping one value and not updating each call

func SightIncrease(enterOrExit:bool): # Called by $Sight onFirst() & onEmpty()
	if enterOrExit: $Sight/CollisionShape2D.shape.radius += 250
	else:           $Sight/CollisionShape2D.shape.radius -= 250

## OVERRIDE FUNCS: Entity Funcs overridden by Enemy.gd
func Death():
	for E in $Sight.smartArea: # For each Player in Sight
		if E is Player: death.connect(E.GainXP.bind(XP))
	
	var LT = find_child("LootTable") # Setup LootTable signal connections
	if LT: death.connect(LT.DropItem.bind(global_position))
	
	death.emit() # If has a parent spawner, this is already connected with bind(self)
	queue_free()
