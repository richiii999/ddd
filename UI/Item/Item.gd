class_name Item extends Sprite2D ## Item stats and info

@export var itemName : String = "" #TODO: itemname is filename without underscores
@export var price : int = 1 # Price to buy this item from a shop
var ID : int = 0 # Set by ItemSpawner when items are created

enum Types {INV, HELM, CHEST, RING, MAINHAND, OFFHAND, UNDROPPABLE}
@export var type : int = -1 # -1=unset, should be one of ^

## Stats: Adds Player's gear stats
@warning_ignore("int_as_enum_without_cast")
@export var stats : Dictionary[Stats.STAT, int] = {Stats.STR: 0, Stats.INT: 0, Stats.AGI: 0, Stats.TOU: 0, Stats.WIS: 0, Stats.DEX: 0, Stats.BLK: 0, Stats.WIL: 0, Stats.SPD: 0}

## Projectile: What projectile is given from this item? Overrides the player's
# NOTE: Only used on Main/Off-hand items
@export var projectile : PackedScene = null

func _ready(): 
	if itemName == "": push_warning("ItemName not set! " + str(self))
