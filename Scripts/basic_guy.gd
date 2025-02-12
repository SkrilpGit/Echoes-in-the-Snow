extends Node3D

@export var anim_ctrl = AnimationPlayer
@export var spine_ik = SkeletonIK3D.new()
@export var left_hand : BoneAttachment3D
@export var right_hand : BoneAttachment3D

var equipped : Node3D

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
	if equipped.has_method("fire"):
		equipped.fire()

func chamber():
	if equipped.has_method("chamber"):
		equipped.chamber()

func _on_animation_finished(_anim_name):
	pass 
