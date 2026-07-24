extends CharacterBody2D
@export var acceleration: int = 15
@export var speed: int = 150
@export var jump_speed: int = -speed * 2.8
@export var gravity: int = speed * 4
@export var gravity_down_factor: float = 2.5

@onready var jump_buffer_timer: Timer = $JumpBufferTimer

enum State{idle, walk, jump, down}
var current_state: State = State.idle

func _physics_process(delta: float) -> void:
	handle_input()
	move_and_slide()
	update_movement(delta)
	update_states()
	
func handle_input() -> void: 
	if Input.is_action_just_pressed("ui_up") and is_on_floor(): 
		velocity.y = jump_speed
		current_state == State.jump
		
	var direction = Input.get_axis("ui_left", "ui_right") 
	if direction == 0: 
		velocity.x = move_toward(velocity.x, 0, acceleration)
	else:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
		

func update_movement(delta: float) -> void: 
	if current_state == State.jump:	
		velocity.y += gravity * delta 
	else:
		velocity.y += gravity * gravity_down_factor * delta 
	
func update_states() -> void: 
	match current_state:
		State.idle when velocity.x != 0:
			current_state = State.walk 
		State.walk:
			if velocity.x == 0:
				current_state = State.idle
			if not is_on_floor() && velocity.y > 0:
				current_state = State.down 
		State.jump when velocity.y < 0:
				current_state = State.down
		State.down when is_on_floor(): 
			if velocity.x == 0: 
				current_state = State.idle
			else:
				current_state = State.walk
				
			
