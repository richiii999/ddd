extends EffectBASE ## Effect_Burn: Increased move speed, Damage() each tick
func InitialEffect(): 
	# TODO: makes you go faster
	pass
func EffectTick(): entity.Damage(strength)
func EndEffect(): pass
