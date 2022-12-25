extends CharacterBody2D

@export var walk_speed = 4.0
const TILE_SIZE = 16

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var ray = $RayCast2D

enum AnimationStates { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var animation_state = AnimationStates.IDLE
var facing_direction = FacingDirection.DOWN

var stop_input: bool = false

var direction_keys = []

var player_state
# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	initial_position = position
	
	
func _process(delta):
	# Store direction keys in a "stack", ordered by when they're pressed
	if Input.is_action_just_pressed("ui_right"):
		direction_keys.push_back("ui_right")
	elif Input.is_action_just_released("ui_right"):
		direction_keys.erase("ui_right")
	if Input.is_action_just_pressed("ui_left"):
		direction_keys.push_back("ui_left")
	elif Input.is_action_just_released("ui_left"):
		direction_keys.erase("ui_left")
	if Input.is_action_just_pressed("ui_down"):
		direction_keys.push_back("ui_down")
	elif Input.is_action_just_released("ui_down"):
		direction_keys.erase("ui_down")
	if Input.is_action_just_pressed("ui_up"):
		direction_keys.push_back("ui_up")
	elif Input.is_action_just_released("ui_up"):
		direction_keys.erase("ui_up")
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_up"):
		direction_keys.clear()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#movement loop
	if is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false
	
	#define player state
	DefinePlayerState()

func DefinePlayerState():
	player_state = {"T": Time.get_unix_time_from_system(), "P": self.global_position}
	NetworkConnection.SendPlayerState(player_state)

func process_player_movement_input():
# Get input direction from directional key input stack
	if direction_keys.size() == 0:
		input_direction = Vector2.ZERO
	else:
		var key = direction_keys.back()
		if Input.is_action_pressed(key):
			if key == "ui_right":
				input_direction.x = 1
				input_direction.y = 0
			elif key == "ui_left":
				input_direction.x = -1
				input_direction.y = 0
			elif key == "ui_down":
				input_direction.x = 0
				input_direction.y = 1
			elif key == "ui_up":
				input_direction.x = 0
				input_direction.y = -1
			else:
				input_direction = Vector2.ZERO
		
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		
		initial_position = position
		is_moving = true
	else:
		anim_state.travel("Idle")
		
func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	
	ray.target_position = desired_step
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)	
	else:
		is_moving = false
