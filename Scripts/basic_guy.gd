extends Node3D

@export var anim_ctrl = AnimationPlayer.new()
@export var spine_ik = SkeletonIK3D.new()

enum states{
	FIRED,
	CHAMBERING,
	READY
}
var state = states.READY
var anim_queue = []

func _ready():
	pass
func _input(event):
	if Input.is_action_just_pressed("fire") and state == states.READY:
		if anim_ctrl.get_animation("basic_guy/Idle_Upper"):
			anim_ctrl.play("basic_guy/Fire_Upper")
		elif anim_queue.is_empty():
			anim_queue.append("basic_guy/Fire_Upper")
		state = states.FIRED
		#print("bang!")
	elif Input.is_action_just_released("fire") and state == states.FIRED:
		if anim_ctrl.current_animation == "":
			anim_ctrl.play("basic_guy/Chamber_Spent_Upper")
		elif anim_queue.is_empty():
			anim_queue.append("basic_guy/Chamber_Spent_Upper")
		state = states.CHAMBERING
		#print("clink! clonk!")
		

func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"basic_guy/Fire_Upper":
			anim_ctrl.play("basic_guy/Idle_Upper")
		"basic_guy/Chamber_Spent_Upper":
			anim_ctrl.play("basic_guy/Idle_Upper")
			state = states.READY
		"basic_guy/Idle_Upper":
			if !anim_queue.is_empty():
				anim_ctrl.play(anim_queue[0])
				anim_queue = []
