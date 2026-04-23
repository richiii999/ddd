class_name Interactable extends Area2D ## Makes parent interactable, connect 'Interact' signal to a parent function or whatever
# NOTE: You MUST add a CollisionShape2D as the first child to this obj otherwise it doesnt work

@export var interactable : bool = true

signal Interact # Emitted with Player (pressing 'E') or null (player leaves range
func Interaction(P:Player = null): Interact.emit(P)

func _ready():
	body_entered.connect(EnterOrExit.bind(true))
	body_exited.connect(EnterOrExit.bind(false))
	setInteractable(interactable)

func EnterOrExit(body : Node2D, enterOrExit): # Area2D Enter/Exit: Connect / disconnect signals for Players in range
	print("EnterOrExit: " + str(get_parent().name) + " | body: " + str(body.name) + " | enter: " + str(enterOrExit))
	get_parent().self_modulate = Color("BLUE") if enterOrExit else Color("WHITE") # Changes color when in Interact range #TODO make it a highlight outline
	if get_parent() is Waygate:
		#the sprites HAVE to be the first 2 children, otherwise it breaks, but does the same as the interact for NPC
		get_parent().get_child(0).self_modulate = Color("BLUE") if enterOrExit else Color("WHITE")
		get_parent().get_child(1).self_modulate = Color("BLUE") if enterOrExit else Color("WHITE")
	
	# Enter / Exit range
	if enterOrExit: 
		body.Interact.connect(Interaction)
	else: 
		Interact.emit(null) # So interactables can do cleanup (ex. close GUIs)
		body.Interact.disconnect(Interaction)

func setInteractable(state:bool):
	if get_child_count(): get_child(0).set_deferred("disabled", not state) # Docs say to use defer
	RemoveAllConnections() # Remove any leftover connections

func RemoveAllConnections() -> void: # Removes all signal connections
	for conn in Interact.get_connections():
		disconnect(conn["signal"].get_name(), conn["callable"])
