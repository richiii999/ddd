class_name Item extends Sprite2D ## Item stats and info

@export var itemName : String = "" #TODO: itemname is filename without underscores
@export var price : int = 1 # Price to buy this item from a shop
var ID : int = 0 # Set by ItemSpawner when items are created

#enum Stat {STR, INT, AGI, TOU, WIS, DEX, BLK, WIL, SPD}
enum Types {INV, HELM, CHEST, RING, MAINHAND, OFFHAND, UNDROPPABLE}
@export var type : int = -1 # -1=unset, should be one of ^

## Stats: Adds Player's gear stats
@export var Stats := {Player.Stat.STR: 5, Player.Stat.INT: 5, Player.Stat.AGI : 5, Player.Stat.TOU : 3, Player.Stat.WIS : 3, Player.Stat.DEX : 3, Player.Stat.BLK: 1, Player.Stat.WIL : 1, Player.Stat.SPD : 1}

## Input stats & Weights: Used mostly for weapons, affects how important the player's stats are for this item
@export var statWeights = {Player.Stat.STR : 1.00}

## Projectile: generally main & offhand items, but potentially others.
@export var projectile : PackedScene = null

func _ready(): 
	if itemName == "": push_warning("ItemName not set! " + str(self))
	#if $TestItem.Type == Types.MAINHAND: 
		#print("yuh")
