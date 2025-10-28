class_name ItemSystem extends Node

const TICK_DELTA: float = 1.0 / 60.0
var _items: Array[Item] = []
var _player_ball: PlayerBall
var _game_board: GameBoard
var _tick: int = 0
var _match_state: MatchState
var _physics_calculator: StatefulPhysicsCalculator

func _init(items: Array[ItemDef], player_ball: PlayerBall, game_board: GameBoard):
	_player_ball = player_ball
	_game_board = game_board
	_physics_calculator = StatefulPhysicsCalculator.new()
	add_child(_physics_calculator)
	for item_def in items:
		var item := _item_for_id(item_def.item_id)
		item._inject(_physics_calculator)
		_items.append(item)
	_match_state = MatchState.new(0, _player_ball, _items, [] as Array[ItemEvent])

func _item_for_id(item_id: ItemDef.ItemId) -> Item:
	match item_id:
		ItemDef.ItemId.ADD_STAMINA:
			return AddStaminaItem.new()
		_:
			return AddStaminaItem.new()

func _physics_process(__):
	var events: Array[ItemEvent] = []
	events.append_array(_player_ball.advance_tick(TICK_DELTA))
	for item: Item in _items:
		var new_events := item.activate(_match_state)
		events.append_array(new_events)
	_tick += 1
	_match_state.tick += 1

class MatchState:
	var tick: int
	var player_ball: PlayerBall
	var items: Array[Item]
	var events: Array[ItemEvent]
	
	func _init(tick: int, player_ball: PlayerBall, items: Array[Item], events: Array[ItemEvent]):
		self.tick = tick
		self.player_ball = player_ball
		self.items = items
		self.events = events

@abstract
class Item extends RefCounted:
	signal destroyed()
	
	var _physics_calculator: StatefulPhysicsCalculator
	
	func _inject(physics_calculator: StatefulPhysicsCalculator):
		_physics_calculator = physics_calculator
	
	# Business logic spawn setup: What bodies/display nodes to register...
	func spawn():
		pass
	
	# Generate physics events (collisions + overlaps)
	func advance_physics(tick_delta: float) -> Array[ItemEvent]:
		return []
	
	# The core of the logic! Evaluate triggers and perform actions
	@abstract func activate(state: MatchState) -> Array[ItemEvent]

class AddStaminaItem extends Item:
	var _added_stamina := false
	
	func activate(state: MatchState):
		if not _added_stamina:
			state.player_ball._stamina_seconds += 10
			state.player_ball._max_stamina += 10
			_added_stamina = true
		return [] as Array[ItemEvent]

class PlayerBallItem extends Item:
	func activate(state: MatchState):
		return [] as Array[ItemEvent]

@abstract
class ItemEvent extends RefCounted:
	pass

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
	var collided_item: Item
		
	func _init(collision: KinematicCollision2D, body_position: Vector2, collided_item: Item):
		self.collision = collision
		self.body_position = body_position
		self.collided_item = collided_item

class ItemAndBody extends RefCounted:
	var item: Item
	var body: PhysicsBody2D
	
	func _init(item: Item, body: PhysicsBody2D):
		self.item = item
		self.body = body

class StatefulPhysicsCalculator extends Node2D:
	var _rid_to_body := {}
	
	func provision_physics_body(parent_item: Item, position: Vector2, shape: Shape2D, is_static: bool = true) -> RID:
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = shape.duplicate()
		var body: PhysicsBody2D = StaticBody2D.new() if is_static else CharacterBody2D.new()
		body.add_child(collision_shape)
		body.position = position
		add_child(body)
		_rid_to_body[body.get_rid()] = ItemAndBody.new(parent_item, body)
		parent_item.destroyed.connect(func ():
			body.queue_free()
			_rid_to_body.erase(body.get_rid()))
		return body.get_rid()
	
	func compute_collision(rid: RID, start_pos: Vector2, motion: Vector2, shape: Shape2D) -> CollisionResult:
		var item_and_body: ItemAndBody = _rid_to_body[rid]
		if not item_and_body.body is CharacterBody2D:
			print("Trying to move a static body")
			return null
		var character := item_and_body.body as CharacterBody2D
		var collision_shape: CollisionShape2D = character.get_node("CollisionShape2D")
		collision_shape.shape = shape
		var kinematic_collision := character.move_and_collide(motion)
		return CollisionResult.new(kinematic_collision, character.position, item_and_body.item) # TODO: global pos?
		
