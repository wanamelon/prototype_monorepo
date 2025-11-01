class_name SpeedBuffOnDestroy extends ItemSystem.Item

func activate(state: MatchState):
	for event in state.last_tick_events:
		if event is ItemSystem.DespawnEvent:
			var despawn := event as ItemSystem.DespawnEvent
			if despawn.source is Roller:
				_add_event(ItemSystem.AddStatusEffect.new(
					ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SPEED_BUFF, 100, 2.5), despawn.source))
