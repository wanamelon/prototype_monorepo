class_name Crop extends ItemSystem.Item

const CROP_SCENE: PackedScene = preload("res://source/item/crop.tscn")
const THOUSANDS_LEVEL_SUFFIXES = ["", "K", "M"]
const DIGITS_PER_THOUSAND_LEVEL: int = 3
const LEVEL_COLORS := [
	Color.BLACK, 
	Color.GHOST_WHITE, # Level 1
	Color.GREEN,
	Color.MEDIUM_TURQUOISE, 
	Color.MIDNIGHT_BLUE,
	Color.GOLDENROD,
	Color.ORANGE_RED,
	Color.MEDIUM_VIOLET_RED,
	Color.DARK_VIOLET
]
var rng := RandomNumberGenerator.new()
var level: int = 1

static func instance() -> Crop:
	return CROP_SCENE.instantiate()

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	_try_level_up_on_tick(state, events)
	_level_down_if_hit(state, events)
	_apply_level_changes(state, events)
	return events

func _try_level_up_on_tick(state: MatchState, o_events: Array[ItemEvent]):
	var expected_seconds_until_growth: float = 4.0 + 8 * log(level)
	var growth_probability_per_second := 1.0 / expected_seconds_until_growth
	if rng.randf() < (state.delta * growth_probability_per_second):
		o_events.append(ItemSystem.LevelChangeEvent.new(1, ItemSystem.SpecificItem.new(self)))

func _level_down_if_hit(state: MatchState, o_events: Array[ItemEvent]):
	for event in state.last_tick_events:
		if event is ItemSystem.FreshOverlapEvent:
			var overlap := event as ItemSystem.FreshOverlapEvent
			# TODO: should not depend on first/second order bruh
			if overlap.first is PlayerBall and overlap.second == self:
				var player := overlap.first as PlayerBall
				o_events.append(ItemSystem.LevelChangeEvent.new(
					-player.compute_damage_per_hit(), ItemSystem.SpecificItem.new(self)))

func _apply_level_changes(state: MatchState, o_events: Array[ItemEvent]):
	var total_positive_level_change: int = 0
	var total_negative_level_change: int = 0
	for event in state.last_tick_events:
		if event is ItemSystem.LevelChangeEvent:
			var level_change := event as ItemSystem.LevelChangeEvent
			if (level_change.target is ItemSystem.SpecificItem and level_change.target.target == self):
				if level_change.levels >= 0:
					total_positive_level_change += level_change.levels
				else:
					total_negative_level_change += level_change.levels
	if total_positive_level_change > 0:
		$LevelUpAudioPlayer.play()
	if total_negative_level_change < 0:
		$LevelDownAudioPlayer.play()
	var level_changes_canceled_out: int = min(abs(total_positive_level_change), abs(total_negative_level_change))
	for i in range(level_changes_canceled_out):
		o_events.append(ItemSystem.GivePointsEvent.new(_compute_point_value()))
	var net_level_change := total_positive_level_change + total_negative_level_change
	if net_level_change > 0:
		level = min(20, level + net_level_change)
	else:
		for i in range(abs(net_level_change)):
			o_events.append(ItemSystem.GivePointsEvent.new(_compute_point_value()))
			level -= 1
			if level <= 0:
				state.player_ball.on_tile_destroyed()
				o_events.append(ItemSystem.DespawnEvent.new(self))
				break

func _compute_point_value():
	return 2 ** (level - 1)

func _process(delta):
	var points = 2 ** (level - 1)
	var thousands_level: int = 0
	var normalized: int = points
	while normalized > 1000:
		normalized /= 1000
		thousands_level += 1
	var num_digits = str(points).length()
	$LevelLabel.text = str(normalized) + THOUSANDS_LEVEL_SUFFIXES[thousands_level]
	$LevelLabel.set("theme_override_colors/font_color", LEVEL_COLORS[min(len(LEVEL_COLORS)- 1, num_digits)])

#func toggle_bounce(should: bool):
	#if should:
		#var overlap_ball_query = PhysicsShapeQueryParameters2D.new()
		#overlap_ball_query.shape = $Hitbox/CollisionShape2D.shape
		#overlap_ball_query.transform = global_transform
		#overlap_ball_query.collision_mask = 1
		#overlap_ball_query.collide_with_areas = false
		#var overlaps = get_world_2d().direct_space_state.intersect_shape(overlap_ball_query)
		#if overlaps.is_empty():
			#$StaticBody2D/CollisionShape2D.disabled = false
	#else:
		#$StaticBody2D/CollisionShape2D.disabled = true

#func try_level_up_from_snail_trail(chance: float):
	#if rng.randf() < chance:
		#_level_up()
