extends RigidBody3D

@export var lifetime: float

func _process(delta):
	lifetime -= delta
	#print(lifetime)
	if lifetime <= 0:
		queue_free()
