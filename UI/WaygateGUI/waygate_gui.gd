extends Panel ## WaygateGUI: Menu for players to teleport to active waygates
# NOTE: WaygateGUI Buttons signal to this

@onready var player = find_parent("Player") # ref to parent player

func _ready():
	# Connect the Nexus button to it's waygate (if not already set)
	if !($NexButton.button_down.is_connected(useWaygateGUI)): 
		$NexButton.button_down.connect(useWaygateGUI.bind(get_node_or_null("/root/GameManager/Nexus/Waygates/NexusWaygate")))

## TP to a waygate when player clicks one of the Waygate buttons
func useWaygateGUI(waygate : Waygate):
	waygate.UseWaygate(player)
	player.toggleWaygateGUI() # Close GUI after teleporting

## Get a list of Active, 2-way gates, except the one in the nexus.
# NOTE: Called on Player.ToggleWaygateGUI()
# Active: The player has activated the waygate (or active by default)
# 2-way: Non-exit waygates (since you shouldnt be able to TP directly to the end of the dung)
# Not nexus: The nexus waygate is special
func UpdateWaygateList():
	for child in $GridContainer.get_children(): child.queue_free() # Clear old buttons
	
	# Search all waygates in the world
	get_node("/root/GameManager").world.updateWorldWaygateList()
	var numNewButtons : int = 0
	for waygate in get_node("/root/GameManager").world.Waygates:
		if not waygate.active: continue
		if waygate.oneWayTarget: continue
		if waygate.currWorld == get_node("/root/GameManager").nexus: continue
		
		numNewButtons += 1
		var button = $NexButton.duplicate() # Instantiate and setup a button scene
		button.name = ("WaygateButton_" + str(waygate)) 
		button.icon = waygate.get_node("Sprite2D_ON").texture # TODO: custom icons per zone
		button.get_child(0).text = waygate.name
		button.button_down.connect(useWaygateGUI.bind(waygate)) # Connect new button to this script
		$GridContainer.add_child(button)
	
	# GUI vertical spacing between button rows
	$GridContainer.add_theme_constant_override("v_separation", 10 if numNewButtons > 6 else 40)
