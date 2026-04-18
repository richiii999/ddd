class_name EntitySight extends SmartArea ## Keeps an array of the nodes inside of an entity's Sight SmartArea and adds focus on sight

@onready var Entity = get_parent() # Ref to the entity this is a part of

## OVERRIDE FUNCS: Funcs in SmartArea overridden by EntitySight
func onEnter(N: Node2D): Entity.FocusAdd(N) # Add a minimal amount of focus on sight, to trigger entity behaviors
