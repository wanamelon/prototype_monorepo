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

func _init(
	item_type: ENUM.Items,
	can_drop_data: Callable = Callable(),
	drop_data: Callable = Callable()
) -> void:
	var item_data_scene: ItemWithPoints = ITEM_TYPE_TO_SCENE.get(item_type).instantiate()
	item_data_scene.name = "ItemWithPoints"
	add_child(item_data_scene)
	item_data_scene.get_drag_activate_area().set_drag_forwarding(self._get_drag_data, can_drop_data, drop_data)
	DragSignals.drag_ended.connect(self._handle_drag_end)

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
	get_item_data().get_drag_activate_area().set_drag_preview(new_preview)
	is_dragging = true
	hide()
	return new_preview

func get_item_data() -> ItemWithPoints:
	return $ItemWithPoints

func get_shape_as_offsets() -> Array[Vector2]:
	var empty_array: Array[Vector2] = []
	return empty_array if is_dragging else get_item_data().get_shape_as_offsets()
