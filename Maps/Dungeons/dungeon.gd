class_name DungeonBASE extends WorldBASE ## Inspired by Gungeon, waves of enemies spawn in rooms
# Boss room has exit portal, activates when boss dies 
	# (boss death signal emits to dungeon which then calls waygate.activate and spawns chest)
# Miniboss in each dungeon
	# Gives lesser loot compared to boss, but easier. Can farm just this if you are too weak for boss
# rng treasure rooms with a chest

# TODO Displayed on entrance
@export var DungeonTitle : String = "Dungeon"

# TODO Dungeon music
#@export var bkgMusic

func onDungeonClear(): # Called by signal from boss room roomClear()
	print_debug("Dungeon Clear")

func _process(_d):
	if Input.is_action_just_pressed("V"): ResetDungeon()
func ResetDungeon():
	# TODO: Kick players out if they're still in it
	for room in $Rooms.get_children():
		room.Reset()
