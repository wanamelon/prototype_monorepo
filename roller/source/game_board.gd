class_name GameBoard extends Node2D

const PLAYER_BALL_SCENE: PackedScene = preload("res://source/player_ball.tscn")
const GRID_ITEM_SCENE: PackedScene = preload("res://source/grid_item.tscn")
var _random := RandomNumberGenerator.new()
var _player_ball: PlayerBall

func generate_grid_items(round: int):
	for existing_item in $GridItems.get_children():
		existing_item.queue_free()
	var available_cells: Array[Vector2i] = $TileMapLayer.get_used_cells().duplicate()
	available_cells.shuffle()
	for cell in available_cells.slice(0, 8 + round * 2):
		var grid_item: GridItem = GRID_ITEM_SCENE.instantiate()
		grid_item.position = $TileMapLayer.map_to_local(cell)
		grid_item.level = _random.randi_range(1, 5)
		$GridItems.add_child(grid_item)

func spawn_ball():
	_player_ball = PLAYER_BALL_SCENE.instantiate()
	_player_ball.position = $TileMapLayer.map_to_local($TileMapLayer.get_used_cells().pick_random())
	add_child(_player_ball)
	return _player_ball
