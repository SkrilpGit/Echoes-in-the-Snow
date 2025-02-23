extends Node3D


@export var muzzle_velocity = 1000.0
@export var bullet_weight = 1.0
@export var air_resistance = 1.0
@export var terminal_velocity = -100.0

var creator = Object

var velocity = Vector3.ZERO
var prev_pos = Vector3.ZERO
var dir : Vector3
var speed : float
var gravity = 0

var lifetime = 0
var drop = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("YOOOOOOOOOOOOOO")
	speed = muzzle_velocity
	prev_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	lifetime += delta
	
	if gravity > terminal_velocity:
		gravity += -9.8 * delta
	calc_drag(delta)
	prev_pos = position
	velocity = dir * speed
	drop += -gravity * delta
	position += velocity * delta
	global_position.y += gravity * delta
	
	if speed < muzzle_velocity/8:
		print("too slow")
		hit()
	
	var query = PhysicsRayQueryParameters3D.create(prev_pos, position)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		print(result["collider"].get_parent().get_parent().name)
		hit(result["collider"])

func calc_drag(delta):
	speed -= pow(speed,air_resistance) * delta
	#print(speed)

func hit(target : Object = null):
	var distance = creator.global_position - global_position
	distance = distance.length()
	print("bullet: "+name)
	print("final speed: "+str(speed)+"m/s")
	print("final distance:"+str(Global.round_to_dec(distance,2))+"m")
	print("bullet drop: "+str(Global.round_to_dec(drop,2))+"m")
	print("bullet time: "+str(Global.round_to_dec(lifetime,2))+"s")
	if target != null:
		var real_target = target.get_parent().get_parent()
		if real_target.has_method("hit"):
			print("HIT")
			real_target.hit()
	queue_free()
