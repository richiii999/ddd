extends Panel ## WaygateGUI: Menu for players to teleport to active waygates
# NOTE: WaygateGUI Buttons signal to this

@onready var player = find_parent("Player") # ref to parent player

func _ready():
	# Connect the first WGButton to the Nexus
	$WGButton.button_down.connect(useWaygateGUI.bind(get_node("/root/GameManager/Maps/Nexus/Waygates/NexusWaygate")))

## TP to a waygate when player clicks one of the Waygate buttons
func useWaygateGUI(waygate : Waygate):
	waygate.UseWaygate(player)
	player.toggleWaygateGUI(false) # Close GUI after teleporting

## Get a list of Active, 2-way gates, except the one in the nexus.
# NOTE: Called on Player.ToggleWaygateGUI()
# Active: The player has activated the waygate (or active by default)
# 2-way: Non-exit waygates (since you shouldnt be able to TP directly to the end of the dung)
# Not nexus: The nexus waygate is special
func UpdateWaygateList():
	for child in $GridContainer.get_children(): child.queue_free() # Clear old buttons
	
	## Add all active waygates in the world to the GUI
	var numNewButtons : int = 0
	for WG in get_node("/root/GameManager").GetActiveWaygates():
		numNewButtons += 1
		var button = $WGButton.duplicate() # Instantiate and setup a button scene
		button.name = ("WaygateButton_" + str(WG)) 
		button.icon = WG.get_node("Sprite2D_ON").texture # TODO: custom icons per zone
		button.get_child(0).text = WG.name
		button.button_down.connect(useWaygateGUI.bind(WG)) # Connect new button to this script
		$GridContainer.add_child(button)
	
	# GUI vertical spacing between button rows
	$GridContainer.add_theme_constant_override("v_separation", 10 if numNewButtons > 6 else 40)
