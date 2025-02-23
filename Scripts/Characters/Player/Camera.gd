extends Node3D

var anim_ready = true

@export var anim_ctrl : AnimationPlayer
@export var char : Node3D
@export var cam : Camera3D
@export var HUD : Node2D
@export var MOUSE_SENSE = 0.001
var mouse_sensitivity = 0.1

@export var offset = Vector3.ZERO # make this value match the one in the editor :)

var gun = null
var CamStates = null

var input_enabled = true

func _input(event):
	if event is InputEventMouseMotion and input_enabled:
		var cam_rot = rotation_degrees
		cam_rot.x = clamp(cam_rot.x - event.relative.y * mouse_sensitivity, -85, 85)
		cam_rot.y += -event.relative.x * mouse_sensitivity
		rotation_degrees = cam_rot

func _ready():
	gun = char.equipped
	CamStates = char.find_child("CameraStates")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(state )
	mouse_sensitivity = get_viewport().get_camera_3d().fov * MOUSE_SENSE
	pass

func camlerp(speed,delta):
	var tarPos = char.body.position + offset
	position = lerp(position,tarPos,speed*delta)

func aim():
	if anim_ready:
		anim_ready = false
		CamStates.change_state()
		#print(CamStates.state)
		

func playAnim(anim):
	anim_ctrl.play(anim)
	HUD.visible = false

func _on_animation_finished(anim_name):
	anim_ready = true
	cam.rotation = Vector3.ZERO
	match anim_name:
		"Shoulder":
			char.aiming = true
			gun.aiming(true)
			CamStates.change_state("SHOULDER")
			HUD.visible = true
		"ADS":
			pass
		"Reset":
			#char.aiming = false
			pass
