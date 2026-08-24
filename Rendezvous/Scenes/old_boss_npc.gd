extends Area2D

@onready var ui_tip: Label = $UITip
@onready var chat_box: Control = $CanvasLayer/ChatBox

var player_in_range: bool = false

func _ready() -> void:
	ui_tip.hide()
	chat_box.hide()

func _on_body_entered(body: Node2D) -> void:
	# Ensure your player character node is actually named "Player"
	if body.name == "Player":
		player_in_range = true
		ui_tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		ui_tip.hide()
		chat_box.hide() # Closes the chat if the player walks away

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("ui_down"):
		ui_tip.hide() # Hide the prompt while talking
		chat_box.show()
