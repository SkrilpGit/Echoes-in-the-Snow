extends Node3D

var anim_ready = true

@export var anim_ctrl : AnimationPlayer
@export var character : CharacterBody3D
@export var cam : Camera3D
@export var HUD : Node2D
@export var MOUSE_SENSE = 0.001
var mouse_sensitivity = 0.1

var zoom_max = 75
var zoom_min = 0.1
@export var zoom_step = 0.5

@export var offset = Vector3.ZERO

var scope = null

enum states{
	FREE,
	TRANSITION,
	SHOULDER,
	SCOPED
}
enum mode{
	ELEVATION,
	WINDAGE,
	MAGNIFICATION
}
var scope_mode = mode.MAGNIFICATION

var state = states.FREE

var input_enabled = true

func _input(event):
	if event is InputEventMouseMotion and input_enabled:
		var cam_rot = rotation_degrees
		cam_rot.x = clamp(cam_rot.x - event.relative.y * mouse_sensitivity, -85, 85)
		cam_rot.y += -event.relative.x * mouse_sensitivity
		rotation_degrees = cam_rot

func _ready():
	scope = character.rig.equipped

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(state )
	mouse_sensitivity = get_viewport().get_camera_3d().fov * MOUSE_SENSE
	match state:
		states.FREE:
			var tarPos = character.position + offset
			position = lerp(position,tarPos,5*delta)
		states.TRANSITION:
			var tarPos = character.position + offset
			position = lerp(position,tarPos,5*delta)

func aim():
	if anim_ready:
		anim_ready = false
		match state:
			states.FREE:
				state = states.TRANSITION
				anim_ctrl.play("Shoulder")
			states.SHOULDER:
				if scope.find_child("Scope"):
					state = states.SCOPED
					scope.find_child("Scope").make_current()
					anim_ctrl.play("ADS")
					HUD.visible = false
				else:
					state = states.FREE
					anim_ctrl.play("Reset")
					HUD.visible = false
			states.SCOPED:
				state = states.FREE
				cam.make_current()
				anim_ctrl.play("Reset")
				HUD.visible = false
		

func _on_animation_finished(anim_name):
	anim_ready = true
	cam.rotation = Vector3.ZERO
	match anim_name:
		"Shoulder":
			character.aiming = true
			state = states.SHOULDER
			HUD.visible = true
		"ADS":
			anim_ready = true
		"Reset":
			character.aiming = false
