class_name GameBoardGrid extends Node2D

const GRID_SIZE := Vector2(128, 128)

var grid: Array = []

func _ready():
	$DragTargetBox.set_drag_forwarding(Callable(), self._can_drop_data, self._drop_data)

func _can_drop_data(local_position: Vector2, dragged_item_data: Variant):
	print("Check")
	var item_data := dragged_item_data as TestPreview
	for fish_shape_offset in item_data.get_shape_as_offsets():
		var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_position + fish_shape_offset)
		if not is_legal_tile(tile_for_item_segment):
			print("Failed, illegal position")
			return false
	print("Legal")
	return true

func _drop_data(local_position: Vector2, dragged_item_data: Variant):
	print("Dropped ", dragged_item_data, " at ", local_position)
	pass

func is_legal_tile(tile_coord: Vector2i) -> bool:
	return tile_coord.x >= 0 and tile_coord.x < 6 and tile_coord.y >= 0 and tile_coord.y < 6
