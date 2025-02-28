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
var last_bone_transforms = {}

signal recoil_recovered()

func _ready():
	
	char = get_node("../..")
	skeleton = char.rig.find_child("Skeleton3D")
	recoil_controller = self
	spine_ik = skeleton.find_child("Spine_IK")
	recoil_offset_pos = recoil_controller.position
	recoil_offset_rot = recoil_controller.rotation
	print(recoil_controller.get_parent())
	
	init_IK_Tars()
	#print("spine ",spine_target)
	#print(get_node(spine_ik.target_node))

func init_IK_Tars():
	spine_target = char.find_child("IK_target")
	sIKoffset_pos = spine_target.global_position
	sIKoffset_rot = spine_target.rotation
	spine_ik.target_node = spine_target.get_path()
	
	var arm_r = skeleton.find_child("Arm_IK_R")
	var arm_l = skeleton.find_child("Arm_IK_L")
	
	arm_r.target_node = recoil_controller.find_child("Arm_IK_Tar_R").get_path()
	arm_l.target_node = recoil_controller.find_child("Arm_IK_Tar_L").get_path()
func init_recoil():
	var hand_r_transform = skeleton.get_bone_global_pose(skeleton.find_bone("Hand.R"))
	var hand_l_transform = skeleton.get_bone_global_pose(skeleton.find_bone("Hand.L"))
	
	var hand_r = find_child("Arm_IK_Tar_R")
	var hand_l = find_child("Arm_IK_Tar_L")
	
	var y_offset = -2.0
	var x_rot = get_parent().rotation.x
	if x_rot < 0:
		y_offset = -2 + ((-x_rot/PI)*(-x_rot/PI))/(-x_rot/PI/2)
	#print(x_rot/PI)
	#print(y_offset)
	var mirror_basis = Basis(
		Vector3(-1, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, 0, -1)
	)
	
	var mirror_transform = Transform3D(mirror_basis,Vector3(0,y_offset,0))
	# Apply the transformations
	hand_r.transform = recoil_controller.transform * mirror_transform * halve_y_rotation(hand_r_transform)
	hand_l.transform = recoil_controller.transform * mirror_transform * halve_y_rotation(hand_l_transform)
	
	skeleton.find_child("Arm_IK_R").start()
	skeleton.find_child("Arm_IK_L").start()

# --- Halving Y rotation correctly ---
func halve_y_rotation(transform: Transform3D) -> Transform3D:
	var euler = transform.basis.get_euler()
	euler.y *= 0.5  # Halve the pitch rotation
	return Transform3D(Basis.from_euler(euler), transform.origin)  # Recreate the transform with the modified rotation

func _process(delta):
	if fired:
		if recoil_controller.position.distance_to(recoil_offset_pos) > 0.05:
			var dir = recoil_controller.position - recoil_offset_pos
			var dir2 = spine_target.position - sIKoffset_pos
			dir2 = dir2.normalized()
			dir = dir.normalized()
			recoil_controller.position -= dir * 1*delta
			spine_target.position += dir2 * 2*delta
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
	#print(dir)
	#print(recoil_controller.position)
	var rot = calculate_recoil_rot(dir,force)
	recoil_controller.global_position += dir * force/2
	spine_target.global_position += dir * force
	spine_target.rotation_degrees += Vector3(rot.x,-rot.y*2,rot.z)*10
	recoil_controller.rotation_degrees += rot
	skeleton.find_child("Arm_IK_R").set_interpolation(1.0)
	skeleton.find_child("Arm_IK_L").set_interpolation(1.0)
	fired = true
	pass

func calculate_recoil_rot(dir,mag):
	var rot_y = 0
	var rot_x = 0
	
	var dif = dir - position
	rot_y = dif.normalized().length() * mag
	rot_x = -mag
	var final_rot = Vector3(rot_x,rot_y,0)
	return final_rot

func stop_recoil_IK():
	skeleton.find_child("Arm_IK_R").set_interpolation(0.0)
	skeleton.find_child("Arm_IK_L").set_interpolation(0.0)
