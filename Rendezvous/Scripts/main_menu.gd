extends Node2D

@onready var start_sprite: AnimatedSprite2D = $Button_Manager/StartButton/Start
@onready var options_sprite: AnimatedSprite2D = $Button_Manager/OptionsButton/Options
@onready var end_sprite: AnimatedSprite2D = $"Button_Manager/End Button/End"

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
	print("Settings menu will load here!")

# --- End Button ---
func _on_end_button_mouse_entered() -> void:
	end_sprite.play("On")

func _on_end_button_mouse_exited() -> void:
	end_sprite.play("Off")

func _on_end_button_pressed() -> void:
	get_tree().quit()
