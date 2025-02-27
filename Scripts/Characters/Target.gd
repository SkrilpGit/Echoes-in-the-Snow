extends Node3D

@export var anim_ctrl : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func hit():
	print("ow")
	anim_ctrl.play("Fall")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Fall":
		anim_ctrl.play("Reset")
