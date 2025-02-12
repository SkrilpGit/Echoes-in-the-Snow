extends Camera3D

@export var zoom_max = 10
@export var zoom_min = 0.1
@export var zoom_step = 0.5

@export var HUD : Node2D
@export var MODE : Label
@export var mag : Label
@export var elev : Label
@export var wind : Label

enum mode{
	ELEVATION,
	WINDAGE,
	MAGNIFICATION
}
var scope_mode = mode.MAGNIFICATION

var input_enabled = false

func _input(_event):
	if input_enabled:
		if Input.is_action_just_pressed("increment"):
			increment(true)
		if Input.is_action_just_pressed("decrement"):
			increment(false)
		if Input.is_action_just_pressed("change_mode"):
			change_mode()

func _ready():
	MODE.set_text("Mode: MAGNIFICATION")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(state )
	
	if current:
		input_enabled = true
		HUD.visible = true
	else:
		input_enabled = false
		HUD.visible = false
	
	mag.set_text("Magnification: "+str(fov))
	elev.set_text("Elevation: "+str(rotation_degrees.x))
	wind.set_text("Windage: "+str(rotation_degrees.y))

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
	print(fov)
	var zoom = fov
	var step = snapped((zoom / 10),zoom_step)
	if step == 0:
		step += zoom_step
	
	if In and zoom > zoom_min:
		zoom -= step
	elif !In and zoom < zoom_max:
		zoom += step
	
	if zoom > zoom_max:
		zoom = zoom_max
	elif zoom < zoom_min:
		zoom = zoom_min
	fov = zoom

func Elevate(up):
	if up:
		rotation_degrees.x += 0.05
	else:
		rotation_degrees.x -= 0.05

func Wind(right):
	if right:
		rotation_degrees.y += 0.01
	else:
		rotation_degrees.y -= 0.01

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
