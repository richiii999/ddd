class_name PetPickup extends AnimatedSprite2D ## PetPickup: Interactable that spawns Pet

@export var pet : PackedScene # Pet to spawn

func _ready():
	$InteractComponent.Interact.connect(PickupPet)
	if pet == null: push_error("No pet set on PetPickup!", self)

func PickupPet(P:Player): if P != null: P.SpawnPet(pet)
