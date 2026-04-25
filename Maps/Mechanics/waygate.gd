class_name Waygate extends GPUParticles2D ## Waygate: Node for teleporting players
# Emits particles and changes sprite momentarily when triggered

@onready var currWorld : WorldBASE = Tools.FindParentByType(self, WorldBASE)
@export var active : bool = false # Players can only spawn here if active
@export var oneWayTarget : Waygate = null # Instantly tp to oneWayTarget, no GUI (ex. dung exit)

var currPlayer : Player = null # Set when player interacts with this
# TODO: This is used often for interactables, perhaps move it to there idk

# Activation cost
# NOTE: Consumed upon activation, if free, can just press 'E' to activate
# NOTE: oneway and dungeon-related waygates shouldnt have these, only the open-world ones.
@export var coinPrice : int = 0
@export var itemPrice : PackedScene = null # put any Item.tscn in editor
var itemPriceItem : Item = null # Actual item from ^

func _ready():
	$InteractComponent.Interact.connect(WaygateInteract)
	$EffectTimer.timeout.connect(EffectTrigger.bind(false)) # Timer controls particle burst
	
	if itemPrice: itemPriceItem = itemPrice.instantiate()

func WaygateInteract(P:Player):
	if P == null: # Player left range
		if currPlayer: currPlayer.toggleWaygateGUI(false)
		currPlayer = null
		return
	
	currPlayer = P # Player interacted with waygate
	
	if !active: # Inactive, try to purchase
		if itemPrice and P.Inv.HasItemName(itemPriceItem.itemName) == -1: # itemName since ID is 0
			P.StatusLabel.addStatusText("Missing Item: " + str(itemPriceItem.name), "RED")
		elif P.coins < coinPrice:
			P.StatusLabel.addStatusText("Need " + str(coinPrice) + " Coins", "RED")
		else: # Player can afford it
			P.incCoins(coinPrice * -1)
			#print(P.Inv.HasItemName(itemPriceItem.itemName))
			if itemPrice:
				var slotN = P.Inv.HasItemName(itemPriceItem.itemName) # Find the item slot
				P.Inv.PutItemInSlot(slotN, null) # Delete the item from Player Inv
			setActive(true)
	
	else: # Already active
		if oneWayTarget: oneWayTarget.UseWaygate(P) # One-way gates activate immediately
		else: P.toggleWaygateGUI(true) # Regular waygates open the GUI to select a destination

func UseWaygate(P:Player): # Teleports player to this waygate
	P.ECS.ClearEffects()
	P.Heal(P.HPmax - P.HP)
	await P.LoadingScreenStart() # Show loading screen before moving player & camera
	# TODO: When going from nex to world, play a short transition screen showing the world name and some info, player in center (with party to side)
		# and some quest details, and any other stuff like stats idk
	
	P.global_position = global_position # Move player 
	P.find_child("PlayerCam").InstantMove(global_position) # Force move camera without smoothing
	P.currWorld = currWorld # Set the player's currWorld to this one (otherwise reading tilemap breaks)
	
	P.LoadingScreenEnd()
	
	EffectTrigger()

# BUG: The nexus waygate gets set twice when the game is started, something in gameManager
func setActive(state:bool):
	EffectTrigger(state)
	$Sprite2D_ON.visible = state;
	$Sprite2D_OFF.visible = !state;
	active = state

func EffectTrigger(state:bool=true): # Emits blue particles and changes sprite for a moment
	#print("EffectTrigger called, state: " + str(state) + "WG= " + str(self))
	emitting = state; 
	if(state): $EffectTimer.start(1.5) # Ttops emitting (calls this with state = false)
