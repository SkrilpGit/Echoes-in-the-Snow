extends Node3D


var counter = 0
var anim_ready = true

@export var anim_ctrl : AnimationPlayer
@export var character : CharacterBody3D
@export var cam : Camera3D
@export var MOUSE_SENSE = 0.001
var mouse_sensitivity = 0.1

var viewport_size = Vector2.ZERO
var screen_size = Vector2.ZERO
var zoom_max = 75
var zoom_min = 0.1
@export var zoom_step = 0.5

@export var MODE : Label
@export var mag : Label
@export var elev : Label
@export var wind : Label

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(state )
	if state == states.FREE or state == states.TRANSITION:
		position = lerp(position,character.position,5*delta)
	
	mag.set_text("Magnification: "+str(cam.fov))
	elev.set_text("Elevation: "+str(cam.rotation_degrees.x))
	wind.set_text("Windage: "+str(cam.rotation_degrees.y))

func aim():
	if anim_ready:
		match state:
			states.FREE:
				state = states.TRANSITION
				anim_ctrl.play("Shoulder")
			states.SHOULDER:
				state = states.SCOPED
				anim_ctrl.play("ADS")
			states.SCOPED:
				state = states.FREE
				anim_ctrl.play("Reset")
		anim_ready = false

func screen_size_changed():
	var zoom = cam.fov
	mouse_sensitivity = cam.fov * MOUSE_SENSE
	screen_size = Vector2(viewport_size.x/zoom,viewport_size.y/zoom)

func increment(inc):
	match scope_mode:
		mode.MAGNIFICATION:
			Zoom(inc)
		mode.ELEVATION:
			Elevate(inc)
		mode.WINDAGE:
			Wind(inc)

func Zoom(In):
	print(zoom_step)
	print(cam.fov)
	print(mouse_sensitivity)
	var zoom = cam.fov
	var step = snapped((zoom / 10),zoom_step)
	if step == 0:
		step += zoom_step
	
	if In and zoom > zoom_min:
		zoom -= step
		mouse_sensitivity -= 0.001
	elif !In and zoom < zoom_max:
		zoom += step
		mouse_sensitivity += 0.001
	
	if zoom > zoom_max:
		zoom = zoom_max
	elif zoom < zoom_min:
		zoom = zoom_min
	cam.fov = zoom
	screen_size_changed()

func Elevate(up):
	if up:
		cam.rotation_degrees.x += 0.05
	else:
		cam.rotation_degrees.x -= 0.05

func Wind(right):
	if right:
		cam.rotation_degrees.y += 0.01
	else:
		cam.rotation_degrees.y -= 0.01

func change_mode():
	match scope_mode:
		mode.MAGNIFICATION:
			scope_mode = mode.ELEVATION
			MODE.set_text("Mode: ELEVATON")
		mode.ELEVATION:
			scope_mode = mode.WINDAGE
			MODE.set_text("Mode: WINDAGE")
		mode.WINDAGE:
			scope_mode = mode.MAGNIFICATION
			MODE.set_text("Mode: MAGNIFICATION")
	print(scope_mode)

func _on_animation_finished(anim_name):
	anim_ready = true
	cam.rotation = Vector3.ZERO
	match anim_name:
		"Shoulder":
			character.aiming = true
			state = states.SHOULDER
			mouse_sensitivity = cam.fov * MOUSE_SENSE
			print(mouse_sensitivity)
		"ADS":
			mouse_sensitivity = cam.fov * MOUSE_SENSE
			print(mouse_sensitivity)
		"Reset":
			character.aiming = false
			mouse_sensitivity = cam.fov * MOUSE_SENSE
			print(mouse_sensitivity)
