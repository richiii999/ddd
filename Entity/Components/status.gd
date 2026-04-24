class_name Status extends RichTextLabel ## Controls status texts and flashing colors for entities

@export var textQueue : Array[String] = [] # Stores the status texts to be displayed in order

var currStatusColor : Color = Color("WHITE") # Used as a temp to store the longer status color so that the shorter flash doesnt overwrite it

func addStatusText(s : String = "", c : String = "GOLD"): ## Adds text to the queue. Called for many things like getting hurt, gaining XP, or casting spells.
	textQueue.append("[color=" + c + "]" + s + '\n')
	displayText()
	statusTextTimer()

func statusTextTimer(timeout : bool = false): # Erases one line from the text queue and restarts the timer based on queue length (min 0.15s)
	if timeout: textQueue.pop_front()
	if textQueue.size(): $StatusTextTimer.start(max(0.15, 1.00 / textQueue.size()))
	displayText()

func displayText(): # Displays the text with the right sizing for linecount, since the text is vertically top justified
	text = "" # Reset the textbox size
	
	for i in textQueue.size(): # Add text one at a time and resize accordingly
		text += textQueue[i]
		if i == 5: break # The textQueue can still have more than 5, but only 5 are shown at once

#TODO: fix this so that we can have it actually flash and not knockback the player
func setStatusColor(c : Color = Color("WHITE"), t : float = 0.00): # Used for lingering effects (e.g. poison)
	if(t): $StatusColorTimer.start(t)
	#get_parent().find_child("AnimatedSprite2D").set_self_modulate(c)
	
	currStatusColor = c # Set the status color so long colors are not overridden by a short flashed colors

func setStatusFlash(c : Color = currStatusColor, t : float = 0.00): # Used for damage flash (RED) and spellcast (BLUE), flashes over but doesnt end setStatusColor()
	if(t): $StatusFlashTimer.start(t)
	#get_parent().find_child("AnimatedSprite2D").set_self_modulate(c)
