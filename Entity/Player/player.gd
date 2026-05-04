class_name Player extends ENTITY ## PLAYER: Gamedevs be like: Player.script = 10,000LoC, any other script = 5 LoC
# controls the player and UI via keypresses. Stores stats, actions, storage, and lots of stuff...

## Refs to child nodes
@onready var Inv = $CanvasLayer/RMenu/Inventory # Other stuff needs to access player inv (ex. shops)
# NOTE: Inv requires there to be a ItemPickupRange (type SmartArea)
@onready var death_sound: AudioStreamPlayer = $"Death Sound"
@onready var hurt_sound: AudioStreamPlayer = $Hurt
@onready var shoot: AudioStreamPlayer = $shoot

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
var HPotC   : int = 0 # Current Potion count
var MPotC   : int = 0

## Pet
@export var pet: PackedScene
var pet_instance = null

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
var dashNum : float = dashMax # Current dashes stored (use 1.00 per dash)
var dashRec : float = 0.005 # Dash recovered per frame (def: 0.005)
var dashLen : float = 0.2  # (s) Length of dash
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

# Get overall stat value for a given stat
func getStats(stat:int) -> int: 
	return coreStats.get(stat, 0) + gearStats.get(stat, 0) + effectStats.get(stat, 0)

func getEquippedAttack(index : int) -> AttackData:
	#check to make sure the inventory node is not null
	if Inv == null:
		return null
		
	var main = Inv.ItemInSlot(Inv.Slot.MAINHAND)
	var off = Inv.ItemInSlot(Inv.Slot.OFFHAND)
	
	#check if the projectiles exist and left click is pressed, then return
	if index == 0 and main:
		return main.attack
	
	if index == 1 and off:
		return off.attack
	return null

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

func _ready():
	super._ready() # call ENTITY._ready() (sets HP and MP)
	super.EntityUI()
	UpdateProjStats()
	maxManaCalc()
	maxHealthCalc()
	StatusLabel.addStatusText("Spawned in!", "BLUE")
	#print(get_tree_string_pretty()) #Debug print the nodetree
	#test_apply_stats()
	%DeathScreen.find_child("Restart").pressed.connect(_OnDeathScreenButtonPushed)
	%DeathScreen.find_child("DebugRestart").pressed.connect(_OnDebugRevive)
	## Initialize the UI info
	%RMenu/Utility/Nex_Button.pressed.connect(Nexus)
	%RMenu/Utility/HPot_Button.pressed.connect(HPot)
	%RMenu/Utility/MPot_Button.pressed.connect(MPot)
	
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
	
	# NOTE: EscMenu has to go before the inputStatus check otherwise u get stuck in the menu
	if Input.is_action_just_pressed("Esc"): 
		%EscMenu.visible = !(%EscMenu.visible) 
		InputStatus = !(%EscMenu.visible)
	
	if !InputStatus: return # Disallow input if it's disabled
	
	## Movement keys:
	InputV = Input.get_vector("left", "right", "up", "down")
	if !dashing: 
		#get the speed and then cap it as you keep leveling up
		var spd_mult := get_move_spd()
		velocity += InputV * (accel * effectMoveSpeed * tileSpeed * spd_mult) + tilePush
	
	## Change sprite frame and flip direction based on direction / velocity for player
	# The "velocity.length() > 10.0" tells us "are we moving fast enough to count as moving?", and the else gives us a vector pointing from the player toward the mouse 
	var facingDir : Vector2 = velocity if velocity.length() > 10.0 else (get_global_mouse_position() - global_position)
	# Flip the sprite horizontally when facing the left 
	if facingDir.x != 0: $AnimatedSprite2D.flip_h = facingDir.x > 0
	
	if velocity.length() > 10.0: $AnimatedSprite2D.play("walk")
	else: $AnimatedSprite2D.play("idle")

	## Mouse inputs: "pressed" NOT "just_pressed" so player can hold shoot / dash
	# Left Click: Shoot1
	if (Input.is_action_pressed("LMB") && $ShotTimer.is_stopped()):
		shoot.play()
		$ShotTimer.start(max((0.30 / atkSpeed), 0.05)) # Max AtkSpeed is 0.05s per shot (AtkSpeed == 6.00), any higher does nothing
		ShootProj(1, get_global_mouse_position())
	
	# Right Click: Dash
	if (Input.is_action_pressed("RMB") && dashNum >= 1.00 && %DashTimer.is_stopped() && InputV && charge == 0):
		setDashing(true) # Disables WASD movement
		$Projectile_Hitbox.set_collision_layer_value(7, false) # Disable projectile hitbox
		# Min dash of 0.1s, max of 0.5s, so very high speed values dont have long dashes
		%DashTimer.start(clampf(dashLen + getStats(Stats.SPD) * 0.02, 0.1, 0.5))
		#print(%DashTimer.time_left)
		
		dashNum -= 1.00
		velocity += InputV * dashSpd
		
		ResetTile() # No tile effects while dashing
	
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
			else:
				$Status.addStatusText("OPUS!")
				ShootProj(3, get_global_mouse_position())
	if Input.is_action_just_released("space"): # Release space to cast spell based on charge
		%Charge_Label.visible = false
		%DashBar.visible = true # Update the visibility for both bars since charging ended
		if   charge < 10 : incMP(charge) # dont spend mana if it was just a tap
		elif charge < 25 || charge > MP: $Status.addStatusText("Fizzle! (" + str(charge) + ")", "GRAY") # spend mana, but dont cast a spell if weak charge / OOM
		elif charge < 100:
			var old_main = mainStat
			mainStat = mainStat + getStats(Stats.INT) * 2
			ShootProj(2, get_global_mouse_position())
			mainStat = old_main
			$Status.addStatusText("Spellcast (" + str(charge) + ")", "BLUE")
		elif charge < 125 :
			var old_main = mainStat
			mainStat = mainStat + getStats(Stats.INT) * 2
			ShootProj(2, get_global_mouse_position())
			mainStat = old_main
			Damage((int)( (HPmax >> 3) * ((charge - 100) / 25.00) ))
			$Status.addStatusText("Spellcast (" + str(charge) + ")", "BLUE")
			$Status.addStatusText("Manaburn (" + str((int)((HPmax >> 3) * ((charge - 100) / 25.00))) + ")", "RED")
		incMP(-charge)
		charge = 0
	
	## Interaction: Interactables handle their signal connections automatically. 'Interact' can be emitted blindly
	if Input.is_action_just_pressed("Interact"): Interact.emit(self)
	
	## Utility button keys
	if Input.is_action_just_pressed("HPot"): HPot() # HPot with 'H'
	if Input.is_action_just_pressed("MPot"): MPot() # MPot with 'G'
	if Input.is_action_just_pressed("Nexus"): Nexus() # TP back to Nexus with 'N'
	if Input.is_action_just_pressed("Loot"): Inv.Loot() # Loot with 'Q'
	if Input.is_action_just_pressed("PetTrick"): PetTrick() # Pet do trick with 'X'
	if Input.is_action_just_pressed("delete-pet"): DeletePet() # Delete pet with 'Z'
	
	## UI Toggles 
	if Input.is_action_just_pressed("Loading Screen Toggle"):
		%LoadingScreen.visible = !(%LoadingScreen.visible)
	if Input.is_action_just_pressed("F1"): # Controls toggle 'F1'
		%ControlsText.visible = !(%ControlsText.visible)
		%HiddenControlsText.visible = !(%HiddenControlsText.visible)
	if Input.is_action_just_pressed("WaygateGUI"): toggleWaygateGUI(!%WaygateGUI.visible) # WaygateGUI toggle 'F2'
	if Input.is_action_just_pressed("RMenu Toggle"): 
		%RMenu.visible = !(%RMenu.visible) # RMenu toggle 'F12'
		%PlayerCam.setOffset(%RMenu.visible)
	if Input.is_action_just_pressed("SkillsUI"): %SkillsUI.visible = !(%SkillsUI.visible) # SkillsUI 'P'
	if Input.is_action_just_pressed("CharMenu"): toggleCharMenu(!%CharMenu.visible) # CharMenu 'C'
		

func _physics_process(_delta):
	## Movement
	if not dashing: ReadTerrain()
	#print(currTile)
	get_input()
	
	if not dashing: EntityMovement()
	else: move_and_slide()
	
	## MP
	if(tilePain): Damage(tilePain)

	var mp_regen = 1 + getStats(Stats.WIS) / 5
	if MP < MPmax: incMP(mp_regen * (2 if $HurtTimer.is_stopped() else 1))
	if MP > MPmax  : MP -= (int)( ((MP - MPmax) >> 6) + 1 )
	if MP < 0 - 2 * MPmax: MP = 0 - 2 * MPmax

	## HP
	var hp_regen = 1 + getStats(Stats.TOU) / 5
	if $HurtTimer.is_stopped() && HP < (HPmax >> 1): incHP(hp_regen)
	if HP > HPmax : HP -= (int)( ((HP - HPmax) >> 7) + 1 )
	
	## Misc
	if dashNum < dashMax: dashNum += dashRec # Recover dash
	
	UpdateUIBars()
	
	#using this to debug shit
	if Input.is_action_just_pressed("Debug_Print"):
		print("tilePain: ", tilePain)
		print("HurtTimer stopped: ", $HurtTimer.is_stopped())
		print("HurtTimer time left: ", $HurtTimer.time_left)
		print("HP: ", HP, " / ", HPmax)
		print("HPmax >> 1: ", HPmax >> 1)
		
func maxManaCalc():
	MPmax = 100 + (Level * 10) + (getStats(Stats.WIL) * 15)
	%RMenu/MP_Bar.max_value = MPmax

func maxHealthCalc():
	HPmax = 100 + (Level * 20) + (getStats(Stats.TOU) * 15)
	%RMenu/HP_Bar.max_value = HPmax

## Stats calculations
func WepPower() -> int:
	var wep = Inv.ItemInSlot(Inv.Slot.MAINHAND)
	if wep == null: return int(getStats(Stats.STR) * 0.5)
	return wep.attack.power + getStats(Stats.STR)

## Consumables
func HPot(): # Health Potion: Called when press 'H' to restore HP
	if !HPotC: $Status.addStatusText("Out of Health pots!", "GOLD") # First, if you are out of pots, fail and show UI
	else: # Use a HPot
		incHPot(-1)
		incHP(int(HPmax * (0.3 + getStats(Stats.WIS) * 0.01)))
		$Status.addStatusText("Used health potion", "RED") # Show status text
func MPot(): # Mana Potion: Called when press 'G' to restore MP
	if !MPotC: $Status.addStatusText("Out of Mana pots!", "GOLD") # First, if you are out of pots, fail and show UI
	else: # Use a MPot
		incMPot(-1)
		incMP(int(MPmax * (0.6 + getStats(Stats.WIS) * 0.01)))
		$Status.addStatusText("Used mana potion", "BLUE") # Show status text
func incHPot(i:int):
	HPotC += i 
	
	%RMenu/Utility/HPot_Button/HPotValue.text = str(HPotC) + "/" + str(HPotmax)
	if HPotC == 0: # Empty sprite
		%RMenu/Utility/HPot_Button/HPotIconFull.visible = false
		%RMenu/Utility/HPot_Button/HPotIconEmpty.visible = true
	elif HPotC == i: # No longer empty
		%RMenu/Utility/HPot_Button/HPotIconFull.visible = true
		%RMenu/Utility/HPot_Button/HPotIconEmpty.visible = false
func incMPot(i:int):
	MPotC += i 
	
	%RMenu/Utility/MPot_Button/MPotValue.text = str(MPotC) + "/" + str(MPotmax)
	if MPotC == 0: # Empty sprite
		%RMenu/Utility/MPot_Button/MPotIconFull.visible = false
		%RMenu/Utility/MPot_Button/MPotIconEmpty.visible = true
	elif MPotC == i: # No longer empty
		%RMenu/Utility/MPot_Button/MPotIconFull.visible = true
		%RMenu/Utility/MPot_Button/MPotIconEmpty.visible = false

func Nexus():
	get_node("/root/GameManager/Maps/Nexus/Waygates/NexusWaygate").UseWaygate(self)
	$Status.addStatusText("Nexus!", "BLUE")

## XP / Leveling: Called by signals from enemy deaths, quest rewards, and other things
func GainXP(xp : int = 0):
	XP += xp
	$Status.addStatusText( ("XP: " + str(xp)), "GREEN")
	if(Level < 25): $CanvasLayer/RMenu/XP_Bar.value = XP 
	else: $CanvasLayer/RMenu/Fame_Bar.value = XP
	while (XP >= XPmax): LevelUp() # "While" for rare cases where you level up more than once
	
## Spawn the given Pet
func SpawnPet(newPet:PackedScene):
	if pet_instance != null:
		$Status.addStatusText("You have a Pet!", "BLUE")
		$Status.addStatusText("'Z' to abandon Pet!", "BLUE")
		return
	
	pet_instance = newPet.instantiate()
	get_parent().add_child(pet_instance)
	
	pet_instance.global_position = global_position + Vector2(50, 0)
	pet_instance.player = self # Set the player variable for the instantiated newPet
	$Status.addStatusText("You gained a Pet!", "BLUE")
	$Status.addStatusText("'X' to do a trick!", "BLUE")

## Deletes the player's Pet
func DeletePet(): 
	if is_instance_valid(pet_instance):
		pet_instance.queue_free()
		pet_instance = null

## Makes Player's Pet do a trick
func PetTrick(): if pet_instance != null: pet_instance.Trick()

## Changes currWorld and plays BGM
func setCurrWorld(newWorld:WorldBASE):
	if newWorld == null: push_error("Tried to set null world!"); return
	currWorld = newWorld
	
	$BGM.set_stream(newWorld.BGM if newWorld.BGM else null)
	if $BGM.stream: $BGM.play()

func LevelUp(): 
	if (Level < 25): # If not maxed yet
		Level += 1; $Status.addStatusText( ("Level " + str(Level) + "!"), "ORANGE")
		XP -= XPmax; XPmax = (int)(XPmax * XPScaleFactor) # WARNING: Narrowing conversion
		$CanvasLayer/RMenu/XP_Bar.max_value = XPmax
		$CanvasLayer/RMenu/XP_Bar.value = XP
		
		maxManaCalc()
		maxHealthCalc()
		$CanvasLayer/RMenu/MP_Bar.max_value = MPmax
		$CanvasLayer/RMenu/HP_Bar.max_value = HPmax
		skillPoints += 1
		$CanvasLayer/SkillsUI/SkillPointsText/SkillPointsCount.text = str(skillPoints)
		
		## Switch(level): unlock things at certain levels
		if (Level == 25): # Atmax level, adjust scale and switch to fame mechanics
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
		maxManaCalc()
		maxHealthCalc()
	incHP(HPmax)
	incMP(MPmax)

#updates the projectile stats
# TODO: Possibly add modifiers?
func UpdateProjStats(): 
	projSpeed  = 10 + (getStats(Stats.AGI) / 2)
	mainStat   = 10 + (getStats(Stats.STR) / 2) 
	piercing   = 2 + (getStats(Stats.DEX) / 2)
	kBstrength1 = 250.0 + (getStats(Stats.STR) / 2)

#TODO: update this function to take in an item rather than bool, type, sourcestats since item has all of that garbagio
func UpdateStats(increase: bool, stats: Dictionary) -> void:
	if increase: #if its a stat increase, increase the stat
		applyStats(gearStats, stats)
	else:
		applyStats(gearStats, stats, -1)
	
	UpdateProjStats() #recalculate proj stats after any gear change
	maxManaCalc()
	maxHealthCalc()
	
## Transitional stuff: Player is teleporting, loading into the world, or otherwise waiting
func toggleBubble(state:bool) -> void: # Makes player invulnerable, disables input, bubble around player
	velocity = Vector2.ZERO
	setInput(!state)
	setInvulnerable(state)
	set_collision_layer_value(5, !state)
	
	#TODO: replace with "<bubble animation forward/reverse>"
	if (state):
		$Status.setStatusFlash(Color("BLUE"), 1.50)
		#await get_tree().create_timer(1.00).timeout # NOTE: This causes the game's start to lag
	else:
		await get_tree().create_timer(1.00).timeout
func LoadingScreenStart() -> void: # Display the loading screen, this function is awaited by the caller
	await toggleBubble(true)
	%LoadingScreen.Enable()
func LoadingScreenEnd() -> void: # Fade out the loading screen, this function is NOT awaited by the caller
	await %LoadingScreen.FadeOut().timeout
	await toggleBubble(false)

## UI toggle (called from outside so has to be it's own func)
func toggleWaygateGUI(state:bool): 
	%WaygateGUI.visible = !%WaygateGUI.visible if state else false
	if state: %WaygateGUI.UpdateWaygateList() # Refreshes the list of usable waygates
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

func toggleCharMenu(state:bool):
	%CharMenu.visible = state
	%CharMenu.refresh_stats()

## OVERRIDE FUNCS: Entity Overridden funcs by Player.gd
func Death(): 
	%DeathScreen.visible = true
	death_sound.play()
	toggleBubble(true)
	self.velocity = Vector2.ZERO
	
	get_tree().set_pause( true )

func Damage(power : int, crit:bool=false):
	var reduction = getStats(Stats.BLK) * 0.02  # 2% eper point
	power = int(power * (1.0 - reduction))
	hurt_sound.play()
	super.Damage(power, crit)
	$HurtTimer.start(5.00)

# Signal function called when button is pressed, signals game maneger to handle hard reset
func _OnDeathScreenButtonPushed() -> void:
	%DeathScreen.visible = false
	get_node("/root/GameManager").DeathHandling()
	

# Signal function called when debug is pressed, revives player on the spot
func _OnDebugRevive() -> void:
	%DeathScreen.visible = !(%DeathScreen.visible)
	get_tree().set_pause(false)
	self.InputStatus = true
	HP = HPmax
	toggleBubble(false)
