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

func _state_logic(_delta):
	pass

func _exit_state(_previous_state, _new_state):
	pass

func _enter_state(_new_state, _previous_state):
	pass

func add_state(state_name):
	states[state_name] = states.size()
