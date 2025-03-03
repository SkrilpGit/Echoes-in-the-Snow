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
var direction = Vector3.ZERO
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
	
	input_dir = Input.get_vector("move_left","move_right","move_forward","move_backward").normalized()
	var cam_basis = Basis(Vector3.UP,camera_pivot.rotation.y)
	direction = (cam_basis*Vector3(input_dir.x,0,input_dir.y))
	
	camera_state(delta,cam_basis)
	
	body.velocity.x = direction.x * move_speed
	body.velocity.z = direction.z * move_speed
	body.velocity.y -= gravity * delta

	body.move_and_slide()
	CamStates._state_logic(delta)
	if aiming:
		camera_pivot.position = body.position + camera_pivot.offset

func camera_state(delta,cam_rot_y):
	var my_rot = rig.rotation_degrees.y
	match CamStates.states.find_key(CamStates.state):
		
		"TRANSITION":
			rig.basis = lerp(rig.basis,cam_rot_y,5*delta)
			if input_dir:
				set_move_animation(input_dir)
			else:
				rig.stand_still()
		
		"SHOULDER":
			rig.spine_ik.target.basis.x = camera_pivot.basis.y
			rig.S_IK(true)
			rig.basis = lerp(rig.basis,cam_rot_y,5*delta)
			if input_dir:
				set_move_animation(input_dir)
			else:
				rig.stand_still()
		
		"SCOPED":
			rig.spine_ik.target.basis.x = camera_pivot.basis.y
			rig.S_IK(true)
			rig.basis = lerp(rig.basis,cam_rot_y,5*delta)
			if input_dir:
				set_move_animation(input_dir)
			else:
				rig.stand_still()
		
		"FREE":
			rig.S_IK(false)
			if input_dir:
				rig.rotation_degrees.y = Global.lerp_to_direction(my_rot,Vector2(direction.x,direction.z),5,delta)
				rig.move_forward()
			else:
				rig.stand_still()

func set_move_animation(dir):
	#print(dir)
	if dir == Vector2(0,-1):
		rig.move_forward()
	elif dir == Vector2(0,1):
		rig.move_backward()
	elif dir.x > 0:
		rig.move_right()
	elif dir.x < 0:
		rig.move_left()
