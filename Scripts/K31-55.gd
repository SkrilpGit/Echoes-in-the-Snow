extends Node3D

@export var anim_ctrl = AnimationPlayer.new()
@export var rig_anim_lib = AnimationLibrary

@export var bullet: PackedScene
@export var casing : PackedScene

@export var node : Node3D

@onready var b_spawn = $Spawn_Bullet
@onready var c_spawn = $Spawn_Casing

@onready var rig_anim = AnimationPlayer.new()
var character

enum states{
	FIRED,
	CHAMBERING,
	READY
}
var state = states.READY
var anim_queue = []

func _ready():
	#find the node that controls this characters behaviour
	# k31-55 -> bone attach -> skeleton -> armature -> rig -> body3D -> character
	#e.g. Player
	character = get_node("../../../../..")
	print(character)
	character.fire_pressed.connect(self.fire)
	character.fire_released.connect(self.chamber)
	
	
	rig_anim.name = "RigPlayer"
	add_child(rig_anim)
	# find the node that is 4 parents above me;
	# k31-55 -> bone attach -> skeleton -> armature -> rig
	rig_anim.root_node = get_node("../../../..").get_path()
	rig_anim.add_animation_library("K31_anims",rig_anim_lib)
	#print(rig_anim.get_animation_list())
	#print(get_node(rig_anim.root_node))
	rig_anim.speed_scale = anim_ctrl.speed_scale

func spawn_bullet():
	var instance = bullet.instantiate()
	#instance.global_position = b_spawn.global_position
	instance.global_transform = b_spawn.global_transform
	var direction = b_spawn.global_position - global_position
	instance.dir = direction
	instance.creator = owner
	get_tree().get_root().add_child.call_deferred(instance)
	#print("bullet b_spawned")

func fire():
	if state == states.READY:
		if anim_ctrl.get_animation("Idle"):
			anim_ctrl.play("Fire")
			rig_anim.play("K31_anims/Fire_Upper")
		elif anim_ctrl.get_queue().is_empty():
			anim_ctrl.queue("Fire")
			rig_anim.queue("K31_anims/Fire_Upper")
		state = states.FIRED

func chamber():
	if state == states.FIRED:
		if anim_ctrl.current_animation == "":
			anim_ctrl.play("Chamber_Spent")
			rig_anim.play("K31_anims/Chamber_Spent_Upper")
		elif anim_ctrl.get_queue().is_empty():
			anim_ctrl.queue("Chamber_Spent")
			rig_anim.queue("K31_anims/Chamber_Spent_Upper")
		state = states.CHAMBERING
		

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Fire":
			anim_ctrl.play("Idle")
			rig_anim.play("K31_anims/Aiming_Upper")
		"Chamber_Spent":
			anim_ctrl.play("Idle")
			rig_anim.play("K31_anims/Aiming_Upper")
			state = states.READY
		"Idle":
			pass

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
	print(random_torque)
