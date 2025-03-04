extends Node3D


@export var muzzle_velocity = 1000.0
@export var bullet_weight = 1.0
@export var BC = 1.0
@export var terminal_velocity = -100.0

var creator = Object
var birth_place = Vector3.ZERO

var velocity = Vector3.ZERO
var prev_pos = Vector3.ZERO
var dir : Vector3
var speed : float
var gravity = 0
var distance = 0

var lifetime = 0
var drop = 0.0

var prev_speed = 0
var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	#print("YOOOOOOOOOOOOOO")
	speed = muzzle_velocity
	prev_pos = position
	birth_place = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	lifetime += delta
	
	distance = birth_place - global_position
	distance = distance.length()
	
	if gravity > terminal_velocity:
		gravity += -9 * delta
	prev_pos = position
	velocity = dir * speed
	drop += -gravity * delta
	position += velocity * delta
	global_position.y += gravity * delta
	
	calc_drag(delta)
	
	if distance >= counter:
		print(speed,"m/s at ",distance,"m")
		print(speed-prev_speed)
		prev_speed = speed
		counter += 100
	
	if speed < 100:
		#print("too slow")
		hit()
	
	var query = PhysicsRayQueryParameters3D.create(prev_pos, position)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		#print(result["collider"].get_parent().get_parent().name)
		hit(result["collider"])

func calc_drag(delta):
	# wow what a cool algorithm
	var drag
	#supersonic
	if speed >= 345:
		drag = (pow(speed,2))/(300*BC)
	else:
		drag = (pow(speed,2))/(800*BC)
	speed -= drag/sqrt(bullet_weight*2) * delta
	#print(pow(speed,2)/(150*BC))

func prnt_info(target_name):
	print("bullet: ",name,"\n",
	"target hit: ",target_name,"\n",
	"final speed: ",str(speed),"m/s","\n",
	"final distance: ",str(Global.round_to_dec(distance,2)),"m","\n",
	"bullet drop: ",str(Global.round_to_dec(drop,2)),"m","\n",
	"bullet time: ",str(Global.round_to_dec(lifetime,2)),"s")

func hit(target : Object = null):
	var target_name = "null"
	if target != null:
		var real_target = target.get_parent().get_parent()
		if real_target.has_method("hit"):
			#print("HIT")
			real_target.hit()
		target_name = target.get_parent().get_parent().name
	
	prnt_info(target_name)
	
	queue_free()
