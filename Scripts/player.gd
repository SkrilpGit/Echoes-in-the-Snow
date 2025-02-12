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
var esc_tog = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	
	if Input.is_action_just_pressed("fire"):
		rig.fire()
	elif Input.is_action_just_released("fire"):
		rig.chamber()
	
	if Input.is_action_just_pressed("aim"):
		camera_pivot.aim()
	
	if Input.is_action_just_pressed("ui_cancel"):
		if esc_tog:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			camera_pivot.input_enabled = false
			esc_tog = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			camera_pivot.input_enabled = true
			esc_tog = true
		
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
	
	match camera_pivot.state:
		camera_pivot.states.TRANSITION:
			var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
			dir = Vector2(-dir.x,dir.y)
			rig.rotation_degrees.y = lerp_to_direction(dir,5,delta)
			if input_dir:
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
		camera_pivot.states.SHOULDER:
			rig.spine_ik.target.basis.x = camera_pivot.basis.y
			rig.S_IK(true)
			if input_dir:
				#var dir = Vector2(input_dir.x,-input_dir.y)
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
				rig.rotation_degrees.y = lerp_to_direction(-input_dir,5,delta)
			else:
				var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
				dir = Vector2(-dir.x,dir.y)
				rig.rotation_degrees.y = lerp_to_direction(dir,5,delta)
		camera_pivot.states.FREE:
			rig.S_IK(false)
			if input_dir:
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
				rig.rotation_degrees.y = lerp_to_direction(-input_dir,5,delta)
	
	input_dir = input_dir.normalized()
	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.y * move_speed
	velocity.y -= gravity * delta

	move_and_slide()
	if aiming:
		camera_pivot.position = position + camera_pivot.offset
