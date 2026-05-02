class_name Interactable extends Area2D ## Makes parent interactable, connect 'Interact' signal to a parent function or whatever
# NOTE: You MUST add a CollisionShape2D as the first child to this obj otherwise it doesnt work

@export var interactable : bool = true

signal Interact # Emitted with Player (player interacted) or null (player leaves range)
func Interaction(P:Player = null): Interact.emit(P)

func _ready():
	body_entered.connect(EnterOrExit.bind(true))
	body_exited.connect(EnterOrExit.bind(false))
	setInteractable(interactable)

## Area2D Enter/Exit: Connect / disconnect signals for Players in range
# Interactable changes color when in range
func EnterOrExit(body : Node2D, enterOrExit):
	if get_parent() is Waygate:
		# NOTE: Sprites MUST to be the first 2 children, otherwise it breaks
		get_parent().get_child(0).self_modulate = Color("BLUE") if enterOrExit else Color("WHITE")
		get_parent().get_child(1).self_modulate = Color("BLUE") if enterOrExit else Color("WHITE")
	else: get_parent().self_modulate = Color("BLUE") if enterOrExit else Color("WHITE") 
	
	# Enter / Exit range
	if enterOrExit: 
		body.Interact.connect(Interaction)
	else: 
		Interact.emit(null) # So interactables can do cleanup (ex. close GUIs)
		body.Interact.disconnect(Interaction)

## Setter, also removes leftover connections
func setInteractable(state:bool):
	if get_child_count(): get_child(0).set_deferred("disabled", not state) # Docs say to use defer
	RemoveAllConnections() # Remove any leftover connections

## Removes all signal connections
func RemoveAllConnections() -> void: 
	for conn in Interact.get_connections():
		disconnect(conn["signal"].get_name(), conn["callable"])
