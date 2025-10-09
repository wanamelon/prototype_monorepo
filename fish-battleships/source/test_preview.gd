class_name TestPreview extends Control

var quarter_turns: int = 0
var shape_offsets: Array[Vector2] = []

func _ready():
	for child: Node2D in $Points.get_children():
		shape_offsets.append(child.position)

func _input(event):
	if event.is_action_pressed("RotateClockwise"):
		quarter_turns = (quarter_turns + 1) % 4
		get_viewport().set_input_as_handled() # Otherwise, right click cancels drag
	elif event.is_action_pressed("RotateCounterClockwise"):
		quarter_turns = (quarter_turns - 1) % 4
		get_viewport().set_input_as_handled()
	rotation = (PI / 2) * quarter_turns

func get_shape_as_offsets() -> Array[Vector2]:
	var rotated: Array[Vector2] = []
	for child: Node2D in $Points.get_children():
		var raw_position = child.position.rotated(quarter_turns * PI / 2.0)
		rotated.append(raw_position.snapped(Vector2.ONE))
	return rotated
