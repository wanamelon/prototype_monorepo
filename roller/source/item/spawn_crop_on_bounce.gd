class_name SpawnCropOnBounce extends ItemSystem.Item

func activate(state: MatchState):
	for event in state.last_tick_events:
		if event is BounceEvent and Utils.RNG.randf() < 0.25:
			_add_event(ItemSystem.SpawnEvent.new(func (): return Crop.instance(2, 1), ItemSystem.AnyFreeCell.new()))
