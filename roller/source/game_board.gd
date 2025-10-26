class_name GameBoard extends Node2D

const PLAYER_BALL_SCENE: PackedScene = preload("res://source/player_ball.tscn")
const TILE_OBJECT_SCENE: PackedScene = preload("res://source/tile_object.tscn")
const BOUNCE_PILLAR_SCENE: PackedScene = preload("res://source/bounce_pillar.tscn")
var _random := RandomNumberGenerator.new()
var _player_ball: PlayerBall
var _item_per_cell := {} # prevents race condition overlap, adding 2 items in one tick

func clear():
	for existing_item in $TileObjects.get_children():
		existing_item.queue_free()

func generate_grid_items(round: int):
	clear()
	var available_cells: Array[Vector2i] = $TileMapLayer.get_used_cells().duplicate()
	available_cells.shuffle()
	for cell in available_cells.slice(0, 10 + round * 2):
		_spawn_item(_create_coin_random_level(), cell)

func _physics_process(delta):
	if _player_ball:
		for existing_item in $TileObjects.get_children():
			if existing_item.has_method("toggle_bounce"):
				existing_item.toggle_bounce(_player_ball.should_bounce_off_everything())

func spawn_ball(items: Array[ItemDef]):
	_player_ball = PLAYER_BALL_SCENE.instantiate().scene_init(items)
	_player_ball.position = $TileMapLayer.map_to_local($TileMapLayer.get_used_cells().pick_random())
	_player_ball.spawn_item.connect(func (chance):
		_spawn_item_in_random_cell(_create_coin_random_level(), chance))
	_player_ball.spawn_bounce_pillar.connect(self._spawn_bounce_pillar)
	add_child(_player_ball)
	return _player_ball

func _create_coin_random_level():
	var tile_obj = TILE_OBJECT_SCENE.instantiate()
	tile_obj.level = _random.randi_range(1, 3)
	return tile_obj

func _spawn_item(item: Node2D, cell: Vector2i):
	item.position = $TileMapLayer.map_to_local(cell)
	_item_per_cell[cell] = item
	$TileObjects.call_deferred("add_child", item)
	item.tree_exited.connect(func (): _item_per_cell.erase(cell))
	if item is BouncePillar:
		$PlacementAudioPlayer.play()
	elif item is TileObject:
		$SpawnCoinAudioPlayer.play()

func _spawn_item_in_random_cell(item: Node2D, spawn_chance: float):
	if _random.randf() > 1.0:
		return
	var available_cells: Array[Vector2i] = []
	var occupied_cells: Array[Vector2i] = []
	for existing_item: Node2D in $TileObjects.get_children():
		occupied_cells.append($TileMapLayer.local_to_map(existing_item.position))
	occupied_cells.append_array(_item_per_cell.keys())
	for possible_grid_cell: Vector2i in $TileMapLayer.get_used_cells():
		if not occupied_cells.has(possible_grid_cell):
			available_cells.append(possible_grid_cell)
	available_cells.shuffle()
	for spawn_cell in available_cells:
		var loc = to_global($TileMapLayer.map_to_local(spawn_cell))
		if item.has_method("can_place") and not item.can_place(loc, get_world_2d()):
			continue
		_spawn_item(item, spawn_cell)
		break

func _spawn_bounce_pillar(spawn_chance: float):
	var bounce_pillar_count: int = 0
	for existing_item: Node2D in $TileObjects.get_children():
		if existing_item is BouncePillar:
			bounce_pillar_count += 1
	if bounce_pillar_count < 4:
		_spawn_item_in_random_cell(BOUNCE_PILLAR_SCENE.instantiate(), spawn_chance)
