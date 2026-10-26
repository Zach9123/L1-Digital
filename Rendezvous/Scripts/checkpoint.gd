
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Update the player's start_position to this checkpoint's location
		body.start_position = global_position
		
