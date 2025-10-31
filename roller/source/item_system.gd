class_name ItemSystem extends Node

signal score_changed(new_score: int)

const TICK_DELTA: float = 1.0 / 60.0

var _game_board: GameBoard
var _match_state: MatchState
var _physics_calculator: StatefulPhysicsCalculator

func _init(item_defs: Array[ItemDef], player_ball: PlayerBall, game_board: GameBoard, points: int):
	_game_board = game_board
	_physics_calculator = StatefulPhysicsCalculator.new()
	add_child(_physics_calculator)
	var items: Array[Item] = []
	for item_def in item_defs:
		var item := _item_for_id(item_def.item_id)
		item._inject(_physics_calculator)
		items.append(item)
	_match_state = MatchState.new(0, points, player_ball, items, [] as Array[ItemEvent])

func _item_for_id(item_id: ItemDef.ItemId) -> Item:
	match item_id:
		ItemDef.ItemId.ADD_STAMINA:
			return AddStaminaItem.new()
		ItemDef.ItemId.LEVEL_UP_ITEM_ON_TOUCH:
			return LevelUpCropOnHit.new()
		ItemDef.ItemId.SPAWN_CROPS_ON_START:
			return CropSpawner.new()
		_:
			return AddStaminaItem.new()

func _physics_process(__):
	var events: Array[ItemEvent] = []
	events.append_array(compute_overlaps(_match_state))
	for item: Item in _match_state.items:
		var new_events := item.activate(_match_state)
		events.append_array(new_events)
	for event in events:
		if event is SpawnEvent:
			# TODO: respect targeting config
			var spawn := event as SpawnEvent
			var new_item: Item = spawn.factory.call()
			_game_board._spawn_item_in_random_cell(new_item, spawn.spawn_chance)
			_match_state.items.append(new_item)
		elif event is GivePointsEvent:
			var give_points_event := event as GivePointsEvent
			_match_state.points += give_points_event.points
			score_changed.emit(_match_state.points)
		elif event is DespawnEvent:
			_match_state.items.erase(event.target)
			event.target.queue_free()
		elif event is FreshOverlapEvent:
			var overlap := event as FreshOverlapEvent
#			print("Overlapped ", overlap.first.name, " ", overlap.first.position, " ", overlap.second.name, " ", overlap.second.position)
	_match_state.last_tick_events = events
	_match_state.tick += 1

func get_score() -> int:
	return _match_state.points

static func find_parent_item(node: Node) -> ItemSystem.Item:
	var current_node := node
	while not current_node is ItemSystem.Item:
		current_node = current_node.get_parent()
		if current_node == null:
			assert(false, "No item parent for node %s" % node.get_path())
	return current_node

class MatchState:
	var tick: int
	var points: int
	var player_ball: PlayerBall
	var items: Array[Item]
	var last_tick_events: Array[ItemEvent]
	
	func _init(tick: int, points: int, player_ball: PlayerBall, items: Array[Item], events: Array[ItemEvent]):
		self.tick = tick
		self.points = points
		self.player_ball = player_ball
		self.items = items
		self.last_tick_events = events

class OverlapState:
	var last_hit_phase: int
	var last_hit_tick: int
	func _init(last_hit_phase, last_hit_tick):
		self.last_hit_phase = last_hit_phase
		self.last_hit_tick = last_hit_tick

var last_overlap_state_per_uid_pair := {}

static func stable_overlap_key(first: Object, second: Object):
	var uids = [first.get_instance_id(), second.get_instance_id()]
	uids.sort()
	return uids

func compute_overlaps(match_state: MatchState) -> Array[ItemEvent]:
	var overlaps: Array[ItemEvent] = []
	var hitbox_to_item = {}
	for item in match_state.items:
		for child in item.get_children():
			if child.name.to_lower() == "hitbox":
				assert(child is Area2D, "Hitboxes should be area2d!")
				hitbox_to_item[child] = item
	var player_hitbox: Area2D = match_state.player_ball.get_node("Hitbox")
	for overlapped in player_hitbox.get_overlapping_areas():
		var overlapped_item: Item = hitbox_to_item.get(overlapped)
		if overlapped_item != null:
			var overlap_key = stable_overlap_key(match_state.player_ball, overlapped_item)
			var last_overlap_state = last_overlap_state_per_uid_pair.get(overlap_key, OverlapState.new(-1000, -1000))
			if (last_overlap_state.last_hit_phase != match_state.player_ball._bounce_count 
					and match_state.tick > last_overlap_state.last_hit_tick + 6):
				overlaps.append(FreshOverlapEvent.new(match_state.player_ball, overlapped_item))
				last_overlap_state_per_uid_pair[overlap_key] = OverlapState.new(
					match_state.player_ball._bounce_count, match_state.tick)
	return overlaps

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

class FreshOverlapEvent extends ItemEvent:
	var first
	var second
	
	func _init(first, second):
		self.first = first
		self.second = second

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

class LevelChangeEvent extends ItemEvent:
	var levels: int
	var target: TargetingConfig
	func _init(levels: int, target: TargetingConfig):
		self.levels = levels
		self.target = target

@abstract
class TargetingConfig extends RefCounted:
	pass

class AnyFreeCell extends TargetingConfig:
	pass

class SpecificItem extends TargetingConfig:
	var target: Item
	func _init(target: Item):
		self.target = target

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
		
