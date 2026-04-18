extends Panel ## WaygateGUI: Menu for players to teleport to active waygates
# Buttons signal to this which then sends the player to the waygate.

@onready var player = find_parent("Player") # ref to parent player

func _ready(): if !($NexButton.button_down.is_connected(useWaygateGUI)): $NexButton.button_down.connect(useWaygateGUI.bind(get_node_or_null("/root/GameManager/Nexus/Waygates/NexusWaygate")))

func useWaygateGUI(waygate : Waygate = null): # Uses a waygate when player clicks one of the GUI waygate buttons
	if !waygate: push_error("called 'useWayGateGUI' with no value for arg 'waygate'")
	else: waygate.UseWaygate(player)
	
	player.toggleWaygateGUI() # Closes GUI

func UpdateWaygateList(): # Called on Player.toggleWaygateGUI()
	for child in $GridContainer.get_children(): child.queue_free() # Clear old buttons
	
	get_node("/root/GameManager").world.updateWorldWaygateList()
	var numNewButtons : int = 0
	for waygate in get_node("/root/GameManager").world.Waygates: # For each waygate in the world...
		var button = $NexButton.duplicate() # Instantiate and setup a button scene
		button.name = ("WaygateButton_" + str(waygate)) 
		button.icon = waygate.get_node("Sprite2D_ON").texture # Temp: eventually change this to custom icons per zone
		button.get_child(0).text = waygate.name
		button.button_down.connect(useWaygateGUI.bind(waygate)) # Connect button to this script
		$GridContainer.add_child(button)
		numNewButtons += 1
	
	if numNewButtons > 6: $GridContainer.add_theme_constant_override("v_separation", 10) # reduce vertical spacing after 6 buttons
	else: $GridContainer.add_theme_constant_override("v_separation", 40)
