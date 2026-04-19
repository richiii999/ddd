class_name EntitySight extends SmartArea ## Keeps an array of the nodes inside Sight

@onready var Entity = get_parent() # Ref to the entity this is a part of

## OVERRIDE FUNCS: Funcs in SmartArea overridden by EntitySight
func onEnter(N: Node2D): pass
