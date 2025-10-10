class_name TestPreview extends Control

const QUARTER_TURN: float = PI / 2

func _input(event):
	if event.is_action_pressed("RotateClockwise"):
		rotation = snapped(rotation + QUARTER_TURN, QUARTER_TURN)
		get_viewport().set_input_as_handled() # Otherwise, right click cancels drag
	elif event.is_action_pressed("RotateCounterClockwise"):
		rotation = snapped(rotation - QUARTER_TURN, QUARTER_TURN)
		get_viewport().set_input_as_handled()

func get_shape_as_offsets() -> Array[Vector2]:
	var rotated: Array[Vector2] = []
	for child: Node2D in $Points.get_children():
		var raw_position = child.position.rotated(rotation)
		rotated.append(raw_position.snapped(Vector2.ONE))
	return rotated
