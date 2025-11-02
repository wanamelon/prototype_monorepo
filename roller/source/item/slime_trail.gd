class_name SlimeTrail extends ItemSystem.Item

var _level_up_chance_per_second: float = 0.25
var _duration_sec: float = 0.7

static func instance() -> SlimeTrail:
	return load("res://source/item/slime_trail.tscn").instantiate()

func activate(state: MatchState):
	if _duration_sec > 0:
		for area in $SpecialHitbox.get_overlapping_areas():
			var overlapped_item := ItemSystem.find_parent_item(area)
			if overlapped_item is Crop and Utils.RNG.randf() < state.delta * _level_up_chance_per_second:
				_add_event(ItemSystem.LevelChangeEvent.new(1, ItemSystem.SpecificItem.new(overlapped_item), self))
		_duration_sec -= state.delta
		$Sprite2D.modulate.a = min(0.5, _duration_sec)
		if _duration_sec <= 0:
			_add_event(ItemSystem.DespawnEvent.new(self, self))
