class_name GameBoardGrid extends Node2D

const NEUTRAL_TILE: int = 0
const ILLEGAL_TILE: int = 1
const LEGAL_TILE: int = 2
const PLACED_ITEM_SCENE: PackedScene = preload("res://source/placed_item.tscn")

@onready var valid_tile_positions: Array[Vector2i] = $TileMapLayer.get_used_cells()

func _ready():
	$DragTargetBox.set_drag_forwarding(Callable(), self._can_drop_data, self._drop_data)
	$DragTargetBox.mouse_exited.connect(self._reset_tile_states)
	DragSignals.drag_ended.connect(func (__): _reset_tile_states())

func _can_drop_data(__: Vector2, dragged_item_data: Variant):
	if dragged_item_data is not ItemDragPreview:
		return false
	var item_data := dragged_item_data as ItemDragPreview
	_reset_tile_states()
	var local_drop_position := to_local(get_global_mouse_position())
	var current_placed_items := __extract_current_placed_item_data()
	current_placed_items.append(
		PlacedItemData.new(item_data.get_item_data(), _compute_tiles_covered_by_item(local_drop_position, item_data.get_item_data())))
	var is_legal_position := __validate_board_legality(current_placed_items)
	for tile_covered_by_item in _compute_tiles_covered_by_item(local_drop_position, item_data.get_item_data()):
		if __tile_is_in_bounds(tile_covered_by_item):
			var tile_to_display := LEGAL_TILE if is_legal_position else ILLEGAL_TILE
			$TileMapLayer.set_cell(tile_covered_by_item, 0, Vector2i.ZERO, tile_to_display)
	return is_legal_position

func _drop_data(__: Vector2, dragged_item_data: Variant):
	var item_data := dragged_item_data as ItemDragPreview
	var item_shape_offset := item_data.get_item_data().get_shape_as_offsets()[0]
	var local_drop_position := to_local(get_global_mouse_position())
	var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_drop_position + item_shape_offset)
	var local_position_for_item_segment: Vector2 = $TileMapLayer.map_to_local(tile_for_item_segment)
	var local_pos_to_place_item := (local_position_for_item_segment - item_shape_offset).snapped(Vector2.ONE)
	var placed_item: PlacedItem = PlacedItem.new(item_data.get_item_data().item_type, self._can_drop_data, self._drop_data)
	placed_item.position = local_pos_to_place_item
	placed_item.rotation = item_data.rotation
	$PlacedItems.add_child(placed_item)

func _compute_tiles_covered_by_item(item_local_position: Vector2, item: ItemWithPoints) -> Array[Vector2i]:
	var tile_indices: Array[Vector2i] = []
	for item_segment_offset in item.get_shape_as_offsets():
		tile_indices.append($TileMapLayer.local_to_map(item_local_position + item_segment_offset))
	return tile_indices

func __extract_current_placed_item_data() -> Array[PlacedItemData]:
	var result: Array[PlacedItemData] = []
	for placed_item: PlacedItem in $PlacedItems.get_children():
		if not placed_item.is_dragging:
			var tiles_covered_by_item := _compute_tiles_covered_by_item(placed_item.position, placed_item.get_item_data())
			result.append(PlacedItemData.new(placed_item.get_item_data(), tiles_covered_by_item))
	return result

func __validate_board_legality(placed_items: Array[PlacedItemData]) -> bool:
	var items_per_tile := {}
	for placed_item in placed_items:
		for tile in placed_item.covered_tiles:
			var typed_empty_arr: Array[ItemWithPoints] = []
			Utils.default_if_absent(items_per_tile, tile, typed_empty_arr).append(placed_item.item_data)
	# Check all in bounds
	for tile_index in items_per_tile:
		if not __tile_is_in_bounds(tile_index):
			return false
	# Check disallowed overlaps
	for tile_index in items_per_tile:
		var item_datas_on_tile: Array[ItemWithPoints] = items_per_tile[tile_index]
		for item_data in item_datas_on_tile:
			for disallowed_overlap_type in item_data.placement_rules.disallowed_overlapping_item_types:
				for other_item in item_datas_on_tile:
					if item_data != other_item and other_item.layer_type == disallowed_overlap_type:
						return false
	# Check required overlaps
	for tile_index in items_per_tile:
		var item_datas_on_tile: Array[ItemWithPoints] = items_per_tile[tile_index]
		for item_data in item_datas_on_tile:
			for required_overlap_type in item_data.placement_rules.required_overlapping_item_types:
				var has_required_overlap = false
				for other_item in item_datas_on_tile:
					if item_data != other_item and other_item.layer_type == required_overlap_type:
						has_required_overlap = true
				if not has_required_overlap:
					return false
	return true

func __tile_is_in_bounds(tile_coord: Vector2i) -> bool:
	return tile_coord in valid_tile_positions

func _reset_tile_states():
	for cell_coord: Vector2i in $TileMapLayer.get_used_cells():
		$TileMapLayer.set_cell(cell_coord, 0, Vector2i.ZERO, NEUTRAL_TILE)

class PlacedItemData extends RefCounted:
	var item_data: ItemWithPoints
	var covered_tiles: Array[Vector2i]

	func _init(item_data: ItemWithPoints, covered_tiles: Array[Vector2i]):
		self.item_data = item_data
		self.covered_tiles = covered_tiles
