## TODO.gd: Using to store my TODO's and ideas
# NOTE: We are NOT doing classes, instead there's a large skill tree that offers specializations

## BUG list
# death screen sometimes fuck up
# why does the enemy sometimes get burned in a field and other times doesn't when you charge and push out a field?

## Enemies and behaviors
# Chase (slow strong zombies), spawn in large groups 
# Chase (fast weak flyers), spawn individually 
# Flee, opposite of chase, fast treasure bunnies that drop good items but u have to catch them
# Orbit (done)
# Detonate: enemy suicides and launches many projectiles when doing so
	# Can use this after a short period of chase to make suicide bomber enemies
# Think of 1-2 more behaviors and code them with an enemy to test it
# Enemy that acts like the car from L4D2. Anytime a player is in its radius or doesn't kill it in time, it triggers a horde of enemies

## Main Menu - Initial Version Done: Needs more
# Splash screen / intro on game launch, specifically a custom Godot Editor splash (cool version)
# credits with dev nicknames and roles
# Loading screen (game launch): press space to skip all intros and just load to main asap.
# main menu music and animation
# BASIC options menu, may or may not rebind keys
# quit game button (ofc)


## Save feature for player
# Saves only player info like stats, inventory, etc.
# Also saves bank, not lost on death
# read on game launch, if present, uses the save file
# if not present, just makes a new player


## Pets
# pet follows player: 
	# Player.pos - pet.pos (+- offset based on direction or whatever), 
	# if nonzero, divide by some small number and subtract by a constant 
# Cosmetic first, then functional like stat boost or something


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
# Island is BIG, way bigger than mythfall's tiny ass island and bigger even than realm. I have big plans
	# One biome in my island is probably like the whole map in mythfall, maybe a bit less than that idk, depends on the biome ofc.


## Crystals / Essence
# Dungeons and open world minibosses from an area drop shards / essence
# One of which is required to unlock the shrine (teleporter) for a biome. 
# As a way to ensure the player has actually been in that area for a little bit.


## I fuckin hate anchors. Why is it so hard to scale things to the screen? 
# I litterally just locked the resolution of the game to 1280x720 to fix it "temporarily" (forever)
# TODO: ^ probably should lock it to 2k res and use scaling or whatever.


## Effects management stuff:
# TODO: UI stuff display icons and timers or soemthing (graphically transparent circles like wow)
# UI display effects similar to wow with little squares in tr or soemthing and an icon
# TODO: when nexus, clear all effects and stuff, heal you, etc.

## Effect content ideas:
# Effect that gets spammed alot, whole mechanic is about not reaching too high of a timer
	# Effect is reapplied often in dungeon, and unavoidably, so the timer never goes down, if you get too high, hurt or soemthing
	# Goal is to do dungeon with minimal stacks of effect
# Magnet, positive negative fields are attached to opposites
# "berserk", applies to enemies when their spawn node deactivates, or when the packboss dies, or for certain enemies, when they go below a HP threshold
# Magnet (from specified point or node2D) by adding velocity based on what's in the field (area2D) and how close it is
# Magnet (directional) adding constant velocity
# Heal
# Damage NOTE: done
# Speed up / slow down
# Can also have tiles that have effects beyond just hurting you or whatever, conveyor belts, slippery ice, status effect goo
	
## Constant effects, not the same thing as perma or untimed effects. 
# Constant effects are stored on the player, and applied even when effects are wiped (e.g. nexus)
# Example could be: Everyone gets a constant effect for holidays or something idk.
# Constant effects for certain classes in the form of perma-buffs?
# Constant effects applied from gear? e.g. constantly regen HP, or soemthing
# Effects applied by tiles? Effects applied by worlds or dungeons?
# as mentioned, Effects are cleared when nexus, and some other times. 
	# Priests and other supports can also clear negative effects and stuff, idk how exactly that's gonna work
