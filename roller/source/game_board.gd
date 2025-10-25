class_name GameBoard extends Node2D

const PLAYER_BALL_SCENE: PackedScene = preload("res://source/player_ball.tscn")
const TILE_OBJECT_SCENE: PackedScene = preload("res://source/tile_object.tscn")
var _random := RandomNumberGenerator.new()
var _player_ball: PlayerBall

func generate_grid_items(round: int):
	for existing_item in $TileObjects.get_children():
		existing_item.queue_free()
	var available_cells: Array[Vector2i] = $TileMapLayer.get_used_cells().duplicate()
	available_cells.shuffle()
	for cell in available_cells.slice(0, 10 + round * 2):
		_spawn_item(cell)

func spawn_ball(items: Array[ItemDef]):
	_player_ball = PLAYER_BALL_SCENE.instantiate().scene_init(items)
	_player_ball.position = $TileMapLayer.map_to_local($TileMapLayer.get_used_cells().pick_random())
	_player_ball.spawn_item.connect(self._spawn_item_in_random_cell)
	add_child(_player_ball)
	return _player_ball

func _spawn_item(cell: Vector2i):
	var grid_item: TileObject = TILE_OBJECT_SCENE.instantiate()
	grid_item.position = $TileMapLayer.map_to_local(cell)
	grid_item.level = _random.randi_range(1, 3)
	$TileObjects.add_child(grid_item)

func _spawn_item_in_random_cell(spawn_chance: float):
	if _random.randf() > spawn_chance:
		return
	var available_cells: Array[Vector2i] = [] # $TileMapLayer.get_used_cells().duplicate()
	var occupied_cells: Array[Vector2i] = []
	for existing_item: Node2D in $TileObjects.get_children():
		occupied_cells.append($TileMapLayer.local_to_map(existing_item.position))
	for possible_grid_cell: Vector2i in $TileMapLayer.get_used_cells():
		if not possible_grid_cell in occupied_cells:
			available_cells.append(possible_grid_cell)
	_spawn_item(available_cells.pick_random())
