class_name DungeonBASE extends WorldBASE ## Inspired by Gungeon, waves of enemies spawn in randomly generated rooms. 
# The root dungeon node has a 'DungeonID' which is given to the Dungeon generator, 
	# which generates the dungeon by picking rooms with the same ID from a set
	# It places the portal room first at the center, and the boss room last after the outermost room (by # of rooms from spawn)
# Boss room has exit portal, activates when boss dies 
	# (boss death signal emits to dungeon which then calls waygate.activate and spawns chest)
# Miniboss in each dungeon
	# Gives lesser loot compared to boss, but easier. Can farm just this if you are too weak for boss
# rng treasure rooms with a chest

@export var DungeonID : int = 0

func _ready(): 
	pass
	#await DungeonGenerator.Generate(DungeonID) # Generate a new dungeon based on the ID

func onDungeonClear(): # Called by signal from boss room roomClear()
	print_debug("Dungeon Clear")


func _process(_delta):
	pass
