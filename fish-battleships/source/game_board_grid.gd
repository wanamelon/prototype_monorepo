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
	var is_legal_position = do_items_satisfy_rules(item_data)
	for fish_shape_offset in item_data.get_item_data().get_shape_as_offsets():
		var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_position + fish_shape_offset)
		if tile_is_in_bounds(tile_for_item_segment):
			var tile_to_display := LEGAL_TILE if is_legal_position else ILLEGAL_TILE
			$TileMapLayer.set_cell(tile_for_item_segment, 0, Vector2i.ZERO, tile_to_display)
	return is_legal_position

func _drop_data(local_position: Vector2, dragged_item_data: Variant):
	var item_data := dragged_item_data as TestPreview
	var placed_item: PlacedItem = PLACED_ITEM_SCENE.instantiate()
	var fish_shape_offset = item_data.get_item_data().get_shape_as_offsets()[0]
	var tile_for_item_segment: Vector2i = $TileMapLayer.local_to_map(local_position + fish_shape_offset)
	var local_position_for_tile: Vector2 = $TileMapLayer.map_to_local(tile_for_item_segment)
	placed_item.scene_init(
		(local_position_for_tile - fish_shape_offset).snapped(Vector2.ONE), 
		item_data.rotation,
		$DragTargetBox,
		self._can_drop_data, 
		self._drop_data)
	$PlacedItems.add_child(placed_item)

func do_items_satisfy_rules(candidate_item_data: TestPreview) -> bool:
	var tile_index_to_item_datas := {}
	for placed_item: PlacedItem in $PlacedItems.get_children():
		for item_segment_offset: Vector2 in placed_item.get_shape_as_offsets():
			var item_segment_local_position = placed_item.position + item_segment_offset
			var tile_index_for_item_segment: Vector2i = $TileMapLayer.local_to_map(item_segment_local_position)
			if not tile_index_for_item_segment in tile_index_to_item_datas:
				tile_index_to_item_datas[tile_index_for_item_segment] = [] as Array[ItemWithPoints]
			tile_index_to_item_datas[tile_index_for_item_segment].append(placed_item.get_item_data())
			
	for item_segment_offset: Vector2 in candidate_item_data.get_item_data().get_shape_as_offsets():
		var item_segment_local_position = to_local(candidate_item_data.global_position) + item_segment_offset
		var tile_index_for_item_segment: Vector2i = $TileMapLayer.local_to_map(item_segment_local_position)
		if not tile_index_for_item_segment in tile_index_to_item_datas:
			tile_index_to_item_datas[tile_index_for_item_segment] = [] as Array[ItemWithPoints]
		tile_index_to_item_datas[tile_index_for_item_segment].append(candidate_item_data.get_item_data())

	for tile_index in tile_index_to_item_datas:
		var item_datas_on_tile: Array[ItemWithPoints] = tile_index_to_item_datas[tile_index]
		for item in item_datas_on_tile:
			for disallowed_overlap_type in item.placement_rules.disallowed_overlapping_item_types:
				for other_item in item_datas_on_tile:
					if item != other_item and other_item.item_type == disallowed_overlap_type:
						return false
			for required_overlap_type in item.placement_rules.required_overlapping_item_types:
				var has_required_overlap = false
				for other_item in item_datas_on_tile:
					if item != other_item and other_item.item_type == required_overlap_type:
						has_required_overlap = true
				if not has_required_overlap:
					return false 
	return true

#class ItemDataAndPositions extends RefCounted:
	#var item_data: ItemWithPoints
	#var tile_indexes: Array[Vector2i]
	#
	#func _init(item_data: ItemWithPoints, tile_indexes: Array[Vector2i]):
		#self.item_data = item_data
		#self.tile_indexes = tile_indexes

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
