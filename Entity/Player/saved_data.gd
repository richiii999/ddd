class_name SavedData
extends Resource

#Extra vars {Test}
#@export var items: Item

#Player stats
@export var max_player_health: int
@export var current_hp: int
@export var max_player_mp: int
@export var current_mp: int
@export var core_Stats: Dictionary[Stats.STAT, int]
@export var hp_pot_max: int
@export var hp_pot_current: int
@export var mp_pot_max: int
@export var mp_pot_current: int
@export var level: int
@export var xp_max: int
@export var xp_current: int
@export var fame: int
@export var skill_points: int
@export var coins: int

#Bank items
#NOTE: Currently being unused, might be replaced with other method or stored using .json
@export var bank_item_paths: Array[String] = []

#Player Inventory
#TODO: Might require for each item to be saved diffrently, maybe save this throguh .json instead, equally annoying
