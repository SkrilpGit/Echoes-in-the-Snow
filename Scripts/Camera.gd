extends Node3D


var counter = 0
var anim_ready = true

@export var anim_ctrl : AnimationPlayer
@export var character : CharacterBody3D
@export var freecam : Node3D
@export var cam : Camera3D
@export var mouse_sensitivity = 0.1

enum camera_states{
	FREE,
	TRANSITION,
	SHOULDER,
	SCOPED
}
var camera_state = camera_states.FREE

func _input(event):
	if event is InputEventMouseMotion:
		if camera_state != camera_states.FREE:
			var cam_rot = rotation_degrees.x
			var char_rot = character.rotation_degrees.y
			cam_rot = clamp(cam_rot - event.relative.y * mouse_sensitivity, -89, 89)
			char_rot += -event.relative.x * mouse_sensitivity
			
			rotation_degrees.x = cam_rot
			character.rotation_degrees.y = char_rot
			freecam.rotation_degrees = Vector3(cam_rot,char_rot,rotation_degrees.z)
		else:
			var cam_rot = freecam.rotation_degrees
			cam_rot.x = clamp(cam_rot.x - event.relative.y * mouse_sensitivity, -89, 89)
			cam_rot.y += -event.relative.x * mouse_sensitivity
			freecam.rotation_degrees = cam_rot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(camera_state )
	if camera_state == camera_states.FREE:
		freecam.position = lerp(freecam.position,character.position,5*delta)
		character.S_IK(false)
		mouse_sensitivity = 0.1
	elif camera_state == camera_states.SHOULDER:
		character.S_IK(true)
		mouse_sensitivity = 0.075
	elif camera_state == camera_states.SCOPED:
		mouse_sensitivity = 0.01

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func aim():
	if anim_ready:
		match camera_state:
			camera_states.FREE:
				character.rotation.y = freecam.rotation.y
				cam.make_current()
				camera_state = camera_states.TRANSITION
				anim_ctrl.play("Shoulder")
				character.aiming = true
			camera_states.SHOULDER:
				camera_state = camera_states.SCOPED
				anim_ctrl.play("ADS")
			camera_states.SCOPED:
				camera_state = camera_states.FREE
				anim_ctrl.play("Reset")
		anim_ready = false

func _on_camera_animation_finished(anim_name):
	anim_ready = true
	match anim_name:
		"Shoulder":
			camera_state = camera_states.SHOULDER
		"ADS":
			pass
		"Reset":
			freecam.get_child(0).make_current()
			character.aiming = false
			character.rig.rotation.y = character.rotation.y + 135
			character.rotation.y = 0
