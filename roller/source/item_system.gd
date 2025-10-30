class_name ItemSystem extends Node

signal score_changed(new_score: int)

const TICK_DELTA: float = 1.0 / 60.0
var _items: Array[Item] = []
var _player_ball: PlayerBall
var _game_board: GameBoard
var _tick: int = 0
var _match_state: MatchState
var _physics_calculator: StatefulPhysicsCalculator

func _init(items: Array[ItemDef], player_ball: PlayerBall, game_board: GameBoard, points: int):
	_player_ball = player_ball
	_game_board = game_board
	_physics_calculator = StatefulPhysicsCalculator.new()
	add_child(_physics_calculator)
	for item_def in items:
		var item := _item_for_id(item_def.item_id)
		item._inject(_physics_calculator)
		_items.append(item)
	_items.append(CropSpawner.new())
	_match_state = MatchState.new(0, points, _player_ball, _items, [] as Array[ItemEvent])

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
	for event in events:
		if event is SpawnEvent:
			# TODO: respect targeting config
			var spawn := event as SpawnEvent
			var new_item: Item = spawn.factory.call()
			_game_board._spawn_item_in_random_cell(new_item, spawn.spawn_chance)
			_items.append(new_item)
		elif event is GivePointsEvent:
			var give_points_event := event as GivePointsEvent
			_match_state.points += give_points_event.points
			score_changed.emit(_match_state.points)
		elif event is DespawnEvent:
			_items.erase(event.target)
			event.target.queue_free()
	_tick += 1
	_match_state.tick += 1

func get_score() -> int:
	return _match_state.points

class MatchState:
	var tick: int
	var points: int
	var player_ball: PlayerBall
	var items: Array[Item]
	var events: Array[ItemEvent]
	
	func _init(tick: int, points: int, player_ball: PlayerBall, items: Array[Item], events: Array[ItemEvent]):
		self.tick = tick
		self.points = points
		self.player_ball = player_ball
		self.items = items
		self.events = events

@abstract
class Item extends Node2D:
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
	func spawn():
		var circle = CircleShape2D.new()
		circle.radius = 48
		# TODO: fill in position
		_physics_calculator.provision_physics_body(self, Vector2(), circle, false)
	
	func activate(state: MatchState):
		return [] as Array[ItemEvent]

#class CropItem extends Item:
#
#	func spawn():
#		pass
#
#	func activate(state: MatchState):
#		return [] as Array[ItemEvent]

@abstract
class Location extends RefCounted:
	pass

class GridLocation extends Location:
	pass

class ItemSlotLocation extends Location:
	pass

class UnplacedLocation extends Location:
	pass

@abstract
class ItemEvent extends RefCounted:
	pass

class BounceEvent extends ItemEvent:
	pass

class GivePointsEvent extends ItemEvent:
	var points: int
	func _init(points: int):
		self.points = points

class SpawnEvent extends ItemEvent:
	# Later: Make this more declarative?
	var factory: Callable
	var targeting_config: TargetingConfig
	var spawn_chance: float
	
	func _init(factory: Callable, targeting_config: TargetingConfig, spawn_chance: float):
		self.factory = factory
		self.targeting_config = targeting_config
		self.spawn_chance = spawn_chance

class DespawnEvent extends ItemEvent:
	var target: Item
	func _init(target: Item):
		self.target = target

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

@abstract
class TargetingConfig extends RefCounted:
	pass

class AnyFreeCell extends TargetingConfig:
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
		character.position = start_pos
		var collision_shape: CollisionShape2D = character.get_node("CollisionShape2D")
		collision_shape.shape = shape
		var kinematic_collision := character.move_and_collide(motion)
		# TODO: this is wrong, it should return collided item if available (i.e. it's not a wall or whatever)
		return CollisionResult.new(kinematic_collision, character.position, item_and_body.item) # TODO: global pos?
		
