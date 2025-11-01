class_name Roller extends ItemSystem.Item

"""
To start, a bare minimum one which just does the existing functionalities

[X] basic wiring item spawn
[X] move around
[X] Stamina system
[ ] signal for round end (stamina gone)
[ ] spawn the ball in a sane place
[ ] eliminate refs to old player_ball
[ ] generate bounces?
[ ] item destroyed event
[ ]
"""

const ROLLER_SCENE: PackedScene = preload("res://source/item/roller.tscn")

# TODO: belong inside character body?
var _speed: float = 400.0
var _bounce_count: int = 0
var _velocity: Vector2
var _stamina_seconds: float = 10
var _max_stamina := _stamina_seconds
var finished := false

static func instance() -> Roller:
	var roller: Roller = ROLLER_SCENE.instantiate()
	var near_diagonal_launch_angle = 45 + (90 * Utils.RNG.randi_range(0, 4)) + Utils.RNG.randf_range(-20, 20)
	roller._velocity = (Vector2(1, 0) * roller._speed).rotated(deg_to_rad(near_diagonal_launch_angle))
	return roller

func compute_damage_per_hit():
	return 1

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	var collision_result: KinematicCollision2D = $CharacterBody2D.move_and_collide(_velocity * state.delta)
	position = $CharacterBody2D.position
	if collision_result:
		_velocity = _velocity.bounce(collision_result.get_normal())
		_velocity = _velocity.rotated(deg_to_rad(Utils.RNG.randf_range(-5, 5)))
		_bounce_count += 1
		$BounceAudioPlayer.play()
		events.append(ItemSystem.BounceEvent.new(self, ItemSystem.find_parent_item(collision_result.get_collider())))
	if _stamina_seconds <= 0:
		var damping_factor: float = 4 * _velocity.length() * state.delta
		_velocity -= _velocity.normalized() * damping_factor
		if _velocity.length() < 5:
			finished = true
			events.append(ItemSystem.DespawnEvent.new(self))
	_stamina_seconds -= state.delta
	return events
