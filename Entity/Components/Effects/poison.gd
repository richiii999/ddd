extends EffectBASE ## Effect_Poison: Damage() each tick
func InitialEffect(): pass
func EffectTick(): entity.Damage((tier * 2) + sourcePower)
func EndEffect(): pass
