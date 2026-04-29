## TODO.gd: Using to store my TODO's and ideas
# NOTE: We are NOT doing classes, instead there's a large skill tree that offers specializations

## BUG FIXES / FUNCTIONALITY LIST

# TODO z idx list
## Z-Index list (all values should be absolute):
# 10: PLAYER, player projectiles, groundItems
# 2:  enemies
# 1:  -
# 0:  -
# -1: -
# -2: -
# -10: WorldBase
# -99: WorldEffects, should never be seen (hidden behind world)

## BUG list
# whenever you hit the necromancer, its summons take damage (that's fine for now, but we could change this in the future)
# save doesnt save skill tree information

## Main Menu - Initial Version Done: Needs more
# Splash screen / intro on game launch, specifically a custom Godot Editor splash (cool version)
# Loading screen (game launch): press space to skip all intros and just load to main asap.
# main menu music and animation


## Hall of Fame
# When you die, add entry to this list, viewable in town
# Lists the date, and amount of xp/fame u had when died


## Minimap
# your dot and enemy dots, player dots, treasure dots, dungeon dots
# Simplified terrain view


## Various enemy ideas
# Big slime boss that splits up in some phases and you can kill parts, but they break up into smaller parts that can reform
	# Changes color to show what damage type you need to use to kill it (e.g. green = poison, red = fire, etc.)
# Chase (slow strong zombies), spawn in large groups (done)
# Chase (fast weak flyers), spawn individually (done)
# Flee, opposite of chase, fast treasure bunnies that drop good items but u have to catch them
# Orbit (done)
# Detonate: enemy suicides and launches many projectiles when doing so
	# Can use this after a short period of chase to make suicide bomber enemies
# Think of 1-2 more behaviors and code them with an enemy to test it
# Enemy that acts like the car from L4D2. Anytime a player is in its radius or doesn't kill it in time, it triggers a horde of enemies (done, we added the necromancer)
# Add a necromancer boss that is fast, but has low HP BUT summons 3 giant enemies and you can't kill the necromancer until those enemies die


## Audio
# Sounds, music, sound effects, UI noises on focus and click, items have special pickup/drop sounds etc. etc.
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


## Knockback content:
# Introduce knockback as a important mechanic via pirate miniboss enemy in beach / pirate dungeon,
	# He shoots cannonball with high piercing that has HUGE knockback, you get slammed into wall / off platform into water
	# This tells player what knockback is, with minor consequences
	# PirateSHIP boss, shoots rows of cannonballs across screen with 1 or 2 holes, this is like movement mechanic.
		# If you get hit, fall off platform into water which has pirhrana enemies that only can be in water and shoot very short range
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


## World map ideas
# island has 1 waygate per biome
# Island is BIG, way bigger than mythfall's tiny ass island and bigger even than realm. I have big plans
	# One biome in my island is probably like the whole map in mythfall, maybe a bit less than that idk, depends on the biome ofc.


## Crystals / Essence
# Dungeons and open world minibosses from an area drop shards / essence
# One of which is required to unlock the shrine (teleporter) for a biome. 
# As a way to ensure the player has actually been in that area for a little bit.


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

#### CONTENT
## Tutorial 
# Tutorial will be a dungeon with several rooms (i was thinking maybe 6-7?), each showcasing different abilities of the player and possibly the enemy/dungeon itself
	# Dungeon will include: traps, base enemies, doorways, nexus gateway, item usage, very basic boss (and probably more things)
	# Loot in this dungeon should probably be fixed, just to showcase the loot and what it does
	# In order to access the other parts of the game, they have to do the tutorial dungeon
# There will be a tutorial NPC that talks the player into doing the dungeon (with maybe some basic controls involved as well)
# Problems with this idea: when a player dies, their player node gets deleted entirely, meaning they would have to do the tutorial all over again... how can we bypass that? 

## Boss Rush
# Boss Rush will be a dungeon that's high risk high reward, containing what's in the name... bosses
	# Each room will have a boss (or maybe more? not sure), which is buffed up higher than their normal version
	# They may have reworked boss mechanics or something (probably just the same boss but one thing that's different about them)
	# Each boss will drop high tier loot, which incentivizes the player to try and fight them
# Probably will be locked to a specific level (maybe like 10 or above)

## NPCs of Developers
# Literally easter egg that has us, the devs, in the game

##  
