extends Control

var spin_speed := 0.0

func _input(event):
	if event.is_action_pressed("PlaceFish"):
		spin_speed = RandomNumberGenerator.new().randf_range(18.0, 24.0)

func _process(delta):
	$CircleAndSpinners/FRICK.rotation += delta * spin_speed
	spin_speed = max(0, spin_speed - 10.0 * delta)
