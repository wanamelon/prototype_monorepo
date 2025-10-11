extends Control

var preview: PackedScene = preload("res://source/test_preview.tscn")

func _notification(what):
	match what:
		NOTIFICATION_DRAG_END:
			if is_drag_successful():
				queue_free()
			else:
				show()

func _get_drag_data(at_position: Vector2) -> Control:
	var new_preview: Control = preview.instantiate()
	set_drag_preview(new_preview)
	hide()
	return new_preview
