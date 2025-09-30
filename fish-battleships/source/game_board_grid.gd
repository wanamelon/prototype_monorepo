class_name GameBoardGrid extends Node2D

const GRID_SIZE := Vector2(128, 128)

var grid: Array = []

func _ready():
	var top_left_tile_center := position + (GRID_SIZE / 2)
	var current_position = top_left_tile_center
	for i in range(8):
		var row = []
		for j in range(8):
			row.append(top_left_tile_center + GRID_SIZE * Vector2(i, j))
		grid.append(row)
	#print(grid)

func _draw():
	for row in grid:
		for point in row:
			draw_circle(to_local(point), 40, Color.RED)

func _process(delta):
	queue_redraw()

func handle_fish_placement(fish: Fish, placed_position_global: Vector2) -> void:
	var placement_pos_as_tile_coordinate: Vector2i = $TileMapLayer.local_to_map(to_local(placed_position_global))
	for fish_shape_offset in fish.get_shape_as_tile_offsets():
		var fish_body_coordinate_to_check: Vector2i = placement_pos_as_tile_coordinate + fish_shape_offset	
		if not is_legal_tile(fish_body_coordinate_to_check):
			print("Failed, illegal position")
			return
	print("good position!")

func is_legal_tile(tile_coord: Vector2i):
	return tile_coord.x >= 0 and tile_coord.x < 8 and tile_coord.y >= 0 and tile_coord.y < 8
