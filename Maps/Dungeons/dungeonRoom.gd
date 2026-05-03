class_name DungeonRoom extends TileMapLayer ## Controls mob waves and doors
# NOTE: Must have child nodes: "Doors", Waves", "Props"

@onready var waves : Array[Node] = $Waves.get_children()
var currWave : Node = null
var roomActive: bool = false # Player entered the room
var roomClear : bool = false # Waves defeated (or no waves)

signal roomCleared

var currWaveNumEnemies : int = 0

func _ready():
	for door in $Doors.get_children(): 
		door.get_node("PlayerDetector").body_entered.connect(onPlayerEnter)

## Activate all spawners in the next wave
func NextWave(): 
	currWave = waves.pop_front() # Get current wave
	if !currWave: RoomClear(); return # All waves are clear (or no waves)
	
	for spawner in currWave.get_children():
		#print("Spawned")
		var dupe = spawner.duplicate() # Dupe spawner (to re-use on dungeon reset)
		currWave.add_child(dupe)
		dupe.global_position = spawner.global_position
		dupe.setEnabled(true)
		dupe.deathSignalConnection = self # Hacky way to connect signals, enemy doesnt exist yet
		currWaveNumEnemies += 1

func SetDoors(state:bool): 
	for door in $Doors.get_children(): door.SetOpen(state)

## Signal to dungeon and unlock doors for this room
func RoomClear():
	if roomClear: push_error("Room cleared more than once"); return
	roomClear = true
	
	SetDoors(true) # Unlock
	
	roomCleared.emit()

func onEnemyDeath(): 
	currWaveNumEnemies -= 1
	if currWaveNumEnemies == 0: NextWave() # Wave is complete when no enemies remain

func onPlayerEnter(_P):
	if !roomActive: # Activate on first player entered
		roomActive = true
		get_parent().get_parent().currRoom = self # Set Dungeon currRoom
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
	#print("roomReset")
	
	currWave = null
	roomActive = false
	roomClear = false
	
	SetDoors(false) # Lock
	waves = $Waves.get_children() # Reset waves
	
	for wave in waves: # Delete stray enemies
		for child in wave.get_children():
			if child is Enemy: child.queue_free()
