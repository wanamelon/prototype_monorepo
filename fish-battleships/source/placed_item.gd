class_name PlacedItem extends Node2D

const PREVIEW_SCENE: PackedScene = preload("res://source/test_preview.tscn")

var is_dragging: bool = false

var _can_drop_data: Callable = Callable()
var _drop_data: Callable = Callable()

func scene_init(position, rotation, delegate_target: Control, can_drop_data: Callable, drop_data: Callable) -> PlacedItem:
	self.position = position
	self.rotation = rotation
	_can_drop_data = _delegate_drop_data_calls_in_local_position(can_drop_data, delegate_target)
	_drop_data = _delegate_drop_data_calls_in_local_position(drop_data, delegate_target)
	return self

func _delegate_drop_data_calls_in_local_position(delegate: Callable, delegate_target: Control):
	return func (at_position, data):
		var position_offset_from_delegate = $DragActivateArea.global_position - delegate_target.global_position
		delegate.call(position_offset_from_delegate + at_position, data)

func _ready():
	DragSignals.drag_ended.connect(self._handle_drag_end)
	$DragActivateArea.set_drag_forwarding(self._get_drag_data, _can_drop_data, _drop_data)

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

func get_item_data() -> ItemWithPoints:
	return $ItemWithPoints

func get_shape_as_offsets() -> Array[Vector2]:
	var empty_array: Array[Vector2] = []
	return empty_array if is_dragging else $ItemWithPoints.get_shape_as_offsets()
