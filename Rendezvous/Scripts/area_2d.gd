extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Check if the object touching the area is the Player
	if body.name == "Player":
		# Load the next scene
		get_tree().change_scene_to_file("res://Scenes/End_screen.tscn")
