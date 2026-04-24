class_name DungeonRoom extends TileMapLayer ## Controls mob waves and doors

@onready var waves : Array[Node] = $Waves.get_children()
var roomActive: bool = false # Atleast 1 player entered the room
var roomClear : bool = false # Waves defeated (or no waves)

signal roomCleared

var currWaveNumEnemies : int = 0

func _ready():
	for door in $Doors.get_children(): 
		door.get_node("PlayerDetector").body_entered.connect(onPlayerEnter)
	
	if !waves: return
	for wave in waves: 
		for spawner in wave.get_children(): spawner.deathSignalConnection = self # Hacky way to connect signals, there is probably a better way

func NextWave(): 
	var currWave = waves.pop_front() # Get current wave
	if !currWave: RoomClear(); return # If null, that means all waves are clear (or 0 waves), so room is clear
	
	for spawner in currWave.get_children(): 
		spawner.setEnabled(true)
		currWaveNumEnemies += 1

func UnlockDoors(): 
	for door in $Doors.get_children(): door.Open()

func RoomClear(): # Called when the room is cleared (all waves defeated, or no waves and player enters)
	if roomClear: print_debug("Room cleared more than once"); return
	roomClear = true
	
	UnlockDoors()
	# TODO: Spawn reward sometimes or something idk
	
	roomCleared.connect(get_parent().get_parent().onDungeonClear); roomCleared.emit() # Connected by parent dungeon node

func onEnemyDeath(): 
	currWaveNumEnemies -= 1
	if currWaveNumEnemies == 0: NextWave() # Wave is complete when no enemies remain

func onPlayerEnter(_player): 
	if !roomActive: # Activate on first player entered
		roomActive = true
		NextWave()
	else:
		pass 
		# TODO: More players entering room makes room harder or something idk
