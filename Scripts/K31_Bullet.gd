extends Node3D


@export var muzzle_velocity = 1000
@export var bullet_weight = 1
@export var air_resistance = 1

var creator = Object

var velocity = Vector3.ZERO
var prev_pos = Vector3.ZERO
var dir : Vector3
var speed : float

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("YOOOOOOOOOOOOOO")
	speed = muzzle_velocity
	prev_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	velocity = dir
	speed -= air_resistance * delta
	prev_pos = position
	velocity.y += -9.8 * delta
	position += velocity * speed * delta
	
	if speed < muzzle_velocity/2:
		hit()
		pass
	
	var query = PhysicsRayQueryParameters3D.create(prev_pos, position)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		print(result["collider"].get_parent().get_parent().name)
		hit(result["collider"])

func hit(target : Object = null):
	print("HIT")
	if target != null:
		var real_target = target.get_parent().get_parent()
		if real_target.has_method("hit"):
			var distance_to_target = creator.global_position - real_target.global_position
			print("WOW YOU SHOT THEM FROM: "+str(distance_to_target.length())+"m")
			real_target.hit()
	queue_free()
