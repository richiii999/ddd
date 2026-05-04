#Created only for items saving, Each items needs data individualy saved
#NOTE: Currently unused, may be obsolete

extends Resource
class_name ItemSaveData

@export var item_name: String = ""
@export var price: int = 0
@export var tier: int = 0
@export var type: int = 0
@export var stats: Dictionary = {}
@export var attack_path: String = ""
