class_name GameBoardGrid extends Node2D

const GRID_SIZE := Vector2(128, 128)

@onready
var grid: Array[Vector2i] = $TileMapLayer.get_used_cells()

func _ready():
	$DragTargetBox.set_drag_forwarding(Callable(), self._can_drop_data, self._drop_data)

func _can_drop_data(local_position: Vector2, dragged_item_data: Variant):
	if dragged_item_data is not TestPreview: return false
	var item_data := dragged_item_data as TestPreview
	_reset_tile_states()
	var is_legal_position := true
	for fish_shape_offset in item_data.get_shape_as_offsets():
		var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_position + fish_shape_offset)
		if not is_legal_tile(tile_for_item_segment):
			is_legal_position = false
	for fish_shape_offset in item_data.get_shape_as_offsets():
		var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_position + fish_shape_offset)
		if is_legal_tile(tile_for_item_segment):
			$TileMapLayer.set_cell(tile_for_item_segment, 0, Vector2i.ZERO, 2 if is_legal_position else 1)
	return is_legal_position

func _reset_tile_states():
	for cell_coord: Vector2i in $TileMapLayer.get_used_cells():
		$TileMapLayer.set_cell(cell_coord, 0, Vector2i.ZERO, 0)

func _drop_data(local_position: Vector2, dragged_item_data: Variant):
	print("Dropped ", dragged_item_data, " at ", local_position)
	pass

func is_legal_tile(tile_coord: Vector2i) -> bool:
	return tile_coord in grid
