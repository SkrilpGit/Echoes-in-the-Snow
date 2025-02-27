extends Node3D

@export var anim_ctrl = AnimationPlayer.new()
@export var spine_ik = SkeletonIK3D.new()
@export var left_hand : BoneAttachment3D
@export var right_hand : BoneAttachment3D

@export var anim_speed : float

var anim_queue = []
var skeleton = Skeleton3D
var recoil_bones = Node3D
var recoil_offset = Vector3.ZERO
var char = Node3D

func _ready():
	
	char = get_node("../..")
	skeleton = $Armature/Skeleton3D
	recoil_bones = $"Armature/Skeleton3D/Recoil Bones"
	recoil_offset = recoil_bones.position
	print(recoil_offset)
	
	if left_hand.get_child_count() > 0:
		char.equipped = left_hand.get_children()[0]
	elif right_hand.get_child_count() > 0:
		char.equipped = right_hand.get_children()[0]

func init_recoil():
	var hand_r_transform = skeleton.get_bone_global_pose(skeleton.find_bone("Hand.R"))
	var hand_r = skeleton.find_child("Arm_IK_Tar_R")
	hand_r.transform = hand_r_transform
	skeleton.find_child("Arm_IK_R").start()
	
	var hand_l_transform = skeleton.get_bone_global_pose(skeleton.find_bone("Hand.L"))
	var hand_l = skeleton.find_child("Arm_IK_Tar_L")
	hand_l.transform = hand_l_transform
	skeleton.find_child("Arm_IK_L").start()
	
	pass

func _process(delta):
	if recoil_bones.position != recoil_offset:
		recoil_bones.position = lerp(recoil_bones.position,recoil_offset,5*delta)
	elif recoil_bones.position == recoil_offset:
		skeleton.find_child("Arm_IK_R").stop()
		skeleton.find_child("Arm_IK_L").stop()
	pass

func recoil(dir: Vector3,force: float):
	#print(dir," ",force)
	print(recoil_bones.position)
	recoil_bones.global_position += dir * force
	pass

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
	if anim_ctrl.current_animation != "movement_anims/move_left_standing":
		anim_ctrl.play("movement_anims/move_left_standing")
		anim_ctrl.speed_scale = anim_speed

func stand_still():
	anim_ctrl.play("movement_anims/idle_standing")

func _on_animation_finished(_anim_name):
	pass 
