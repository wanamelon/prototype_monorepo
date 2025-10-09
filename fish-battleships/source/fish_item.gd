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
	#var drag_data := DragData.new()
	var new_preview: Control = preview.instantiate()
	#drag_data.rotated.connect(func (rotation_rads: float): new_preview.rotation = rotation_rads)
	set_drag_preview(new_preview)
	#add_child(drag_data)
	hide()
	return new_preview
