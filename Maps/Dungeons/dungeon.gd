class_name DungeonBASE extends WorldBASE ## Inspired by Gungeon, waves of enemies spawn in rooms
# NOTE: The boss room should be the last child of $Rooms

# TODO: RNG treasure rooms with a chest

# TODO Displayed on entrance
@export var DungeonTitle : String = "Dungeon"
var currRoom = self # Set by each room's entrance door

# TODO Dungeon music
#@export var bkgMusic

var exitWaygate : Waygate = null # ref to exitWaygate (if any)

func _ready():
	$Waygates.get_child(0).arrived.connect(ResetDungeon)
	$Rooms.get_children().pop_back().roomCleared.connect(onDungeonClear)

func onDungeonClear(): # Called by signal from bossRoom's roomClear()
	print_debug("Dungeon Clear!")
	
	for room in $Rooms.get_children():
		room.SetDoors(true) # Unlock any leftover doors
	
	# Exit Waygate spawned on dungeon clear, takes player back to nexus and resets dungeon
	# NOTE: Unbind(1) in the last line here means ignore the passed arg (free doesnt have params)
	exitWaygate = load("res://Maps/Mechanics/Waygate.tscn").instantiate()
	$Rooms.get_children().pop_back().call_deferred("add_child", exitWaygate)
	exitWaygate.exit = true
	exitWaygate.setActive(true)
	exitWaygate.find_child("InteractComponent").Interact.connect(exitWaygate.queue_free.unbind(1))

func ResetDungeon(_P): # Trash player argument from exitWaygate.Interact
	for room in $Rooms.get_children(): room.Reset()
	if exitWaygate != null: exitWaygate.queue_free() # Clear leftover exit
