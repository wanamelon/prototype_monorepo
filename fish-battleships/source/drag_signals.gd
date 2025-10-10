extends Control

signal drag_ended(is_success: bool)

func _notification(what):
	match what:
		NOTIFICATION_DRAG_END:
			drag_ended.emit(is_drag_successful())
