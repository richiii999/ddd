class_name Player extends ENTITY ## PLAYER: Gamedevs be like: Player.script = 10,000LoC, any other script = 5 LoC
# controls the player and UI via keypresses. Stores stats, actions, storage, and lots of stuff...

## Refs to child nodes
@onready var Inv = $CanvasLayer/RMenu/Inventory # Other stuff needs to access player inv (ex. shops)
# NOTE: Inv requires there to be a ItemPickupRange (type SmartArea)

## Stats
@warning_ignore("int_as_enum_without_cast")
@export var coreStats: Dictionary[Stats.STAT, int] = {
Stats.STR: 5, 
Stats.INT: 5, 
Stats.AGI: 5, 
Stats.TOU: 3, 
Stats.WIS: 3, 
Stats.DEX: 3, 
Stats.BLK: 1, 
Stats.WIL: 1, 
Stats.SPD: 1
}
var gearStats := {}
var effectStats := {}

@export var defaultProjectile : PackedScene
## Pots
var HPotmax : int = 5 # Max Potions you can carry
var MPotmax : int = 10
var HPotC   : int = 3 # Current Potion count
var MPotC   : int = 5
var potionFactor : float = 1.00 # Multiplier to potion effects # TODO: (applies to status potions timers also). Changed by gear, skills, perks, status effects, etc.

## XP
var Level : int = 1   # maxes out at 25
var XPmax : int = 100 # XP needed for a given level (scales up, see LevelUp())
var XP    : int = 0   # Current XP
var Fame  : int = 0   # Current Fame (on this char, can cash in max ever earned per class per acc)
var XPScaleFactor : float = 1.25 # How much does the cost go up per level?
var FMScaleFactor : float = 1.05 # How much does the cost go up per fame? (scales slower)
var skillPoints : int = 1 # One per level

## Currency
var coins : int = 0 # Coins drop from various places / enemies
func incCoins(i:int): coins += i; %RMenu/Coins.text = str(coins)

## Dashing
var dashing : bool = false # Dashing state, if true, cannot move with WASD
var dashMax : float = 2.00 # Max dashes stored
var dashNum : float = 0.00 # Current dashes stored (use 1.00 per dash)
var dashRec : float = 0.005 # Dash recovered per frame (def: 0.005)
var dashLen : float = 100  # (px) Length of dash
var dashSpd : float = 600  # (px/s) Speed of dash
func setDashing(B:bool): dashing = B # needed cause signal (vvv)
# $DashTimer.timeout -> setDashing(false)
# $DashTimer.timeout -> $Projhitbox.col_layer(7, true)

## Input
var InputStatus : bool = true # Set by setInput()
func setInput(state:bool): InputStatus = state # Disables all input (used when loading or during certain animations)
var InputV : Vector2 = Vector2.ZERO # Input vector
var charge : int = 0 # (Spacebar) Charge incrementor for spellcasting
signal Interact # Emitted with self to any connected interact component

#get all of your stats 
func getStats(stat : int) -> int: 
	return coreStats.get(stat, 0) + gearStats.get(stat, 0) + effectStats.get(stat, 0 )

#get the item in your main and offhand
#func getMainHand():
#	return %Inventory.Inv[%Inventory.Slot.MAINHAND]

#func getOffHand():
#	return %Inventory.Inv[%Inventory.Slot.OFFHAND]

func getEquippedProj(index : int) -> PackedScene:
	#check to make sure the inventory node is not null
	if Inv == null or Inv.Inv == null:
		return super.getEquippedProj(index)
		
	var main = Inv.Inv[Inv.Slot.MAINHAND]
	
	#check if the projectiles exist and left click is pressed, then return
	if index == 0:
		if main and main.projectile:
			print("Using MAINHAND projectile:", main.projectile.resource_path)
			return main.projectile
		else:
			print("Default projectile")
	return super.getEquippedProj(index)

#apply the stats of items/skillpoints 
func applyStats(target: Dictionary, stats : Dictionary, mult : int = 1):
	for key in stats: 
		var new_val = target.get(key, 0) + stats[key] * mult
		
		#if the entry is empty, remove it
		if new_val == 0: 
			target.erase(key)
		else:
			target[key] = new_val
#get the move speed buff

func get_move_spd() -> float: 
	var spd = getStats(Stats.SPD)
	return 1.0 + (spd / (spd + 20.0))

#debug testing
#func test_apply_stats():
	#var test_stats = {Stats.STR: 10, Stats.SPD: 5}
	
	#print("Before:", gearStats)

	#applyStats(gearStats, test_stats)

	#print("After add:", gearStats)
	#print("Total STR:", getStats(Stats.STR)) # should be 5 (core) + 10 = 15
	#print("Total SPD:", getStats(Stats.SPD)) # should be 1 (core) + 5 = 6

	#applyStats(gearStats, test_stats, -1)

	#print("After remove:", gearStats)
	#print("Total STR:", getStats(Stats.STR)) # back to 5
	#print("Total SPD:", getStats(Stats.SPD)) # back to 1

func _ready():
	super._ready() # call ENTITY._ready() (sets HP and MP)
	super.initEntityUI()
	print("Inventory node:", Inv)
	#print(get_tree_string_pretty()) #Debug print the nodetree
	#test_apply_stats()
	%DeathScreen.find_child("Restart").pressed.connect(_OnDeathScreenButtonPushed)
	%DeathScreen.find_child("DebugRestart").pressed.connect(_OnDebugRevive)
	## Initialize the UI info
	%RMenu/Utility/MPot_Button.text = "%s/%s" % [MPotC, MPotmax]
	%RMenu/Utility/HPot_Button.text = "%s/%s" % [HPotC, HPotmax]
	%RMenu/MP_Bar.max_value = MPmax
	%RMenu/XP_Bar.max_value = XPmax
	%RMenu/HP_Bar.visible = true
	
	# Connect signals
	$DashBar/DashTimer.timeout.connect(setDashing.bind(false))
	$DashBar/DashTimer.timeout.connect($Projectile_Hitbox.set_collision_layer_value.bind(7, true))

func get_input(): # TODO: replace this with _input() ?
	## Debug stuff
	if Input.is_action_pressed("H- (Debug)"): Damage(20)   # "CRTL+0"   Health minus
	if Input.is_action_pressed("H+ (Debug)"): Heal(20)     # "Shift+0"  Heal plus
	if Input.is_action_just_pressed("X+ (Debug)"): GainXP(9999) # '9'        XP plus for leveling up for debugging
	if Input.is_action_just_pressed("DEBUG_Bubble"): toggleBubble(!invulnerable) # "Shift+7" Toggles bubble invulnerable
	
	if !InputStatus: return # Disallow input if it's disabled
	
	## Movement keys:
	InputV = Input.get_vector("left", "right", "up", "down")
	if !dashing: 
		#get the speed and then cap it as you keep leveling up
		var spd_mult := get_move_spd()
		velocity += InputV * (accel * effectMoveSpeed * tileSpeed * spd_mult)
		velocity *= Vector2(0.95,0.95) # slowdown / speed soft-clamp
	
	# TODO: change aniframe and sprite flip direction based on direction / velocity for player, or if not moving, mousePos\ (DONE), now we need to get sprites
	# The "velocity.length() > 10.0" tells us "are we moving fast enough to count as moving?", and the else gives us a vector pointing from the player toward the mouse 
	var facingDir : Vector2 = velocity if velocity.length() > 10.0 else (get_global_mouse_position() - global_position)
	# Flip the sprite horizontally when facing the left 
	if facingDir.x != 0:
		$AnimatedSprite2D.flip_h = facingDir.x > 0
		#insert something like $Sprite2D.flip_h = facingDir < 0 
	
	if velocity.length() > 10.0:
		$AnimatedSprite2D.play("walk")
		#insert something like $AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
		#insert something like $AnimatedSprite2D.play("idle")

	## Mouse inputs: "pressed" NOT "just_pressed" so player can hold shoot / dash
	if (Input.is_action_pressed("LMB") && $ShotTimer.is_stopped()):
		$ShotTimer.start(max((0.30 / atkSpeed), 0.05)) # Max AtkSpeed is 0.05s per shot (AtkSpeed == 6.00), any higher does nothing
		ShootProj(1, get_global_mouse_position())
	if (Input.is_action_pressed("RMB") && dashNum >= 1.00 && %DashTimer.is_stopped() && InputV && charge == 0):
		%DashTimer.start(dashLen / dashSpd)
		#print(%DashTimer.time_left)
		setDashing(true) # Disables WASD movement
		$Projectile_Hitbox.set_collision_layer_value(7, false) # Disable projectile hitbox
		dashNum -= 1.00
		velocity += InputV * dashSpd
	## Spacebar: Charged shots by holding then releasing space with mana
	# charge linearly by holding space (up to 125%)
	# if charge over 100: can discharge but hurts self, aim for 100 exactly or go over to do more but hurts more.
	# if under 25 charge: fizzle out. If under 10 (quick tap on accident), do nothing.
	# TODO: Play a chargegup sound that gets higher pitched sound that plateaus around 85-100,
	# ^ then jumps up after 100 until 125, on release, play a shoot sound, at 125, play a boom sound.
	if Input.is_action_pressed("space"): # Holding space to charge up 
		charge += 1 # "charge" up spellcast attack by holding space
		%Charge_Label.value = charge
		if charge >= 10: 
			%Charge_Label.visible = true # Only show charge for holding space, not just a tap
			%DashBar.visible = false # Make it invisible when you are charging up
		if charge >= 125: # If charge a spell to 125%, the spell explodes on player dealing damage and costing mana
			incMP(-charge)
			charge = 0 # Reset charge
			if(Level < 20): #since they're less than level 20 (5 levels before max), they get hurt
				Damage(HPmax >> 2) # Deal 1/4 HP damage
				incMP(-HPmax >> 1) # cost extra MP @ 2:1 HP
				$Status.addStatusText("Boom! (" + str(HPmax >> 2) + ")", "RED")
				$Status.addStatusText("Manaburn (" + str(HPmax >> 1) + ")", "RED")
			else: #TODO: implement opus somehow
				$Status.addStatusText("Casting OPUS!")
				ShootProj(3, get_global_mouse_position())
	if Input.is_action_just_released("space"): # Release space to cast spell based on charge
		%Charge_Label.visible = false
		%DashBar.visible = true # Update the visibility for both bars since charging ended
		if   charge < 10 : incMP(charge) # dont spend mana if it was just a tap
		elif charge < 25 || charge > MP: $Status.addStatusText("Fizzle! (" + str(charge) + ")", "GRAY") # spend mana, but dont cast a spell if weak charge / OOM
		elif charge < 100 : ShootProj(2, get_global_mouse_position()); $Status.addStatusText("Spellcast (" + str(charge) + ")", "BLUE")
		elif charge < 125 :
			ShootProj(2, get_global_mouse_position())
			Damage((int)( (HPmax >> 3) * ((charge - 100) / 25.00) )) # cost up to 1/8 HP if over 100 charge
			$Status.addStatusText("Spellcast (" + str(charge) + ")", "BLUE")
			$Status.addStatusText("Manaburn (" + str((int)((HPmax >> 3) * ((charge - 100) / 25.00))) + ")", "RED")
		incMP(-charge)
		charge = 0
	
	## Interaction: Interactables handle their signal connections automatically. 'Interact' can be emitted blindly
	if Input.is_action_just_pressed("Interact"): Interact.emit(self)
	
	## Utility button keys
	if Input.is_action_just_pressed("HPot"): HPot() # HPot with 'H'
	if Input.is_action_just_pressed("MPot"): MPot() # MPot with 'G'
	if Input.is_action_just_pressed("Nexus"): Nexus() # Nex with 'N'
	if Input.is_action_just_pressed("Loot"): Inv.Loot() # Loot with 'Q'
	
	## UI Toggles 
	if Input.is_action_just_pressed("Loading Screen Toggle"):
		%LoadingScreen.visible = !(%LoadingScreen.visible)
		#get_tree().set_pause( !(get_tree().is_paused()) ) # Toggle pause
	if Input.is_action_just_pressed("Esc"): %EscMenu.visible = !(%EscMenu.visible) # Esc manu goes above loading screen, both disable all lower controls and UI interactions.
	if Input.is_action_just_pressed("F1"): # Controls toggle 'F1'
		%ControlsText.visible = !(%ControlsText.visible)
		%HiddenControlsText.visible = !(%HiddenControlsText.visible)
	if Input.is_action_just_pressed("WaygateGUI"): toggleWaygateGUI() # WaygateGUI toggle 'F2'
	if Input.is_action_just_pressed("RMenu Toggle"): 
		%RMenu.visible = !(%RMenu.visible) # RMenu toggle 'F12'
		%PlayerCam.setOffset(%RMenu.visible)
	if Input.is_action_just_pressed("SkillsUI"): %SkillsUI.visible = !(%SkillsUI.visible) # SkillsUI 'P'

func _physics_process(_delta):
	## Movement
	ReadTerrain()
	get_input()
	if not immovable: move_and_slide()
	
	## MP
	if(tilePain): Damage(tilePain)
	
	if MP < MPmax: incMP(2 if $HurtTimer.is_stopped() else 1) # recharge mana up to 100% (faster if passive)
	if MP > MPmax  : MP -= (int)( ((MP - MPmax) >> 6) + 1 ) # remove 1/64 proportion + 1 constantly from overflowed MP
	if MP < 0 - 2 * MPmax: MP = 0 - 2 * MPmax # Clamp minimum MP to -2*max (yes negative is allowed)
	
	## HP
	if $HurtTimer.is_stopped() && HP < (HPmax >> 1) : incHP(1) # recharge health up to 50%
	if HP > HPmax : HP -= (int)( ((HP - HPmax) >> 7) + 1 ) # remove 1/128 proportion + 1 constantly from overflowed HP
	
	## Misc
	if dashNum < dashMax: dashNum += dashRec # Recover dash
	
	UpdateUIBars()

## Stats calculations
func WepPower() -> int:
	var wep = %Inventory.Inv[%Inventory.Slot.MAINHAND]
	# Null case: use STR / 2
	if wep == null: return int((coreStats[Stats.STR] + effectStats[Stats.STR] + gearStats[Stats.STR]) * 0.5)
	
	return 0

## Consumables
# TODO: UI flash red the MPot button (& healthpot aswell)
func HPot(): # Health Potion: Called when press 'H' to restore HP
	if !HPotC: $Status.addStatusText("Out of Health pots!", "GOLD") # First, if you are out of pots, fail and show UI
	else: # Use a HPot
		incHPot(-1)
		incHP((int)(60 * potionFactor))
		$Status.addStatusText("Used health potion", "RED") # Show status text
func MPot(): # Mana Potion: Called when press 'G' to restore MP
	if !MPotC: $Status.addStatusText("Out of Mana pots!", "GOLD") # First, if you are out of pots, fail and show UI
	else: # Use a MPot
		incMPot(-1)
		incMP((int)(100 * potionFactor))
		$Status.addStatusText("Used mana potion", "BLUE") # Show status text
func incHPot(i:int):
	HPotC += i 
	$CanvasLayer/RMenu/Utility/HPot_Button.text = str(HPotC) + "/" + str(HPotmax)
func incMPot(i:int):
	MPotC += i 
	$CanvasLayer/RMenu/Utility/MPot_Button.text = str(MPotC) + "/" + str(MPotmax)

func Nexus(): ## Nexus: On press, makes you invincible for a moment then transports you to the nexus
	print("Nexus!")
	var nexusWaygate = get_node_or_null("/root/GameManager/Nexus/Waygates/NexusWaygate")
	if nexusWaygate: nexusWaygate.UseWaygate(self)
	#Added hp increment can be removed if behavior is unintended
	#incHP(HPmax)
	


## XP / Leveling: Called by signals from enemy deaths, quest rewards, and other things
func GainXP(xp : int = 0):
	# Statistics
	
	# XP & leveling
	XP += xp
	$Status.addStatusText( ("XP: " + str(xp)), "GREEN")
	if(Level < 25): $CanvasLayer/RMenu/XP_Bar.value = XP 
	else: $CanvasLayer/RMenu/Fame_Bar.value = XP
	while (XP >= XPmax): LevelUp() # "While" instead of "if" for rare cases where you level up more than once in a tick
func LevelUp(): 
	if (Level < 25): # If not maxed yet
		Level += 1; $Status.addStatusText( ("Level " + str(Level) + "!"), "ORANGE")
		XP -= XPmax; XPmax = (int)(XPmax * XPScaleFactor) # WARNING: Narrowing conversion ( int *= float ) (3 instances of this in this func)
		$CanvasLayer/RMenu/XP_Bar.max_value = XPmax
		$CanvasLayer/RMenu/XP_Bar.value = XP
		
		MPmax += 10
		$CanvasLayer/RMenu/MP_Bar.max_value = MPmax
		$CanvasLayer/RMenu/HP_Bar.max_value = HPmax
		skillPoints += 1
		$CanvasLayer/SkillsUI/SkillPointsText/SkillPointsCount.text = str(skillPoints)
		
		## Switch(level): unlock things at certain levels
		if (Level == 10): return # TODO: At L10, unlock class specs
		if (Level == 20): return # TODO: At L20, unlock opus (3rd ability)
		if (Level == 25): # At L25 (max level), adjust scale and switch to fame mechanics
			XPmax = (int)(XPmax * 0.60)
			$CanvasLayer/RMenu/Fame_Bar.max_value = XPmax
			$CanvasLayer/RMenu/Fame_Bar.value = XP
			$CanvasLayer/RMenu/XP_Bar.visible = false
			$CanvasLayer/RMenu/Fame_Bar.visible = true
	else: # Fame levelups
		Fame += 1; $Status.addStatusText( ("Fame " + str(Fame) + "!"), "ORANGE")
		XP -= XPmax; XPmax = (int)(XPmax * XPScaleFactor)
		$CanvasLayer/RMenu/Fame_Bar.value = XP
		$CanvasLayer/RMenu/Fame_Bar.max_value = XPmax
		
	HPmax += 20
	MPmax += 10
	incHP(HPmax)
	incMP(MPmax)

#TODO: update this function to take in an item rather than bool, type, sourcestats since item has all of that garbagio
func UpdateStats(increase: bool, stats: Dictionary) -> void:
	if increase: #if its a stat increase, increase the stat
		applyStats(gearStats, stats)
	else:
		applyStats(gearStats, stats, -1)

	#print("GEAR STATS:", gearStats)
	#print("FINAL SPD:", getStats(Stats.SPD))
	
## Transitional stuff: Used when the player is teleporting, loading into the world, or otherwise changing in a way that they must wait for
func toggleBubble(state:bool) -> void: # Makes player invulnerable, disables input, and puts a bubble around player
	velocity = Vector2.ZERO
	setInput(!state)
	setInvulnerable(state)
	
	#TODO: replace with "await <bubble animation forward/reverse>"
	if (state):
		modulate = Color(0,0,1)
		await get_tree().create_timer(1.00).timeout
	else:
		await get_tree().create_timer(1.00).timeout
		modulate = Color(1,1,1)
func LoadingScreenStart() -> void: # Display the loading screen, this function is awaited by the caller
	await toggleBubble(true)
	%LoadingScreen.Enable()
func LoadingScreenEnd() -> void: # Fade out the loading screen, this function is NOT awaited by the caller
	await %LoadingScreen.FadeOut().timeout
	await toggleBubble(false)

## UI toggle (called from outside so has to be it's own func)
func toggleWaygateGUI(): 
	%WaygateGUI.visible = !(%WaygateGUI.visible)
	if %WaygateGUI.visible: %WaygateGUI.UpdateWaygateList() # Refreshes the list of usable waygates
func UpdateUIBars(): # All at once rather than spread out
	%RMenu/HP_Bar.value = HP
	%RMenu/MP_Bar.value = MP
	%RMenu/XP_Bar.value = XP
	%RMenu/Fame_Bar.value = Fame
	$DashBar.value = dashNum
	%RMenu/HP_Bar.max_value = HPmax
	%RMenu/MP_Bar.max_value = MPmax
	
	$CanvasLayer/RMenu/Utility/HPot_Button.text = str(HPotC) + "/" + str(HPotmax)
	$CanvasLayer/SkillsUI/SkillPointsText/SkillPointsCount.text = str(skillPoints)
	$CanvasLayer/RMenu/Utility/MPot_Button.text = str(MPotC) + "/" + str(MPotmax)
	%RMenu/HP_Bar/HP_Text.text = "%s / %s" % [HP, HPmax]
	%RMenu/MP_Bar/MP_Text.text = "%s / %s" % [MP, MPmax]
	%RMenu/XP_Bar/XP_Text.text = "%s / %s" % [XP, XPmax]
	%RMenu/Fame_Bar/Fame_Text.text = "%s" % [Fame]

## Items
# TODO wip move

## OVERRIDE FUNCS: Entity Overridden funcs by Player.gd
func Death(): 
	# BUG: When ded, can togle loading screen and will unded due to natural regen, # probably gonna be removed later when other death stuff is added, so leaving for now (as of v0.7)
	# TODO: keep a list / vector of the last N things that hurt you within 10s,then display them like in WoW
	# death.emit(self); # print("[SIGNAL T] Death")
	
	%DeathScreen.visible = true # print("Death Screen Toggled")
	
	InputStatus = false
	self.velocity = Vector2.ZERO
	
	#incHP(HPmax) ## Debug: just reset HP when ded
	
	get_tree().set_pause( true ) # Toggle pause

func Damage(power : int):
	super.Damage(power)
	$HurtTimer.start(5.00)


# Singal function called when button is pressed, signals game maneger to handle hard reset
func _OnDeathScreenButtonPushed() -> void:
	%DeathScreen.visible = false
	get_node("/root/GameManager").DeathHandling()
	

# signal function called when debug is pressed, revives player on the spot
func _OnDebugRevive() -> void:
	%DeathScreen.visible = !(%DeathScreen.visible)
	get_tree().set_pause(false)
	self.InputStatus = true
	HP = HPmax
