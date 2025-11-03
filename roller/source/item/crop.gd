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
var level: int = 1

static func instance(mean_level: float = 1.0, level_std: float = 1.0) -> Crop:
	var crop: Crop = CROP_SCENE.instantiate()
	crop.level = clampi(int(round(Utils.RNG.randfn(mean_level, level_std))), 1, MAX_LEVEL)
	return crop

func tags():
	return [Tag.CROP] as Array[String]

func activate(state: MatchState):
	_try_level_up_on_tick(state)
	_level_down_if_hit(state)
	_apply_level_changes(state)

func _try_level_up_on_tick(state: MatchState):
	var expected_seconds_until_growth: float = 4.0 + 8 * log(level)
	var growth_probability_per_second := 1.0 / expected_seconds_until_growth
	if Utils.RNG.randf() < (state.delta * growth_probability_per_second):
		_add_event(ItemSystem.LevelChangeEvent.new(1, ItemSystem.SpecificItem.new(self), self))

func _level_down_if_hit(state: MatchState):
	for hit: ItemSystem.HitEvent in Utils.filter(state.last_tick_events, func (e): return e is ItemSystem.HitEvent):
		# TODO: should not depend on first/second order bruh
		if hit.aggressor.has_all_tags(Tag.ROLLER) and hit.receiver.matches(self):
			_add_event(ItemSystem.LevelChangeEvent.new(-hit.damage, ItemSystem.SpecificItem.new(self), hit.aggressor))

func _apply_level_changes(state: MatchState):
	var total_positive_change: int = 0
	var negative_changes: Array[ItemSystem.LevelChangeEvent] = []
	for level_change: ItemSystem.LevelChangeEvent in Utils.filter(state.last_tick_events, func(e): return e is ItemSystem.LevelChangeEvent):
		if (level_change.target is ItemSystem.SpecificItem and level_change.target.target.matches(self)):
			if level_change.levels >= 0:
				total_positive_change += level_change.levels
				_audio_player.play_crop_level_up()
			else:
				negative_changes.append(level_change)
				_audio_player.play_crop_level_down()
	level = min(MAX_LEVEL, level + total_positive_change)
	for negative_change in negative_changes:
		for i in range(abs(negative_change.levels)):
			_add_event(ItemSystem.GivePointsEvent.new(_compute_point_value()))
			level -= 1
			if level <= 0:
				_add_event(ItemSystem.DespawnEvent.new(self, negative_change.source))
				return

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
