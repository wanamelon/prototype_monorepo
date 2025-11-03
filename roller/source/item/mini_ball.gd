class_name MiniBall extends ItemSystem.Item

var _velocity: Vector2 = Vector2(0, 200).rotated(deg_to_rad(Utils.RNG.randf_range(0, 360)))
var _bounce_count: int = 0
var _life_sec: float = 5

static func instance() -> MiniBall:
	return load("res://source/item/mini_ball.tscn").instantiate()

func _ready():
	$CharacterBody2D.position = position

func activate(state: MatchState):
	var collision_result: KinematicCollision2D = $CharacterBody2D.move_and_collide(_velocity * state.delta)
	position = $CharacterBody2D.position
	if collision_result:
		_velocity = _velocity.bounce(collision_result.get_normal())
		_bounce_count += 1
		_audio_player.play_bounce()
		_add_event(ItemSystem.BounceEvent.new(ItemSystem.find_parent_item(collision_result.get_collider())))
	_life_sec -= state.delta
	if _life_sec <= 0:
		_add_event(ItemSystem.DespawnEvent.new(self, self))

class Spawner extends ItemSystem.Item:
	var _points_given_counter: int = 0
	func activate(state: MatchState):
		for give_points: ItemSystem.GivePointsEvent in Utils.filter(state.last_tick_events, func(e): return e is ItemSystem.GivePointsEvent):
			_points_given_counter += 1
			if _points_given_counter % 20 == 0:
				for roller: ItemSystem.Item in Utils.filter(state.items, func(i): return i.has_all_tags(Tag.ROLLER)):
					_audio_player.play_spawn_mini_ball()
					_add_event(ItemSystem.SpawnEvent.new(
						MiniBall.instance, ItemSystem.SpecificPosition.new(roller.global_position)))
					break
