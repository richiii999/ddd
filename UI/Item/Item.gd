class_name Item extends Sprite2D ## Item stats and info

@export var price : int = 1 # Price to buy this item from a shop
var ID : int = 0 # Set by ItemSpawner when items are created

# Item rarity, gives border color
@export_enum("Common", "Uncommon", "Rare", "Epic", "Quest") var tier : int = 0 

enum Types {INV, HELM, CHEST, RING, MAINHAND, OFFHAND}
@export_enum("Item", "Helm", "Chest", "Ring", "Mainhand", "Offhand") var type : int = -1 
# -1=unset, should be one of ^

## Stats: Adds Player's gear stats
@warning_ignore("int_as_enum_without_cast")
@export var stats : Dictionary[Stats.STAT, int] = {Stats.STR: 0, Stats.INT: 0, Stats.AGI: 0, Stats.TOU: 0, Stats.WIS: 0, Stats.DEX: 0, Stats.BLK: 0, Stats.WIL: 0, Stats.SPD: 0}

## Projectile: What projectile is given from this item? Overrides the player's
# NOTE: Only used on Main/Off-hand items
@export var attack : AttackData

func _ready(): 
	scale = Vector2(0.5,0.5) # Items are small
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST # fix blurry pixelart
