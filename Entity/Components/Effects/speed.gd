extends EffectBASE ## Effect_Speed: Increased movespeed
func InitialEffect(): entity.effectMoveSpeed += 0.5 #50% movespeed increase 
func EffectTick(): pass
func EndEffect(): entity.effectMoveSpeed -= 0.5 
