extends Control ## CharMenu: Press 'C' to show character stats
@onready var player : Player = Tools.FindParentByType(self, Player)
@onready var str_value = $CharacterRect/Stats/STR_Label/STR
@onready var spd_value = $CharacterRect/Stats/SPD_Label/SPD
@onready var tou_value = $CharacterRect/Stats/TOU_Label/TOU
@onready var blk_value = $CharacterRect/Stats/BLK_Label/BLK
@onready var wis_value = $CharacterRect/Stats/WIS_Label/WIS
@onready var int_value = $CharacterRect/Stats/INT_Label/INT
@onready var dex_value = $CharacterRect/Stats/DEX_Label/DEX
@onready var wil_value = $CharacterRect/Stats/WIL_Label/WIL
@onready var agi_value = $CharacterRect/Stats/AGI_Label/AGI
# TODO
# Displays at the center of your screen, similar to deathScreen
# Copies the sprite of your character and displays on the left,
# Stats on the right with stat labels "STR, AGI, INT ..." and their values
# Can maybe make symbols or something idk

func _ready():
	pass

func refresh_stats():
	if player == null:
		return
	str_value.text = str(player.getStats(Stats.STR))
	spd_value.text = str(player.getStats(Stats.SPD))
	tou_value.text = str(player.getStats(Stats.TOU))
	blk_value.text = str(player.getStats(Stats.BLK))
	wis_value.text = str(player.getStats(Stats.WIS))
	int_value.text = str(player.getStats(Stats.INT))
	dex_value.text = str(player.getStats(Stats.DEX))
	wil_value.text = str(player.getStats(Stats.WIL))
	agi_value.text = str(player.getStats(Stats.AGI))
