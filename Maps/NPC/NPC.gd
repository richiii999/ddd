class_name DialogueNPC extends Node
## NPC: Controls interactability of the NPC, stores state info if any
# NOTE: Should always set "Editable Children" on NPCs, to change the name and stuff

@export var repeatable:bool = true # Can the dialogue be repeated?
var currStep = -1 # Which dialogue string currently used?
@export var dialogue: Array[String] = [ # Change in editor for each NPC
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
func DialogueStep(P:Player = null, step:int = -1):
	if P == null: return # Dont dialogue if player leaves
	
	currStep = currStep + 1 if (step == -1) else step # Go to next/specific step
	if currStep > len(dialogue) - 1: 
		push_error("IndexOOB on dialogue")
		return
	
	$DialoguePanel/Text.text = dialogue[currStep]
	DisplayDialogue(true)
	
	if currStep == len(dialogue) - 1: # Reached end of dialogue
		if repeatable: currStep = -1
		else: $InteractComponent.setInteractable(false)
