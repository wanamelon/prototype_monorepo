class_name ItemDragPreview extends Control

const QUARTER_TURN: float = PI / 2

func _input(event):
	if event.is_action_pressed("RotateClockwise"):
		rotation = snapped(rotation + QUARTER_TURN, QUARTER_TURN)
		get_viewport().set_input_as_handled() # Otherwise, right click cancels drag
		get_viewport().update_mouse_cursor_state() # Ensure we call _can_drop_data even if mouse stationary
	elif event.is_action_pressed("RotateCounterClockwise"):
		rotation = snapped(rotation - QUARTER_TURN, QUARTER_TURN)
		get_viewport().set_input_as_handled()
		get_viewport().update_mouse_cursor_state()

func get_item_data() -> ItemWithPoints:
	return $ItemWithPoints
