extends StateMachine

#FROM PARENT
#var state = null
#var previous_state = null
#var states = {}
#@onready var parent = get_parent()

func _ready():
	add_state("FREE")
	add_state("TRANSITION")
	add_state("SHOULDER")
	add_state("SCOPE")
	
	state = states.get("FREE")

func change_state():
	#print("attempting to change state ...")
	#print("state= ",state)
	#print("states.find_key(state)= ",states.find_key(state))
	match states.find_key(state):
		"FREE":
			set_state(states.get("TRANSITION"))
		"TRANSITION":
			set_state(states.get("SHOULDER"))
		"SHOULDER":
			set_state(states.get("SCOPE"))
		"SCOPE":
			set_state(states.get("FREE"))

func _state_logic(_delta):
	pass

func _exit_state(_previous_state, _new_state):
	pass

func _enter_state(_new_state, _previous_state):
	pass

func add_state(state_name):
	states[state_name] = states.size()
