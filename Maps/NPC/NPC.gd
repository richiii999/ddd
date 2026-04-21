class_name NPC extends Node
## NPC: Controls interactability of the NPC, stores state info if any
# NOTE: Interaction signal comes with a ref to player, hence the _Player param (trashing since we dont use it)

var interactable:bool = true
func setInteractable(_Player, state:bool):
	interactable = state
	$InteractComponent/CollisionShape2D.set_deferred("disabled", not state) # Docs say to use defer
	$InteractComponent.RemoveAllConnections() # Remove any leftover connections

var repeatable:bool = true # Can the dialogue be repeated?
var currStep = -1 # Which dialogue string currently used?
var dialogue: Array[String] = [
	"TEST1",
	"TEST2",
	"TEST3"
]

func _ready():
	$InteractComponent.Interact.connect(DialogueStep)
	$DialoguePanel/Timer.timeout.connect(DisplayDialogue.bind(false))

# Dialogue text is visible for a few seconds then goes away automatically
func DisplayDialogue(state:bool):
	$DialoguePanel.visible = state
	$DialoguePanel/Timer.start(3.0)

# Step through the dialogue, displaying in a text box above the NPC
func DialogueStep(_Player, step:int = -1):
	currStep = currStep + 1 if (step == -1) else step # Go to next/specific step
	if currStep > len(dialogue) - 1: currStep = 0 # Failsafe: go to 0 if > len
	
	$DialoguePanel/Text.text = dialogue[currStep]
	
	DisplayDialogue(true)
