class_name PlacedItem extends Node2D

const PREVIEW_SCENE: PackedScene = preload("res://source/test_preview.tscn")

var is_dragging: bool = false

const SELF_SCENE: PackedScene = preload("res://source/placed_item.tscn")
const ITEM_1_SCENE: PackedScene = preload("res://source/item_1.tscn")
const ITEM_2_SCENE: PackedScene = preload("res://source/item_2.tscn")
const ITEM_TYPE_TO_SCENE: Dictionary = {
	ENUM.Items.ITEM_1: ITEM_1_SCENE,
	ENUM.Items.ITEM_2: ITEM_2_SCENE 
}

var _can_drop_data: Callable = Callable()
var _drop_data: Callable = Callable()

@onready var _drag_activate_area: Control = $ItemWithPoints.get_drag_activate_area()

func _init(
	item_type: ENUM.Items,
	delegate_target: Control = null,
	can_drop_data: Callable = Callable(),
	drop_data: Callable = Callable()
) -> void:
	var item_data_scene: ItemWithPoints = ITEM_TYPE_TO_SCENE.get(item_type).instantiate()
	item_data_scene.name = "ItemWithPoints"
	add_child(item_data_scene)
	item_data_scene.get_drag_activate_area().set_drag_forwarding(self._get_drag_data, can_drop_data, drop_data)
#	_can_drop_data = _delegate_drop_data_calls_in_local_position(can_drop_data, delegate_target)
#	_drop_data = _delegate_drop_data_calls_in_local_position(drop_data, delegate_target)

#static func instance(
#	item_type: ENUM.Items, 
#	position, 
#	rotation, 
#	delegate_target: Control = null, 
#	can_drop_data: Callable = Callable(), 
#	drop_data: Callable = Callable()
#) -> PlacedItem:
#	var item_data_scene: ItemWithPoints = ITEM_TYPE_TO_SCENE.get(item_type).instantiate()
#	item_data_scene.name = "ItemWithPoints"
#	var self_new_node: PlacedItem = SELF_SCENE.instantiate()
#	self_new_node.add_child(item_data_scene)
#	self_new_node.scene_init(position, rotation, delegate_target, can_drop_data, drop_data)
#	return self_new_node
#
#func scene_init(position, rotation, delegate_target: Control, can_drop_data: Callable, drop_data: Callable) -> PlacedItem:
#	self.position = position
#	self.rotation = rotation
#	_can_drop_data = _delegate_drop_data_calls_in_local_position(can_drop_data, delegate_target)
#	_drop_data = _delegate_drop_data_calls_in_local_position(drop_data, delegate_target)
#	return self

func _delegate_drop_data_calls_in_local_position(delegate: Callable, delegate_target: Control):
	return func (at_position, data):
		var mouse_drop_pos_global : Vector2 = _drag_activate_area.get_global_transform() * at_position
		var position_offset_from_delegate = mouse_drop_pos_global - delegate_target.global_position
		return delegate.call(position_offset_from_delegate, data)

func _ready():
	DragSignals.drag_ended.connect(self._handle_drag_end)
	_drag_activate_area.set_drag_forwarding(self._get_drag_data, _can_drop_data, _drop_data)

func _handle_drag_end(success):
	if success and is_dragging:
		queue_free()
	else:
		show()
	is_dragging = false

func _get_drag_data(at_position: Vector2) -> Control:
	var new_preview: Control = PREVIEW_SCENE.instantiate()
	var item_data_scene: ItemWithPoints = ITEM_TYPE_TO_SCENE.get(get_item_data().item_type).instantiate()
	item_data_scene.name = "ItemWithPoints"
	new_preview.add_child(item_data_scene)
	new_preview.rotation = rotation
	_drag_activate_area.set_drag_preview(new_preview)
	is_dragging = true
	hide()
	return new_preview

func get_item_data() -> ItemWithPoints:
	return $ItemWithPoints

func get_shape_as_offsets() -> Array[Vector2]:
	var empty_array: Array[Vector2] = []
	return empty_array if is_dragging else $ItemWithPoints.get_shape_as_offsets()
