extends BehaviorBASE ## Boss1: Stands still and shoots slowly

@export var healthThreshold = 0.33 # What % health remaining to switch phases?

## Override funcs: behaviorBASE funcs overridden by ChaseFlee
func onEnter(): # Boss stands still
	Entity.immovable = true
	Entity.velocity = Vector2.ZERO
	Entity.StatusLabel.addStatusText("Boss1", "WHITE")

func onLeave(): # Reset movement stuff
	Entity.immovable = false

func checkConditions() -> bool: return (Entity.HPBar.ratio <= healthThreshold)
