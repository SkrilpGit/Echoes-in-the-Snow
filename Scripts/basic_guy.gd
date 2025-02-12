extends Node3D

@export var anim_ctrl = AnimationPlayer.new()
@export var spine_ik = SkeletonIK3D.new()
@export var left_hand : BoneAttachment3D
@export var right_hand : BoneAttachment3D

var equipped : Node3D

enum upper{
	FIRED,
	CHAMBERING,
	READY
}
var Ustate = upper.READY
var anim_queue = []

func _ready():
	if left_hand.get_child_count() > 0:
		equipped = left_hand.get_children()[0]
	elif right_hand.get_child_count() > 0:
		equipped = right_hand.get_children()[0]

func S_IK(start):
	if start:
		spine_ik.start()
	else:
		spine_ik.stop()

func fire():
	if Ustate == upper.READY:
		if anim_ctrl.get_animation("basic_guy/Idle_Upper"):
			anim_ctrl.play("basic_guy/Fire_Upper")
		elif anim_queue.is_empty():
			anim_queue.append("basic_guy/Fire_Upper")
		Ustate = upper.FIRED
		if equipped.has_method("fire"):
			equipped.fire()

func chamber():
	if Ustate == upper.FIRED:
		if anim_ctrl.current_animation == "":
			anim_ctrl.play("basic_guy/Chamber_Spent_Upper")
		elif anim_queue.is_empty():
			anim_queue.append("basic_guy/Chamber_Spent_Upper")
		Ustate = upper.CHAMBERING
		if equipped.has_method("chamber"):
			equipped.chamber()

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"basic_guy/Fire_Upper":
			anim_ctrl.play("basic_guy/Idle_Upper")
		"basic_guy/Chamber_Spent_Upper":
			anim_ctrl.play("basic_guy/Idle_Upper")
			Ustate = upper.READY
		"basic_guy/Idle_Upper":
			if !anim_queue.is_empty():
				anim_ctrl.play(anim_queue[0])
				anim_queue = []
