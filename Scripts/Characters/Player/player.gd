extends Node3D

# Movement speed
@export var move_speed = 5.0

# Gravity
@export var gravity = 9.8

# Jump force
@export var jump_force = 10.0

@export var char_strength = 100
# Character Body
@onready var body = $CharacterBody3D

# Camera Pivot
@export var camera_pivot: Node3D

@export var rig : Node3D

var aiming = false
var input_dir = Vector2.ZERO
var esc_tog = true
var pause = false

signal fire_pressed()
signal fire_released()

@onready var CamStates = $CameraStates
@onready var MovStates = $MovementStates

var equipped : Node3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	
	if Input.is_action_just_pressed("fire") and aiming:
		fire_pressed.emit()
	elif Input.is_action_just_released("fire") and aiming:
		fire_released.emit()
	
	if Input.is_action_just_pressed("aim"):
		camera_pivot.aim()
	
	if Input.is_action_just_pressed("ui_cancel"):
		if esc_tog:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			camera_pivot.input_enabled = false
			esc_tog = false
			#Engine.time_scale = 0.0
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			camera_pivot.input_enabled = true
			esc_tog = true
			#Engine.time_scale = 1.0
	
	if Input.is_action_just_pressed("pause"):
		if pause:
			Engine.time_scale = 1.0
			pause = false
		else:
			Engine.time_scale = 0.0
			pause = true
	
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
	
	camera_state(delta)
	
	input_dir = input_dir.normalized()
	body.velocity.x = input_dir.x * move_speed
	body.velocity.z = input_dir.y * move_speed
	body.velocity.y -= gravity * delta

	body.move_and_slide()
	CamStates._state_logic(delta)
	if aiming:
		camera_pivot.position = body.position + camera_pivot.offset

func camera_state(delta):
	var my_rot = rig.rotation_degrees.y
	match CamStates.states.find_key(CamStates.state):
		
		"TRANSITION":
			var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
			dir = Vector2(-dir.x,dir.y)
			rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,dir,5,delta)
			if input_dir:
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
		
		"SHOULDER":
			rig.spine_ik.target.basis.x = camera_pivot.basis.y
			rig.S_IK(true)
			if input_dir:
				set_move_animation(input_dir)
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
				var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
				dir = Vector2(-dir.x,dir.y)
				rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,dir,5,delta)
			else:
				rig.stand_still()
				var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
				dir = Vector2(-dir.x,dir.y)
				rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,dir,5,delta)
		
		"SCOPED":
			rig.spine_ik.target.basis.x = camera_pivot.basis.y
			rig.S_IK(true)
			if input_dir:
				set_move_animation(input_dir)
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
				var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
				dir = Vector2(-dir.x,dir.y)
				rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,dir,5,delta)
			else:
				rig.stand_still()
				var dir = Global.angle_to_vector2(camera_pivot.rotation.y)
				dir = Vector2(-dir.x,dir.y)
				rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,dir,5,delta)
		
		"FREE":
			rig.S_IK(false)
			if input_dir:
				var angle = Global.vector2_to_angle(input_dir)
				var n_angle = angle - camera_pivot.rotation.y
				input_dir = Global.angle_to_vector2(n_angle)
				rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,-input_dir,5,delta)
				rig.move_forward()
			else:
				rig.stand_still()

func set_move_animation(dir):
	#print(dir)
	if dir == Vector2(0,-1):
		rig.move_forward()
	elif dir == Vector2(0,1):
		rig.move_backward()
	elif dir.x < 0:
		rig.move_right()
	elif dir.x > 0:
		rig.move_left()
