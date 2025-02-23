extends Node
class_name StateMachine

var state = null
var previous_state = null
var states = {}
@onready var parent = get_parent()

func _state_logic(_delta):
	pass

func set_state(new_state):
	#breakpoint
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)
	previous_state = state
	state = new_state


func _exit_state(_previous_state, _new_state):
	pass

func _enter_state(_new_state, _previous_state):
	pass

func add_state(state_name):
	states[state_name] = states.size()
