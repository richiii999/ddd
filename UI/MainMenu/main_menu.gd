class_name MainMenu extends Control
signal quitPressed
signal playPressed
signal escHandling

var escapeMenu : EscapeMenu
var childrenSearch
var worldSlot

# TODO: add a better way to access the escape menu signal when 
func _ready() -> void:
	pass

func ActivateMainMenu():
	escHandling.emit()

# Signal when play button is pressed
func _OnPlayPressed() -> void:
	self.hide()
	playPressed.emit()

func _OnQuitPressed() -> void:
	quitPressed.emit()
