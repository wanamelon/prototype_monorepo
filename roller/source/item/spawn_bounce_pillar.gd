class_name SpawnBouncePillar extends ItemSystem.Item

# TODO: ensure safe to place
func activate(state: MatchState):
	var bounce_pillar_count: int = Utils.filter(state.items, func(i): return i is BouncePillar).size()
	if bounce_pillar_count >= 4:
		return
	for despawn: DespawnEvent in Utils.filter(state.last_tick_events, func(i): return i is DespawnEvent):
		if despawn.source.has_all_tags(Tag.ROLLER) and Utils.RNG.randf() < 1.5:
			if bounce_pillar_count < 4:
				_add_event(ItemSystem.SpawnEvent.new(
					BouncePillar.instance, ItemSystem.AnyFreeCell.new()))
				bounce_pillar_count += 1
