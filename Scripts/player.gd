extends CharacterBody3D

# Movement speed
@export var move_speed = 5.0
@export var rotate_speed = 3.0

# Gravity
@export var gravity = 9.8

# Jump force
@export var jump_force = 10.0

# Camera Pivot
@export var camera_pivot: Node3D

@export var rig : Node3D

@export var spine_ik: SkeletonIK3D

var aiming = false
var input_dir = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func S_IK(start):
	if start:
		spine_ik.start()
	else:
		spine_ik.stop()

func _input(event):
	
	
	
	if Input.is_action_just_pressed("aim"):
		camera_pivot.aim()
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force


func lerp_to_direction(direction,speed,delta):
	var angle = rad_to_deg(atan2(-direction.x, -direction.y))
	var my_rot = rig.rotation_degrees.y
	# Wrap angles to [0, 360] for easier quadrant checking
	var wrapped_angle = int(angle + 360) % 360
	var wrapped_my_rot = int(my_rot + 360) % 360
	# Calculate shortest path
	var delta_angle = wrapped_angle - wrapped_my_rot
	# Handle quadrant crossing (wrap delta_angle to [-180, 180])
	if delta_angle > 180:
		delta_angle -= 360
	elif delta_angle < -180:
		delta_angle += 360
	# Smoothly interpolate using lerp
	var new_angle = my_rot + delta_angle * (speed * delta)
	# Update rotation
	return new_angle

func angle_to_vector2(angle : float):
	return Vector2(-sin(angle), cos(angle))

func vector2_to_angle(v : Vector2):
	return atan2(v.x,v.y)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _physics_process(delta):
	
	input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_dir.y += -1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += -1
	
	if aiming:
		rig.rotation_degrees.y = 180
		if input_dir:
			var angle = vector2_to_angle(input_dir)
			var n_angle = angle - rotation.y
			input_dir = angle_to_vector2(n_angle)
	
	if !aiming:
		if input_dir:
			var angle = vector2_to_angle(input_dir)
			var n_angle = angle - camera_pivot.freecam.rotation.y
			input_dir = angle_to_vector2(n_angle)
			rig.rotation_degrees.y = lerp_to_direction(-input_dir,5,delta)

	input_dir = input_dir.normalized()
	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.y * move_speed
	velocity.y -= gravity * delta

	move_and_slide()
