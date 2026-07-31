extends CharacterBody2D
@export var acceleration: int = 25
@export var speed: int = 200
@export var jump_speed: int = -speed * 4.5
@export var gravity: int = speed * 5
@export var gravity_down_factor: float = 3


var start_position = Vector2(579, 319)

@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var cyote_timer: Timer = $CyoteTimer

enum State{idle, walk, jump, down}
var current_state: State = State.idle

func _physics_process(delta: float) -> void:
	handle_input()
	move_and_slide()
	update_movement(delta)
	update_states()
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var tilemap = collision.get_collider() as TileMapLayer
		
		if tilemap:
			var cell = tilemap.local_to_map(collision.get_position() - collision.get_normal())
			var tile = tilemap.get_cell_tile_data(cell)
			if tile and tile.get_custom_data('spikes'):
				respawn()


func handle_input() -> void: 
	if Input.is_action_just_pressed("ui_up"): 
		jump_buffer_timer.start()
		
	var direction = Input.get_axis("ui_left", "ui_right") 
	if direction == 0: 
		velocity.x = move_toward(velocity.x, 0, acceleration)
	else:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration)
		

func update_movement(delta: float) -> void: 
	if (is_on_floor() || cyote_timer.time_left > 0) && jump_buffer_timer.time_left > 0: 
		velocity.y = jump_speed
		current_state = State.jump
		jump_buffer_timer.stop()
		cyote_timer.stop()
		 
	if current_state == State.jump:
		velocity.y += gravity * delta 
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
				
		State.jump when velocity.y < 0:
				current_state = State.down
				
		State.down when is_on_floor(): 
			
			if velocity.x == 0: 
				current_state = State.idle
				
			else:
				current_state = State.walk
				
func respawn():
	position = start_position
	
