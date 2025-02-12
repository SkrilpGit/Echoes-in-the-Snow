extends Node3D

@export var anim_ctrl = AnimationPlayer.new()

@export var spawn = Node3D
@export var bullet: PackedScene

enum states{
	FIRED,
	CHAMBERING,
	READY
}
var state = states.READY
var anim_queue = []

func spawn_bullet():
	var instance = bullet.instantiate()
	#instance.global_position = spawn.global_position
	instance.global_transform = spawn.global_transform
	var direction = spawn.global_position - global_position
	instance.dir = direction
	instance.creator = owner
	get_tree().get_root().add_child.call_deferred(instance)
	print("bullet spawned")

func fire():
	if state == states.READY:
		if anim_ctrl.get_animation("Idle"):
			anim_ctrl.play("Fire")
		elif anim_queue.is_empty():
			anim_queue.append("Fire")
		state = states.FIRED

func chamber():
	if state == states.FIRED:
		if anim_ctrl.current_animation == "":
			anim_ctrl.play("Chamber_Spent")
		elif anim_queue.is_empty():
			anim_queue.append("Chamber_Spent")
		state = states.CHAMBERING

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Fire":
			anim_ctrl.play("Idle")
		"Chamber_Spent":
			anim_ctrl.play("Idle")
			state = states.READY
		"Idle":
			if !anim_queue.is_empty():
				anim_ctrl.play(anim_queue[0])
				anim_queue = []
