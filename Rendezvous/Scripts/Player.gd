extends CharacterBody2D

# --- CAMERA & DIALOGUE VARIABLES ---
@onready var camera: Camera2D = $Camera2D 
var default_zoom: Vector2 = Vector2(1, 1)
var camera_tween: Tween
var in_dialogue: bool = false
# -----------------------------------

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

# Add a boolean to track if the player is currently dying
var is_dead: bool = false

func _ready() -> void:
	if camera:
		default_zoom = camera.zoom

func _physics_process(delta: float) -> void:
	# If dead, stop processing inputs and normal states
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, acceleration) # Stop horizontal movement
		velocity.y += gravity * delta # Still apply gravity so they fall if they die mid-air
		move_and_slide()
		return
		
	handle_input()
	update_movement(delta)
	update_states()
	move_and_slide()
	check_hazards() 
	update_animation()
	process_dash(delta)

func check_hazards() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Make sure we don't trigger die() repeatedly if already dead
		if collider and collider.name == "Spikes_obstacles" and not is_dead:
			die()

# --- NEW DEATH FUNCTION ---
func die() -> void:
	is_dead = true
	animations.play("death")
	
	# Wait for the death animation to finish completely before moving on
	await animations.animation_finished
	respawn()
# --------------------------

func respawn():
	position = start_position
	# Reset states so the player can move normally again
	is_dead = false
	current_state = State.idle

func handle_input() -> void: 
	if in_dialogue:
		velocity.x = move_toward(velocity.x, 0, acceleration)
		return

	if Input.is_action_just_pressed("ui_up"): 
		jump_buffer_timer.start()
		
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()
		
	if is_dashing:
		return
	
	var direction = Input.get_axis("ui_left", "ui_right") 
	
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, acceleration)
	else:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
		
func update_animation() -> void:
	if is_dead: return # <--- THIS PREVENTS OVERWRITING THE DEATH ANIMATION

	if velocity.x != 0:
		animations.scale.x = sign(velocity.x)
		
	match current_state:
		State.idle: animations.play("idle")
		State.jump: animations.play("jump")
		State.walk: animations.play("run")
		State.down: animations.play("down")
		State.dash: animations.play("dash")
		
func update_movement(delta: float) -> void: 
	if is_dashing:
		return 

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

func update_states() -> void: 
	if is_dashing:
		return 

	match current_state:
		State.idle:
			if velocity.x != 0:
				current_state = State.walk 
			elif not is_on_floor():
				current_state = State.down
				cyote_timer.start()
			
		State.walk:
			if velocity.x == 0:
				current_state = State.idle
			elif not is_on_floor() && velocity.y > 0:
				current_state = State.down 
				cyote_timer.start()  
				
		State.jump when velocity.y > 0:
				current_state = State.down
				
		State.down when is_on_floor(): 
			if velocity.x == 0: 
				current_state = State.idle
			else:
				current_state = State.walk
				
func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	current_state = State.dash
	
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		dash_direction = Vector2(input_dir, 0).normalized()
	else:
		dash_direction = Vector2(animations.scale.x, 0).normalized()

func process_dash(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed 
		
		if dash_timer <= 0:
			is_dashing = false
			velocity.x = dash_direction.x * speed 
			
			if is_on_floor():
				current_state = State.idle
			else:
				current_state = State.down

	if not can_dash and not is_dashing:
		if is_on_floor():
			can_dash = true

func focus_camera(target_global_pos: Vector2, target_zoom: Vector2 = Vector2(2.5, 2.5)) -> void:
	if not camera: return
	if camera_tween and camera_tween.is_valid():
		camera_tween.kill()
		
	camera_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	var target_offset = target_global_pos - global_position
	camera_tween.tween_property(camera, "offset", target_offset, 0.5)
	camera_tween.tween_property(camera, "zoom", target_zoom, 0.5)

func reset_camera() -> void:
	if not camera: return
	if camera_tween and camera_tween.is_valid():
		camera_tween.kill()
		
	camera_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_property(camera, "offset", Vector2.ZERO, 0.5)
	camera_tween.tween_property(camera, "zoom", default_zoom, 0.5) 
