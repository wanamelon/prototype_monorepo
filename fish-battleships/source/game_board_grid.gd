class_name GameBoardGrid extends Node2D

"""
State:
	some kind of grid
		each cell can hold a pointer to a fish maybe?
	also know all the fish and their positions
	Probably a fish would be child of the board

Methods:
	register a fish and position (we trigger separately) + other CRUD methods in future
	
"""

const GRID_SIZE := Vector2(128, 128)

var grid: Array = []

func is_legal_tile(tile_coord: Vector2i):
	return tile_coord.x >= 0 and tile_coord.x < 8 and tile_coord.y >= 0 and tile_coord.y < 8

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

func handle_fish_placement(fish: Fish, pos: Vector2):
	print("Tried place fish at ", pos)
	var position_as_tile_coord: Vector2i = $TileMapLayer.local_to_map(to_local(pos))
	# find out which tile is pos
	print("Tile pos ", position_as_tile_coord)
	# if it's not in the grid, we're doomed haha
	for fish_shape_relative_coordinate in fish.get_shape_as_tile_offsets():
		var tile_to_check = position_as_tile_coord + fish_shape_relative_coordinate	
		if not is_legal_tile(tile_to_check):
			print("Failed, illegal psoition")
			return
	
	print("good position!")
