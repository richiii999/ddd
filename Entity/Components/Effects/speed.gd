extends EffectBASE ## Effect_Speed: Increased movespeed
func InitialEffect(): entity.effectMoveSpeed += 0.10 * tier 
func EffectTick(): pass
func EndEffect(): entity.effectMoveSpeed -= 0.10 * tier 
