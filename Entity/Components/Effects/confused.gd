extends EffectBASE ## Confused: Makes your camera zoom in and out
# NOTE: Does nothing to enemies
func InitialEffect(): if entity is Player: entity.find_child("PlayerCam").confused = true
func EffectTick(): pass
func EndEffect(): if entity is Player: entity.find_child("PlayerCam").confused = false
