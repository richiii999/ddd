extends behaviorBASE ## Boss1: Stands still and shoots slowly

@export var healRate = 0.20 # What % to heal per second
@export var healMax = 1.00 # What % to heal up to

## Override funcs: behaviorBASE funcs overridden by ChaseFlee
func onEnter(): # Stop and heal
	Entity.behaviorMoveSpeed = 0.00
	Entity.set_collision_layer_value(9, true)
	Entity.setInvulnerable(true) # Prevent transition-burn cheese
	Entity.StatusLabel.addStatusText("BossHeal", "WHITE")

func onLeave(): # Reset movement stuff
	Entity.behaviorMoveSpeed = 1.00
	Entity.set_collision_layer_value(9, false)
	Entity.setInvulnerable(false)

func checkConditions(): 
	Entity.Heal( int(Entity.HPmax * (healRate / 2.00)) ) # /2 since every 0.5s 
	if ( Entity.HPBar.ratio >= healMax): 
		changeStateByIdx.connect(get_parent().ChangeStateByIdx)
		changeStateByIdx.emit(self.get_index() + 1 ) # Go to next phase
