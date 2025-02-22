extends Node3D

@export var anim_ctrl = AnimationPlayer.new()
@export var spine_ik = SkeletonIK3D.new()
@export var left_hand : BoneAttachment3D
@export var right_hand : BoneAttachment3D

@export var anim_speed : float

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

func move_forward():
	if anim_ctrl.current_animation != "movement_anims/move_forward_standing":
		anim_ctrl.play("movement_anims/move_forward_standing")
		anim_ctrl.speed_scale = anim_speed

func move_backward():
	if anim_ctrl.current_animation != "movement_anims/move_forward_standing":
		anim_ctrl.play("movement_anims/move_forward_standing")
		anim_ctrl.seek(anim_ctrl.current_animation_length, true)
		anim_ctrl.speed_scale = -anim_speed

func move_right():
	if anim_ctrl.current_animation != "movement_anims/move_right_standing":
		anim_ctrl.play("movement_anims/move_right_standing")
		anim_ctrl.speed_scale = anim_speed

func move_left():
	if anim_ctrl.current_animation != "movement_anims/move_right_standing":
		anim_ctrl.play("movement_anims/move_right_standing")
		anim_ctrl.seek(anim_ctrl.current_animation_length, true)
		anim_ctrl.speed_scale = -anim_speed

func stand_still():
	anim_ctrl.play("movement_anims/idle_standing")

func _on_animation_finished(_anim_name):
	pass 
