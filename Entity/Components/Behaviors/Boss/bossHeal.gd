extends BehaviorBASE ## Boss1: Stands still and shoots slowly

@export var healRate = 0.20 # What % to heal per second
@export var healMax = 1.00 # What % to heal up to

## Override funcs: behaviorBASE funcs overridden by ChaseFlee
func onEnter(): # Stop and heal
	Entity.immovable = true
	Entity.velocity = Vector2.ZERO
	Entity.setInvulnerable(true) # Prevent transition-burn cheese
	Entity.StatusLabel.addStatusText("BossHeal", "WHITE")

func onLeave(): # Reset movement stuff
	Entity.immovable = false
	Entity.setInvulnerable(false)

func BehaviorTick(): Entity.Heal( int(Entity.HPmax * (healRate / 2.00)) ) # /2 since every 0.5s 

func checkConditions() -> bool: return (Entity.HPBar.ratio >= healMax)
