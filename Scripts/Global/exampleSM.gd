extends StateMachine

var at_destination: bool = true
var time_delay: float = 0
var timer: Timer
var hitbox: CollisionShape2D

var action_queue = []
@export var WAIT_TIME = 0.05

var CollisionHandler = Node
var AnimationController = Node

var original_move_order = Vector2.ZERO
@onready var corpse = preload("res://Scenes/corpse_placeholder.tscn")

enum Commands {
	NONE,
	MOVE,
	ATTACK_MOVE,
	HOLD
}
var command = Commands.NONE

func _ready():
	add_state("idle")
	add_state("attacking")
	add_state("avoiding")
	add_state("moving")
	add_state("engaging")
	add_state("dying")
	call_deferred("set_state", states.idle)
	time_delay = WAIT_TIME + randf_range(0.001,0.05)
	timer = $Timer
	hitbox = get_node(String(parent.get_path())+"/Hitbox")
	CollisionHandler = get_node(String(get_path())+"/UnitCollisionHandler")
	AnimationController = get_node(String(get_path())+"/AnimationController")
	
func get_previous_state():
	return previous_state

func set_original_move_order():
	original_move_order = parent.get_move_target()

func set_command(cmd):
	command = cmd

func queue(order:String,tar):
	action_queue.append([order,tar,false])

func clear_queue():
	action_queue = []

func queue_next(order:String,tar):
	var temp = []
	temp.append([order,tar,false])
	for i in action_queue:
		temp.append(i)
	action_queue.assign(temp)

func get_timer_stopped():
	return timer.is_stopped()

func start_timer(time:float=time_delay):
	timer.start(time)

func progress_action_queue():
	start_timer()
	match action_queue[0][0]:
		"move":
			set_state(states.moving)
			command = Commands.MOVE
			parent.move_to(action_queue[0][1],action_queue[0][2])
			action_queue.erase(action_queue[0])
		"avoid":
			set_state(states.moving)
			parent.move_to(action_queue[0][1],action_queue[0][2])
			action_queue.erase(action_queue[0])

func _enter_state(new_state, _previous_state):
	match new_state:
		states.idle:
			AnimationController.set_animation("idle")
		states.attacking:
			AnimationController.set_animation("attack")
		states.avoiding:
			AnimationController.set_animation("walk")
			start_timer()
			if new_state == states.avoiding and state == states.avoiding:
				print("double avoid! ", state, _previous_state, new_state)
				state = _previous_state
		states.moving:
			AnimationController.set_animation("walk")
		
		states.engaging:
			AnimationController.set_animation("walk")
			if parent.attack_target.get_ref() != null:
				parent.move_to(parent.attack_target.get_ref().position,false)
			else:
				parent.move_to(parent.position,false)
				set_state(states.idle)
		
		states.dying:
			var instance = corpse.instantiate()
			if get_node("/root/Game/").has_node("/root/Game/"+parent.get_team()):
				var player = get_node(String("/root/Game/"+parent.get_team()))
				if parent in player.selected:
					player.selected.erase(parent)
			parent.get_parent().add_child(instance)
			instance.position = parent.position
			parent.queue_free()

func _exit_state(_previous_state, _new_state):
	match _previous_state:
		states.idle:
			pass
		states.attacking:
			pass
		states.avoiding:
			pass
		states.moving:
			pass
		
		states.engaging:
			pass
		
		states.dying:
			pass

func _get_transition(_delta):
	match state:
		states.idle:
			if command != Commands.HOLD:
				if !at_destination:
					set_state(states.moving)
				if parent.closest_enemy() != null:
					parent.attack_target = weakref(parent.closest_enemy())
					set_state(states.engaging)
			else:
				if !at_destination:
					set_state(states.moving)
				if parent.closest_enemy_within_range() != null:
					parent.attack_target = weakref(parent.closest_enemy())
					set_state(states.attacking)
		states.attacking:
			if parent.attack_target.get_ref() == null:
				set_state(states.idle)
			elif parent.attack_target.get_ref() != parent.closest_enemy_within_range():
				if command == Commands.HOLD:
					set_state(states.idle)
				else:
					set_state(states.engaging)
		states.avoiding:
			if get_timer_stopped():
				set_state(previous_state)
		states.moving:
			if command == Commands.ATTACK_MOVE and parent.closest_enemy() != null:
				parent.attack_target = weakref(parent.closest_enemy())
				queue_next("move",parent.get_move_target())
				set_state(states.engaging)
			if at_destination:
				parent.move_to(parent.position,false)
				set_state(states.idle)
		states.engaging:
			if parent.closest_enemy_within_range() != null:
				parent.attack_target = weakref(parent.closest_enemy())
				set_state(states.attacking)
			elif parent.attack_target.get_ref() == null:
				parent.move_to(parent.position,false)
				set_state(states.idle)
		states.dying:
			pass

func _state_logic(_delta):
	parent.collision_mask = 0b11
	
	var anim_moving_speed = (parent.param_manager.get_speed()*0.2)/(parent.hitbox.shape.radius)
	
	match state:
		states.idle:
			CollisionHandler.handle_idle_unit_collisions(parent)
			AnimationController.update(parent)
			if action_queue.size() > 0 and get_timer_stopped():
				progress_action_queue()
			
		states.attacking:
			if get_timer_stopped() and parent.attack_target.get_ref() != null and parent.attack_target.get_ref() == parent.closest_enemy_within_range():
				start_timer(parent.param_manager.get_attack_speed())
				parent.attack(parent.attack_target)
				#FPS = frame.count()/attack_speed
				AnimationController.update(parent,1/parent.param_manager.get_attack_speed(),parent.get_direction_to_attack_target())
			
		states.avoiding:
			parent.collision_mask = 0b01
			AnimationController.update(parent,anim_moving_speed,parent.get_move_direction())
			
		states.moving:
			var move_direction = parent.get_direction_to_move_target()
			parent.set_move_direction(move_direction)
			if !at_destination:
				AnimationController.update(parent,anim_moving_speed,parent.get_move_direction())
			CollisionHandler.handle_moving_unit_collisions(parent)
		
		states.engaging:
			var move_direction = parent.get_direction_to_attack_target()
			parent.set_move_direction(move_direction)
			AnimationController.update(parent,anim_moving_speed,parent.get_move_direction())
			CollisionHandler.handle_moving_unit_collisions(parent)
		
		states.dying:
			pass
	
