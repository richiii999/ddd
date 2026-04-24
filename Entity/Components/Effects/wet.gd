extends EffectBASE ## Effect_Wet: Makes movement slippery (less friction)
func InitialEffect(): 
	entity.wet = true
	entity.effectMoveSpeed -= 0.7
func EffectTick(): pass
func EndEffect(): 
	entity.wet = false
	entity.effectMoveSpeed += 0.7
