extends Node3D

@export var barrel_length = 610 # ~ 24 inch barrel
@export var gun_weight = 4.5 # weight in kg
@export var anim_ctrl = AnimationPlayer.new()
@export var rig_anim_lib = AnimationLibrary

@export var bullet: PackedScene
@export var casing : PackedScene

@export var node : Node3D

@onready var b_spawn = $Spawn_Bullet
@onready var c_spawn = $Spawn_Casing

@onready var rig_anim = AnimationPlayer.new()
var character
var bullet_instance = null

enum states{
	FIRED,
	CHAMBERING,
	READY
}
var state = states.READY
var anim_queue = []

var recoil_controller
var RTC = true

func _ready():
	#find the node that controls this characters behaviour
	# k31-55 -> bone attach -> skeleton -> armature -> rig -> body3D -> character
	#e.g. Player
	character = get_node("../../../../../..")
	print(character)
	character.fire_pressed.connect(self.fire)
	character.fire_released.connect(self.chamber)
	recoil_controller = character.find_child("RecoilController")
	recoil_controller.recoil_recovered.connect(self.recovered)
	
	
	rig_anim.name = "RigPlayer"
	add_child(rig_anim)
	# find the node that is 4 parents above me;
	# k31-55 -> bone attach -> skeleton -> armature -> rig
	rig_anim.root_node = get_node("../../../..").get_path()
	rig_anim.add_animation_library("K31_anims",rig_anim_lib)
	#print(rig_anim.get_animation_list())
	#print(get_node(rig_anim.root_node))
	rig_anim.speed_scale = anim_ctrl.speed_scale
	rig_anim.play("K31_anims/Idle_Upper")

func _process(delta):
		pass

func fire():
	if state == states.READY:
		if anim_ctrl.current_animation == "Idle":
			anim_ctrl.play("Fire")
			rig_anim.play("K31_anims/Fire_Upper")
		else:
			anim_ctrl.queue("Fire")
			rig_anim.queue("K31_anims/Fire_Upper")
		state = states.FIRED
		RTC = false

func chamber():
	if state == states.FIRED:
		if RTC:
			anim_ctrl.queue("Chamber_Spent")
			rig_anim.queue("K31_anims/Chamber_Spent_Upper")
		else:
			anim_queue.append("Chamber_Spent")
		state = states.CHAMBERING
		

func recovered():
	RTC = true
	if !anim_queue.is_empty():
		if anim_queue[0] == "Chamber_Spent":
			anim_queue = []
			anim_ctrl.queue("Chamber_Spent")
			rig_anim.queue("K31_anims/Chamber_Spent_Upper")
	pass

func aiming(yes):
	if yes:
		if state == states.CHAMBERING:
			state = states.READY
		if anim_ctrl.current_animation == "Idle":
			anim_ctrl.play("Idle")
			rig_anim.play("K31_anims/Aiming_Upper")
		else:
			anim_ctrl.queue("Idle")
			rig_anim.queue("K31_anims/Aiming_Upper")
	else:
		#print(anim_ctrl.current_animation)
		if anim_ctrl.current_animation == "Idle":
			anim_ctrl.play("Idle")
			rig_anim.play("K31_anims/Idle_Upper")
		else:
			anim_ctrl.queue("Idle")
			rig_anim.queue("K31_anims/Idle_Upper")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Fire":
			anim_ctrl.play("Idle")
			rig_anim.play("K31_anims/Aiming_Upper")
		"Chamber_Spent":
			#print("RTF!")
			anim_ctrl.play("Idle")
			rig_anim.play("K31_anims/Aiming_Upper")
			state = states.READY
		"Idle":
			pass

func recoil():
	#print("HIIII")
	recoil_controller.init_recoil()
	
	var recoil_pos = Vector3(position.x,b_spawn.position.y-0.1,position.z)
	var dir = b_spawn.global_position - to_global(recoil_pos)
	# calculate recoil force :)
	var force
	if bullet_instance != null:
		#KE = 1/2mv^2 
		var mass = bullet_instance.bullet_weight / 1000 # mass in kilos
		# bullet from rest to muzzle_velocity in a time determined by the barrel length
		var KE = 0.5*mass*pow(bullet_instance.muzzle_velocity,2)
		force = sqrt(2*KE/gun_weight)
		print(force)
	else:
		print("error: bullet not found")
		force = 0.5
	recoil_controller.recoil(-dir,force)
	pass

func spawn_bullet():
	bullet_instance = bullet.instantiate()
	#instance.global_position = b_spawn.global_position
	bullet_instance.global_transform = b_spawn.global_transform
	var direction = b_spawn.global_position - global_position
	bullet_instance.dir = direction
	bullet_instance.creator = owner
	get_tree().get_root().add_child.call_deferred(bullet_instance)
	#print("bullet b_spawned")

func eject_casing():
	var instance = casing.instantiate()
	get_tree().get_root().add_child(instance)
	#instance.global_position = b_spawn.global_position
	instance.global_transform = c_spawn.global_transform
	var dir = instance.global_position - global_position
	dir.normalized()
	dir = Vector3(dir.x,dir.y/2,dir.z)
	instance.apply_impulse(dir*30)
	var random_torque = Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10))
	instance.apply_torque_impulse(random_torque)
	#print(random_torque)
