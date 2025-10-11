extends Control

const PLACED_ITEM_SCENE: PackedScene = preload("res://source/placed_item.tscn")

func _can_drop_data(at_position, data):
	if not data is TestPreview:
		return false
	var item_data := data as TestPreview
	return get_global_rect().encloses(item_data.get_item_data().get_visual_bounding_box())

func _drop_data(at_position, data):
	var placed_item = PLACED_ITEM_SCENE.instantiate()
	placed_item.rotation = data.rotation
	placed_item.position = at_position
	add_child(placed_item)
