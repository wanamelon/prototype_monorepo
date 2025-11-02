class_name ItemSystem extends Node2D

signal score_changed(new_score: int)
signal match_finished()

const TICK_DELTA: float = 1.0 / 60.0

var _audio_player: ThrottlingAudioPlayer
var _game_board: GameBoard
var _match_state: MatchState
var _physics_calculator: StatefulPhysicsCalculator

func _init(item_defs: Array[ItemDef], game_board: GameBoard, points: int):
	_game_board = game_board
	_physics_calculator = StatefulPhysicsCalculator.new()
	add_child(_physics_calculator)
	_audio_player = ThrottlingAudioPlayer.instance()
	add_child(_audio_player)
	var items: Array[Item] = []
	for item_def in item_defs:
		var item := _item_for_id(item_def.item_id)
		item._inject(_physics_calculator, self, _audio_player)
		add_child(item)
		items.append(item)
	_match_state = MatchState.new(0, points, items, [] as Array[ItemEvent])

func _item_for_id(item_id: ItemDef.ItemId) -> Item:
	match item_id:
		ItemDef.ItemId.ADD_STAMINA:
			return AddStamina.new()
		ItemDef.ItemId.LEVEL_UP_ITEM_ON_TOUCH:
			return LevelUpCropOnHit.new()
		ItemDef.ItemId.SPAWN_CROPS_ON_START:
			return CropSpawner.new()
		ItemDef.ItemId.BOUNCE_OFF_EVERYTHING:
			return BounceOffEverything.new()
		ItemDef.ItemId.SPEED_BUFF_ON_DESTROY:
			return SpeedBuffOnDestroy.new()
		ItemDef.ItemId.INCREASE_SIZE:
			return SizeBuffOnDestroy.new()
		ItemDef.ItemId.SPAWN_RANDOM_TILE_OBJECT:
			return SpawnCropOnBounce.new()
		ItemDef.ItemId.SPAWN_BOUNCE_PILLAR:
			return SpawnBouncePillar.new()
		ItemDef.ItemId.MORE_DAMAGE:
			return MoreDamage.new()
		ItemDef.ItemId.SNAIL_TRAIL_OF_LEVEL_UP_SLIME:
			return LeaveSlimeTrail.new()
		ItemDef.ItemId.ROLLER:
			var roller := Roller.instance()
			roller.position = Vector2(1920, 1080) / 2.0
			return roller
		_:
			assert(false, "Unknown item id %s" % item_id)
			return null

func _physics_process(__):
	var events: Array[ItemEvent] = []
	events.append_array(compute_overlaps(_match_state))
	for item: Item in _match_state.items:
		item.activate(_match_state)
		events.append_array(item.flush_events())
	_advance_status_effect_timers()
	_apply_events(events)
	_check_end_condition()
	_match_state.last_tick_events = events
	_match_state.tick += 1

func _check_end_condition():
	var active_roller_count: int = 0
	for item: Item in _match_state.items:
		if item is Roller and not (item as Roller).finished:
			active_roller_count += 1
	if active_roller_count <= 0:
		match_finished.emit()

func _advance_status_effect_timers():
	for item: Item in _match_state.items:
		var active_effects: Array[StatusEffect] = []
		for effect in item.status_effects:
			effect.duration_sec = effect.duration_sec - _match_state.delta
			if effect.duration_sec > 0:
				active_effects.append(effect)
		item.status_effects = active_effects

func _apply_events(events: Array[ItemEvent]):
	for event in events:
		if event is SpawnEvent:
			# TODO: respect targeting config
			var spawn := event as SpawnEvent
			var new_item: Item = spawn.factory.call()
			var was_placed: bool = false
			if spawn.targeting_config is AnyFreeCell:
				was_placed = _game_board._spawn_item_in_random_cell(new_item, spawn.spawn_chance)
			elif spawn.targeting_config is SpecificPosition:
				new_item.position = (spawn.targeting_config as SpecificPosition).position
				add_child(new_item)
				was_placed = true
			if was_placed:
				new_item._inject(_physics_calculator, self, _audio_player)
				_match_state.items.append(new_item)
		elif event is DespawnEvent:
			var item_to_remove: Item = Utils.filter(_match_state.items, event.target.matches)[0]
			_match_state.items.erase(item_to_remove)
			item_to_remove.queue_free()
		elif event is GivePointsEvent:
			var give_points_event := event as GivePointsEvent
			_match_state.points += give_points_event.points
			score_changed.emit(_match_state.points)
			_audio_player.play_gain_points(give_points_event.points)
		elif event is AddStatusEffect:
			var add_effect := event as AddStatusEffect
			var item_to_apply_to := _item_for_ref(add_effect.target)
			if item_to_apply_to != null:
				item_to_apply_to.status_effects.append(add_effect.effect)

func _item_for_ref(ref: ItemRef) -> Item:
	var matching_items = Utils.filter(_match_state.items, ref.matches)
	if matching_items.size() == 1:
		return matching_items[0]
	else:
		return null

func get_score() -> int:
	return _match_state.points

static func find_parent_item(node: Node) -> ItemSystem.Item:
	var current_node := node
	while not current_node is ItemSystem.Item:
		current_node = current_node.get_parent()
		if current_node == null:
			return null
	return current_node

class MatchState:
	var tick: int
	var points: int
	var items: Array[Item]
	var last_tick_events: Array[ItemEvent]
	var delta: float = 1.0 / 60.0
	
	func _init(tick: int, points: int, items: Array[Item], events: Array[ItemEvent]):
		self.tick = tick
		self.points = points
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
#	var rollers = Utils.filter(match_state.items, func (i): i is Roller)
	for item in match_state.items:
		if item is Roller:
			var roller := item as Roller 
			var player_hitbox: Area2D = roller.get_node("Hitbox")
			for overlapped in player_hitbox.get_overlapping_areas():
				var overlapped_item: Item = hitbox_to_item.get(overlapped)
				if overlapped_item != null:
					var overlap_key = stable_overlap_key(roller, overlapped_item)
					var last_overlap_state = last_overlap_state_per_uid_pair.get(overlap_key, OverlapState.new(-1000, -1000))
					if (last_overlap_state.last_hit_phase != roller._bounce_count 
							and match_state.tick > last_overlap_state.last_hit_tick + 10):
						overlaps.append(FreshOverlapEvent.new(roller, overlapped_item))
						last_overlap_state_per_uid_pair[overlap_key] = OverlapState.new(
							roller._bounce_count, match_state.tick)
	return overlaps

func is_safe_to_place(shape: Shape2D, global_pos: Vector2, excluded=[]):
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, global_pos) 
	query.collision_mask = 1
	query.collide_with_areas = false
	query.exclude = excluded
	var overlaps = get_world_2d().direct_space_state.intersect_shape(query)
	return overlaps.is_empty()

@abstract
class Item extends Node2D:
	signal destroyed()
	
	var _physics_calculator: StatefulPhysicsCalculator
	var _item_root: ItemSystem
	var _audio_player: ThrottlingAudioPlayer
	var status_effects: Array[StatusEffect] = []
	var _new_events: Array[ItemEvent] = []
	var tags: Array[String] = []
	
	func _inject(physics_calculator: StatefulPhysicsCalculator, item_root: Node2D, audio_player: ThrottlingAudioPlayer):
		_physics_calculator = physics_calculator
		_item_root = item_root
		_audio_player = audio_player
	
	# Business logic spawn setup: What bodies/display nodes to register...
	func spawn():
		pass
	
	# Generate physics events (collisions + overlaps)
	func advance_physics(tick_delta: float) -> Array[ItemEvent]:
		return []
	
	# The core of the logic! Evaluate triggers and perform actions
	@abstract func activate(state: MatchState) -> void
	
	func _add_event(event: ItemEvent) -> void:
		_new_events.append(event)
	
	func flush_events() -> Array[ItemEvent]:
		var copy = _new_events.duplicate()
		_new_events.clear()
		return copy

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

enum StatusEffectId {
	SPEED_BUFF,
	SIZE_BUFF,
	STAMINA_BUFF,
	DAMAGE_BUFF
}

class StatusEffect extends RefCounted:
	var id: StatusEffectId
	var intensity: float
	var duration_sec: float
	func _init(id: StatusEffectId, intensity: float, duration_sec: float):
		self.id = id
		self.intensity = intensity
		self.duration_sec = duration_sec

class AddStatusEffect extends ItemEvent:
	var effect: StatusEffect
	var target: ItemRef
	
	func _init(effect: StatusEffect, target):
		self.effect = effect
		self.target = ItemRef.from(target)

#class ItemDestroyed extends ItemEvent:
#	var destroyer: Item
#	var victim: Item
#	
#	func _init(destroyer: Item, victim: Item):
#		self.destroyer = destroyer
#		self.victim = victim

class BounceEvent extends ItemEvent:
	var roller: Roller
	var collided_item: ItemRef
	
	func _init(roller: Roller, collided_item: Item):
		self.roller = roller
		self.collided_item = ItemRef.from(collided_item)

class FreshOverlapEvent extends ItemEvent:
	var first: ItemRef
	var second: ItemRef
	var damage: int = 1
	
	func _init(first, second):
		self.first = ItemRef.from(first)
		self.second = ItemRef.from(second)
		if first is Roller:
			self.damage = first.compute_damage_per_hit()

class GivePointsEvent extends ItemEvent:
	var points: int
	func _init(points: int):
		self.points = points

class SpawnEvent extends ItemEvent:
	# Later: Make this more declarative?
	var factory: Callable
	var targeting_config: LocationTarget
	var spawn_chance: float
	
	func _init(factory: Callable, targeting_config: LocationTarget, spawn_chance: float):
		self.factory = factory
		self.targeting_config = targeting_config
		self.spawn_chance = spawn_chance

class DespawnEvent extends ItemEvent:
	var target: ItemRef
	var source: ItemRef
	func _init(target, source):
		self.target = ItemRef.from(target)
		self.source = ItemRef.from(source)

class LevelChangeEvent extends ItemEvent:
	var levels: int
	var target: ItemTarget
	var source: ItemRef
	func _init(levels: int, target: ItemTarget, source):
		self.levels = levels
		self.target = target
		self.source = ItemRef.from(source)

class ItemRef extends RefCounted:
	static var NONE: ItemRef = ItemRef.new(-1, [])
	
	var instance_id: int
	var tags: Array[String]
	
	func _init(instance_id: int, tags: Array[String]):
		self.instance_id = instance_id
		self.tags = tags
	
	func matches(item: Item) -> bool:
		return item.get_instance_id() == instance_id
	
	func has_all_tags(...query_tags: Array):
		var query_tags_in_self = Utils.filter(query_tags, func (t): return t in tags)
		return query_tags_in_self.size() == query_tags.size()
	
	func has_any_tags(...query_tags: Array):
		var query_tags_in_self = Utils.filter(query_tags, func (t): return t in tags)
		return not query_tags_in_self.is_empty()
	
	static func from(item) -> ItemRef:
		if item is Item:
			return ItemRef.new(item.get_instance_id(), item.tags.duplicate())
		elif item is ItemRef:
			return item
		elif item == null:
			return ItemRef.NONE
		else:
			assert(false, "Input item %s must be Item, ItemRef, or null!" % item)
			return ItemRef.NONE

@abstract
class LocationTarget extends RefCounted:
	pass

class AnyFreeCell extends LocationTarget:
	pass

class SpecificPosition extends LocationTarget:
	var position: Vector2
	func _init(position: Vector2):
		self.position = position

@abstract
class ItemTarget extends RefCounted:
	pass

class SpecificItem extends ItemTarget:
	var target: ItemRef
	func _init(target):
		self.target = ItemRef.from(target)

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
		
