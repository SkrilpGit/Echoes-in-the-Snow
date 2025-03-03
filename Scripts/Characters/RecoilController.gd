extends Node3D

var skeleton = Skeleton3D
var recoil_controller = Node3D
var recoil_offset_pos = Vector3.ZERO
var recoil_offset_rot = Vector3.ZERO
var sIKoffset_pos = Vector3.ZERO
var sIKoffset_rot = Vector3.ZERO
var char = Node3D

var fired = false

var spine_target
var spine_ik
var head_target
var head_ik

var arm_ik_r : SkeletonIK3D
var arm_tar_r : Node3D
var arm_ik_l : SkeletonIK3D
var arm_tar_l : Node3D

var strength : float

signal recoil_recovered()

func _ready():
	
	char = get_node("../..")
	skeleton = char.rig.find_child("Skeleton3D")
	recoil_controller = self
	spine_ik = skeleton.find_child("Spine_IK")
	head_ik = skeleton.find_child("Head_IK")
	recoil_offset_pos = recoil_controller.position
	recoil_offset_rot = recoil_controller.rotation
	print(recoil_controller.get_parent())
	
	strength = char.char_strength
	
	arm_ik_r = skeleton.find_child("Arm_IK_R")
	arm_ik_l = skeleton.find_child("Arm_IK_L")
	
	init_IK_Tars()
	#print("spine ",spine_target)
	#print(get_node(spine_ik.target_node))

func init_IK_Tars():
	spine_target = char.find_child("IK_target")
	head_target = find_child("Head_IK_Tar")
	arm_tar_r = find_child("Arm_IK_Tar_R")
	arm_tar_l = find_child("Arm_IK_Tar_L")
	
	sIKoffset_pos = spine_target.global_position
	sIKoffset_rot = spine_target.rotation
	
	spine_ik.target_node = spine_target.get_path()
	head_ik.target_node = head_target.get_path()
	
	arm_ik_r.target_node = arm_tar_r.get_path()
	arm_ik_l.target_node = arm_tar_l.get_path()
func init_recoil():
	var pose_form_r = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("Hand.R"))
	var pose_form_l = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("Hand.L"))
	var pose_form_h = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("Head"))
	
	arm_tar_r.transform = recoil_controller.global_transform.inverse() * pose_form_r
	arm_tar_l.transform = recoil_controller.global_transform.inverse() * pose_form_l
	head_target.transform = recoil_controller.global_transform.inverse() * pose_form_h
	
	#print(transform)
	#print(transform.inverse() * pose_form_r)
	if !arm_ik_r.is_running():
		arm_ik_r.start()
		arm_ik_l.start()
	if !head_ik.is_running():
		head_ik.start()

func _process(delta):
	if fired:
		#init_recoil()
		if recoil_controller.position.distance_to(recoil_offset_pos) > 0.05:
			var dir = recoil_controller.position - recoil_offset_pos
			var dir2 = spine_target.position - sIKoffset_pos
			dir2 = dir2.normalized()
			dir = dir.normalized()
			recoil_controller.position -= dir * (1*strength/100)*delta
			spine_target.position += dir2 * (2*strength/100)*delta
			recoil_controller.rotation = lerp(recoil_controller.rotation,recoil_offset_rot,10*delta)
			spine_target.rotation = lerp(spine_target.rotation,sIKoffset_rot,10*delta)
		elif recoil_controller.position.distance_to(recoil_offset_pos) <= 0.05:
			fired = false
			spine_target.position = Vector3.ZERO
			spine_target.rotation = sIKoffset_rot
			recoil_controller.rotation = recoil_offset_rot
			recoil_recovered.emit()
			call_deferred("stop_recoil_IK")
			
	pass
func recoil(dir: Vector3,force: float):
	#print(recoil_controller.position)
	#print(dir)
	force = force/strength
	var rot = calculate_recoil_rot(dir,force)
	recoil_controller.global_position += dir * force/2
	spine_target.global_position += dir * force
	spine_target.rotation_degrees += Vector3(-rot.x*2,-rot.y,rot.z)*5
	recoil_controller.rotation_degrees += rot
	#print(recoil_controller.rotation_degrees)
	arm_ik_r.set_interpolation(1.0)
	arm_ik_l.set_interpolation(1.0)
	head_ik.set_interpolation(1.0)
	fired = true
	pass

func calculate_recoil_rot(dir,mag):
	var rot_y = 0
	var rot_x = 0
	mag *= 5
	
	var dif = dir - position
	rot_y = dif.normalized().length() * mag
	rot_x = mag
	var final_rot = Vector3(rot_x,rot_y,0)
	return final_rot

func stop_recoil_IK():
	arm_ik_r.set_interpolation(0.0)
	arm_ik_l.set_interpolation(0.0)
	head_ik.set_interpolation(0.0)
