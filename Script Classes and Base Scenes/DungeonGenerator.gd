class_name DungeonGenerator ## DungeonGenerator.gd: Generates dungeon rooms given a dungeonID string

# TODO: everything

static func Generate(DungeonID:int = -1): pass

func pickRoomFromID(RoomID:int = -1) -> DungeonRoom: 
	match RoomID:
		-1: # No argument provided
			return null
	return null

## Algo pseudocode
# SEED RNG!!!
# Starting with root node, decide you want at range of X1-X2 rooms
# pick X from range X1-X2
# Loop pick a random room from the set of already existing rooms
# go out in xy grid random direction by 1, 
# try to place a room there directionally from weighted list of room
# if overlap different size, try again with different room
# if there is already a room and hallway, restart round
# elif there is already a room, but no hallway, add a hallway and restart round
# else there is no room, try to add a room from that direction using that room's side doors (rng of set of doors that direction)
# # if the room doesnt fit, try with another room
# # else the room fits, add it and end round
# ^after X rounds (or 10 fails in arow idk), there are atmost X rooms, 
# algo sort the rooms by how far away from root
# # pick the farthest room, try to add a boss room away from the root (by XY to get direction)
# # if fail, try to add it on all other sides
# # if fail, try the next farthest room
# make sure if there is atleast 1 treasure room
# # if not, loop try to add one randomly until it adds one
# there shound now be adungeon with X rooms (within range X1-X2 rooms plus one possible treasure extra), with a boss room

# Grid-graph data structure, extends graph by each vertex having a single coordinate. Edges can only be length 1 perhaps
# The graph is stored as a list of vertices and sublists of verticies for rooms bigger than 1x1. Sublists contain vertices

## Ok just watched some yt vids, this one seems cool but it's 3d and shit: https://www.youtube.com/watch?v=h64U6j_sFgs
# learned that godot has algorithms for this stuff so that can help. I want to do predefined room shapes tho, like gungeon
# also pg said something big brain, add cover props like gungeon. Can iteract with them and they become cover or something,
# # destructible ofc, 
