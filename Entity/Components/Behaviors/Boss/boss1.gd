extends behaviorBASE ## Boss1: Stands still and shoots slowly

@export var healthThreshold = 0.33 # What % health remaining to switch phases?

## Override funcs: behaviorBASE funcs overridden by ChaseFlee
func onEnter(): # Boss stands still
	Entity.behaviorMoveSpeed = 0.00
	Entity.set_collision_layer_value(9, true)
	Entity.StatusLabel.addStatusText("Boss1", "WHITE")

func onLeave(): # Reset movement stuff
	Entity.behaviorMoveSpeed = 1.00
	Entity.set_collision_layer_value(9, false)

func checkConditions(): 
	if ( Entity.HPBar.ratio <= healthThreshold): 
		changeStateByIdx.connect(get_parent().ChangeStateByIdx)
		changeStateByIdx.emit(self.get_index() + 1 ) # Go to next phase
