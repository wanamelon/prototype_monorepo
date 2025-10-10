class_name GameBoardGrid extends Node2D

const NEUTRAL_TILE: int = 0
const ILLEGAL_TILE: int = 1
const LEGAL_TILE: int = 2
const GRID_SIZE := Vector2(128, 128)
const PLACED_ITEM_SCENE: PackedScene = preload("res://source/placed_item.tscn")

@onready var valid_tile_positions: Array[Vector2i] = $TileMapLayer.get_used_cells()

func _ready():
	$DragTargetBox.set_drag_forwarding(Callable(), self._can_drop_data, self._drop_data)
	$DragTargetBox.mouse_exited.connect(self._reset_tile_states)
	DragSignals.drag_ended.connect(func (__): _reset_tile_states())

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
		if tile_is_in_bounds(tile_for_item_segment):
			var tile_to_display := LEGAL_TILE if is_legal_position else ILLEGAL_TILE
			$TileMapLayer.set_cell(tile_for_item_segment, 0, Vector2i.ZERO, tile_to_display)
	return is_legal_position

func _drop_data(local_position: Vector2, dragged_item_data: Variant):
	var item_data := dragged_item_data as TestPreview
	var placed_item = PLACED_ITEM_SCENE.instantiate()
	placed_item.rotation = item_data.rotation
	var fish_shape_offset = item_data.get_shape_as_offsets()[0]
	var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_position + fish_shape_offset)
	var local_position_for_tile: Vector2 = $TileMapLayer.map_to_local(tile_for_item_segment)
	placed_item.position = (local_position_for_tile - fish_shape_offset).snapped(Vector2.ONE)
	$PlacedItems.add_child(placed_item)

func is_legal_tile(tile_coord: Vector2i) -> bool:
	for placed_item: PlacedItem in $PlacedItems.get_children():
		for item_segment_offset: Vector2 in placed_item.get_shape_as_offsets():
			var item_segment_local_position = placed_item.position + item_segment_offset
			var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(item_segment_local_position)
			if tile_coord == tile_for_item_segment:
				return false
	return tile_is_in_bounds(tile_coord)

func tile_is_in_bounds(tile_coord: Vector2i) -> bool:
	return tile_coord in valid_tile_positions

func _reset_tile_states():
	for cell_coord: Vector2i in $TileMapLayer.get_used_cells():
		$TileMapLayer.set_cell(cell_coord, 0, Vector2i.ZERO, NEUTRAL_TILE)
