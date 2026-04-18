class_name DungeonRoom extends TileMapLayer ## Controls spawning mob waves and locking / unlocking doors
# Props are filled in to the max, so in the editor it looks crowded but they are RNG deleted to randomize room furniture and stuff

@onready var waves : Array[Node] = $Waves.get_children()
@export var roomActive: bool = false # Has the room been activated? (Atleast 1 player entered)
@export var roomClear : bool = false # has the room been cleared (all waves defeated or no waves)

@export var isBossRoom: bool = false # If true, signals to parent dungeon node on room clear
signal dungeonClear

var currWaveNumEnemies : int = 0

@export var propFill : int = 20 # 0-100% of props removed

func _ready(): 
	#for prop in $Props.get_children(): if randi() <range 1-100> <= propFill: prop.queue_free() # TODO randomly disable props
	
	for door in $Doors.get_children(): door.get_node("PlayerDetector").body_entered.connect(onPlayerEnter)
	
	if !waves: return
	for wave in waves: 
		for spawner in wave.get_children(): spawner.deathSignalConnection = self # Hacky way to connect signals, there is probably a better way

func NextWave(): 
	var currWave = waves.pop_front() # Get current wave
	if !currWave: RoomClear(); return # If null, that means all waves are clear (or 0 waves), so room is clear
	
	for spawner in currWave.get_children(): 
		spawner.setEnabled(true)
		currWaveNumEnemies += 1

func unlockDoors(): for door in $Doors.get_children(): door.Open()

func RoomClear(): # Called when the room is cleared (all waves defeated, or no waves and player enters)
	if roomClear: print_debug("Room cleared more than once"); return
	roomClear = true
	
	unlockDoors()
	# TODO: Spawn reward sometimes or something idk
	
	if isBossRoom: dungeonClear.connect(get_parent().get_parent().onDungeonClear); dungeonClear.emit() # Connected by parent dungeon node

func WaveClear(): NextWave() # TODO: perhaps display UI stuff about wave info, and spawn minor stuff like healing

func onEnemyDeath(): 
	currWaveNumEnemies -= 1
	if !currWaveNumEnemies: WaveClear() # Wave is complete when no enemies remain

func onPlayerEnter(_player): 
	if !roomActive: 
		roomActive = true
		NextWave()
	else:
		pass 
		# TODO: More players entering room makes room harder or something idk
