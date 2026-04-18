class_name Item extends Sprite2D ## Item CLASS definition
# Applied to all <item>.tres (which are the actual individual item files)

@export var itemName : String = ""

enum Stat {STR, INT, AGI, TOU, WIS, DEX, BLK, WIL, SPD}
enum Types {INV, HELM, CHEST, RING, MAINHAND, OFFHAND, UNDROPPABLE}
@export var type : int = -1 # -1=unset, should be one of ^

## Stats: Adds Player's gear stats
var Stats : Array = [1,1,1,  1,1,1,  1,1,1]

## Input stats & Weights: Used mostly for weapons, affects how important the player's stats are for this item
@export var statWeights = {Stat.STR : 1.00}

## Projectile: generally main & offhand items, but potentially others.
@export var projectile : PackedScene = null

# TODO: item table is res:// strings, just pick one randoml;y or someth
