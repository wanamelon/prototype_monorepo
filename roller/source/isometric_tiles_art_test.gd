extends Node3D

func _input(event):
	if event.is_action_pressed("PlaceFish") and not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("disturb")
		$AudioStreamPlayer.play()
