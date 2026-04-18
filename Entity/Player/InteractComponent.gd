class_name InteractComponent extends Area2D ## Makes parent interactable, connect 'Interact' signal to a parent function or whatever

signal Interact # recieved from player and re-emitted to parent or wherever
func Interaction(P:Player = null): Interact.emit(P)

func EnterOrExit(body : Node2D, enterOrExit): # Area2D Enter/Exit: Connect / disconnect signals for Players in range
	get_parent().modulate = Color("BLUE") if enterOrExit else Color("WHITE") # Changes color when in Interact range #TODO make it a highlight outline
	
	if enterOrExit: body.Interact.connect(Interaction)
	else: body.Interact.disconnect(Interaction)
