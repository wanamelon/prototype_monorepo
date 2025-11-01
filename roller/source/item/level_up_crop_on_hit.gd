class_name LevelUpCropOnHit extends ItemSystem.Item

var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	for event in state.last_tick_events:
		if event is ItemSystem.FreshOverlapEvent:
			var overlap := event as ItemSystem.FreshOverlapEvent
			# TODO: should not depend on first/second order bruh
			if overlap.first is Roller and overlap.second is Crop:
				if _random.randf() < 0.2:
					events.append(ItemSystem.LevelChangeEvent.new(1, ItemSystem.SpecificItem.new(overlap.second)))
	return events
