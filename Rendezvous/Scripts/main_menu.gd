extends Node2D

@onready var start_sprite: AnimatedSprite2D = $Button_Manager/StartButton/Start
@onready var options_sprite: AnimatedSprite2D = $Button_Manager/OptionsButton/Options

func _ready() -> void:
	# Set both sprites to use the "On" animation
	start_sprite.animation = "On"
	options_sprite.animation = "On"
	
	# Jump exactly to frame 1 (or 0 for the first image)
	start_sprite.frame = 1
	options_sprite.frame = 1
	
	# Stop them from playing so they stay frozen on that frame until hovered
	start_sprite.stop()
	options_sprite.stop()

# --- Start Button ---
func _on_start_button_mouse_entered() -> void:
	start_sprite.play("On")

func _on_start_button_mouse_exited() -> void:
	start_sprite.play("Off")

# --- Options Button ---
func _on_options_button_mouse_entered() -> void:
	options_sprite.play("On")

func _on_options_button_mouse_exited() -> void:
	options_sprite.play("Off")
