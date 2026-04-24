extends EffectBASE ## Effect_Slow: slows you down
func InitialEffect(): entity.effectMoveSpeed -= 0.15 * tier
func EffectTick(): pass
func EndEffect(): entity.effectMoveSpeed += 0.15 * tier
