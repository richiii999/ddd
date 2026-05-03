extends EffectBASE ## Effect_Burn: Increased move speed, Damage() each tick
func InitialEffect(): entity.effectMoveSpeed += 0.15
func EffectTick(): entity.Damage((tier * 2) + sourcePower)
func EndEffect(): entity.effectMoveSpeed -= 0.15
