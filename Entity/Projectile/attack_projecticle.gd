class_name AttackData
extends Resource

@export var projectile : PackedScene
@export var field : PackedScene
@export var fieldEffect : PackedScene
@export var effect : PackedScene

func make_unique():
	return Resource.new()
