class_name Crop extends ItemSystem.Item

const CROP_SCENE: PackedScene = preload("res://source/item/crop.tscn")
const MAX_LEVEL: int = 20
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

static func instance(mean_level: float = 1.0, level_std: float = 1.0) -> Crop:
	var crop: Crop = CROP_SCENE.instantiate()
	crop.level = clampi(int(round(Utils.RNG.randfn(mean_level, level_std))), 1, MAX_LEVEL)
	return crop

func activate(state: MatchState):
	_try_level_up_on_tick(state)
	_level_down_if_hit(state)
	_apply_level_changes(state)

func _try_level_up_on_tick(state: MatchState):
	var expected_seconds_until_growth: float = 4.0 + 8 * log(level)
	var growth_probability_per_second := 1.0 / expected_seconds_until_growth
	if rng.randf() < (state.delta * growth_probability_per_second):
		_add_event(ItemSystem.LevelChangeEvent.new(1, ItemSystem.SpecificItem.new(self), self))

func _level_down_if_hit(state: MatchState):
	for event in state.last_tick_events:
		if event is ItemSystem.FreshOverlapEvent:
			var overlap := event as ItemSystem.FreshOverlapEvent
			# TODO: should not depend on first/second order bruh
			if overlap.first is Roller and overlap.second == self:
				var roller := overlap.first as Roller
				_add_event(ItemSystem.LevelChangeEvent.new(
					-roller.compute_damage_per_hit(), ItemSystem.SpecificItem.new(self), overlap.first))

func _apply_level_changes(state: MatchState):
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
		_add_event(ItemSystem.GivePointsEvent.new(_compute_point_value()))
	var net_level_change := total_positive_level_change + total_negative_level_change
	if net_level_change > 0:
		level = min(MAX_LEVEL, level + net_level_change)
	else:
		for i in range(abs(net_level_change)):
			_add_event(ItemSystem.GivePointsEvent.new(_compute_point_value()))
			level -= 1
			if level <= 0:
				_add_event(ItemSystem.DespawnEvent.new(self, _find_largest_damage_source(state)))
				break

func _find_largest_damage_source(state: MatchState) -> ItemRef:
	var damage_per_source := {}
	var max_damage = 0
	var max_item = null
	for level_change: LevelChangeEvent in Utils.filter(state.last_tick_events, func(e): return e is LevelChangeEvent):
		if (level_change.target is ItemSystem.SpecificItem and level_change.target.target == self): # TODO: itemref!
			if level_change.levels < 0:
				var source_key := level_change.source.instance_id
				damage_per_source[source_key] = damage_per_source.get(source_key, 0) + abs(level_change.levels)
				if damage_per_source[source_key] > max_damage:
					max_damage = damage_per_source[source_key]
					max_item = level_change.source
	return max_item

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
