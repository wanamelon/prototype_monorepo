class_name PlacedItem extends Node2D

var PREVIEW_SCENE: PackedScene = preload("res://source/test_preview.tscn")

var is_dragging: bool = false

func _ready():
	DragSignals.drag_ended.connect(self._handle_drag_end)
	$DragActivateArea.set_drag_forwarding(self._get_drag_data, Callable(), Callable())

func _handle_drag_end(success):
	if success and is_dragging:
		queue_free()
	else:
		show()
	is_dragging = false

func _get_drag_data(at_position: Vector2) -> Control:
	var new_preview: Control = PREVIEW_SCENE.instantiate()
	new_preview.rotation = rotation
	$DragActivateArea.set_drag_preview(new_preview)
	is_dragging = true
	hide()
	return new_preview
