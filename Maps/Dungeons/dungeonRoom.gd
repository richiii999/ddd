class_name DungeonRoom extends TileMapLayer ## Controls mob waves and doors

@onready var waves : Array[Node] = $Waves.get_children()
var currWave : Node = null
var roomActive: bool = false # Player entered the room
var roomClear : bool = false # Waves defeated (or no waves)

signal roomCleared

var currWaveNumEnemies : int = 0

func _ready():
	for door in $Doors.get_children(): 
		door.get_node("PlayerDetector").body_entered.connect(onPlayerEnter)
	
	if !waves: return
	for wave in waves:
		# Hacky way to connect signals, since the enemy doesnt exist yet
		for spawner in wave.get_children(): spawner.deathSignalConnection = self 

## Activate all spawners in the next wave
func NextWave(): 
	currWave = waves.pop_front() # Get current wave
	if !currWave: RoomClear(); return # All waves are clear (or no waves)
	
	for spawner in currWave.get_children():
		spawner.setEnabled(true)
		currWaveNumEnemies += 1

func SetDoors(state:bool): 
	for door in $Doors.get_children(): door.SetOpen(state)

## Signal to dungeon and unlock doors for this room
func RoomClear():
	if roomClear: push_error("Room cleared more than once"); return
	roomClear = true
	
	SetDoors(true) # Unlock
	
	roomCleared.connect(get_parent().get_parent().onDungeonClear, CONNECT_ONE_SHOT)
	roomCleared.emit()

func onEnemyDeath(): 
	currWaveNumEnemies -= 1
	if currWaveNumEnemies == 0: NextWave() # Wave is complete when no enemies remain

func onPlayerEnter(_P):
	if !roomActive: # Activate on first player entered
		roomActive = true
		NextWave()
	else: # Scale enemies for each extra player
		for child in currWave.get_children():
			if child is Enemy:
				child.HPmax = int(child.HPmax * 1.20)
				child.Heal(int(child.HPmax * 0.20))
				child.EntityUI()
			elif child is EnemyDungeonSpawner:
				child.playerScale += 1

## Resets the room
func Reset():
	print("roomReset")
	
	currWave = null
	roomActive = false
	roomClear = false
	
	SetDoors(false) # Lock
	
	
