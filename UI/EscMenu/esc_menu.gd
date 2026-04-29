class_name EscapeMenu extends Control ## Esc Menu
# TODO: Actually add buttons and stuff
# TODO: add blur to background or something idk
signal mainMenuButton

# TODO: Replace EscMenu quit with mainmenu
func quitGame_Button():
	print("quit game pressed")
	get_node_or_null("/root/GameManager").Quit()

#main menu button pressed
func mainMenu_Button() -> void:
	mainMenuButton.emit()
