extends EffectBASE ## Effect_Burn: Increased move speed, Damage() each tick
func InitialEffect(): entity.effectMoveSpeed += 0.2 #20% spd increase
func EffectTick(): entity.Damage(strength)
func EndEffect(): entity.effectMoveSpeed -= 0.2
