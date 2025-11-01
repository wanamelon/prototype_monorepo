class_name Roller extends ItemSystem.Item

"""
To start, a bare minimum one which just does the existing functionalities

[X] basic wiring item spawn
[X] move around
[X] Stamina system
[X] fix progress bar gone?
[X] signal for round end (stamina gone)
[X] eliminate refs to old player_ball
[X] generate bounces events
[X] spawn the ball in a sane place
[X] decide how to wire item destroyed event
[X] speed buff on kill
[ ] add grow on kill
[ ] bouncing mode sprite
[ ] spawn bounce pillar
[ ] more damage item?
"""

const ROLLER_SCENE: PackedScene = preload("res://source/item/roller.tscn")

# TODO: belong inside character body?
var _speed: float = 400.0
var _bounce_count: int = 0
var _velocity: Vector2
var _stamina_seconds: float = 10
var _max_stamina := _stamina_seconds
var _speed_buff_durations: Array[float] = []
var finished := false

static func instance() -> Roller:
	var roller: Roller = ROLLER_SCENE.instantiate()
	var near_diagonal_launch_angle = 45 + (90 * Utils.RNG.randi_range(0, 4)) + Utils.RNG.randf_range(-20, 20)
	roller._velocity = (Vector2(1, 0) * roller._speed).rotated(deg_to_rad(near_diagonal_launch_angle))
	return roller

func _ready():
	$CharacterBody2D.position = position

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
			events.append(ItemSystem.DespawnEvent.new(self, self))
	else:
		_apply_speed_buffs(state.delta)
	_stamina_seconds -= state.delta
	_add_buffs_on_destroy(state.last_tick_events)
	return events

func _add_buffs_on_destroy(events: Array[ItemSystem.ItemEvent]):
	for event in events:
		if event is ItemSystem.DespawnEvent:
			var despawn := event as ItemSystem.DespawnEvent
			if despawn.source is Roller:
				_speed_buff_durations.append(2.5)

func _apply_speed_buffs(delta):
	var speed_with_buffs := _speed
	var new_speed_buff_durations: Array[float] = []
	for duration in _speed_buff_durations:
		speed_with_buffs += 100 * min(1, duration)
		speed_with_buffs = min(speed_with_buffs, 10_000)
		var decremented = duration - delta
		if decremented > 0:
			new_speed_buff_durations.append(decremented)
	_speed_buff_durations = new_speed_buff_durations
	_velocity = _velocity.normalized() * speed_with_buffs

func _process(delta):
	$TextureProgressBar.value = 100.0 * _stamina_seconds / float(_max_stamina)
	# TODO: Wire this somehow?
	#$BouncingModeSprite.visible = should_bounce_off_everything()
