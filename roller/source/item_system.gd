class_name ItemSystem extends Node

var _items: Array[Item] = []
var _player_ball: PlayerBall
var _game_board: GameBoard
var _tick: int = 0

func _init(items: Array[ItemDef], player_ball: PlayerBall, game_board: GameBoard):
	for item_def in items:
		_items.append(_item_for_id(item_def.item_id))
	_player_ball = player_ball
	_game_board = game_board

func _item_for_id(item_id: ItemDef.ItemId) -> Item:
	match item_id:
		ItemDef.ItemId.ADD_STAMINA:
			return AddStaminaItem.new()
		_:
			return AddStaminaItem.new()

func _physics_process(delta):
	var events: Array[ItemEvent] = []
	events.append_array(_player_ball.advance_tick(1.0 / 60.0))
	for item: Item in _items:
		var new_events := item.activate(_tick, _player_ball, _game_board, events)
		events.append_array(new_events)
	_tick += 1

@abstract
class Item extends RefCounted:
	signal destroyed()

	@abstract func activate(tick: int, player: PlayerBall, board: GameBoard, events: Array[ItemEvent]) -> Array[ItemEvent]
	
	func tags() -> Array[String]:
		return []

class AddStaminaItem extends Item:
	var _added_stamina := false
	
	func activate(tick: int, player: PlayerBall, board: GameBoard, events: Array[ItemEvent]):
		if not _added_stamina:
			player._stamina_seconds += 2
			player._max_stamina += 2
			_added_stamina = true

@abstract
class ItemEvent extends RefCounted:
	func tags() -> Array[String]:
		return []

class BounceEvent extends ItemEvent:
	pass

class OverlapEvent extends ItemEvent:
	var player_bounce_count: int
	var global_position: Vector2
	var radius: float
	
	func _init(player_bounce_count: int, global_position: Vector2, radius: float):
		self.player_bounce_count = player_bounce_count 
		self.global_position = global_position 
		self.radius = radius 

class LevelUpEvent extends ItemEvent:
	pass

class CollisionResult extends RefCounted:
	var collision: KinematicCollision2D
	var body_position: Vector2
		
	func _init(collision: KinematicCollision2D, body_position: Vector2):
		self.collision = collision
		self.body_position = body_position

class StatefulPhysicsCalculator extends Node2D:
	var _rid_to_body := {}
	
	func provision_physics_body(parent_item: Item, position: Vector2, shape: Shape2D, is_static: bool = true) -> RID:
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = shape.duplicate()
		var body: PhysicsBody2D = StaticBody2D.new() if is_static else CharacterBody2D.new()
		body.add_child(collision_shape)
		body.position = position
		add_child(body)
		_rid_to_body[body.get_rid()] = body
		parent_item.destroyed.connect(func ():
			body.queue_free()
			_rid_to_body.erase(body.get_rid()))
		return body.get_rid()
	
	func compute_collision(rid: RID, start_pos: Vector2, motion: Vector2, shape: Shape2D) -> CollisionResult:
		var body = _rid_to_body[rid]
		if not body is CharacterBody2D:
			print("Trying to move a static body")
			return null
		var character := body as CharacterBody2D
		var collision_shape: CollisionShape2D = character.get_node("CollisionShape2D")
		collision_shape.shape = shape
		var kinematic_collision := character.move_and_collide(motion)
		return CollisionResult.new(kinematic_collision, character.position) # TODO: global pos?
		
