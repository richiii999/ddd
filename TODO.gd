## TODO.gd: Using to store my TODO's and ideas
# NOTE: We are NOT doing classes, instead there's a large skill tree that offers specializations

## BUG list
# boss2 behavior is supposed to be identical to orbit, but doesnt work.


## Enemies and behaviors
# Chase (slow strong zombies), spawn in large groups 
# Chase (fast weak flyers), spawn individually 
# Flee, opposite of chase, fast treasure bunnies that drop good items but u have to catch them
# Orbit (done)
# Detonate: enemy suicides and launches many projectiles when doing so
	# Can use this after a short period of chase to make suicide bomber enemies
# Think of 1-2 more behaviors and code them with an enemy to test it


## Death - Done
# Deathscreen, with respawn button and shows your XP / Fame
# Respawn takes u back to nexus as new char
# DEBUG: respawndebug button just revives you in the same spot


## Main Menu - Initial Version Done: Needs more
# Splash screen / intro on game launch, specifically a custom Godot Editor splash (cool version)
# credits with dev nicknames and roles
# Loading screen (game launch): press space to skip all intros and just load to main asap.
# main menu music and animation
# BASIC options menu, may or may not rebind keys
# quit game button (ofc)


## Save feature for player
# Saves only player info like stats, inventory, etc.
# read on game launch, if present, uses the save file
# if not present, just makes a new player


## NPC Dialogue
# Preferably re-using the existing 'Interactable' code
# Press 'E' to talk to an NPC, which makes a text box and NPC picture at the bottom of screen
# NOTE: Players can still move when talking to NPC, just close the dialogue if they walk away
# At the end of dialogue, emit a signal for NPC dialogue completed (can perhaps be used for quests)


## Currency
# Drops from bosses, 1 coin per boss maybe
# Can be used at shops (interactables in the nexus):
	# clicking a shop button will attempt to place an item in your inv, while removing coins


## 3rd Ability "Opus"
# Before level 25: Holding space till 125 charge hurts you
# After level 25: Holding space till 125 launches a different spell called an "Opus"
# Opus is unique to each class


## Pets
# pet follows player: 
	# Player.pos - pet.pos (+- offset based on direction or whatever), 
	# if nonzero, divide by some small number and subtract by a constant 
# Cosmetic first, then functional like stat boost or something


## Bank
# Extra inventory that isnt deleted when you die
# Access via some place in the nexus


## Hall of Fame
# When you die, add entry to this list, viewable in town
# Lists the date, and amount of xp/fame u had when died


## Minimap
# your dot and enemy dots, player dots, treasure dots, dungeon dots
# Simplified terrain view

## Various enemy ideas
# Big slime boss that splits up in some phases and you can kill parts, but they break up into smaller parts that can reform
	# Changes color to show what damage type you need to use to kill it (e.g. green = poison, red = fire, etc.)

## Audio
# Sounds, music, sound effects, UI noises on focus and click, items have special pickup/drop sounds etc. etc.
	# ytdl the rotmg OST
	# Other music, open source (kevin macleod)


## Art & Animation
# Player (& enemy) animation when charging spell (particles going into sprite and gorwing bigger
	# play smol sound when mana ready (like terraria mana sound)
	# also play the animation backwards for a single particle when released
	# have growing particle effect on palyer when charging spell (starts at 25, goes up to 100 then pulses up to 125), bursts when cas
# Fancy particle effects, still pixelated but cool lighting and stuff
# Get a pixel art text font
# Glowing lighting and shining stuff, daytime / nighttime effect perhaps? Or oryx can cause an eclipse which darkens the world for 10 mins then final boss


## Projectile Patterns: can spawn projectile's in special patterns
# Possibly can group pattern projectiles via one parent node that has only ONE timer
# interface can be like pattern(type, num, [color optional]) where type is like, circle, 2pair 3p,4p,np, 
# chain (which is a repetition of some other pattern multiple times)
# ex: (circle, 3) makes a triangle, and (circle,40) is a bullet hell
# (bowtie, 20, 50degrees, 45egrees) is a bowtie shape with a safezone of 50deg and a 45deg offset from the rotation of the boss
# Proj pattern example, for loop spaws a grid of projectiles tat moves across the screen on a line or a curved path
# adv patter, block: spawns a 3x3 grid or whatever predefined shape that moves along a path
# adv proj patter, wing rings:  spawns concentric rings that emit from the center and rotate on offset sinewaves via bowtie


## Inventory UI stuff
# Item Color: Wh < Gr < Bl (max openworld) < Pu (dgn boss) < Red (oryx) < Orange (quest items)
# Quickloot: Loots potions, if there are more potions than you can use: "Greedy" option will just use them right out of the bag
	# ex. You have 149/150 HP and 5/5 pots. quickloot will not pick up the pot. Greedy quickloot will
	# ex. you have 1/150 HP and 5/5 pots. both options will use 1 pot, greedy will use 2 from bags. 
	# Quickloot will never use your inventory's pots.
	# ex. you have 149/150 HP and 4/5 pots. Both options will pick up a pot BUT NOT USE IT.
	# Gear quickloot: Automatically upgrades your gear if availible, based on tiers. Can be turned on after you reach 
		# a certain fame level or something idk. QOL to make leveling easier. Can be toggled on for characters under Level 20,
		# will automatically equip higher tier gear than currently, if there is any in bags when you press quickloot.
		# Replaces the bag items with your items, if you want to keep your old items, you have to put them in your inv manually still.


## Knockback stuff:
# Introduce knockback as a important mechanic via pirate miniboss enemy in beach / pirate dungeon,
	# He shoots cannonball with high piercing that has HUGE knockback, you get slammed into wall / off platform into water
	# This tells player what knockback is, with minor consequences
	# PirateSHIP boss, shoots rows of cannonballs across screen with 1 or 2 holes, this is like movement mechanic.
		# If you get hit, fall off platform into wat	er which has pirhrana enemies that only can be in water and shoot very short range
# Later in game, area / dungeon with lava on ground
	# miniboss / boss with aoe knockback effect, if you get hit: knocked into lava
	# This builds on the mechanic from earlier, placing higher consequences for failing the mechanic
# Wind dungeon: Placed high emphasis on knockback mechanic
	# Most enemies, even minor ones, have knockback in this dungeon, they also take high knockback too.
	# Entire dungeon surrounded by push field that pushes player towards bottom of screen, goal is to move upwards
	# Paths are thin, must cross thin paths while being assaulted by enemies that shoot with high KB
	# If you get pushed off, dont die, but take minor damage and have to gat back on path
	# There are "checkpoints" or sections of the dungeon to which you cannot fall below once you cross
	# Dungeon is cloud-themed, with light gray and white tiles and stuff. 
	# Little tornado enemies, wind gust effect fields applied randomly around the place, sky-related bosses (e.g. stormcloud shoots lightning)


## Random idea: Damage nums as particles (heal nums too)
# Since damage nums are so tight in range, would it be more efficient to use particles?
# Test many many damage in a row with status text spawns and despawns on timer
# compared to using switch-case and spawning the right particle from 1-99
# Can have a "damage nums" GPUparticles node and it emits once per damage() with the correct sprite (from an atlas)
# idk, seems more efficient to me, compared to spawning individual rich text nodes and moving them or keeping all damage nums in status text


## "Waygate" node is the player spawn points and teleport network. Interacting with one opens the map. 
# The map btw can be revealed fully once you have all waygates in exchange for coins from an npc guy
# One-way gates only tele one way and are used for dungeon entrances (into dungeon) and exits (back to nexus)
# island has waygates around edge and in concentric rings going to center in each biome
# can activate waygates by interacting with disabled ones, this is per character per acc
	# Achievement for getting all waygates ofc
# Enemies in biome drop keys to run dungeon for that biome, can bring key to the biome's dungeon door and use it to activate it once
	# All players in a group must have a key to enter, as it is PER CHAR
	# Keys are account bound, so can transfer to alts and level faster
	# Keys dont take inv space? Store separately
# Island is BIG, way bigger than mythfall's tiny ass island and bigger even than realm. I have big plans
	# One biome in my island is probably like the whole map in mythfall, maybe a bit less than that idk, depends on the biome ofc.
	# You can teleport to party members tho from the map


## Crystals / Essence
# Dungeons and open world minibosses from an area drop shards / essence
# One of which is required to unlock the shrine (teleporter) for a biome. 
# As a way to ensure the player has actually been in that area for a little bit.
