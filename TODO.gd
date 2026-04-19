## TODO.gd: Using to store my TODO's and ideas
## Remove anything related to focus (richards job)

## Current stuff:
# Enemy behaviors: Chase (slow zombies), reverse this for flee (fast treasure bunnies)


# TODO behavior: Lift "point / target" coordiate var out of all behaviors and put it in base. since its shared
# similar refactor: abstract stat changes to a 'stat's compoment that items, effects, and skills all have. same interface for all 3.

## BUG List
# Still not sure what sets the time for a field to 5s, I litterally changed every possible "length" (none were even 5 btw) and none of them did anything? wtf? Where is this phantom 5 come from?
# focusList doesnt have freed entities removed, so setMaxFocus() on focusTick() can set to a freed entity.
	# partial Fix: Fixed for players, but idk about enemies: When gainXP is called from enemydeath signal, that enemy is removed from player's focusList






## "Easy" / soon stuff:
# 3rd ability: use 125 charge to do opus ability: unlocks at level 20, replaces booming and gettign hurt at 125 (still hurts 100-124)
# Lighting effects: Many things can light stuff up, many things can occlude light. Environmental lights like torches, projectile magic glow, 
# seedRNG? World sets a seed when loaded, dungeons too
# Pets, pet follows player: Player.pos - pet.pos (+- offset based on direction or whatever), if nonzero, divide by some small number and subtract by a constant (or the remainder to 0, whichever smaller ofc)
	# Cosmetic first, then functional like stat boost or something
# Services and stuff will be in the town, so bank, leaderboard, guild building, etc. will all be in nexus scene
	# each service is still its own scene ofc, but it doesnt have to be like totally separate to where you portal to vault or whatever
# Open source tilesets

## "Hard" / later stuff:
# Coins currency, get for doing hard stuff and from daily login.
	# Can have premium coins that gain from hard stuff or like:
	# Spend on whatever, gear, pots etc. Gear tokens cause RNG is cringe
	# leveling to max = 1 coin, killing oryx phase = 1 coin (so 3 total), killing endgame dungeon boss = 1 coin, daily drop = 1 coin, etc. 
	# Spend coins on endgame items like pots and UT gear (1 coin = 3 stat pots any kind, 20 HP AND MP pots, 3 coins = 1 UT, stuff like that idk), 
	# instead of relying on RNG drops, just spend coins as gear tokens on whatever you want.
# Rendering, whole world at once? Or only region around char?
	# Ifn world, but still nexus all at once (Cause statics and smaller overall)
# minimap with your dot and enemy dots, player dots, treasure dots, dungeon dots

## Content Grind:
#Start with like 1 or 2 classes to make sure class specific gear drops are working.
	# Start with 1 or 2 small fight maps, and the nexus ofc. Using tilemaps. 
	# Bossfights and custom scripting for complex mobs can come after generic mob-wandering behivor scripts. 
#Once framework is done, flesh out mainworld and dungeons, then the special oryx dungeon and gear.
	# Dungeon Ideas: Various enemy chambers, puzzles, minibosses and final bosses with loot
		# Obviously copy RotMG dungeons and such, but what else ideas? Incorporate cool mechanics and unique enemy patterns
		# Dungeons have special things in chat, can use a giant area2d that covers the whole thing to limit chats to only players in that D
	# Boss Ideas: Unique sprites & animations, MUSIC(???), scripting / behavior (via phases) in boss script, minions, etc. etc.
		# Big slime boss that splits up in some phases and you can kill parts, but they break up into smaller parts that can reform
			# Changes color to show what damage type you need to use to kill it (e.g. green = poison, red = fire, etc.)
# Sounds, music, sound effects, UI noises on focus and click, items have special pickup/drop sounds etc. etc.
	# ytdl the rotmg OST
	# Other music
# Player (& enemy) animation when charging spell (particles going into sprite and gorwing bigger
	# play smol sound when mana ready (like terraria mana sound)
	# also play the animation backwards for a single particle when released
	# have growing particle effect on palyer when charging spell (starts at 25, goes up to 100 then pulses up to 125), bursts when cas
# Play rotmg, save pics of ui and assets and stuff
# Fancy particle effects, still pixelated but cool lighting and stuff
# Status color orange / blue for goo dungeon mechanics
# Get a pixel art text font
# Glowing lighting and shining stuff, daytime / nighttime effect perhaps? Or oryx can cause an eclipse which darkens the world for 10 mins then final boss

## Classes: have specs & 2shot at level 10 (3 each), Opus at level 20 (3rd ability), level cap is 25 (then earn fame)
# Unlock upgraded class upon reaching fame 5 with a class. Fame rewards per class per account.
	# Fame gear can be recieved once per new char in the nexus, if you have unlocked that tier, you can get free starting gear for that class which is of a certain tier (higher fame unlocks better tiers)
	# ^^ cannot be dropped, only trashed
# Mage: INT (1shot is zap): Pyromancer (spam dot aoe), Cryomancer (precision status effect), Arcanomancer (summony) (red/blue/purple). 
	# 1shot is fireball (med speed, small aoe & applies dot), ice spike (fast, no aoe, applies cold), magic missile (curved 'S' path)
	# 2shot is pyroblast (big aoe & applies dot), Icicle Blast (instant thin long cone aoe, applies cold), mana bomb (slow aoe field)
	# 3rd is dragon breath (wide short cone aoe, dot), Blizzard (aoe thin long blast at mouse, freezes cold enemies), portal (teleport to it on cast, turrets shoots homing missiles from both ends)
# (Mage Upgrade) Sorcerer: WIS (1shot is <>): Geomancer (summon), <> (), <> () 
	# 1shot is Rune (homing), starshot (fast proj)
	# 2shot is 
	# 3shot is summon Golem (turret shoots 1shot and 2shot)
# Warrior: STR (1shot is slice): Knight (1h shield, tank), Berserker (dual wield, shortrange), <> (2h midrange)
	# 1shot is 
	# 2shot is
	# 3shot is
# (Warrior upgrade): END ()
	# 1shot is 
	# 2shot is
	# 3shot is
# Rogue: AGI (1shot is stab): Assasin (dual wield dagger, status effects), <> (), <> ()
	# 1shot is 
	# 2shot is dash (fast move straight line with parralel projectile), 
	# 3shot is knife fan (spray projectiles but like one at a time not all at once)
# (Rogue upgrade): DEX (): Pirate (1h sword, 1h pistol, midrange), <> (), <> ()
	# 1shot is slice, 
	# 2shot is spreadshot (Cone aoe), shadowstep (teleport with trailing projectile)
	# 3shot is Cannonball (med speed projectile with very high piercing), 
# Hunter: 
	# 2shot is lay trap
	# 3shot is bear call (bear projectile lmao, slow proj, single target high fast bleed) 
# (Hunter upgrade): 

## Multiplayer Specific
# Feature: Saving a char, go to nexus and interact with a special
	# how file management?
	# building to save them and the equipment, stats, etc. Loses permad status
	# Vaults are shared per accoint(b) is equivalen
	# as many characters saved as you want
	# HARD: Server side vs client side saving. Saving a char saves both, 
		# (option to pick either or?), servers can disable client loading so you can only load chars from that server
		# this allows for permadeth servers but you can save the char, and prevents save file editing from happening
		# client side. Keep track of it via a unique ID string per server per client. Just enter the ID to get the 
		# list of saved chars. ID's are managed client side in a list and the server they are for, while 
		# they are managed server side with a ID in each save only being sent to clients with a matching ID on request
		# perhaps local chars (offline mode) can be ID of 0000-0000-0000-0000 or something like that
# Permadeath: can enable or disable permad
	# If on, shows char scoreboard in menu (and on death) and option to save or delete on death
	# If saved, continue but stop earing orange points
	# Orange points are used to buy cosmetics and stuff
	# Must start new char to earn orange points, not use a saved char
	# Higher leaderboard or achievements give orange points
# Chat functionality, parties, guilds, whispers, mute list

## Polish ideas:
# Splash screen / intro on game launch, specifically a custom Godot Editor splash (cool version)
# Funny credits: "Me, Me, Me, Me ..."
# Longshot, but custom lightweight node improvements? Litterally take pre-existing nodes and strip out parts I never use, for sake of de-bloating.
# Tism refactor, make the code neat/tidy, UI alignment perfect, Set defaults for params, default vals for prefabs (ex. projectiles arent null, but rather a basic proj), set return types for functions (alot of voids), etc.
# change const variables to consts or whatever its called
# QA test with close friends, get many people on at once, make special world with MANY mobs, turn up the shoot timer's to 0.10 sec, etc. stress test
# Debloat if at all possible any networking stuff, minimize bandwidth necessary and allow leniency for desyncs
# Node Hierarchy: Plan a good node structure [https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html]
# Maybe make triggered things a component? e.g. TriggerTX and TriggerRX components that reference an area's signals to send stuff to eachother
	# Otherwise, with the current implementation, triggered objects have duplicated code that is slightly different (bad practice)
# Loading screen (game launch): allow to skip all intros and just load to main asap. 
	# Other QoL fast features can be like: quickjoin last server on last character, etc.

### Flesh out things
## State machine for controlling enemy behavior
	# DONE: Enenmy basic wandering and shoot at player
	# Basic proj and special aoe attack
	# Multiple behaviors, wander, spaz, circle, chase, leash, flee, etc.
	# projectile types (1, 2, 3, aoe, etc.), and stats, texture, animation frames, etc.
## Also, perhaps can scale up enemy HP by player party size (like set a enemyHPscale, set it to the max of player.partysize in focuslist), 
	# apply this before doing damage to prevent cheese (mythfall suffers from this problem: latency on this effect is too low)
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
# "Locked" loot: OK I rethought the idea, and just make a bag linked to a particular player, one item (or stack) per bag
	# enemies with more than one loot item, just drop them one at a time one per bag.
	# Most normal items and pots will not lock
	# Bosses drop loot to roughly 1/3 of players on focus
	# quest items in a bag will lock the bag to that player only. You cannot drop quest items. #oh yeah also quests and stuff
	# ex. if you have a quest bag, and it despawns or whatever, gets sent to your mail #oh yeah also mail and stuff
# Quickloot: Loots potions, if there are more potions than you can use: "Greedy" option will just use them right out of the bag
	# ex. You have 149/150 HP and 5/5 pots. quickloot will not pick up the pot. Greedy quickloot will
	# ex. you have 1/150 HP and 5/5 pots. both options will use 1 pot, greedy will use 2 from bags. 
	# Quickloot will never use your inventory's pots.
	# ex. you have 149/150 HP and 4/5 pots. Both options will pick up a pot BUT NOT USE IT.
	# Gear quickloot: Automatically upgrades your gear if availible, based on tiers. Can be turned on after you reach 
		# a certain fame level or something idk. QOL to make leveling easier. Can be toggled on for characters under Level 20,
		# will automatically equip higher tier gear than currently, if there is any in bags when you press quickloot.
		# Replaces the bag items with your items, if you want to keep your old items, you have to put them in your inv manually still.
## World (s), dungeon (s), nexus, vault, daily hall, leaderboard hall (personal leaderboard in vault), oryx endgame
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
## Misc idea: Implementation of item slots in UI dialogues (for trading, turning in quests, etc.), plus other stuff
# Can put in items to slots, slots can be filtered to only accept certain items (or even only one particular item) and stacks of items
# Button to transact, so it only happens after you click it not right away. Transactions can't be partial
	# ex. you need 3 items to create a 4th, you must turn in all 3 at once, cannot save or whatevr. Just put the items in bank or something to save them
# Can put resources and currencies too like fame / coins too.
# Special currencies for holiday events, seasons, etc. All earned at a small proportinal rate with XP (like fame).
	# Holidays have currencies for holiday cosmetics
	# Seasons have currencies for their thing, idk kinda dont want to implement seasons. If do, make them selectable for past ones like hor DRG does it.
	# Maybe instead of seasons, can do class currencies? Wizards have wizardbux but it's called something thematically cool like arcana or something idk.
	# The class-based idea has a con where players probably just want to play their 1-2 mains and ignore the other classes, whereas seasons can be done by all classes to 100%
# Content ideas for this mechanic:
	# Crafting system, not to make base items, but really to upgrade base items with augments like gems and stuff idk
		# That would also imply materials to augment items such as the aforementioned gems, but also other thigns too
	# Quest items turn in to NPC for reward
		# Class questlines, do specific dungeons. Access to single-player dungeons for quests, can be altered versions of existing dungeons or soemthing.
			# class dungeons lean heavily into class-specific mechanics obviously
			# Questlines give class gear that's really good. Progression can be like: need a class piece to upgrade with final boss token to get endgame tier gear
				# This makes it impossible to just farm / grind and rely on group cheese or other for reaching highest tier items, must do atleast a little bit of solo skill
	# Item trading with other players: tbh can just drop shit on the ground, soulbound stuff like quest items cant be dropped nor would they be tradable anyways
	# Item transmutation: semi-gambling mechanic where you put an item in + currency and get an item out based on inputs. 
		# Can be used to accellerate new chars if you dont have spare gear but have lots of account currency
# Currency gains: Fame from achievements, helpful to new players. Especially much fame on first max level char, enough to buy a couple upgrades outright to introduce mechanic
# Achievements are per acc of course, so are currencies
# Repeatable quests "dailies" especially during holidays/seasons for currency rewards.
	# Game dailies are simple things like "complete X dungeon", "Kill X enemy type Y times" rewards a daily coin
# Dont worry, NO MICROTRANSACTIONS. I dont even know how to add them anyways. The game is gonna be foss and shit anyways. I will also try to make it such that you can change all the sprites so cosmetics are kinda useless if you know how to do that
## Random idea: Damage nums as particles (heal nums too)
# Since damage nums are so tight in range, would it be more efficient to use particles?
# Test many many damage in a row with status text spawns and despawns on timer
# compared to using switch-case and spawning the right particle from 1-99
# Can have a "damage nums" GPUparticles node and it emits once per damage() with the correct sprite (from an atlas)
# idk, seems more efficient to me, compared to spawning individual rich text nodes and moving them or keeping all damage nums in status text
## "Flask" idea, can craft stat pots, and combine like 10 medium pots of a stat into a "flask" which doesnt take space
	# The flask is reusable forever, and gives 1 medium pot of stat. So you can still use large pots if you want but you can use the flask always
	# Healing and MP flasks can be made too, but you are for sure gonna want to keep hp pots still
	# Flask button goes next to mp and hp pot button
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

## Since IS Started:

# dungeons have 'stages' separated by bosses / minibosses. once clear stage 5x (or wtvr) get key or something to skup to next stages start. 
# e.g. jungle temple first stage is 'JT1' clearing this 5x will let you (one-way) teleport to just after the treasure room of jt1, and the start of jt2. 
# this allows reuse of dungeon spawners and keeps early game content relevant for longer, while not requiring late game players to run throgu hteh 
# early stages of low level dungeons. idea is that different stages have different tilesets but still thematically similar. ex. succ castle 1 is a castle 
# theme with knights and stuff and the boss is throne room. sc2 is a dungeon or red carpeted area . sc3 is idk, maybe dungeons idk. point is they are 
# different loot tiers and difficulties. a dungeons stage shouldnt be linar to difficulty, e.g. stages 1 2 3 shouldnt just be 1 extra tier each, they 
# can jump e.g. stage 1 -> 2 is loot tier 2 -> 4. the gap is purposeful, and is filled by other dungeons and game content to prevent just running the 
# same dungeon from start to end for multiple tiers (esp. in a row) keys are only for whole stages, miniboss skips not necessary. this could result in 
# situation where multiple players join dungeon at same time but start at different stages, thats fine. maybe add room protection (door lock after 
# some time) to prevent late joiners or whatever. have on screen display when stage change and loot tier, along with music change. can have this be 
# singleton overall game UI so not spammable, aso find cool pixely font to use.

# pack bosses can be targets of quests, or also regular mobs idk. e.g. kill 20 slimes (regulr) vs kill 1 big slime or someth (packboss)


#
#Dungeons and open world minibosses from an area drop shards / full crystals, one
#of which is required to unlock the shrine (teleporter) for a biome. As a way to
#ensure the player has actually been in that area for a little bit.
#
