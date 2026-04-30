class_name PetPickup extends Sprite2D ## PetPickup: Interactable that spawns Pet

@export var Pet : PackedScene # Pet to spawn

func _ready():
	$InteractComponent.Interact.connect(PickupPet)
	if Pet == null: push_error("No pet set on PetPickup!" , self)

func PickupPet(P:Player): if P != null: P.SpawnPet(Pet)
