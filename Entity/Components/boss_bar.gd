extends Node2D ## Bossbar: Grabs the entity's HP_Bar node and places it in the world

# Idea, do the effect where continuous damage lowers bar and leaves trail, which only follows when damage stops.
# Can just have anotehr bar behind that goes towards the curr value by some % each frame but damage starts a timer that halts it

# This is prob a bad way to do it, perhaps better would be to have a bossbar on the player and connect to it or someth

var HPBar : ProgressBar # The HPBar of the entity

func _ready(): call_deferred("GrabHPBar") # Wait for the rest of the entity to load

func GrabHPBar(): # Place the Entity's HP_Bar node in the world (while retaining connections to the Entity)
	var entity = get_parent()
	
	# https://forum.godotengine.org/t/is-class-function-for-objects-of-a-custom-class/70875/9
	if (!entity || !entity.get_script() || entity.get_script().get_global_name() != "Enemy"): # is_class() ignores custom classes, wtf? 
		print_debug("BossBar child of non-Enemy")
	else: # Kidnap the HPBar and leave it in the world
		HPBar = entity.HPBar
		HPBar.reparent(self)
		self.reparent(entity.get_parent())
		HPBar.custom_minimum_size = Vector2(250,30)
		HPBar.set_global_position(entity.global_position + Vector2(-125, -300))
		HPBar.visible = true # Visible even at 100% (full HP entities normally hidden)
		entity.death.connect(queue_free) # When the entity dies, delete this too (since no longer child of entity)
