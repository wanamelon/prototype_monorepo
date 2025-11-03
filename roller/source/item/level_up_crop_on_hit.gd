class_name LevelUpCropOnHit extends ItemSystem.Item

var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	for hit: ItemSystem.HitEvent in Utils.filter(state.last_tick_events, func (e): return e is ItemSystem.HitEvent):
		# TODO: should not depend on first/second order bruh
		if hit.aggressor.has_all_tags(Tag.ROLLER) and hit.receiver.has_all_tags(Tag.CROP):
			if _random.randf() < 0.1:
				_add_event(ItemSystem.LevelChangeEvent.new(1, ItemSystem.SpecificItem.new(hit.receiver), hit.aggressor))
