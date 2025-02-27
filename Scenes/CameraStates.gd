extends StateMachine

#FROM PARENT
#var state = null
#var previous_state = null
#var states = {}
#@onready var parent = get_parent()

var cam = Camera3D

func _ready():
	add_state("FREE")
	add_state("TRANSITION")
	add_state("SHOULDER")
	add_state("SCOPED")
	
	state = states.get("FREE")
	cam = parent.find_child("PlayerCam")

func _process(delta):
	#print(states.find_key(state))
	#_state_logic(delta)
	pass

func change_state(new_state : String = ""):
	#print("attempting to change state ...")
	#print("state= ",state)
	#print("states.find_key(state)= ",states.find_key(state))
	
	if new_state != "":
		set_state(states.get(new_state))
		return
	match states.find_key(state):
		"FREE":
			set_state(states.get("TRANSITION"))
		"TRANSITION":
			set_state(states.get("SHOULDER"))
		"SHOULDER":
			if parent.equipped.find_child("Scope"):
				set_state(states.get("SCOPED"))
				parent.equipped.find_child("Scope").make_current()
			else:
				set_state(states.get("FREE"))
		"SCOPED":
			set_state(states.get("FREE"))
	#print("states.find_key(state)= ",states.find_key(state))

func _state_logic(_delta):
	match states.find_key(state):
		"FREE":
			cam.camlerp(5,_delta)
		"TRANSITION":
			cam.camlerp(10,_delta)

func _exit_state(_previous_state, _new_state):
	pass

func _enter_state(_new_state, _previous_state):
	match states.find_key(_new_state):
		"FREE":
			cam.cam.make_current()
			cam.playAnim("Reset")
			parent.equipped.aiming(false)
			parent.aiming = false
		"TRANSITION":
			cam.playAnim("Shoulder")
		"SHOULDER":
			pass
		"SCOPED":
			cam.playAnim("ADS")

func add_state(state_name):
	states[state_name] = states.size()
