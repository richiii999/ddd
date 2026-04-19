extends EffectBASE ## Effect_Burn: Increased move speed, Damage() each tick
func InitialEffect(): 
	# TODO: makes you go faster
	entity.effectMoveSpeed += 0.2
func EffectTick(): entity.Damage(strength)
func EndEffect(): entity.effectMoveSpeed -= 0.2
