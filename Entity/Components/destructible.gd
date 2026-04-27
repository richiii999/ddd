class_name Destructible extends Node ## Component that attaches to walls and stuff
# If a projectile collides with this node's parent, it will signal to this script's WallDamage()

@export var HitsMax  : int = 10 # Destructibles take X number of hits, regardless of a proj's power
@export var HitsLeft : int = HitsMax

@onready var ParentSprite : Node = get_parent().find_child("Sprite2D")

func Flash(c : Color = Color(1,1,1), t : float = 0.00): 
	ParentSprite.set_self_modulate(c)
	if(t): $DamageFlash.start(t)

func WallDamage(): 
	HitsLeft -= 1
	if(!HitsLeft): get_parent().queue_free()
	if(ParentSprite): Flash(Color(1,0,0,1), 0.25) # Flash the color of the sprite to red when hit
