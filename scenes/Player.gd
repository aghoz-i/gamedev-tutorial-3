extends CharacterBody2D

@export var gravity = 500.0
@export var walk_speed = 300
@export var fast_fall_modifier = 500
@export var jump_speed = -300
@export var dash_speed = 500
@export var dash_duration = 300

var jump_count = 0
var last_left_pressed = -1000
var last_right_pressed = -1000
var dash_timer = 0
var is_dashing = false


func _physics_process(delta):
	velocity.y += delta * gravity
	
	# fast fall
	if not is_on_floor() and Input.is_action_just_pressed('ui_down'):
		velocity.y += fast_fall_modifier
	
	if not is_on_floor() and Input.is_action_just_released('ui_down'):
		velocity.y -= fast_fall_modifier
	
	# double jump - reset double jump
	if is_on_floor():
		jump_count = 0
	
	# double jump - count jumps
	if jump_count < 2 and Input.is_action_just_pressed('ui_up'):
		jump_count += 1
		velocity.y = jump_speed
	
	# dash - stop dash when timer ends (below 0)
	if dash_timer <= 0:
		is_dashing = false

	if Input.is_action_just_pressed("ui_left") and not is_dashing:
		var current_time = Time.get_ticks_msec()
		if current_time - last_left_pressed <= 200:
			velocity.x = -dash_speed
			dash_timer = dash_duration
			is_dashing = true
		else:
			last_left_pressed = Time.get_ticks_msec()
	elif Input.is_action_just_pressed("ui_right") and not is_dashing:
		var current_time = Time.get_ticks_msec()
		if current_time - last_right_pressed <= 200:
			velocity.x = dash_speed
			dash_timer = dash_duration
			is_dashing = true
		else:
			last_right_pressed = Time.get_ticks_msec()

	if is_dashing:
		velocity.y = 0
		dash_timer -= delta*1000
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -walk_speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = walk_speed
	else:
		velocity.x = 0

	# "move_and_slide" already takes delta time into account.
	move_and_slide()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
