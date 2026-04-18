extends EFFECT_BASE ## Effect_Poison: Damage() each tick
func InitialEffect(): pass
func EffectTick(): entity.Damage(strength)
func EndEffect(): pass
