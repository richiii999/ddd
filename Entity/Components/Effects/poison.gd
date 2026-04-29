extends EffectBASE ## Effect_Poison: Damage() each tick
func InitialEffect(): pass
func EffectTick(): entity.Damage(tier * 3)
func EndEffect(): pass
