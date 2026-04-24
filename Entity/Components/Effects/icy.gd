extends EffectBASE ## Effect_Icy: Slowed movespeed, Damage() each tick
func InitialEffect(): entity.effectMoveSpeed -= 0.20 * tier
func EffectTick(): entity.Damage(tier * 1)
func EndEffect(): entity.effectMoveSpeed += 0.20 * tier
