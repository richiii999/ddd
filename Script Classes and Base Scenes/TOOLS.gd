class_name Tools ## Tools.gd: Collection of funcs that are helpful
# Funcs are static, so they can be used anywhere, shouldn't need to instantiate this class for any reason

## Custom Operators: there should be an operator like ?= or something that randomly adjusts the Lvalue +- by some amount up to Rvalue
# Randomly adjusts a Vec2 'V2' +- each dimension by up to 'r'
static func NudgeVec2(V2 : Vector2, r : float) -> Vector2: return Vector2(randf_range(V2.x - r, V2.x + r), randf_range(V2.y - r, V2.y + r))
# Randomly adjusts an float 'A' +- by up to 'r'
static func NudgeFloat(A : float, r : float) -> float: return randf_range(A - r, A + r)
# Subracting one Vector2i from another: returns (A - B)
static func VecSub(A : Vector2i, B : Vector2i) -> Vector2i: return Vector2i(A.x - B.x, A.y - B.y)

## Common issue: Need to pass off a particle emitter to some parent node higher in tree due to it's direct parent being free'd
# Simply freeing will result in particles disappearing all at once, so need to wait for particles to fade, then free (via a timer)
# There is probably an intended way to do this but idk
static func ParticlePassOff(P : GPUParticles2D, stopEmitting:bool = true) -> void:
	if stopEmitting: P.emitting = false
	P.get_tree().create_timer(P.lifetime).timeout.connect(P.queue_free) # Free after timer. time = lifetime, because the particles should expire fully, then free
	P.call_deferred("reparent", P.get_node("/root/GameManager/ParticleTrasher")) # Reparent because otherwise the particles are deleted when their parent node is this frame

# From https://forum.godotengine.org/t/is-there-a-way-to-access-a-sibling-node-without-knowing-its-name/730
func find_prev_next_sibling_nodes(target_node):
	var prev_node = null
	var next_node = null
	if target_node:
		var parent = target_node.get_parent()
		var target_index = target_node.get_index()
		if target_index > 0: prev_node = parent.get_child(target_index - 1)
		if target_index < parent.get_child_count() - 1: next_node = parent.get_child(target_index + 1)
	return [prev_node, next_node]

# Recursively search upwards for a parent node of type, returns NULL if cannot find
static func FindParentByType(target_node:Node, type:Variant) -> Node:
	var curr = target_node
	while curr:
		curr = curr.get_parent()
		if is_instance_of(curr, type): return curr
	return null
