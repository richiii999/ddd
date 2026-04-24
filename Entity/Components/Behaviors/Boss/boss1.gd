extends BehaviorBASE ## Boss1: Stands still and shoots slowly

@export var healthThreshold = 0.33 # What % health remaining to switch phases?

## Override funcs: behaviorBASE funcs overridden by ChaseFlee
func onEnter(): # Boss stands still
	Entity.immovable = true
	Entity.velocity = Vector2.ZERO
	Entity.StatusLabel.addStatusText("Boss1", "WHITE")

func onLeave(): # Reset movement stuff
	Entity.immovable = false

func checkConditions(): 
	if (Entity.HPBar.ratio <= healthThreshold): 
		changeStateByIdx.emit(get_index() + 1) # Go to next phase
