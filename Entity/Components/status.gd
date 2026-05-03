class_name Status extends RichTextLabel ## Controls status texts and flashing colors for entities

# Stores the status texts to be displayed in order
@export var textQueue : Array[String] = [] 

var sprite : Node = null # Sprite node (unknown type, set during ready)
var originalColor : Color # Original modulate of the sprite

func _ready():
	# Try to find a sprite or animSprite sibling
	sprite = get_parent().find_child("Sprite2D", false)
	if sprite == null:
		sprite = get_parent().find_child("AnimatedSprite2D", false)
	
	# Delete self if no sprite found
	if sprite == null: 
		push_warning("Status cannot find sprite!")
		get_parent().StatusLabel = null
		queue_free()
	
	originalColor = sprite.self_modulate
	
	$StatusTextTimer.timeout.connect(statusTextTimer.bind(true))
	$StatusFlashTimer.timeout.connect(setStatusFlash)

## Adds text to the queue. Called for many things like getting hurt, gaining XP, or casting spells.
func addStatusText(s : String = "", c : String = "GOLD"): 
	textQueue.append("[color=" + c + "]" + s + '\n')
	displayText()
	statusTextTimer()

## Erases one line from the text queue and restarts the timer based on queue length (min 0.15s)
func statusTextTimer(timeout : bool = false): 
	if timeout: textQueue.pop_front()
	if textQueue.size(): $StatusTextTimer.start(max(0.15, 1.00 / textQueue.size()))
	displayText()

## Displays the text with the right sizing for linecount, since the text is vertically top justified
func displayText(): 
	text = "" # Reset the textbox size
	
	for i in textQueue.size(): # Add text one at a time and resize accordingly
		text += textQueue[i]
		if i == 5: break # Only 5 are shown at once

## Change the color of the parent Entity for a moment
# Ex. damage flash (RED) and bubble (BLUE)
func setStatusFlash(c : Color = originalColor, t : float = 0.00): 
	if(t): $StatusFlashTimer.start(t)
	sprite.self_modulate = c
