extends Area2D

@onready var audio_player = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$AudioStreamPlayer2D.playing = true
		



func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$AudioStreamPlayer2D.playing = false
