extends Node3D


@export var muzzle_velocity = 1000.0
@export var bullet_weight = 1.0
@export var BC = 1.0
@export var cal = 5.56
enum drag_function{
	G1,G7
}
@export var bullet_shape : drag_function
@export var terminal_velocity = -100.0
@export var tracer : MeshInstance3D

var mach_values = [
0.00, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 1.00, 1.10, 
1.20, 1.30, 1.40, 1.50, 1.60, 1.70, 1.80, 1.90, 2.00, 2.50, 3.00, 4.00, 5.00
]
var cw_values = [] #coefficient wave values
var formfactor

var creator = Object
var spawn_pos = Vector3.ZERO

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
	tracer.visible = false
	speed = muzzle_velocity
	prev_pos = position
	spawn_pos = global_position
	cal /= 1000 # caliber in metres
	bullet_weight /= 1000 # weight in kilos
	formfactor = get_formfactor()
	cw_values = get_drag_values(bullet_shape)

func get_drag_values(shape):
	# drag coefficients taken from here: https://www.jbmballistics.com/ballistics/downloads/downloads.shtml THANK YOU <3
	# Also the idea for the drag algorithm taken from here: https://www.x-ballistics.eu/cms/ballistics/how-to-calculate-the-trajectory/
	
	if shape == drag_function.G1:
		return [
			0.26, 0.23, 0.22, 0.21, 0.20, 0.20, 0.21, 0.25, 0.34, 0.48, 0.58, 
			0.63, 0.65, 0.66, 0.65, 0.64, 0.63, 0.62, 0.60, 0.59, 0.53, 0.51, 0.50, 0.49
			]
	else:
		return [
			0.1198, 0.1193, 0.1194, 0.1193, 0.1194, 0.1194, 0.1202, 0.1242, 0.1464, 0.3803, 
			0.4014, 0.3884, 0.3732, 0.3580, 0.3440, 0.3315, 0.3209, 0.3117, 0.3042, 0.2980, 
			0.2697, 0.2424, 0.1935, 0.1618
		]

func get_formfactor():
	var d_inch = cal * 39.3701 # bullet diameter in inches
	var m_pound = bullet_weight * 2.20462 # mass in pounds
	return m_pound / (pow(d_inch,2)*BC)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	lifetime += delta
	
	#tracer.scale.y = speed/10
	#tracer.position.z = -tracer.scale.y/2
	
	distance = spawn_pos - global_position
	distance = distance.length()
	
	if gravity > terminal_velocity:
		gravity += -10 * delta
	prev_pos = position
	velocity = dir * speed
	drop += -gravity * delta
	position += velocity * delta
	global_position.y += gravity * delta
	
	#look_at_from_position(position,velocity)
	#print(transform.basis*velocity)
	
	if distance != 0:
		calc_drag(delta)
		tracer.visible = true
	
	if distance >= counter:
		#print(speed,"m/s at ",distance,"m")
		#print(speed-prev_speed)
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
	var accel
	var air_density = 1.2
	var A = (pow(cal/2,2)*PI)/4
	var c
	var mach = speed/340.3
	var i = 0
	while true:
		if mach_values.size() < i:
			print("failed to find mach value")
			break
		if mach_values[i] >= mach:
			c = lerp(cw_values[i],cw_values[i-1],mach_values[i]-mach)
			#print("drag coefficient = ",c,"\n","mach = ",mach,"\n",
			#"mach_values[i] = ",mach_values[i],"\n","mach_values[i-1] = ",mach_values[i-1])
			break
		i += 1
	#print(formfactor)
	drag = 2*air_density * A * (speed*speed) * c * formfactor
	accel = drag / bullet_weight
	speed -= accel * delta
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
	
	#prnt_info(target_name)
	
	queue_free()


func _on_audio_finished():
	find_child("AudioStreamPlayer3D").playing = true
