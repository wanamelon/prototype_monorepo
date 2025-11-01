class_name SpawnBouncePillar extends ItemSystem.Item

# TODO: ensure safe to place
func activate(state: MatchState):
	var bounce_pillar_count: int = Utils.filter(state.items, func(i): return i is BouncePillar).size()
	if bounce_pillar_count >= 4:
		return
	for event in state.last_tick_events:
		if event is ItemSystem.DespawnEvent:
			var despawn := event as ItemSystem.DespawnEvent
			if despawn.source is Roller and Utils.RNG.randf() < 1.5:
				if bounce_pillar_count < 4:
					_add_event(ItemSystem.SpawnEvent.new(
						BouncePillar.instance, ItemSystem.AnyFreeCell.new(), 1.0))
					bounce_pillar_count += 1
