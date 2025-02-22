extends Node3D

# Movement speed
@export var move_speed = 5.0

# Gravity
@export var gravity = 9.8

# Jump force
@export var jump_force = 10.0

# Character Body
@onready var body = $CharacterBody3D

# Camera Pivot
@export var camera_pivot: Node3D

@export var rig : Node3D

@export var spine_ik: SkeletonIK3D

var aiming = false
var input_dir = Vector2.ZERO
var esc_tog = true

signal fire_pressed()
signal fire_released()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	
	if Input.is_action_just_pressed("fire"):
		fire_pressed.emit()
	elif Input.is_action_just_released("fire"):
		fire_released.emit()
	
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
		
	if body.is_on_floor() and Input.is_action_just_pressed("jump"):
		body.velocity.y = jump_force

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
			rig.rotation_degrees.y = Global.lerp_to_direction(rig.rotation_degrees.y,dir,5,delta)
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
				rig.rotation_degrees.y = Global.lerp_to_direction(rig.rotation_degrees.y,-input_dir,5,delta)
			else:
				var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
				dir = Vector2(-dir.x,dir.y)
				rig.rotation_degrees.y = Global.lerp_to_direction(rig.rotation_degrees.y,dir,5,delta)
		camera_pivot.states.FREE:
			rig.S_IK(false)
			if input_dir:
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
				rig.rotation_degrees.y = Global.lerp_to_direction(rig.rotation_degrees.y,-input_dir,5,delta)
	
	input_dir = input_dir.normalized()
	body.velocity.x = input_dir.x * move_speed
	body.velocity.z = input_dir.y * move_speed
	body.velocity.y -= gravity * delta

	body.move_and_slide()
	if aiming:
		camera_pivot.position = body.position + camera_pivot.offset
