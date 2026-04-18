class_name EffectsComponentSystem extends Node2D ## EffectsComponentSystem: Manages and applies effects to parent
# Components are cool! I just learned about them from a YT vid lmao TODO: [<yt link>]
# Loops over child nodes and applies their effects (if possible)
# Node2D so child effects can inherit position, as many effects apply particles and stuff

# TODO: when nexus, clear all effects and stuff, heal you, etc.
# TODO: UI stuff display icons and timers or soemthing (graphically transparent circles like wow)

## Effects management stuff:
	# e.g. apply a bleed 3 for 5sec, will overwrite a bleed 2 (of any time), or a bleed 3 of less than 5s, but not a bleed 4 (of any time)
	# component effects can have their own timer nodes or something that just queue free the components, reapplying stacks will just refresh the timer (like ^^) rather than make a new node.
	# Maybe different levels of the same effect can stack? idk, mayb
	# Aha! different levels dont stack, but only the highest level is applied, so if you have bleed 3 2s, and bleed 2 5s, you get (in sec) [ 3 3 2 2 2 ]
	# Status effect colors and shit are probably just gonna have to be applied every frame, idk. pick the strongest level effect and use it's color

## Permanent effects? e.g. for use in a dungeon where you are split into 2 groups and have to do stuff idk
		# Magnet, positive negative fields are attached to opposites
	# idea: Effect that gets spammed alot, whole mechanic is about not reaching too high of a timer
		# Effect is reapplied often in dungeon, and unavoidably, so the timer never goes down, if you get too high, hurt or soemthing
		# Goal is to do dungeon with minimal stacks of effect
	# UI display effects similar to wow with little squares in tr or soemthing and an icon
	# Constant effects, not the same thing as perma or untimed effects. 
		# Constant effects are stored on the player, and applied even when effects are otherwise wiped (e.g. nexus)
		# Example could be: Everyone gets a constant effect for holidays or something idk.
		# Constant effects for certain classes in the form of perma-buffs?
		# Constant effects applied from gear? e.g. constantly regen HP, or soemthing
	# Effects applied by tiles? Effects applied by worlds or dungeons?
	# as mentioned, Effects are cleared when nexus, and some other times. 
		# Priests and other supports can also clear negative effects and stuff, idk how exactly that's gonna work

## Content ideas effects:
	# content idea: status effect which adds a higher tier of itself on expire, dealing more and more dmg, must clear
	# content idea: likewise && but counts down, need to keep up stacks or explode at the end
	# TODO: effect "berserk", applies to enemies when their spawn node deactivates, or when the packboss dies, or for certain enemies, when they go below a HP threshold
	# Magnet (from specified point or node2D) by adding velocity based on what's in the field (area2D) and how close it is
	# Magnet (directional) adding constant velocity
	# Heal
	# Damage NOTE: done
	# Element
	# Speed up / slow down
	# Fields can be element resistance, HoT, DoT, etc. litterally anything.
	# Can also have tiles that have effects beyond just hurting you or whatever, conveyor belts, slippery ice, status effect goo

@export var constantEffects : Array[PackedScene] = [] # Effects which should be constant (always on, no timer, no dispell)

func _ready(): ClearEffects()
func _process(_delta): for E in get_children(): E.EffectTick()

func AddEffect(E : EFFECT_BASE = null) -> void:
	if !E: return # null case
	
	# TODO: <if timer, tier, etc. smart logic apply effects and manage timers>
	
	if E in get_children(): print("Prevented duplicate effect: " + E.efname); return # After other filters since E to be added can be different from a prior E from the same source
	
	# else: passes all filters ^^, therefore the effect is new, so add it (which calls the effects ready since this is the first time entering the tree)
	add_child(E); print("Added " + E.efname + " (" + str(E.length) + "s)")
	E.get_child(0).start(E.length) # DEBUG: Start the timer with the effect's length. This shouldnt be needed, but otherwise the timer has 0 seconds and doesnt timeout

func RemoveEffect(E : EFFECT_BASE = null, skipEndEffect : bool = false) -> void: 
	if !E: return # null case
	if E in get_children(): E.Destruct(skipEndEffect) # Only remove the effect if it is a child of this

func ClearEffects() -> void: # Called mainly from nexus or other portaling, also from priests & boss deaths
	for E in get_children(): E.Destruct(true) # Remove all effects, skipping any end effects
	for e in constantEffects: AddEffect(e.instantiate()) # Add constant effects (if any)
	for E in get_children(): E.get_child(0).stop() # Stop timers on constant effects
