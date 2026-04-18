extends EffectBASE ## Effect_Icy: Slowed movespeed, Damage() each tick
func InitialEffect(): 
	# TODO: makes you go slower
	pass
func EffectTick(): entity.Damage(strength)
func EndEffect(): pass
