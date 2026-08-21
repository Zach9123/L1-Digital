extends CharacterBody2D
@export var acceleration: int = 200
@export var speed: int = 380
@warning_ignore("narrowing_conversion")
@export var jump_speed: int = -speed * 3.5
@export var gravity: int = speed * 7.5

@export var gravity_down_factor: float = 1.4

@export var dash_speed: float = 1200
@export var dash_duration: float = 0.2 
@export var dash_cooldown: float = 0.5  




var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var start_position = Vector2(579, 319)

@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var cyote_timer: Timer = $CyoteTimer

enum State{idle, walk, jump, down, dash}
var current_state: State = State.idle




func _physics_process(delta: float) -> void:
	handle_input()
	update_movement(delta)
	update_states()
	move_and_slide()
	update_animation()
	process_dash(delta) 
	
	

func handle_input() -> void: 
	if Input.is_action_just_pressed("ui_up"): 
		jump_buffer_timer.start()
		
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()
	if is_dashing:
		return
	
		
	var direction = Input.get_axis("ui_left", "ui_right") 
	
	if not is_dashing:
		if direction == 0:
			velocity.x = move_toward(velocity.x, 0, acceleration)
		else:
			velocity.x = move_toward(velocity.x, speed * direction, acceleration)
			
	if direction == 0: 
		velocity.x = move_toward(velocity.x, 0, acceleration)
	else:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
		
func update_animation() -> void:
	if velocity.x != 0:
		animations.scale.x = sign(velocity.x)
		
	match current_state:
		State.idle: animations.play("idle")
		State.jump: animations.play("jump")
		State.walk: animations.play("run")
		State.down: animations.play("down")
		
func update_movement(delta: float) -> void: 
	if (is_on_floor() || cyote_timer.time_left > 0) && jump_buffer_timer.time_left > 0: 
		velocity.y = jump_speed
		current_state = State.jump
		jump_buffer_timer.stop()
		cyote_timer.stop()
		 
	if current_state == State.jump:
		velocity.y += gravity * delta 
		if Input.is_action_just_released("ui_up") and velocity.y < 0:
			velocity.y *= 0.5 
	
	else:
		velocity.y += gravity * gravity_down_factor * delta 
	#withered kirk
func update_states() -> void: 
	match current_state:
		State.idle when velocity.x != 0:
			current_state = State.walk 
			
		State.walk:
			if velocity.x == 0:
				current_state = State.idle
			if not is_on_floor() && velocity.y > 0:
				current_state = State.down 
				cyote_timer.start()  
				
		State.jump when velocity.y > 0:
				current_state = State.down
				
				
		State.down when is_on_floor(): 
			
			if velocity.x == 0: 
				current_state = State.idle
				
			else:
				current_state = State.walk
				
func respawn():
	position = start_position
	
func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	# Dash in the direction the player is facing / pressing
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		dash_direction = Vector2(input_dir, 0).normalized()
	else:
		# Fallback to facing direction based on sprite scale
		dash_direction = Vector2(animations.scale.x, 0).normalized()

func process_dash(delta: float) -> void:
	# Update timers
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed  # Freeze Y velocity and force high horizontal velocity
		
		if dash_timer <= 0:
			is_dashing = false
			velocity.x = dash_direction.x * speed # Smooth transition back to normal speed

	# Cooldown timer
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true
		
		
