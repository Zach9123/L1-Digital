extends Node2D

@onready var start_sprite: AnimatedSprite2D = $Button_Manager/StartButton/Start
@onready var options_sprite: AnimatedSprite2D = $Button_Manager/OptionsButton/Options
@onready var end_sprite: AnimatedSprite2D = $"Button_Manager/End Button/End"

# --- OPTIONS MENU VARIABLES ---
@onready var options_menu: Panel = $OptionsMenu 
@onready var left_button: Button = $OptionsMenu/VBoxContainer/LeftButton
@onready var right_button: Button = $OptionsMenu/VBoxContainer/RightButton
@onready var jump_button: Button = $OptionsMenu/VBoxContainer/JumpButton
@onready var dash_button: Button = $OptionsMenu/VBoxContainer/DashButton
@onready var close_button: Button = $OptionsMenu/VBoxContainer/CloseButton

var is_remapping: bool = false
var action_to_remap: String = ""
var button_to_update: Button = null
# ------------------------------

func _ready() -> void:
	start_sprite.animation = "On"
	options_sprite.animation = "On"
	end_sprite.animation = "On"
	
	start_sprite.frame = 1
	options_sprite.frame = 1
	end_sprite.frame = 1
	
	start_sprite.stop()
	options_sprite.stop()
	end_sprite.stop()
	
	if options_menu:
		options_menu.hide()
		left_button.pressed.connect(_on_remap_button_pressed.bind("ui_left", left_button))
		right_button.pressed.connect(_on_remap_button_pressed.bind("ui_right", right_button))
		jump_button.pressed.connect(_on_remap_button_pressed.bind("ui_up", jump_button))
		dash_button.pressed.connect(_on_remap_button_pressed.bind("dash", dash_button))
		
		# Connect the Close button to hide the menu
		close_button.pressed.connect(func(): options_menu.hide())
		
		update_button_labels()

# --- Start Button ---
func _on_start_button_mouse_entered() -> void:
	start_sprite.play("On")

func _on_start_button_mouse_exited() -> void:
	start_sprite.play("Off")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

# --- Options Button ---
func _on_options_button_mouse_entered() -> void:
	options_sprite.play("On")

func _on_options_button_mouse_exited() -> void:
	options_sprite.play("Off")

func _on_options_button_pressed() -> void:
	if options_menu:
		options_menu.visible = !options_menu.visible

# --- End Button ---
func _on_end_button_mouse_entered() -> void:
	end_sprite.play("On")

func _on_end_button_mouse_exited() -> void:
	end_sprite.play("Off")

func _on_end_button_pressed() -> void:
	get_tree().quit()

# --- REMAPPING LOGIC ---
# --- REMAPPING LOGIC ---
func _on_remap_button_pressed(action_name: String, button: Button) -> void:
	is_remapping = true
	action_to_remap = action_name
	button_to_update = button
	button.text = "Press any key..."

func _input(event: InputEvent) -> void:
	if is_remapping and event is InputEventKey and event.is_pressed():
		var menu_actions = ["ui_left", "ui_right", "ui_up", "dash"]
		
		for action in menu_actions:
			if InputMap.action_has_event(action, event):
				InputMap.action_erase_event(action, event)
		
		InputMap.action_erase_events(action_to_remap)
		InputMap.action_add_event(action_to_remap, event)
		
		is_remapping = false
		action_to_remap = ""
		update_button_labels()
		
		get_viewport().set_input_as_handled()

func update_button_labels() -> void:
	var left_events = InputMap.action_get_events("ui_left")
	if left_events.size() > 0:
		left_button.text = "Left: " + left_events[0].as_text().trim_suffix(" (Physical)").trim_suffix(" - Physical")
	else:
		left_button.text = "Left: Unassigned"

	var right_events = InputMap.action_get_events("ui_right")
	if right_events.size() > 0:
		right_button.text = "Right: " + right_events[0].as_text().trim_suffix(" (Physical)").trim_suffix(" - Physical")
	else:
		right_button.text = "Right: Unassigned"

	var jump_events = InputMap.action_get_events("ui_up")
	if jump_events.size() > 0:
		jump_button.text = "Jump: " + jump_events[0].as_text().trim_suffix(" (Physical)").trim_suffix(" - Physical")
	else:
		jump_button.text = "Jump: Unassigned"
		
	var dash_events = InputMap.action_get_events("dash")
	if dash_events.size() > 0:
		dash_button.text = "Dash: " + dash_events[0].as_text().trim_suffix(" (Physical)").trim_suffix(" - Physical")
	else:
		dash_button.text = "Dash: Unassigned"
		
	close_button.text = "Close"
